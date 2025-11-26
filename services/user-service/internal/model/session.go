package model

type UserSession struct {
	ID              uint   `gorm:"primaryKey" json:"id"`
	UserID          uint   `gorm:"column:us_user_id" json:"user_id"`
	Token           string `gorm:"column:us_token" json:"token"`
	RefreshToken    string `gorm:"column:us_refresh_token" json:"refresh_token"`
	ExpiresAt       int64  `gorm:"column:us_expires_at" json:"expires_at"`
	IPAddress       string `gorm:"column:us_ip_address" json:"ip_address"`
	UserAgent       string `gorm:"column:us_user_agent" json:"user_agent"`
	Platform        string `gorm:"column:us_device_type" json:"platform"`
	PlatformVersion string `gorm:"column:us_os" json:"platform_version"`
	Status          int    `gorm:"column:status;default:1" json:"status"`
	DateCreated     int64  `gorm:"column:datecreated" json:"date_created"`
}

func (UserSession) TableName() string {
	return "lit_user_session"
}
