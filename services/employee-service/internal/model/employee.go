package model

type Employee struct {
	ID           uint   `gorm:"primaryKey" json:"id"`
	CompanyID    uint   `gorm:"column:c_id" json:"company_id"`
	UserID       uint   `gorm:"column:u_id" json:"user_id"`
	InternalID   string `gorm:"column:ce_internalid" json:"internal_id"`
	Email        string `gorm:"column:ce_email" json:"email"`
	Status       int    `gorm:"column:status;default:1" json:"status"`
	DateCreated  int64  `gorm:"column:datecreated" json:"date_created"`
	DateModified int64  `gorm:"column:datemodified" json:"date_modified"`
}

func (Employee) TableName() string {
	return "lit_company_employee"
}