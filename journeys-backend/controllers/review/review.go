package review

import (
	"be_journeys/config"
	"be_journeys/controllers/helper"
	"be_journeys/models"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateTripReview(c *gin.Context) {
	userID := c.GetUint("user_id")

	var input struct {
		PlanID  uint   `json:"plan_id" binding:"required"`
		Rating  int    `json:"rating" binding:"required"`
		Comment string `json:"comment"`
	}

	// Validasi input JSON
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format input tidak valid"})
		return
	}

	// Cari plan
	var plan models.Plan
	if err := config.DB.First(&plan, input.PlanID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	// Cegah review plan milik sendiri
	if plan.UserID == userID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kamu tidak bisa mereview plan milik sendiri"})
		return
	}

	// Cegah duplikat review (user sudah pernah review plan ini)
	var existing models.TripReview
	if err := config.DB.
		Where("user_id = ? AND plan_id = ?", userID, input.PlanID).
		First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kamu sudah mereview plan ini"})
		return
	}

	// Buat review
	review := models.TripReview{
		UserID:    userID,
		PlanID:    input.PlanID,
		Rating:    input.Rating,
		Comment:   input.Comment,
		CreatedAt: time.Now(),
	}

	if err := config.DB.Create(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan review"})
		return
	}

	xp := models.UserXP{
		UserID:      userID,
		XPValue:     10,
		Description: "Reviewed a trip",
	}
	config.DB.Create(&xp)

	var totalXP int64
	config.DB.Model(&models.UserXP{}).
		Where("user_id = ?", userID).
		Select("COALESCE(SUM(xp_value), 0)").
		Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))
	config.DB.Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

	c.JSON(http.StatusOK, gin.H{
		"message": "Review berhasil ditambahkan",
		"data": map[string]interface{}{
			"review_id":  review.ReviewID,
			"user_id":    review.UserID,
			"plan_id":    review.PlanID,
			"rating":     review.Rating,
			"comment":    review.Comment,
			"created_at": review.CreatedAt,
		},
	})
}

func DeleteMyTripReview(c *gin.Context) {
	userID := c.GetUint("user_id")
	reviewIDParam := c.Param("review_id")

	var reviewID uint
	if _, err := fmt.Sscanf(reviewIDParam, "%d", &reviewID); err != nil || reviewID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "review_id tidak valid"})
		return
	}

	var review models.TripReview
	if err := config.DB.First(&review, "review_id = ?", reviewID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Review tidak ditemukan"})
		return
	}

	if review.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Kamu tidak memiliki izin untuk menghapus review ini"})
		return
	}

	if err := config.DB.Delete(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus review"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Review berhasil dihapus"})
}

func CreatePlaceReview(c *gin.Context) {
	userID := c.GetUint("user_id")

	routeID := helper.StringToUint(c.PostForm("route_id"))
	rating := helper.StringToInt(c.PostForm("rating"))
	comment := c.PostForm("comment")

	if rating < 1 || rating > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Rating harus 1-5"})
		return
	}

	review := models.PlaceReview{
		UserID:    userID,
		RouteID:   routeID,
		Rating:    rating,
		Comment:   comment,
		CreatedAt: time.Now(),
	}

	if err := config.DB.Create(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan review"})
		return
	}

	form, _ := c.MultipartForm()
	files := form.File["image"]

	for _, file := range files {
		src, _ := file.Open()
		bytes, _ := io.ReadAll(src)
		src.Close()

		config.DB.Create(&models.PlaceReviewImage{
			ReviewID: review.ReviewID,
			Image:    bytes,
		})
	}

	c.JSON(http.StatusOK, gin.H{"message": "Place review berhasil ditambahkan"})
}

