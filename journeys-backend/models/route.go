package models

import "github.com/lib/pq"

type Route struct {
	RouteID     uint           `gorm:"primaryKey;column:route_id" json:"route_id"`
	PlanID      uint           `gorm:"column:plan_id" json:"plan_id"`
	Title       string         `gorm:"column:title" json:"title"`
	Address     string         `gorm:"column:address" json:"address"`
	Description string         `gorm:"column:description" json:"description"`
	Image       []byte         `gorm:"column:image" json:"image"`
	Latitude    float64        `gorm:"column:latitude" json:"latitude"`
	Longitude   float64        `gorm:"column:longitude" json:"longitude"`
	Tags        pq.StringArray `gorm:"type:text[];column:tags" json:"tags"`
	StepOrder   int            `gorm:"column:step_order" json:"step_order"`
}
