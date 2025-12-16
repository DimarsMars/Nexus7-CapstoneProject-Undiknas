package bookmark

import (
	"be_journeys/config"
	"be_journeys/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func AddBookmark(c *gin.Context) {
	userID := c.GetUint("user_id")
	routeID, _ := strconv.ParseUint(c.Param("route_id"), 10, 64)

	bookmark := models.Bookmark{
		UserID:  userID,
		RouteID: uint(routeID),
	}

	if err := config.DB.Create(&bookmark).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal menambahkan bookmark tempat"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Tempat berhasil ditambahkan ke bookmark"})
}

func RemoveBookmark(c *gin.Context) {
	userID := c.GetUint("user_id")
	bookmarkID, _ := strconv.ParseUint(c.Param("bookmark_id"), 10, 64)

	result := config.DB.Where("bookmark_id = ? AND user_id = ?", bookmarkID, userID).Delete(&models.Bookmark{})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus bookmark"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Bookmark tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Bookmark berhasil dihapus"})
}

func GetBookmark(c *gin.Context) {
	userID := c.GetUint("user_id")
	var bookmarks []models.Bookmark

	if err := config.DB.Preload("Route").
		Where("user_id = ?", userID).
		Find(&bookmarks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil bookmarks"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": bookmarks})
}
