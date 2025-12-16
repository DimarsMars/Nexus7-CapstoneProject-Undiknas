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
		planGroup.POST("/", plan.CreatePlan)
		planGroup.GET("/", plan.GetPlans)
		planGroup.PUT("/:id", plan.UpdatePlan)
		planGroup.DELETE("/:id", plan.DeletePlan)
		planGroup.GET("/:id/banner", plan.GetPlanBanner)
		planGroup.GET("/:id/detail", plan.GetPlanDetail)
		planGroup.GET("/category/:id", plan.GetPlansByCategory)
		planGroup.POST("/:id/verify-location", plan.VerifyUserLocation)

	}
}
