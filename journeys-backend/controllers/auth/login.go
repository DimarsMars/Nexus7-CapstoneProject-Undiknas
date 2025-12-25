package auth

import (
	"be_journeys/config"
	"be_journeys/models"
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

func Login(c *gin.Context) {
	var body struct {
		IDToken string `json:"idToken"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	client, _ := config.FirebaseApp.Auth(context.Background())
	token, err := client.VerifyIDToken(context.Background(), body.IDToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	firebaseUID := token.UID

	var user models.User
	if err := config.DB.Where("firebase_uid = ?", firebaseUID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found in database"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login success",
		"user":    user,
	})
}
