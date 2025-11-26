package dto

type CreateEmployeeRequest struct {
	CompanyID  uint   `json:"company_id" binding:"required"`
	UserID     uint   `json:"user_id" binding:"required"`
	InternalID string `json:"internal_id"`
	Email      string `json:"email" binding:"required,email"`
}

type UpdateEmployeeRequest struct {
	InternalID string `json:"internal_id"`
	Email      string `json:"email"`
	Status     int    `json:"status"`
}

type EmployeeResponse struct {
	ID           uint   `json:"id"`
	CompanyID    uint   `json:"company_id"`
	UserID       uint   `json:"user_id"`
	InternalID   string `json:"internal_id"`
	Email        string `json:"email"`
	Status       int    `json:"status"`
	DateCreated  int64  `json:"date_created"`
}