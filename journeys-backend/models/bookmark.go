package models

import "time"

type Bookmark struct {
	BookmarkID uint      `gorm:"primaryKey;column:bookmark_id" json:"bookmark_id"`
	UserID     uint      `gorm:"column:user_id" json:"user_id"`
	RouteID    uint      `gorm:"column:route_id" json:"route_id"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`

	Route Route `gorm:"foreignKey:RouteID;references:RouteID" json:"route"`
}
