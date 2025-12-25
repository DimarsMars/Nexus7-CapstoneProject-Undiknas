package routes

import (
	"be_journeys/controllers/auth"

	"github.com/gin-gonic/gin"
)

func AuthRoutes(r *gin.Engine) {
	authg := r.Group("/auth")
	{
		authg.POST("/register", auth.Register)
		authg.POST("/login", auth.Login)
	}
}
