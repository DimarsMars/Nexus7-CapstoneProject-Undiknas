package routes

import (
	"be_journeys/controllers/review"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func ReviewRoutes(r *gin.Engine) {
	reviewGroup := r.Group("/reviews")
	reviewGroup.Use(middleware.FirebaseAuth())
	{
		reviewGroup.POST("/trip", review.CreateTripReview)
		reviewGroup.POST("/place", review.CreatePlaceReview)
		reviewGroup.GET("/place/:route_id", review.GetPlaceReviews)
		reviewGroup.DELETE("/my/:review_id", review.DeleteMyTripReview)
		reviewGroup.GET("/trip/me", review.GetTripReviewsByUser)
		reviewGroup.GET("/trip/my-plans", review.GetTripReviewsOnMyPlansWithProfile)

	}
}