func GetPlaceReviews(c *gin.Context) {
	routeID := c.Param("route_id")

	var reviews []models.PlaceReview
	config.DB.
		Preload("Image").
		Where("route_id = ?", routeID).
		Order("created_at DESC").
		Find(&reviews)

	response := []map[string]interface{}{}

	for _, r := range reviews {
		image := []string{}
		for _, img := range r.Image {
			image = append(image, base64.StdEncoding.EncodeToString(img.Image))
		}

		response = append(response, map[string]interface{}{
			"review_id":  r.ReviewID,
			"user_id":    r.UserID,
			"route_id":   r.RouteID,
			"rating":     r.Rating,
			"comment":    r.Comment,
			"image":      image,
			"created_at": r.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetTripReviewsByUser(c *gin.Context) {
	userID := c.GetUint("user_id")

	type Result struct {
		ReviewID    uint
		UserID      uint
		Rating      int
		Comment     string
		CreatedAt   time.Time
		PlanID      uint
		Title       string
		Description string
		Tags        string
		Banner      []byte
		AuthorID    uint
	}

	var reviews []Result
	err := config.DB.Raw(`
		SELECT tr.review_id, tr.user_id, tr.rating, tr.comment, tr.created_at,
		       p.plan_id, p.title, p.description, p.tags, p.banner, p.user_id AS author_id
		FROM trip_reviews tr
		JOIN plans p ON tr.plan_id = p.plan_id
		WHERE tr.user_id = ?
		ORDER BY tr.created_at DESC
	`, userID).Scan(&reviews).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil review kamu"})
		return
	}

	authorIDs := []uint{}
	for _, r := range reviews {
		authorIDs = append(authorIDs, r.AuthorID)
	}

	uniqueAuthorIDs := map[uint]bool{}
	filteredAuthorIDs := []uint{}
	for _, id := range authorIDs {
		if !uniqueAuthorIDs[id] {
			uniqueAuthorIDs[id] = true
			filteredAuthorIDs = append(filteredAuthorIDs, id)
		}
	}

	type Author struct {
		UserID   uint
		Username string
	}

	var authors []Author
	if len(filteredAuthorIDs) > 0 {
		config.DB.Table("users").
			Select("user_id, username").
			Where("user_id IN ?", filteredAuthorIDs).
			Find(&authors)
	}

	authorMap := make(map[uint]string)
	for _, a := range authors {
		authorMap[a.UserID] = a.Username
	}

	var response []map[string]interface{}
	for _, r := range reviews {
		bannerBase64 := ""
		if len(r.Banner) > 0 {
			bannerBase64 = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(r.Banner)
		}

		response = append(response, map[string]interface{}{
			"review_id":  r.ReviewID,
			"user_id":    r.UserID,
			"rating":     r.Rating,
			"comment":    r.Comment,
			"created_at": r.CreatedAt,
			"plan": map[string]interface{}{
				"plan_id":     r.PlanID,
				"title":       r.Title,
				"description": r.Description,
				"tags":        r.Tags,
				"banner":      bannerBase64,
				"author_name": authorMap[r.AuthorID],
			},
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetTripReviewsOnMyPlansWithProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var myPlans []models.Plan
	config.DB.Where("user_id = ?", userID).Find(&myPlans)

	var planIDs []uint
	for _, p := range myPlans {
		planIDs = append(planIDs, p.PlanID)
	}

	if len(planIDs) == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}})
		return
	}

	type Result struct {
		ReviewID  uint
		PlanID    uint
		Rating    int
		Comment   string
		CreatedAt time.Time
		UserID    uint
		Username  string
		Photo     []byte
		Rank      string
		Role      string
	}

	var rows []Result
	config.DB.Raw(`
		SELECT tr.review_id, tr.plan_id, tr.rating, tr.comment, tr.created_at,
		u.user_id, u.username, u.role, p.photo, p.rank
		FROM trip_reviews tr
		JOIN users u ON u.user_id = tr.user_id
		JOIN profiles p ON p.user_id = u.user_id
		WHERE tr.plan_id IN (?) AND tr.user_id != ?
		ORDER BY tr.created_at DESC
	`, planIDs, userID).Scan(&rows)

	var result []map[string]interface{}
	for _, r := range rows {
		photoBase64 := ""
		if len(r.Photo) > 0 {
			photoBase64 = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(r.Photo)
		}

		result = append(result, map[string]interface{}{
			"review_id":  r.ReviewID,
			"plan_id":    r.PlanID,
			"rating":     r.Rating,
			"comment":    r.Comment,
			"created_at": r.CreatedAt,
			"user": map[string]interface{}{
				"user_id":  r.UserID,
				"username": r.Username,
				"rank":     r.Rank,
				"role":     r.Role,
				"photo":    photoBase64,
			},
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": result})
}
