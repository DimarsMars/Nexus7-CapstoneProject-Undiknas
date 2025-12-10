package routes

import (
	"be_journeys/controllers/plan"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func PlanRoutes(r *gin.Engine) {
	planGroup := r.Group("/plans")
	planGroup.Use(middleware.FirebaseAuth())
	{
		planGroup.POST("/create", plan.CreatePlan)
		planGroup.GET("/", plan.GetPlans)
	}
}
