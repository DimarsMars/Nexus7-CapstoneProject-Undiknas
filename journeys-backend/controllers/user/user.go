package user

import (
	"be_journeys/config"
	"be_journeys/controllers/helper"
	"be_journeys/models"
	"context"
	"encoding/base64"
	"net/http"

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
