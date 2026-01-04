package plan

import (
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

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

	var user models.User
	if err := config.DB.First(&user, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data user"})
		return
	}

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

	// ✅ AuthorName disimpan di sini
	plan := models.Plan{
		UserID:      userID,
		Title:       title,
		Description: description,
		Tags:        tags,
		Banner:      banner,
		Categories:  categories,
		Status:      status,
		AuthorName:  user.Username,
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
	config.DB.Model(&models.UserXP{}).
		Where("user_id = ?", userID).
		Select("SUM(xp_value)").
		Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))

	config.DB.Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

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
	if err := config.DB.
		Where("plan_id = ?", plan.PlanID).
		Order("step_order ASC").
		Find(&routes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil routes"})
		return
	}

	var rating float64
	config.DB.Table("trip_reviews").
		Select("AVG(rating)").
		Where("plan_id = ?", planID).
		Scan(&rating)

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

	// ✅ Tambahkan data step yang sudah selesai
	userID := c.GetUint("user_id")
	var completedSteps []int
	config.DB.Model(&models.PlanProgress{}).
		Where("user_id = ? AND plan_id = ?", userID, planID).
		Pluck("step_order", &completedSteps)

	c.JSON(http.StatusOK, gin.H{
		"data": map[string]interface{}{
			"plan":            plan,
			"banner":          bannerBase64,
			"routes":          routeList,
			"status":          plan.Status,
			"rating":          rating,
			"completed_steps": completedSteps,
		},
	})
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

	distance := helper.CalculateDistance(
		input.Latitude,
		input.Longitude,
		route.Latitude,
		route.Longitude,
	)

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

	// ✅ TAMBAHAN WAJIB: akhiri trip session route sebelumnya
	config.DB.
		Model(&models.TripSession{}).
		Where(
			"user_id = ? AND plan_id = ? AND status IN ?",
			userID,
			planID,
			[]string{"ongoing", "paused"},
		).
		Updates(map[string]interface{}{
			"status":   "done",
			"ended_at": time.Now(),
		})

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
	config.DB.
		Model(&models.UserXP{}).
		Where("user_id = ?", userID).
		Select("SUM(xp_value)").
		Scan(&totalXP)

	newRank := helper.CalculateRank(int(totalXP))
	config.DB.
		Model(&models.Profile{}).
		Where("user_id = ?", userID).
		Update("rank", newRank)

	var maxStep int
	config.DB.
		Model(&models.Route{}).
		Where("plan_id = ?", planID).
		Select("MAX(step_order)").
		Scan(&maxStep)

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
		config.DB.
			Model(&models.UserXP{}).
			Where("user_id = ?", userID).
			Select("SUM(xp_value)").
			Scan(&updatedTotalXP)

		finalRank := helper.CalculateRank(int(updatedTotalXP))
		config.DB.
			Model(&models.Profile{}).
			Where("user_id = ?", userID).
			Update("rank", finalRank)

		// hapus trip session setelah trip selesai
		config.DB.
			Where("user_id = ? AND plan_id = ?", userID, planID).
			Delete(&models.TripSession{})

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

	// Ambil rata-rata rating per plan_id
	type RatingResult struct {
		PlanID uint
		Rating float64
	}

	var ratings []RatingResult
	config.DB.Table("trip_reviews").
		Select("plan_id, AVG(rating) as rating").
		Group("plan_id").
		Scan(&ratings)

	// Buat map untuk akses cepat rating berdasarkan plan_id
	ratingMap := make(map[uint]float64)
	for _, r := range ratings {
		ratingMap[r.PlanID] = r.Rating
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
			"author_name": p.AuthorName,
			"rating":      ratingMap[p.PlanID],
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

func GetRoutesByPlanID(c *gin.Context) {
	planIDStr := c.Param("plan_id")
	planID, err := strconv.ParseUint(planIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var routes []models.Route
	if err := config.DB.Where("plan_id = ?", planID).Order("step_order ASC").Find(&routes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil routes"})
		return
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

	c.JSON(http.StatusOK, gin.H{"data": routeList})
}

func GetRouteDetail(c *gin.Context) {
	routeIDStr := c.Param("id")
	routeID, err := strconv.ParseUint(routeIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID route tidak valid"})
		return
	}

	var route models.Route
	if err := config.DB.First(&route, "route_id = ?", routeID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Route tidak ditemukan"})
		return
	}

	imgBase64 := ""
	if len(route.Image) > 0 {
		imgBase64 = base64.StdEncoding.EncodeToString(route.Image)
	}

	c.JSON(http.StatusOK, gin.H{
		"data": map[string]interface{}{
			"route_id":    route.RouteID,
			"plan_id":     route.PlanID,
			"title":       route.Title,
			"description": route.Description,
			"address":     route.Address,
			"latitude":    route.Latitude,
			"longitude":   route.Longitude,
			"tags":        route.Tags,
			"step_order":  route.StepOrder,
			"image":       imgBase64,
		},
	})
}

func GetCompletedPlans(c *gin.Context) {
	userID := c.GetUint("user_id")

	type ProgressInfo struct {
		PlanID     uint
		ProgressID uint
	}

	var progressList []ProgressInfo
	config.DB.Raw(`
		SELECT DISTINCT pp.plan_id, pp.progress_id
		FROM plan_progresses pp
		WHERE pp.user_id = ?
		AND pp.step_order = (
			SELECT MAX(step_order) FROM routes r WHERE r.plan_id = pp.plan_id
		)
	`, userID).Scan(&progressList)

	if len(progressList) == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}})
		return
	}

	planIDs := []uint{}
	progressMap := map[uint]uint{}
	for _, p := range progressList {
		planIDs = append(planIDs, p.PlanID)
		progressMap[p.PlanID] = p.ProgressID
	}

	var plans []models.Plan
	config.DB.Preload("Categories").Preload("Routes").
		Where("plan_id IN ?", planIDs).Find(&plans)

	result := []map[string]interface{}{}
	for _, p := range plans {
		banner := ""
		if len(p.Banner) > 0 {
			banner = "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(p.Banner)
		}

		result = append(result, map[string]interface{}{
			"plan_id":     p.PlanID,
			"progress_id": progressMap[p.PlanID],
			"title":       p.Title,
			"description": p.Description,
			"banner":      banner,
			"categories":  p.Categories,
			"routes":      p.Routes,
			"created_at":  p.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": result})
}

func DeleteCompletedPlan(c *gin.Context) {
	userID := c.GetUint("user_id")

	progressIDStr := c.Param("progress_id")
	progressID, err := strconv.ParseUint(progressIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID progress tidak valid"})
		return
	}

	var progress models.PlanProgress
	if err := config.DB.
		First(&progress, "progress_id = ? AND user_id = ?", progressID, userID).
		Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan"})
		return
	}

	planID := progress.PlanID

	if err := config.DB.
		Where("user_id = ? AND plan_id = ?", userID, planID).
		Delete(&models.PlanProgress{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus semua progress trip"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Seluruh history plan berhasil dihapus"})
}

type TripSessionInput struct {
	Action  string `json:"action" binding:"required"`
	RouteID uint   `json:"route_id" binding:"required"`
}

func HandleTripSession(c *gin.Context) {
	userID := c.GetUint("user_id")
	planIDStr := c.Param("plan_id")
	planID, err := strconv.ParseUint(planIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Plan ID tidak valid"})
		return
	}

	var input TripSessionInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	var session models.TripSession
	action := input.Action

	switch action {
	case "start":
		var count int64
		config.DB.Model(&models.TripSession{}).
			Where("user_id = ? AND plan_id = ? AND status = ? AND route_id != ?", userID, planID, "ongoing", input.RouteID).
			Count(&count)

		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Masih ada lokasi lain yang aktif, selesaikan dulu."})
			return
		}

		if err := config.DB.
			Where("user_id = ? AND plan_id = ? AND route_id = ? AND status != ?", userID, planID, input.RouteID, "done").
			First(&session).Error; err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Trip untuk lokasi ini sudah aktif / belum selesai"})
			return
		}

		newSession := models.TripSession{
			UserID:    userID,
			PlanID:    uint(planID),
			RouteID:   input.RouteID,
			Status:    "ongoing",
			StartedAt: time.Now(),
		}
		if err := config.DB.Create(&newSession).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memulai trip"})
			return
		}
		session = newSession

	case "pause":
		if err := config.DB.
			Where("user_id = ? AND plan_id = ? AND route_id = ? AND status = ?", userID, planID, input.RouteID, "ongoing").
			First(&session).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tidak ada trip ongoing untuk lokasi ini"})
			return
		}
		session.Status = "paused"
		session.PausedAt = helper.TimePtr(time.Now())
		config.DB.Save(&session)

	case "resume":
		var count int64
		config.DB.Model(&models.TripSession{}).
			Where("user_id = ? AND plan_id = ? AND status = ? AND route_id != ?", userID, planID, "ongoing", input.RouteID).
			Count(&count)
		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Masih ada lokasi lain yang aktif, selesaikan dulu."})
			return
		}

		if err := config.DB.
			Where("user_id = ? AND plan_id = ? AND route_id = ? AND status = ?", userID, planID, input.RouteID, "paused").
			First(&session).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Trip tidak dalam keadaan pause"})
			return
		}
		session.Status = "ongoing"
		session.PausedAt = nil
		config.DB.Save(&session)

	case "end":
		if err := config.DB.
			Where("user_id = ? AND plan_id = ? AND route_id = ? AND status != ?", userID, planID, input.RouteID, "done").
			First(&session).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Trip belum dimulai atau sudah selesai"})
			return
		}
		session.Status = "done"
		session.EndedAt = helper.TimePtr(time.Now())
		config.DB.Save(&session)

	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Aksi tidak dikenali"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil menjalankan aksi trip: " + action,
		"data":    session,
	})
}

