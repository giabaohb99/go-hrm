package repository

import (
	"github.com/myuser/go-hrm/services/employee-service/internal/model"
	"gorm.io/gorm"
)

type EmployeeRepository interface {
	Create(employee *model.Employee) error
	GetByID(id uint) (*model.Employee, error)
	GetByUserID(userID uint) (*model.Employee, error)
	GetByCompanyID(companyID uint, offset, limit int) ([]*model.Employee, error)
	GetByEmail(email string) (*model.Employee, error)
	Update(employee *model.Employee) error
	Delete(id uint) error
}

type employeeRepository struct {
	db *gorm.DB
}

func NewEmployeeRepository(db *gorm.DB) EmployeeRepository {
	return &employeeRepository{db: db}
}

func (r *employeeRepository) Create(employee *model.Employee) error {
	return r.db.Create(employee).Error
}

func (r *employeeRepository) GetByID(id uint) (*model.Employee, error) {
	var employee model.Employee
	err := r.db.Where("id = ? AND status = 1", id).First(&employee).Error
	if err != nil {
		return nil, err
	}
	return &employee, nil
}

func (r *employeeRepository) GetByUserID(userID uint) (*model.Employee, error) {
	var employee model.Employee
	err := r.db.Where("u_id = ? AND status = 1", userID).First(&employee).Error
	if err != nil {
		return nil, err
	}
	return &employee, nil
}

func (r *employeeRepository) GetByCompanyID(companyID uint, offset, limit int) ([]*model.Employee, error) {
	var employees []*model.Employee
	err := r.db.Where("c_id = ? AND status = 1", companyID).
		Offset(offset).Limit(limit).Find(&employees).Error
	return employees, err
}

func (r *employeeRepository) GetByEmail(email string) (*model.Employee, error) {
	var employee model.Employee
	err := r.db.Where("ce_email = ? AND status = 1", email).First(&employee).Error
	if err != nil {
		return nil, err
	}
	return &employee, nil
}

func (r *employeeRepository) Update(employee *model.Employee) error {
	return r.db.Save(employee).Error
}

func (r *employeeRepository) Delete(id uint) error {
	return r.db.Model(&model.Employee{}).Where("id = ?", id).Update("status", 0).Error
}