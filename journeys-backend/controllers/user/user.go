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
