package routes

import (
	"be_journeys/controllers/plan"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func TripSessionRoutes(r *gin.Engine) {
	trip := r.Group("/trip-sessions")
	trip.Use(middleware.FirebaseAuth())
	{
		trip.POST("/:plan_id", plan.HandleTripSession)
		trip.GET("/active", plan.GetActiveTrip)
	}
}
