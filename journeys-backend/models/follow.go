package models

import "time"

type Follow struct {
	ID          uint `gorm:"primaryKey;column:id" json:"follow_id"`
	FollowerID  uint `gorm:"column:follower_id" json:"follower_id"`
	FollowingID uint `gorm:"column:following_id" json:"following_id"`
	CreatedAt   time.Time
}
