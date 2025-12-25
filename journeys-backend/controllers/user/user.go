package user

import (
	"be_journeys/config"
	"be_journeys/controllers/helper"
	"be_journeys/models"
	"context"
	"encoding/base64"
	"math/rand"
	"net/http"
	"strconv"

	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"
)

func GetUser(c *gin.Context) {
	userID := c.GetUint("user_id")

	var user models.User
	if err := config.DB.First(&user, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": user})
}

func UpdateUser(c *gin.Context) {
	userID := c.GetUint("user_id")
	firebaseUID := c.GetString("firebase_uid")

	var body map[string]interface{}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format JSON salah"})
		return
	}

	var user models.User
	if err := config.DB.First(&user, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	if v, ok := body["username"].(string); ok && v != "" {
		user.Username = v
	}

	if newEmail, ok := body["email"].(string); ok && newEmail != "" {

		client, err := config.FirebaseApp.Auth(context.Background())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Firebase error"})
			return
		}

		params := (&auth.UserToUpdate{}).Email(newEmail)

		_, err = client.UpdateUser(context.Background(), firebaseUID, params)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "Gagal update email di Firebase",
				"details": err.Error(),
			})
			return
		}

		user.Email = newEmail
	}

	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User berhasil diupdate",
		"data":    user,
	})
}

func GetUserXPSummary(c *gin.Context) {
	userID := c.GetUint("user_id")

	var totalXP int64
	if err := config.DB.
		Model(&models.UserXP{}).
		Where("user_id = ?", userID).
		Select("COALESCE(SUM(xp_value), 0)").
		Scan(&totalXP).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung XP"})
		return
	}

	rank := helper.CalculateRank(int(totalXP))

	config.DB.Model(&models.Profile{}).Where("user_id = ?", userID).Update("rank", rank)

	c.JSON(http.StatusOK, gin.H{
		"xp":   totalXP,
		"rank": rank,
	})
}

func GetUserXPHistory(c *gin.Context) {
	userID := c.GetUint("user_id")

	var xpHistory []models.UserXP
	if err := config.DB.
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&xpHistory).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil histori XP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": xpHistory})
}

func GetMostActiveTravellers(c *gin.Context) {
	type TravellerInfo struct {
		UserID   uint   `json:"user_id"`
		Username string `json:"username"`
		Role     string `json:"role"`
		Rank     string `json:"rank"`
		XP       int64  `json:"xp"`
		Photo    string `json:"photo"` // base64 image
	}

	var results []TravellerInfo

	rows, err := config.DB.Raw(`
		SELECT u.user_id, u.username, u.role, p.rank,
			COALESCE(SUM(x.xp_value), 0) as xp,
			p.photo
		FROM users u
		LEFT JOIN profiles p ON u.user_id = p.user_id
		LEFT JOIN user_xps x ON u.user_id = x.user_id
		GROUP BY u.user_id, u.username, u.role, p.rank, p.photo
		ORDER BY xp DESC
		LIMIT 10
	`).Rows()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data user"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var t TravellerInfo
		var photoBytes []byte

		if err := rows.Scan(&t.UserID, &t.Username, &t.Role, &t.Rank, &t.XP, &photoBytes); err == nil {
			if len(photoBytes) > 0 {
				t.Photo = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(photoBytes)
			}
			results = append(results, t)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"data": results,
	})
}

