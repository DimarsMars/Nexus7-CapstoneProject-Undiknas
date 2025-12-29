package routes

import (
	"be_journeys/controllers/follow"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func FollowRoutes(r *gin.Engine) {
	followGroup := r.Group("/follow")
	followGroup.Use(middleware.FirebaseAuth())
	{
		followGroup.POST("/:user_id", follow.FollowUser)
		followGroup.DELETE("/:user_id", follow.UnfollowUser)
		followGroup.GET("/:user_id/socials", follow.GetSocialCounts)
		followGroup.GET("/:user_id/is-following", follow.IsFollowing)
	}
}
