package plan

import (
	"be_journeys/config"
	"be_journeys/models"
	"io"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func CreatePlan(c *gin.Context) {
	userID := c.GetUint("user_id")

	title := c.PostForm("title")
	description := c.PostForm("description")
	tagsRaw := c.PostForm("tags")

	var tags []string
	if tagsRaw != "" {
		tags = strings.Split(tagsRaw, ",")
	}

	bannerFile, err := c.FormFile("banner")
	var bannerBytes []byte
	if err == nil {
		openedFile, _ := bannerFile.Open()
		defer openedFile.Close()
		bannerBytes, _ = io.ReadAll(openedFile)
	}

	plan := models.Plan{
		UserID:      userID,
		Title:       title,
		Description: description,
		Tags:        tags,
		Banner:      bannerBytes,
	}

	if err := config.DB.Create(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan berhasil dibuat", "data": plan})
}
