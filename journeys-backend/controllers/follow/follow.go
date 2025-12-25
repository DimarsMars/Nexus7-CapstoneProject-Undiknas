package follow

import (
	"be_journeys/config"
	"be_journeys/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func FollowUser(c *gin.Context) {
	followerID := c.GetUint("user_id")
	targetIDStr := c.Param("user_id")
	targetID, err := strconv.ParseUint(targetIDStr, 10, 64)
	if err != nil || followerID == uint(targetID) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var exists models.Follow
	if err := config.DB.
		First(&exists, "follower_id = ? AND following_id = ?", followerID, targetID).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kamu sudah mengikuti user ini"})
		return
	}

	follow := models.Follow{
		FollowerID:  followerID,
		FollowingID: uint(targetID),
	}

	if err := config.DB.Create(&follow).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal follow user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Berhasil mengikuti user"})
}

func UnfollowUser(c *gin.Context) {
	followerID := c.GetUint("user_id")
	targetIDStr := c.Param("user_id")
	targetID, err := strconv.ParseUint(targetIDStr, 10, 64)
	if err != nil || followerID == uint(targetID) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	if err := config.DB.
		Delete(&models.Follow{}, "follower_id = ? AND following_id = ?", followerID, targetID).
		Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal unfollow user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Berhasil unfollow user"})
}

func GetFollowerCount(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var count int64
	config.DB.Model(&models.Follow{}).
		Where("following_id = ?", userID).
		Count(&count)

	c.JSON(http.StatusOK, gin.H{"followers_count": count})
}

func GetFollowingCount(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var count int64
	config.DB.Model(&models.Follow{}).
		Where("follower_id = ?", userID).
		Count(&count)

	c.JSON(http.StatusOK, gin.H{"following_count": count})
}
