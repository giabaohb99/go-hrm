package model

type User struct {
	ID           uint   `gorm:"primaryKey" json:"id"`
	Email        string `gorm:"column:u_email;unique" json:"email"`
	Password     string `gorm:"column:u_password" json:"-"`
	FullName     string `gorm:"column:u_full_name" json:"full_name"`
	Status       int    `gorm:"column:status;default:1" json:"status"`
	LastLogin    int64  `gorm:"column:u_last_login" json:"last_login"`
	DateCreated  int64  `gorm:"column:datecreated" json:"date_created"`
	DateModified int64  `gorm:"column:datemodified" json:"date_modified"`
}

func (User) TableName() string {
	return "lit_user"
}
