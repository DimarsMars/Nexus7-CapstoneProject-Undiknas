package auth

import (
	"be_journeys/config"
	"be_journeys/models"
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

func Register(c *gin.Context) {
	var body struct {
		IDToken  string `json:"idToken"`
		Username string `json:"username"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	client, _ := config.FirebaseApp.Auth(context.Background())
	token, err := client.VerifyIDToken(context.Background(), body.IDToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid firebase token"})
		return
	}

	firebaseUID := token.UID
	email := token.Claims["email"].(string)

	var existing models.User
	if err := config.DB.Where("firebase_uid = ?", firebaseUID).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user already exists"})
		return
	}

	user := models.User{
		Username:    body.Username,
		Email:       email,
		FirebaseUID: firebaseUID,
		Role:        "traveller",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile := models.Profile{
		UserID:      user.UserID,
		Photo:       []byte{},
		Location:    "",
		BirthDate:   nil,
		Description: "",
		Languages:   "",
		Status:      "",
		Rank:        "Newbie",
		Followers:   0,
		Following:   0,
	}
	config.DB.Create(&profile)

	c.JSON(http.StatusOK, gin.H{
		"message": "Register success",
		"user":    user,
		"profile": profile,
	})
}
