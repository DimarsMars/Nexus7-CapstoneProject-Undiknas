package models

type Category struct {
	CategoryID uint   `gorm:"primaryKey;column:category_id" json:"category_id"`
	Name       string `gorm:"column:name" json:"name"`
	Image      []byte `gorm:"column:image" json:"image"`
}
