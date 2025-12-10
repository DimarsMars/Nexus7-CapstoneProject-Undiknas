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
	catIDsRaw := c.PostForm("category_ids")

	var tags []string
	if tagsRaw != "" {
		tags = strings.Split(tagsRaw, ",")
	}

	var categories []models.Category
	if catIDsRaw != "" {
		catIDs := strings.Split(catIDsRaw, ",")
		if err := config.DB.Where("category_id IN ?", catIDs).Find(&categories).Error; err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal mengambil kategori"})
			return
		}
	}

	var bannerBytes []byte
	if file, err := c.FormFile("banner"); err == nil {
		opened, _ := file.Open()
		defer opened.Close()
		bannerBytes, _ = io.ReadAll(opened)
	}

	plan := models.Plan{
		UserID:      userID,
		Title:       title,
		Description: description,
		Tags:        tags,
		Banner:      bannerBytes,
		Categories:  categories,
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
	if err := config.DB.Preload("Categories").Where("user_id = ?", userID).Find(&plans).Error; err != nil {
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
			"categories":  plan.Categories,
			"created_at":  plan.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetPlanBanner(c *gin.Context) {
	id := c.Param("id")
	var plan models.Plan

	if err := config.DB.First(&plan, "plan_id = ?", id).Error; err != nil {
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
	if err := config.DB.Preload("Categories").Where("plan_id = ? AND user_id = ?", planID, userID).First(&plan).Error; err != nil {
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
	if catIDsRaw := c.PostForm("category_ids"); catIDsRaw != "" {
		catIDs := strings.Split(catIDsRaw, ",")
		var categories []models.Category
		if err := config.DB.Where("category_id IN ?", catIDs).Find(&categories).Error; err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal mengambil kategori"})
			return
		}
		plan.Categories = categories
	}
	if file, err := c.FormFile("banner"); err == nil {
		opened, _ := file.Open()
		defer opened.Close()
		bannerBytes, _ := io.ReadAll(opened)
		plan.Banner = bannerBytes
	}

	if err := config.DB.Save(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan berhasil diupdate", "data": plan})
}

func DeletePlan(c *gin.Context) {
	userID := c.GetUint("user_id")
	planID := c.Param("id")

	var plan models.Plan
	if err := config.DB.Where("plan_id = ? AND user_id = ?", planID, userID).First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	if err := config.DB.Delete(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Plan dan relasi kategorinya berhasil dihapus",
	})
}

func GetPlansByCategory(c *gin.Context) {
	catID := c.Param("id") 

	var plans []models.Plan
	err := config.DB.
		Joins("JOIN plan_categories ON plan_categories.plan_id = plans.plan_id").
		Where("plan_categories.category_id = ?", catID).
		Preload("Categories").
		Find(&plans).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plan"})
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
			"categories":  plan.Categories,
			"created_at":  plan.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}
