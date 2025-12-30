package models

import "time"

type PlaceReview struct {
	ReviewID  uint               `gorm:"primaryKey;column:review_id" json:"review_id"`
	UserID    uint               `gorm:"column:user_id" json:"user_id"`
	RouteID   uint               `gorm:"column:route_id" json:"route_id"`
	Rating    int                `gorm:"column:rating" json:"rating"`
	Comment   string             `gorm:"column:comment" json:"comment"`
	CreatedAt time.Time          `gorm:"column:created_at" json:"created_at"`
	Image     []PlaceReviewImage `gorm:"foreignKey:ReviewID;references:ReviewID" json:"image"`
}

type PlaceReviewImage struct {
	ImageID  uint   `gorm:"primaryKey;column:image_id" json:"image_id"`
	ReviewID uint   `gorm:"column:review_id" json:"review_id"`
	Image    []byte `gorm:"column:image" json:"image"`
}
