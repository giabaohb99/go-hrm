package service

import (
	"time"

	"github.com/myuser/go-hrm/services/employee-service/internal/dto"
	"github.com/myuser/go-hrm/services/employee-service/internal/model"
	"github.com/myuser/go-hrm/services/employee-service/internal/repository"
)

type EmployeeService interface {
	CreateEmployee(req *dto.CreateEmployeeRequest) (*dto.EmployeeResponse, error)
	GetEmployee(id uint) (*dto.EmployeeResponse, error)
	GetEmployeeByUserID(userID uint) (*dto.EmployeeResponse, error)
	GetEmployeesByCompany(companyID uint, page, limit int) ([]*dto.EmployeeResponse, error)
	UpdateEmployee(id uint, req *dto.UpdateEmployeeRequest) (*dto.EmployeeResponse, error)
	DeleteEmployee(id uint) error
}

type employeeService struct {
	repo repository.EmployeeRepository
}

func NewEmployeeService(repo repository.EmployeeRepository) EmployeeService {
	return &employeeService{repo: repo}
}

func (s *employeeService) CreateEmployee(req *dto.CreateEmployeeRequest) (*dto.EmployeeResponse, error) {
	now := time.Now().Unix()
	employee := &model.Employee{
		CompanyID:    req.CompanyID,
		UserID:       req.UserID,
		InternalID:   req.InternalID,
		Email:        req.Email,
		Status:       1,
		DateCreated:  now,
		DateModified: now,
	}

	if err := s.repo.Create(employee); err != nil {
		return nil, err
	}

	return s.toResponse(employee), nil
}

func (s *employeeService) GetEmployee(id uint) (*dto.EmployeeResponse, error) {
	employee, err := s.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return s.toResponse(employee), nil
}

func (s *employeeService) GetEmployeeByUserID(userID uint) (*dto.EmployeeResponse, error) {
	employee, err := s.repo.GetByUserID(userID)
	if err != nil {
		return nil, err
	}
	return s.toResponse(employee), nil
}

func (s *employeeService) GetEmployeesByCompany(companyID uint, page, limit int) ([]*dto.EmployeeResponse, error) {
	offset := (page - 1) * limit
	employees, err := s.repo.GetByCompanyID(companyID, offset, limit)
	if err != nil {
		return nil, err
	}

	responses := make([]*dto.EmployeeResponse, len(employees))
	for i, employee := range employees {
		responses[i] = s.toResponse(employee)
	}

	return responses, nil
}

func (s *employeeService) UpdateEmployee(id uint, req *dto.UpdateEmployeeRequest) (*dto.EmployeeResponse, error) {
	employee, err := s.repo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if req.InternalID != "" {
		employee.InternalID = req.InternalID
	}
	if req.Email != "" {
		employee.Email = req.Email
	}
	if req.Status != 0 {
		employee.Status = req.Status
	}
	employee.DateModified = time.Now().Unix()

	if err := s.repo.Update(employee); err != nil {
		return nil, err
	}

	return s.toResponse(employee), nil
}

func (s *employeeService) DeleteEmployee(id uint) error {
	return s.repo.Delete(id)
}

func (s *employeeService) toResponse(employee *model.Employee) *dto.EmployeeResponse {
	return &dto.EmployeeResponse{
		ID:          employee.ID,
		CompanyID:   employee.CompanyID,
		UserID:      employee.UserID,
		InternalID:  employee.InternalID,
		Email:       employee.Email,
		Status:      employee.Status,
		DateCreated: employee.DateCreated,
	}
}