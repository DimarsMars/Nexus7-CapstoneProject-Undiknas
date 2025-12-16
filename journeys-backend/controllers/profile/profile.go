package profile

import (
	"be_journeys/config"
	"be_journeys/models"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var profile models.Profile
	if err := config.DB.First(&profile, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profil tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": profile})
}

func UpdateProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var profile models.Profile
	if err := config.DB.First(&profile, "user_id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profil tidak ditemukan"})
		return
	}

	fields := []string{"location", "birth_date", "description", "languages", "status", "rank"}

	for _, f := range fields {
		if val := c.PostForm(f); val != "" {
			switch f {
			case "location":
				profile.Location = val
			case "birth_date":
				profile.BirthDate = &val
			case "description":
				profile.Description = val
			case "languages":
				profile.Languages = val
			case "status":
				profile.Status = val
			case "rank":
				profile.Rank = val
			}
		}
	}

	file, err := c.FormFile("photo")
	if err == nil {
		openedFile, _ := file.Open()
		defer openedFile.Close()

		fileBytes, _ := io.ReadAll(openedFile)
		profile.Photo = fileBytes
	}

	if err := config.DB.Save(&profile).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profil berhasil diupdate",
		"data":    profile,
	})
}
