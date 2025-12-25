package routes

import (
	"be_journeys/controllers/profile"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func ProfileRoutes(r *gin.Engine) {
	p := r.Group("/profile")
	p.Use(middleware.FirebaseAuth())
	{
		p.GET("/me", profile.GetProfile)
		p.PUT("/update", profile.UpdateProfile)
	}
}
