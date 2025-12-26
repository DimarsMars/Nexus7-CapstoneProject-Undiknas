package favorite

import (
	"be_journeys/config"
	"be_journeys/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func AddFavorite(c *gin.Context) {
	userID := c.GetUint("user_id")
	planID, _ := strconv.ParseUint(c.Param("plan_id"), 10, 64)

	fav := models.Favorite{
		UserID: userID,
		PlanID: uint(planID),
	}

	if err := config.DB.Create(&fav).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal menambahkan favorite plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan berhasil ditambahkan ke favorite"})
}

func RemoveFavorite(c *gin.Context) {
	userID := c.GetUint("user_id")
	favoriteID, _ := strconv.ParseUint(c.Param("favorite_id"), 10, 64)

	result := config.DB.Where("favorite_id = ? AND user_id = ?", favoriteID, userID).
		Delete(&models.Favorite{})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus favorite"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Favorite tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Favorite berhasil dihapus"})
}

func GetFavorites(c *gin.Context) {
	userID := c.GetUint("user_id")
	var favorites []models.Favorite

	if err := config.DB.
		Preload("Plan.Routes").
		Where("user_id = ?", userID).
		Find(&favorites).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil favorites"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": favorites})
}
