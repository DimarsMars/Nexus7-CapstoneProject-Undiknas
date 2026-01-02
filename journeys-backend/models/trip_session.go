package models

import "time"

type TripSession struct {
	SessionID uint       `gorm:"primaryKey;column:session_id" json:"session_id"`
	UserID    uint       `gorm:"column:user_id" json:"user_id"`
	PlanID    uint       `gorm:"column:plan_id" json:"plan_id"`
	RouteID   uint       `gorm:"column:route_id" json:"route_id"`
	Status    string     `gorm:"column:status" json:"status"`
	StartedAt time.Time  `gorm:"column:started_at" json:"started_at"`
	PausedAt  *time.Time `gorm:"column:paused_at" json:"paused_at"`
	EndedAt   *time.Time `gorm:"column:ended_at" json:"ended_at"`

	Plan Plan `gorm:"foreignKey:PlanID;references:PlanID"`
}
