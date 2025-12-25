package models

import "time"

type Favorite struct {
	FavoriteID uint      `gorm:"primaryKey;column:favorite_id" json:"favorite_id"`
	UserID     uint      `gorm:"column:user_id" json:"user_id"`
	PlanID     uint      `gorm:"column:plan_id" json:"plan_id"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`

	Plan Plan `gorm:"foreignKey:PlanID;references:PlanID" json:"plan"`
}
