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

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format input tidak valid"})
		return
	}

	var plan models.Plan
	if err := config.DB.First(&plan, input.PlanID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	review := models.TripReview{
		UserID:    userID,
		PlanID:    input.PlanID,
		Rating:    input.Rating,
		Comment:   input.Comment,
		CreatedAt: time.Now(),
	}

	if err := config.DB.Create(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan plan review"})
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
		Select("COALESCE(SUM(xp_value),0)").
		Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))
	config.DB.Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

	c.JSON(http.StatusOK, gin.H{
		"message": "Plan review berhasil ditambahkan",
		"data":    review,
	})
}

func GetTripReviews(c *gin.Context) {
	planIDParam := c.Param("plan_id")

	var planID uint
	if _, err := fmt.Sscanf(planIDParam, "%d", &planID); err != nil || planID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "plan_id tidak valid"})
		return
	}

	var reviews []models.TripReview
	if err := config.DB.
		Where("plan_id = ?", planID).
		Order("created_at DESC").
		Find(&reviews).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plan reviews"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": reviews})
}

func DeleteTripReview(c *gin.Context) {
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

	var plan models.Plan
	if err := config.DB.First(&plan, "plan_id = ?", review.PlanID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data plan"})
		return
	}

	if plan.UserID != userID {
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

	routeID := c.PostForm("route_id")
	rating := c.PostForm("rating")
	comment := c.PostForm("comment")

	var ratingInt int
	if _, err := fmt.Sscanf(rating, "%d", &ratingInt); err != nil || ratingInt < 1 || ratingInt > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Rating harus berupa angka antara 1 sampai 5"})
		return
	}

	routeUint := helper.StringToUint(routeID)
	var route models.Route
	if err := config.DB.First(&route, routeUint).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Route tidak ditemukan"})
		return
	}

	var imageBytes []byte
	file, err := c.FormFile("image")
	if err == nil {
		src, _ := file.Open()
		defer src.Close()
		imageBytes, _ = io.ReadAll(src)
	}

	review := models.PlaceReview{
		UserID:    userID,
		RouteID:   routeUint,
		Rating:    ratingInt,
		Comment:   comment,
		Image:     imageBytes,
		CreatedAt: time.Now(),
	}

	if err := config.DB.Create(&review).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan place review"})
		return
	}

	xp := models.UserXP{
		UserID:      userID,
		XPValue:     10,
		Description: "Reviewed a place",
	}
	config.DB.Create(&xp)

	var totalXP int64
	config.DB.Model(&models.UserXP{}).
		Where("user_id = ?", userID).
		Select("COALESCE(SUM(xp_value),0)").
		Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))
	config.DB.Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

	c.JSON(http.StatusOK, gin.H{
		"message": "Place review berhasil ditambahkan",
		"data":    review,
	})
}

func GetPlaceReviews(c *gin.Context) {
	routeID := c.Param("route_id")

	var reviews []models.PlaceReview
	if err := config.DB.
		Where("route_id = ?", routeID).
		Order("created_at DESC").
		Find(&reviews).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil place reviews"})
		return
	}

	var result []map[string]interface{}
	for _, r := range reviews {
		imageBase64 := ""
		if len(r.Image) > 0 {
			imageBase64 = base64.StdEncoding.EncodeToString(r.Image)
		}

		result = append(result, map[string]interface{}{
			"review_id":  r.ReviewID,
			"user_id":    r.UserID,
			"route_id":   r.RouteID,
			"rating":     r.Rating,
			"comment":    r.Comment,
			"image":      imageBase64,
			"created_at": r.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": result})
}
