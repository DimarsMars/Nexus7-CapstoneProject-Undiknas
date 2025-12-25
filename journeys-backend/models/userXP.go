package models

import "time"

type UserXP struct {
	XPID        uint      `gorm:"primaryKey;column:xp_id" json:"xp_id"`
	UserID      uint      `gorm:"column:user_id" json:"user_id"`
	XPValue     int       `gorm:"column:xp_value" json:"xp_value"`
	Description string    `gorm:"column:description" json:"description"`
	CreatedAt   time.Time `gorm:"column:created_at" json:"created_at"`
}
