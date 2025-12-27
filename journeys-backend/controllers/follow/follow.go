package follow

import (
	"be_journeys/config"
	"be_journeys/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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

	err = config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&follow).Error; err != nil {
			return err
		}

		if err := tx.Model(&models.Profile{}).
			Where("user_id = ?", targetID).
			UpdateColumn("followers", gorm.Expr("followers + 1")).Error; err != nil {
			return err
		}

		if err := tx.Model(&models.Profile{}).
			Where("user_id = ?", followerID).
			UpdateColumn("following", gorm.Expr("following + 1")).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
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

	err = config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Delete(&models.Follow{}, "follower_id = ? AND following_id = ?", followerID, targetID).Error; err != nil {
			return err
		}

		if err := tx.Model(&models.Profile{}).
			Where("user_id = ?", targetID).
			UpdateColumn("followers", gorm.Expr("GREATEST(followers - 1, 0)")).Error; err != nil {
			return err
		}

		if err := tx.Model(&models.Profile{}).
			Where("user_id = ?", followerID).
			UpdateColumn("following", gorm.Expr("GREATEST(following - 1, 0)")).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal unfollow user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Berhasil unfollow user"})
}

func GetSocialCounts(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var profile models.Profile
	if err := config.DB.
		Select("followers, following").
		Where("user_id = ?", userID).
		First(&profile).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profile tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"followers_count": profile.Followers,
		"following_count": profile.Following,
	})
}