func GetCategoryTravellers(c *gin.Context) {
	var categories []models.Category
	if err := config.DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil kategori"})
		return
	}

	result := []map[string]interface{}{}
	usedUserIDs := map[uint]bool{} // mencegah duplikat user di kategori lain

	for _, cat := range categories {
		var users []models.User

		err := config.DB.
			Joins("JOIN plans ON plans.user_id = users.user_id").
			Joins("JOIN plan_categories pc ON pc.plan_id = plans.plan_id").
			Where("pc.category_id = ?", cat.CategoryID).
			Preload("Profile").
			Preload("Plans", "plan_id IN (SELECT plan_id FROM plan_categories WHERE category_id = ?)", cat.CategoryID).
			Preload("Plans.Categories").
			Find(&users).Error

		if err != nil || len(users) == 0 {
			continue
		}

		// filter user yang belum pernah dipakai
		filteredUsers := []models.User{}
		for _, u := range users {
			if !usedUserIDs[u.UserID] {
				filteredUsers = append(filteredUsers, u)
			}
		}

		if len(filteredUsers) == 0 {
			continue
		}

		selected := filteredUsers[rand.Intn(len(filteredUsers))]
		usedUserIDs[selected.UserID] = true // tandai user sudah digunakan

		var photoBase64 string
		if len(selected.Profile.Photo) > 0 {
			photoBase64 = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(selected.Profile.Photo)
		}

		plans := []map[string]interface{}{}
		for _, p := range selected.Plans {
			banner := ""
			if len(p.Banner) > 0 {
				banner = base64.StdEncoding.EncodeToString(p.Banner)
			}
			plans = append(plans, map[string]interface{}{
				"plan_id":     p.PlanID,
				"title":       p.Title,
				"description": p.Description,
				"tags":        p.Tags,
				"banner":      banner,
				"categories":  p.Categories,
				"created_at":  p.CreatedAt,
			})
		}

		result = append(result, map[string]interface{}{
			"category_id": cat.CategoryID,
			"category":    cat.Name,
			"image":       base64.StdEncoding.EncodeToString(cat.Image),
			"user": map[string]interface{}{
				"user_id":  selected.UserID,
				"username": selected.Username,
				"role":     selected.Role,
				"rank":     selected.Profile.Rank,
				"photo":    photoBase64,
				"status":   selected.Profile.Status,
				"plans":    plans,
			},
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": result})
}

func GetUserProfile(c *gin.Context) {
	userID, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var user models.User
	if err := config.DB.Preload("Profile").
		First(&user, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	var totalReviews int64
	config.DB.Model(&models.PlaceReview{}).
		Where("user_id = ?", userID).
		Count(&totalReviews)

	var totalRoutes int64
	config.DB.Model(&models.Plan{}).
		Where("user_id = ?", userID).
		Count(&totalRoutes)

	var plans []models.Plan
	config.DB.Preload("Categories").
		Where("user_id = ?", userID).
		Find(&plans)

	planResp := []map[string]interface{}{}
	for _, p := range plans {
		bannerBase64 := ""
		if len(p.Banner) > 0 {
			bannerBase64 = base64.StdEncoding.EncodeToString(p.Banner)
		}
		planResp = append(planResp, map[string]interface{}{
			"plan_id":     p.PlanID,
			"title":       p.Title,
			"description": p.Description,
			"tags":        p.Tags,
			"banner":      bannerBase64,
			"categories":  p.Categories,
			"created_at":  p.CreatedAt,
			"status":      p.Status,
		})
	}

	photoBase64 := ""
	if len(user.Profile.Photo) > 0 {
		photoBase64 = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(user.Profile.Photo)
	}

	resp := map[string]interface{}{
		"user_id":   user.UserID,
		"username":  user.Username,
		"email":     user.Email,
		"role":      user.Role,
		"photo":     photoBase64,
		"rank":      user.Profile.Rank,
		"followers": user.Profile.Followers,
		"following": user.Profile.Following,
		"stats": map[string]interface{}{
			"reviews": totalReviews,
			"routes":  totalRoutes,
		},
		"plans": planResp,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

func GetAllTravellerProfiles(c *gin.Context) {
	var users []models.User

	err := config.DB.
		Preload("Profile").
		Where("role = ?", "traveller").
		Find(&users).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pengguna"})
		return
	}

	var result []map[string]interface{}
	for _, u := range users {
		photoBase64 := ""
		if len(u.Profile.Photo) > 0 {
			photoBase64 = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(u.Profile.Photo)
		}

		result = append(result, map[string]interface{}{
			"user_id":  u.UserID,
			"username": u.Username,
			"rank":     u.Profile.Rank,
			"photo":    photoBase64,
			"role":     u.Role,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": result})
}
