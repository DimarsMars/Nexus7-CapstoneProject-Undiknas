package models

import "time"

type Follow struct {
	ID          uint `gorm:"primaryKey;column:id" json:"follow_id"`
	FollowerID  uint `gorm:"primaryKey;column:follower_id" json:"follower_id"`
	FollowingID uint `gorm:"primaryKey;column:following_id" json:"following_id"`
	CreatedAt   time.Time
}
