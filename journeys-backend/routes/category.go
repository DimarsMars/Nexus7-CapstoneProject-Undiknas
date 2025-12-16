package routes

import (
	"be_journeys/controllers/category"
	"be_journeys/middleware"

	"github.com/gin-gonic/gin"
)

func CategoryRoutes(r *gin.Engine) {
	c := r.Group("/category")
	c.Use(middleware.FirebaseAuth())
	{
		c.GET("/", category.GetAllCategories)
		c.POST("/", category.CreateCategory)
	}
}
