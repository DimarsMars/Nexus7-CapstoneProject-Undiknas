package review

import (
	"be_journeys/config"
	"be_journeys/models"
	"fmt"
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

	c.JSON(http.StatusOK, gin.H{"message": "Plan review berhasil ditambahkan", "data": review})
}

func GetTripReviews(c *gin.Context) {
	planIDParam := c.Param("plan_id")

	var planID uint
	if _, err := fmt.Sscanf(planIDParam, "%d", &planID); err != nil || planID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "plan_id tidak valid"})
		return
	}

	var reviews []models.TripReview
	if err := config.DB.Where("plan_id = ?", planID).Order("created_at DESC").Find(&reviews).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plan reviews"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": reviews})
}
