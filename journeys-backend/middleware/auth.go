package middleware

import (
	"be_journeys/config"
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

func FirebaseAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		idToken := c.Request.Header.Get("Authorization")

		if idToken == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "missing authorization header"})
			c.Abort()
			return
		}

		client, _ := config.FirebaseApp.Auth(context.Background())
		_, err := client.VerifyIDToken(context.Background(), idToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			c.Abort()
			return
		}

		c.Next()
	}
}
