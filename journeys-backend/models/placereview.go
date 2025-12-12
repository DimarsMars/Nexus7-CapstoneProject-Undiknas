package models

import "time"

type PlaceReview struct {
	ReviewID  uint      `gorm:"primaryKey;column:review_id" json:"review_id"`
	UserID    uint      `gorm:"column:user_id" json:"user_id"`
	RouteID   uint      `gorm:"column:route_id" json:"route_id"`
	Rating    int       `gorm:"column:rating" json:"rating"`
	Comment   string    `gorm:"column:comment" json:"comment"`
	Image     []byte    `gorm:"column:image" json:"image"`
	CreatedAt time.Time `gorm:"column:created_at" json:"created_at"`
}