func GetActiveTrip(c *gin.Context) {
	userID := c.GetUint("user_id")

	var sessions []models.TripSession
	if err := config.DB.
		Preload("Plan").
		Preload("Plan.Routes").
		Where("user_id = ? AND status IN ?", userID, []string{"ongoing", "paused"}).
		Order("started_at DESC").
		Find(&sessions).Error; err != nil {

		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal mengambil trip aktif",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": sessions,
	})
}

func GetCompletedStepsByUser(c *gin.Context) {
	userID := c.GetUint("user_id")
	planIDStr := c.Param("id") // ✅ BENAR

	planID, err := strconv.ParseUint(planIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID plan tidak valid"})
		return
	}

	var progresses []models.PlanProgress
	if err := config.DB.
		Where("user_id = ? AND plan_id = ?", userID, planID).
		Find(&progresses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data progress"})
		return
	}

	completed := []int{}
	for _, p := range progresses {
		completed = append(completed, p.StepOrder)
	}

	c.JSON(http.StatusOK, gin.H{"data": completed})
}

func CancelTripSession(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)
	planID := c.Query("plan_id")

	if planID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Plan ID wajib disertakan"})
		return
	}

	// Cek apakah ada session
	var count int64
	if err := config.DB.Model(&models.TripSession{}).
		Where("user_id = ? AND plan_id = ?", userID, planID).
		Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengecek sesi"})
		return
	}

	if count == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tidak ada trip session ditemukan"})
		return
	}

	// Hapus
	if err := config.DB.Delete(&models.TripSession{}, "user_id = ? AND plan_id = ?", userID, planID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus sesi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Semua trip session berhasil dibatalkan"})
}
