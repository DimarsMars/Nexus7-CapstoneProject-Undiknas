package models

import (
	"time"

	"github.com/lib/pq"
)

type Plan struct {
	PlanID      uint           `gorm:"primaryKey;column:plan_id" json:"plan_id"`
	UserID      uint           `gorm:"column:user_id" json:"user_id"`
	Title       string         `gorm:"column:title" json:"title"`
	Description string         `gorm:"column:description" json:"description"`
	Banner      []byte         `gorm:"column:banner" json:"banner"`
	Tags        pq.StringArray `gorm:"type:text[];column:tags" json:"tags"`
	CreatedAt   time.Time      `gorm:"column:created_at" json:"created_at"`
	Categories  []Category     `gorm:"many2many:plan_categories;joinForeignKey:PlanID;joinReferences:CategoryID" json:"categories"`
	Status      string         `gorm:"column:status" json:"status"`
}
