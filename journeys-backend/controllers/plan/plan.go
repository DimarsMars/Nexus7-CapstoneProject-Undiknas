package plan

import (
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"

	"be_journeys/config"
	"be_journeys/controllers/helper"
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
	status := c.PostForm("status")

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
		Status:      status,
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

	xp := models.UserXP{
		UserID:      userID,
		XPValue:     100,
		Description: "Created a new plan",
	}
	if err := config.DB.Create(&xp).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan XP"})
		return
	}

	var totalXP int64
	config.DB.Model(&models.UserXP{}).Where("user_id = ?", userID).Select("SUM(xp_value)").Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))

	config.DB.Model(&models.Profile{}).Where("user_id = ?", userID).Update("rank", newRank)

	c.JSON(http.StatusOK, gin.H{
		"message": "Plan dan routes berhasil dibuat",
		"data":    plan,
	})
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
			"status":      p.Status,
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
			"status": plan.Status,
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

	if status := c.PostForm("status"); status != "" {
		plan.Status = status
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

type VerifyLocationInput struct {
	Latitude  float64 `json:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" binding:"required"`
	StepOrder int     `json:"step_order" binding:"required"`
}

func VerifyUserLocation(c *gin.Context) {
	userID := c.GetUint("user_id")
	planIDStr := c.Param("id")
	planID, err := strconv.ParseUint(planIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var input VerifyLocationInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format input tidak valid"})
		return
	}

	var route models.Route
	if err := config.DB.
		Where("plan_id = ? AND step_order = ?", planID, input.StepOrder).
		First(&route).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Route tidak ditemukan"})
		return
	}

	distance := helper.CalculateDistance(input.Latitude, input.Longitude, route.Latitude, route.Longitude)

	if distance > 0.3 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":       "Kamu belum sampai di lokasi",
			"distance_km": distance,
		})
		return
	}

	var progress models.PlanProgress
	err = config.DB.
		Where("user_id = ? AND plan_id = ? AND step_order = ?", userID, planID, input.StepOrder).
		First(&progress).Error
	if err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kamu sudah menyelesaikan lokasi ini"})
		return
	}

	newProgress := models.PlanProgress{
		UserID:    userID,
		PlanID:    uint(planID),
		StepOrder: input.StepOrder,
	}
	if err := config.DB.Create(&newProgress).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan progress"})
		return
	}

	xp := models.UserXP{
		UserID:      userID,
		XPValue:     10,
		Description: "Arrived at step " + strconv.Itoa(input.StepOrder),
	}

	if err := config.DB.Create(&xp).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan XP"})
		return
	}

	var totalXP int64
	config.DB.Model(&models.UserXP{}).Where("user_id = ?", userID).Select("SUM(xp_value)").Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))

	config.DB.Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

	var maxStep int
	config.DB.
		Model(&models.Route{}).
		Where("plan_id = ?", planID).
		Select("MAX(step_order)").Scan(&maxStep)

	if input.StepOrder == maxStep {

		finalXP := models.UserXP{
			UserID:      userID,
			XPValue:     100,
			Description: "Completed the trip",
		}
		if err := config.DB.Create(&finalXP).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambahkan XP akhir trip"})
			return
		}

		var updatedTotalXP int64
		config.DB.Model(&models.UserXP{}).Where("user_id = ?", userID).Select("SUM(xp_value)").Scan(&updatedTotalXP)

		finalRank := helper.CalculateRank(int(updatedTotalXP))
		config.DB.Model(&models.Profile{}).
			Where("user_id = ?", userID).
			Update("rank", finalRank)

		c.JSON(http.StatusOK, gin.H{
			"message":  "Selamat, kamu telah menyelesaikan seluruh trip!",
			"complete": true,
		})
		return
	}

	var next models.Route
	if err := config.DB.
		Where("plan_id = ? AND step_order = ?", planID, input.StepOrder+1).
		First(&next).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"message": "Berhasil menyelesaikan lokasi ini, lanjut ke route selanjutnya",
		})
		return
	}

	nextImage := ""
	if len(next.Image) > 0 {
		nextImage = base64.StdEncoding.EncodeToString(next.Image)
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil sampai lokasi, lanjut ke route berikutnya",
		"next_route": map[string]interface{}{
			"route_id":    next.RouteID,
			"title":       next.Title,
			"description": next.Description,
			"address":     next.Address,
			"latitude":    next.Latitude,
			"longitude":   next.Longitude,
			"step_order":  next.StepOrder,
			"tags":        next.Tags,
			"image":       nextImage,
		},
	})
}

func GetRecommendedPlans(c *gin.Context) {
	userID := c.GetUint("user_id")

	var profile models.Profile
	if err := config.DB.First(&profile, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profil tidak ditemukan"})
		return
	}

	var recommendedPlans []models.Plan
	if err := config.DB.
		Joins("JOIN plan_categories pc ON pc.plan_id = plans.plan_id").
		Joins("JOIN categories c ON c.category_id = pc.category_id").
		Where("plans.status = ? OR c.name IN ?", profile.Status, strings.Split(profile.Description, ",")).
		Preload("Categories").
		Find(&recommendedPlans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil rekomendasi plan"})
		return
	}

	resp := []map[string]interface{}{}
	for _, p := range recommendedPlans {
		banner := ""
		if len(p.Banner) > 0 {
			banner = base64.StdEncoding.EncodeToString(p.Banner)
		}

		resp = append(resp, map[string]interface{}{
			"plan_id":     p.PlanID,
			"title":       p.Title,
			"description": p.Description,
			"status":      p.Status,
			"categories":  p.Categories,
			"banner":      banner,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

func GetAllPlans(c *gin.Context) {
	var plans []models.Plan

	if err := config.DB.Preload("Categories").Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil semua plans"})
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
			"status":      p.Status,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}
