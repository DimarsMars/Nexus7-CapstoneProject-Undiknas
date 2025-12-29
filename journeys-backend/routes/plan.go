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
		planGroup.POST("/:id/verify-location", plan.VerifyUserLocation)
		planGroup.GET("/recommendations", plan.GetRecommendedPlans)
		planGroup.GET("/all", plan.GetAllPlans)
		planGroup.GET("/plans/:plan_id/route", plan.GetRoutesByPlanID)
		planGroup.GET("/route/:id", plan.GetRouteDetail)
		planGroup.GET("/history", plan.GetCompletedPlans)
		planGroup.DELETE("/completed-plans/:progress_id", plan.DeleteCompletedPlan)

	}
}
