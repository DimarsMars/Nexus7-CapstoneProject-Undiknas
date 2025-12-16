package category

import (
	"be_journeys/config"
	"be_journeys/models"
	"encoding/base64"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetAllCategories(c *gin.Context) {
	var categories []models.Category

	if err := config.DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil kategori"})
		return
	}

	var response []map[string]interface{}
	for _, cat := range categories {
		base64Img := ""
		if len(cat.Image) > 0 {
			base64Img = base64.StdEncoding.EncodeToString(cat.Image)
		}

		response = append(response, map[string]interface{}{
			"category_id": cat.CategoryID,
			"name":        cat.Name,
			"image":       base64Img,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func CreateCategory(c *gin.Context) {
	name := c.PostForm("name")

	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Image wajib diupload"})
		return
	}

	openedFile, _ := file.Open()
	defer openedFile.Close()

	fileBytes, _ := io.ReadAll(openedFile)

	category := models.Category{
		Name:  name,
		Image: fileBytes,
	}

	if err := config.DB.Create(&category).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat kategori"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Kategori dibuat", "data": category})
}
