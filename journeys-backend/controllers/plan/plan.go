package plan

import (
	"be_journeys/config"
	"be_journeys/models"
	"encoding/base64"
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

func GetPlans(c *gin.Context) {
	userID := c.GetUint("user_id")

	var plans []models.Plan
	if err := config.DB.Where("user_id = ?", userID).Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plans"})
		return
	}

	var response []map[string]interface{}
	for _, plan := range plans {
		var bannerBase64 string
		if len(plan.Banner) > 0 {
			bannerBase64 = base64.StdEncoding.EncodeToString(plan.Banner)
		}

		response = append(response, map[string]interface{}{
			"plan_id":     plan.PlanID,
			"title":       plan.Title,
			"description": plan.Description,
			"tags":        plan.Tags,
			"banner":      bannerBase64,
			"created_at":  plan.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetPlanBanner(c *gin.Context) {
	id := c.Param("id")

	var plan models.Plan
	if err := config.DB.First(&plan, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	if len(plan.Banner) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Banner kosong"})
		return
	}

	c.Data(http.StatusOK, "image/jpeg", plan.Banner)
}

func UpdatePlan(c *gin.Context) {
	userID := c.GetUint("user_id")
	planID := c.Param("id")

	var plan models.Plan
	if err := config.DB.Where("plan_id = ? AND user_id = ?", planID, userID).First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Plan tidak ditemukan"})
		return
	}
	if title := c.PostForm("title"); title != "" {
		plan.Title = title
	}
	if desc := c.PostForm("description"); desc != "" {
		plan.Description = desc
	}
	if tagsRaw := c.PostForm("tags"); tagsRaw != "" {
		plan.Tags = strings.Split(tagsRaw, ",")
	}

	if file, err := c.FormFile("banner"); err == nil {
		opened, _ := file.Open()
		defer opened.Close()
		fileBytes, _ := io.ReadAll(opened)
		plan.Banner = fileBytes
	}

	if err := config.DB.Save(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan berhasil diupdate", "data": plan})
}
