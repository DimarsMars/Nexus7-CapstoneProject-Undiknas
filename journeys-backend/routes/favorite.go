package routes

import (
	"be_journeys/controllers/favorite"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func FavoriteRoutes(r *gin.Engine) {
	favoriteGroup := r.Group("/favorites")
	favoriteGroup.Use(middleware.FirebaseAuth())
	{
		favoriteGroup.POST("/:plan_id", favorite.AddFavorite)
		favoriteGroup.GET("/", favorite.GetFavorites)
		favoriteGroup.DELETE("/:favorite_id", favorite.RemoveFavorite)
	}
}
