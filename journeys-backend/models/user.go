package models

type User struct {
	UserID      uint   `gorm:"primaryKey;autoIncrement;column:user_id" json:"user_id"`
	Username    string `gorm:"column:username" json:"username"`
	Email       string `gorm:"column:email" json:"email"`
	FirebaseUID string `gorm:"column:firebase_uid" json:"firebase_uid"`
	Role        string `gorm:"column:role" json:"role"`
}
