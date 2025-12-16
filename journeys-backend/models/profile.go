package models

type Profile struct {
	ProfileID   uint    `gorm:"primaryKey;column:profile_id" json:"profile_id"`
	UserID      uint    `gorm:"column:user_id" json:"user_id"`
	Photo       []byte  `gorm:"column:photo" json:"photo"`
	Location    string  `gorm:"column:location" json:"location"`
	BirthDate   *string `gorm:"column:birth_date" json:"birth_date"`
	Description string  `gorm:"column:description" json:"description"`
	Languages   string  `gorm:"column:languages" json:"languages"`
	Status      string  `gorm:"column:status" json:"status"`
	Rank        string  `gorm:"column:rank" json:"rank"`
	Followers   int     `gorm:"column:followers" json:"followers"`
	Following   int     `gorm:"column:following" json:"following"`
}
