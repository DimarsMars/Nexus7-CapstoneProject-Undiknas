package middleware

import (
	"context"
	"net/http"
	"strings"

	"be_journeys/config"
	"be_journeys/models"

	"github.com/gin-gonic/gin"
)

func FirebaseAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header missing"})
			c.Abort()
			return
		}

		idToken := strings.Replace(authHeader, "Bearer ", "", 1)

		client, err := config.FirebaseApp.Auth(context.Background())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Firebase initialization failed"})
			c.Abort()
			return
		}

		token, err := client.VerifyIDToken(context.Background(), idToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		uid := token.UID

		var user models.User
		if err := config.DB.Where("firebase_uid = ?", uid).First(&user).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in database"})
			c.Abort()
			return
		}

		c.Set("firebase_uid", uid)
		c.Set("user_id", user.UserID)

		c.Next()
	}
}
