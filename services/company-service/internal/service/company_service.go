package service

import (
	"time"

	"github.com/myuser/go-hrm/services/company-service/internal/dto"
	"github.com/myuser/go-hrm/services/company-service/internal/model"
	"github.com/myuser/go-hrm/services/company-service/internal/repository"
)

type CompanyService interface {
	CreateCompany(req *dto.CreateCompanyRequest) (*dto.CompanyResponse, error)
	GetCompany(id uint) (*dto.CompanyResponse, error)
	GetCompanyByDomain(domain string) (*dto.CompanyResponse, error)
	UpdateCompany(id uint, req *dto.UpdateCompanyRequest) (*dto.CompanyResponse, error)
	DeleteCompany(id uint) error
	ListCompanies(page, limit int) ([]*dto.CompanyResponse, error)
}

type companyService struct {
	repo repository.CompanyRepository
}

func NewCompanyService(repo repository.CompanyRepository) CompanyService {
	return &companyService{repo: repo}
}

func (s *companyService) CreateCompany(req *dto.CreateCompanyRequest) (*dto.CompanyResponse, error) {
	now := time.Now().Unix()
	company := &model.Company{
		Domain:       req.Domain,
		Name:         req.Name,
		OwnerID:      req.OwnerID,
		Status:       1,
		DateCreated:  now,
		DateModified: now,
	}

	if err := s.repo.Create(company); err != nil {
		return nil, err
	}

	return s.toResponse(company), nil
}

func (s *companyService) GetCompany(id uint) (*dto.CompanyResponse, error) {
	company, err := s.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toResponse(company), nil
}

func (s *companyService) GetCompanyByDomain(domain string) (*dto.CompanyResponse, error) {
	company, err := s.repo.GetByDomain(domain)
	if err != nil {
		return nil, err
	}
	return s.toResponse(company), nil
}

func (s *companyService) UpdateCompany(id uint, req *dto.UpdateCompanyRequest) (*dto.CompanyResponse, error) {
	company, err := s.repo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		company.Name = req.Name
	}
	if req.Status != 0 {
		company.Status = req.Status
	}
	company.DateModified = time.Now().Unix()

	if err := s.repo.Update(company); err != nil {
		return nil, err
	}

	return s.toResponse(company), nil
}

func (s *companyService) DeleteCompany(id uint) error {
	return s.repo.Delete(id)
}

func (s *companyService) ListCompanies(page, limit int) ([]*dto.CompanyResponse, error) {
	offset := (page - 1) * limit
	companies, err := s.repo.List(offset, limit)
	if err != nil {
		return nil, err
	}

	responses := make([]*dto.CompanyResponse, len(companies))
	for i, company := range companies {
		responses[i] = s.toResponse(company)
	}

	return responses, nil
}

func (s *companyService) toResponse(company *model.Company) *dto.CompanyResponse {
	return &dto.CompanyResponse{
		ID:          company.ID,
		Domain:      company.Domain,
		Name:        company.Name,
		OwnerID:     company.OwnerID,
		Status:      company.Status,
		DateCreated: company.DateCreated,
	}
}