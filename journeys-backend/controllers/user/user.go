package user

import (
	"be_journeys/config"
	"be_journeys/models"
	"context"
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

	rank := calculateRank(int(totalXP))

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

func calculateRank(xp int) string {
	switch {
	case xp >= 300:
		return "Master"
	case xp >= 200:
		return "Pro"
	case xp >= 100:
		return "Adventurer"
	default:
		return "Newbie"
	}
}
