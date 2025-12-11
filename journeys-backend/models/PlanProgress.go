package models

import (
	"time"
)

type PlanProgress struct {
	ProgressID uint      `gorm:"primaryKey" json:"progress_id"`
	UserID     uint      `gorm:"column:user_id" json:"user_id"`
	PlanID     uint      `gorm:"column:plan_id" json:"plan_id"`
	StepOrder  int       `gorm:"column:step_order" json:"step_order"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`
}
