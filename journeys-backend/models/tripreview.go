package models

import "time"

type TripReview struct {
	ReviewID  uint      `gorm:"primaryKey;column:review_id" json:"review_id"`
	UserID    uint      `gorm:"column:user_id" json:"user_id"`
	PlanID    uint      `gorm:"column:plan_id" json:"plan_id"`
	Rating    int       `gorm:"column:rating" json:"rating"`
	Comment   string    `gorm:"column:comment" json:"comment"`
	CreatedAt time.Time `gorm:"column:created_at" json:"created_at"`
}
