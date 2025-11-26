package model

type Company struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Domain      string `gorm:"column:c_domain;unique" json:"domain"`
	Name        string `gorm:"column:c_name" json:"name"`
	OwnerID     uint   `gorm:"column:c_owner_id" json:"owner_id"`
	Status      int    `gorm:"column:status;default:1" json:"status"`
	DateCreated int64  `gorm:"column:datecreated" json:"date_created"`
	DateModified int64 `gorm:"column:datemodified" json:"date_modified"`
}

func (Company) TableName() string {
	return "lit_company"
}