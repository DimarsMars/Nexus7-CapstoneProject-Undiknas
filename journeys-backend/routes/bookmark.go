package routes

import (
	"be_journeys/controllers/bookmark"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func BookmarkRoutes(r *gin.Engine) {
	bookmarkGroup := r.Group("/bookmarks")
	bookmarkGroup.Use(middleware.FirebaseAuth())
	{
		bookmarkGroup.POST("/:route_id", bookmark.AddBookmark)
		bookmarkGroup.GET("/", bookmark.GetBookmark)
		bookmarkGroup.DELETE("/:bookmark_id", bookmark.RemoveBookmark)
	}
}
