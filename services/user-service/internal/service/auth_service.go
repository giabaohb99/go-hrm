package service

import (
	"errors"
	"log"
	"time"
	"user-service/internal/dto"
	"user-service/internal/model"
	"user-service/internal/repository"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	repo      *repository.Repository
	jwtSecret string
}

func NewAuthService(repo *repository.Repository, jwtSecret string) *AuthService {
	return &AuthService{repo: repo, jwtSecret: jwtSecret}
}

func (s *AuthService) Login(req dto.LoginRequest, ipAddress, userAgent string) (*dto.LoginResponse, error) {
	log.Printf("[LOGIN] Starting login for email: %s, hostname: %s", req.Email, req.Hostname)
	
	// 1. Get Company
	company, err := s.repo.GetCompanyByHostname(req.Hostname)
	if err != nil {
		log.Printf("[LOGIN] Company not found for hostname: %s, error: %v", req.Hostname, err)
		return nil, errors.New("company not found")
	}
	log.Printf("[LOGIN] Found company: ID=%d, Name=%s", company.ID, company.Name)

	// 2. Get Employee
	identifier := req.Email
	if req.InternalID != "" {
		identifier = req.InternalID
	}
	employee, err := s.repo.GetEmployeeByEmailOrInternalID(company.ID, identifier)
	if err != nil {
		log.Printf("[LOGIN] Employee not found for identifier: %s, company: %d, error: %v", identifier, company.ID, err)
		return nil, errors.New("employee not found")
	}
	log.Printf("[LOGIN] Found employee: ID=%d, UserID=%d", employee.ID, employee.UserID)

	// 3. Get User
	user, err := s.repo.GetUserByID(employee.UserID)
	if err != nil {
		log.Printf("[LOGIN] User not found for ID: %d, error: %v", employee.UserID, err)
		return nil, errors.New("user account not found")
	}
	log.Printf("[LOGIN] Found user: ID=%d, Email=%s, PasswordHash=%s", user.ID, user.Email, user.Password[:20]+"...")

	// 4. Verify Password
	log.Printf("[LOGIN] Verifying password for user: %d", user.ID)
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		log.Printf("[LOGIN] Password verification failed: %v", err)
		return nil, errors.New("invalid password")
	}
	log.Printf("[LOGIN] Password verified successfully")

	// 5. Generate JWT (Access Token)
	expiresAt := time.Now().Add(24 * time.Hour) // 1 day for access token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss": "cropany",
		"aud": "cropany",
		"iat": time.Now().Unix(),
		"exp": expiresAt.Unix(),
		"data": map[string]interface{}{
			"user": map[string]interface{}{
				"id": user.ID,
				"company_id": company.ID,
				"employee_id": employee.ID,
			},
		},
	})
	
	tokenString, err := token.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return nil, err
	}

	// 6. Generate Refresh Token (longer expiry)
	refreshExpiresAt := time.Now().Add(30 * 24 * time.Hour) // 30 days for refresh token
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss": "cropany",
		"aud": "cropany-refresh",
		"iat": time.Now().Unix(),
		"exp": refreshExpiresAt.Unix(),
		"type": "refresh",
		"data": map[string]interface{}{
			"user_id": user.ID,
			"company_id": company.ID,
			"employee_id": employee.ID,
		},
	})
	
	refreshTokenString, err := refreshToken.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return nil, err
	}

	// 7. Create Session

	session := &model.UserSession{
		UserID:          user.ID,
		Token:           tokenString, 
		RefreshToken:    refreshTokenString,
		ExpiresAt:       expiresAt.Unix(),
		IPAddress:       ipAddress,
		UserAgent:       userAgent,
		Platform:        req.Platform,
		PlatformVersion: req.Version,
		Status:          1,
		DateCreated:     time.Now().Unix(),
	}

	if err := s.repo.CreateUserSession(session); err != nil {
		return nil, err
	}

	// 8. Update Last Login
	s.repo.UpdateUserLastLogin(user.ID, time.Now().Unix())

	// 9. Prepare Response
	return &dto.LoginResponse{
		JWT:          tokenString, // Return full JWT token, not hash
		RefreshToken: refreshTokenString,
		ExpiresAt:    expiresAt.Unix(),
		User: dto.UserDTO{
			ID:            user.ID,
			FullName:      user.FullName,
			Email:         user.Email,
			Status:        user.Status,
			DateLastLogin: user.LastLogin,
		},
		Company: dto.CompanyDTO{
			ID:     company.ID,
			Name:   company.Name,
			Domain: company.Domain,
			Owner:  company.OwnerID,
			Status: company.Status,
		},
		Employee: dto.EmployeeDTO{
			ID:         employee.ID,
			InternalID: employee.InternalID,
			Email:      employee.Email,
			Status:     employee.Status,
		},
		Role: "210:,220:1-10", // Mock role for now
	}, nil
}
func (s *AuthService) RefreshToken(req dto.RefreshTokenRequest) (*dto.RefreshTokenResponse, error) {
	// Parse and validate refresh token
	token, err := jwt.Parse(req.RefreshToken, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.jwtSecret), nil
	})
	
	if err != nil || !token.Valid {
		return nil, errors.New("invalid refresh token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, errors.New("invalid token claims")
	}

	// Check if it's a refresh token
	if tokenType, exists := claims["type"]; !exists || tokenType != "refresh" {
		return nil, errors.New("not a refresh token")
	}

	// Extract user data
	data, ok := claims["data"].(map[string]interface{})
	if !ok {
		return nil, errors.New("invalid token data")
	}

	userID := uint(data["user_id"].(float64))
	companyID := uint(data["company_id"].(float64))
	employeeID := uint(data["employee_id"].(float64))

	// Generate new access token
	expiresAt := time.Now().Add(24 * time.Hour)
	newToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss": "cropany",
		"aud": "cropany",
		"iat": time.Now().Unix(),
		"exp": expiresAt.Unix(),
		"data": map[string]interface{}{
			"user": map[string]interface{}{
				"id": userID,
				"company_id": companyID,
				"employee_id": employeeID,
			},
		},
	})

	newTokenString, err := newToken.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return nil, err
	}

	// Generate new refresh token
	refreshExpiresAt := time.Now().Add(30 * 24 * time.Hour)
	newRefreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss": "cropany",
		"aud": "cropany-refresh",
		"iat": time.Now().Unix(),
		"exp": refreshExpiresAt.Unix(),
		"type": "refresh",
		"data": map[string]interface{}{
			"user_id": userID,
			"company_id": companyID,
			"employee_id": employeeID,
		},
	})

	newRefreshTokenString, err := newRefreshToken.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return nil, err
	}

	// Update session with new tokens
	if err := s.repo.UpdateUserSessionTokens(userID, newTokenString, newRefreshTokenString); err != nil {
		return nil, err
	}

	return &dto.RefreshTokenResponse{
		JWT:          newTokenString, // Return full JWT token, not hash
		RefreshToken: newRefreshTokenString,
		ExpiresAt:    expiresAt.Unix(),
	}, nil
}

func (s *AuthService) Logout(userID uint) error {
	return s.repo.DeactivateUserSessions(userID)
}