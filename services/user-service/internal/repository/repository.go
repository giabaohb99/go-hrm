package repository

import (
	"user-service/internal/model"
	"gorm.io/gorm"
)

type Repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// Temporary models for cross-service data access
type Company struct {
	ID       uint   `gorm:"primaryKey"`
	Domain   string `gorm:"column:c_domain"`
	Name     string `gorm:"column:c_name"`
	OwnerID  uint   `gorm:"column:c_owner_id"`
	Status   int    `gorm:"column:status"`
}

func (Company) TableName() string {
	return "lit_company"
}

type Employee struct {
	ID         uint   `gorm:"primaryKey"`
	CompanyID  uint   `gorm:"column:c_id"`
	UserID     uint   `gorm:"column:u_id"`
	InternalID string `gorm:"column:ce_internalid"`
	Email      string `gorm:"column:ce_email"`
	Status     int    `gorm:"column:status"`
}

func (Employee) TableName() string {
	return "lit_company_employee"
}

func (r *Repository) GetCompanyByHostname(hostname string) (*Company, error) {
	var company Company
	// Assuming hostname maps to c_domain
	if err := r.db.Where("c_domain = ?", hostname).First(&company).Error; err != nil {
		return nil, err
	}
	return &company, nil
}

func (r *Repository) GetEmployeeByEmailOrInternalID(companyID uint, identifier string) (*Employee, error) {
	var employee Employee
	if err := r.db.Where("c_id = ? AND (ce_email = ? OR ce_internalid = ?)", companyID, identifier, identifier).First(&employee).Error; err != nil {
		return nil, err
	}
	return &employee, nil
}

func (r *Repository) GetUserByID(userID uint) (*model.User, error) {
	var user model.User
	if err := r.db.First(&user, userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *Repository) CreateUserSession(session *model.UserSession) error {
	return r.db.Create(session).Error
}

func (r *Repository) UpdateUserLastLogin(userID uint, timestamp int64) error {
	return r.db.Model(&model.User{}).Where("id = ?", userID).Update("u_last_login", timestamp).Error
}

func (r *Repository) UpdateUserSessionTokens(userID uint, token, refreshToken string) error {
	return r.db.Model(&model.UserSession{}).
		Where("us_user_id = ? AND status = 1", userID).
		Updates(map[string]interface{}{
			"us_token":         token,
			"us_refresh_token": refreshToken,
		}).Error
}

func (r *Repository) DeactivateUserSessions(userID uint) error {
	return r.db.Model(&model.UserSession{}).
		Where("us_user_id = ?", userID).
		Update("status", 0).Error
}
