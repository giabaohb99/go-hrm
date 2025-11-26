package dto

// LoginRequest represents the login request payload
type LoginRequest struct {
	Email      string `json:"email" binding:"required" example:"admin@gmail.com"`
	Password   string `json:"password" binding:"required" example:"admin123"`
	Hostname   string `json:"hostname" binding:"required" example:"local.localhost"`
	Platform   string `json:"platform" binding:"required" example:"web"`
	Version    string `json:"version" binding:"required" example:"1.0.0"`
	InternalID string `json:"internalid,omitempty"` // Optional
}

// LoginResponse represents the login response payload
type LoginResponse struct {
	JWT          string      `json:"jwt" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	RefreshToken string      `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	ExpiresAt    int64       `json:"expires_at" example:"1640995200"`
	User         UserDTO     `json:"user"`
	Company      CompanyDTO  `json:"company"`
	Employee     EmployeeDTO `json:"employee"`
	Role         string      `json:"role" example:"210:,220:1-10"`
}

type UserDTO struct {
	ID            uint   `json:"id"`
	FullName      string `json:"fullname"`
	Email         string `json:"email"`
	Status        int    `json:"status"`
	DateLastLogin int64  `json:"datelastlogin"`
}

type CompanyDTO struct {
	ID     uint   `json:"id"`
	Name   string `json:"name"`
	Domain string `json:"domain"`
	Owner  uint   `json:"owner"`
	Status int    `json:"status"`
}

type EmployeeDTO struct {
	ID         uint   `json:"id"`
	InternalID string `json:"internal_id"`
	Email      string `json:"email"`
	Status     int    `json:"status"`
}
// RefreshTokenRequest represents the refresh token request payload
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

// RefreshTokenResponse represents the refresh token response payload
type RefreshTokenResponse struct {
	JWT          string `json:"jwt" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	ExpiresAt    int64  `json:"expires_at" example:"1640995200"`
}