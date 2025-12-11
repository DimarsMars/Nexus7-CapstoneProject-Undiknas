package routes

import (
	"be_journeys/controllers/user"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func UserRoutes(r *gin.Engine) {
	u := r.Group("/user")
	u.Use(middleware.FirebaseAuth())
	{
		u.GET("/me", user.GetUser)
		u.PUT("/update", user.UpdateUser)
		u.GET("/xp", user.GetUserXPSummary)
		u.GET("/xp/history", user.GetUserXPHistory)
	}
}
