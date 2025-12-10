package plan

import (
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"

	"be_journeys/config"
	"be_journeys/models"

	"github.com/gin-gonic/gin"
)

// struct untuk parsing route dari request
type routeInput struct {
	Title       string   `json:"title"`
	Description string   `json:"description"`
	Address     string   `json:"address"`
	Latitude    float64  `json:"latitude"`
	Longitude   float64  `json:"longitude"`
	Tags        []string `json:"tags"`
	StepOrder   int      `json:"step_order"`
	ImageBase64 string   `json:"image"`
}

func CreatePlan(c *gin.Context) {
	userID := c.GetUint("user_id")

	title := c.PostForm("title")
	description := c.PostForm("description")
	tagsRaw := c.PostForm("tags")
	catIDsRaw := c.PostForm("category_ids")
	routesRaw := c.PostForm("routes")

	var tags []string
	if tagsRaw != "" {
		tags = strings.Split(tagsRaw, ",")
	}

	var categories []models.Category
	if catIDsRaw != "" {
		catIDs := strings.Split(catIDsRaw, ",")
		if err := config.DB.Where("category_id IN ?", catIDs).Find(&categories).Error; err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Kategori tidak ditemukan"})
			return
		}
	}

	var routeInputs []routeInput
	if routesRaw != "" {
		if err := json.Unmarshal([]byte(routesRaw), &routeInputs); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Format routes tidak valid"})
			return
		}
	}

	var banner []byte
	if len(routeInputs) > 0 && routeInputs[0].ImageBase64 != "" {
		if b, err := base64.StdEncoding.DecodeString(routeInputs[0].ImageBase64); err == nil {
			banner = b
		}
	}

	plan := models.Plan{
		UserID:      userID,
		Title:       title,
		Description: description,
		Tags:        tags,
		Banner:      banner,
		Categories:  categories,
	}

	if err := config.DB.Create(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat plan"})
		return
	}

	for _, r := range routeInputs {
		imgBytes := []byte{}
		if r.ImageBase64 != "" {
			if b, err := base64.StdEncoding.DecodeString(r.ImageBase64); err == nil {
				imgBytes = b
			}
		}

		route := models.Route{
			PlanID:      plan.PlanID,
			Title:       r.Title,
			Description: r.Description,
			Address:     r.Address,
			Latitude:    r.Latitude,
			Longitude:   r.Longitude,
			Tags:        r.Tags,
			StepOrder:   r.StepOrder,
			Image:       imgBytes,
		}

		if err := config.DB.Create(&route).Error; err != nil {

			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan route"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan dan routes berhasil dibuat", "data": plan})
}

func GetPlans(c *gin.Context) {
	userID := c.GetUint("user_id")

	var plans []models.Plan
	if err := config.DB.Preload("Categories").Where("user_id = ?", userID).Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plans"})
		return
	}

	var response []map[string]interface{}
	for _, p := range plans {
		var bannerBase64 string
		if len(p.Banner) > 0 {
			bannerBase64 = base64.StdEncoding.EncodeToString(p.Banner)
		}

		response = append(response, map[string]interface{}{
			"plan_id":     p.PlanID,
			"title":       p.Title,
			"description": p.Description,
			"tags":        p.Tags,
			"banner":      bannerBase64,
			"categories":  p.Categories,
			"created_at":  p.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetPlanDetail(c *gin.Context) {
	idStr := c.Param("id")
	planID, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var plan models.Plan
	if err := config.DB.Preload("Categories").First(&plan, "plan_id = ?", planID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	var routes []models.Route
	if err := config.DB.Where("plan_id = ?", plan.PlanID).Find(&routes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil routes"})
		return
	}

	var bannerBase64 string
	if len(plan.Banner) > 0 {
		bannerBase64 = base64.StdEncoding.EncodeToString(plan.Banner)
	}

	var routeList []map[string]interface{}
	for _, r := range routes {
		imgBase64 := ""
		if len(r.Image) > 0 {
			imgBase64 = base64.StdEncoding.EncodeToString(r.Image)
		}
		routeList = append(routeList, map[string]interface{}{
			"route_id":    r.RouteID,
			"title":       r.Title,
			"description": r.Description,
			"address":     r.Address,
			"latitude":    r.Latitude,
			"longitude":   r.Longitude,
			"tags":        r.Tags,
			"step_order":  r.StepOrder,
			"image":       imgBase64,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"data": map[string]interface{}{
			"plan":   plan,
			"banner": bannerBase64,
			"routes": routeList,
		},
	})
}

func GetPlanBanner(c *gin.Context) {
	idStr := c.Param("id")
	planID, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var plan models.Plan
	if err := config.DB.First(&plan, "plan_id = ?", planID).Error; err != nil {
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
	idStr := c.Param("id")
	planID, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

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
			c.JSON(http.StatusBadRequest, gin.H{"error": "Kategori tidak ditemukan"})
			return
		}
		config.DB.Model(&plan).Association("Categories").Replace(categories)
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
	idStr := c.Param("id")
	planID, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var plan models.Plan
	if err := config.DB.Where("plan_id = ? AND user_id = ?", planID, userID).First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Plan tidak ditemukan"})
		return
	}

	if err := config.DB.Delete(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus plan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Plan berhasil dihapus"})
}

func GetPlansByCategory(c *gin.Context) {
	catIDStr := c.Param("id")
	catID, err := strconv.ParseUint(catIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID kategori tidak valid"})
		return
	}

	var plans []models.Plan
	if err := config.DB.
		Joins("JOIN plan_categories pc ON pc.plan_id = plans.plan_id").
		Where("pc.category_id = ?", catID).
		Preload("Categories").
		Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil plans"})
		return
	}

	var response []map[string]interface{}
	for _, p := range plans {
		var bannerBase64 string
		if len(p.Banner) > 0 {
			bannerBase64 = base64.StdEncoding.EncodeToString(p.Banner)
		}
		response = append(response, map[string]interface{}{
			"plan_id":     p.PlanID,
			"title":       p.Title,
			"description": p.Description,
			"tags":        p.Tags,
			"banner":      bannerBase64,
			"categories":  p.Categories,
			"created_at":  p.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}
