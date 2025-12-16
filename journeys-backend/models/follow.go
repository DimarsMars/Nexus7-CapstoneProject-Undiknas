package models

import "time"

type Follow struct {
	FollowerID  uint `gorm:"primaryKey;column:follower_id" json:"follower_id"`
	FollowingID uint `gorm:"primaryKey;column:following_id" json:"following_id"`
	CreatedAt   time.Time
}
