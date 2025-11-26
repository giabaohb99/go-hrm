package repository

import (
	"github.com/myuser/go-hrm/services/company-service/internal/model"
	"gorm.io/gorm"
)

type CompanyRepository interface {
	Create(company *model.Company) error
	GetByID(id uint) (*model.Company, error)
	GetByDomain(domain string) (*model.Company, error)
	Update(company *model.Company) error
	Delete(id uint) error
	List(offset, limit int) ([]*model.Company, error)
}

type companyRepository struct {
	db *gorm.DB
}

func NewCompanyRepository(db *gorm.DB) CompanyRepository {
	return &companyRepository{db: db}
}

func (r *companyRepository) Create(company *model.Company) error {
	return r.db.Create(company).Error
}

func (r *companyRepository) GetByID(id uint) (*model.Company, error) {
	var company model.Company
	err := r.db.Where("id = ? AND status = 1", id).First(&company).Error
	if err != nil {
		return nil, err
	}
	return &company, nil
}

func (r *companyRepository) GetByDomain(domain string) (*model.Company, error) {
	var company model.Company
	err := r.db.Where("c_domain = ? AND status = 1", domain).First(&company).Error
	if err != nil {
		return nil, err
	}
	return &company, nil
}

func (r *companyRepository) Update(company *model.Company) error {
	return r.db.Save(company).Error
}

func (r *companyRepository) Delete(id uint) error {
	return r.db.Model(&model.Company{}).Where("id = ?", id).Update("status", 0).Error
}

func (r *companyRepository) List(offset, limit int) ([]*model.Company, error) {
	var companies []*model.Company
	err := r.db.Where("status = 1").Offset(offset).Limit(limit).Find(&companies).Error
	return companies, err
}