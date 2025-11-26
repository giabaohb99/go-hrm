package dto

type CreateCompanyRequest struct {
	Domain  string `json:"domain" binding:"required"`
	Name    string `json:"name" binding:"required"`
	OwnerID uint   `json:"owner_id" binding:"required"`
}

type UpdateCompanyRequest struct {
	Name   string `json:"name"`
	Status int    `json:"status"`
}

type CompanyResponse struct {
	ID          uint   `json:"id"`
	Domain      string `json:"domain"`
	Name        string `json:"name"`
	OwnerID     uint   `json:"owner_id"`
	Status      int    `json:"status"`
	DateCreated int64  `json:"date_created"`
}