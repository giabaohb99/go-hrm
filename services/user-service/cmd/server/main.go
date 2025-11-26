package main

import (
	"log"
	"time"
	"user-service/internal/controller"
	"user-service/internal/repository"
	"user-service/internal/router"
	"user-service/internal/service"

	"github.com/myuser/go-hrm/pkg/config"
	"github.com/myuser/go-hrm/pkg/database"
	"gorm.io/gorm"
)

// @title User Service API
// @version 1.0
// @description User Service for Go HRM system
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8081
// @BasePath /

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	// 1. Load Config
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Printf("Warning: Could not load config: %v", err)
	}

	// Debug: Print config values (remove in production)
	log.Printf("Config loaded - DB_HOST: %s, DB_PORT: %s, DB_USER: %s, DB_NAME: %s", 
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBName)

	// 2. Connect to Database with retry
	var db *gorm.DB
	maxRetries := 10
	for i := 0; i < maxRetries; i++ {
		db, err = database.NewMySQLConnection(cfg.DBUser, cfg.DBPassword, cfg.DBHost, cfg.DBPort, cfg.DBName)
		if err == nil {
			break
		}
		log.Printf("Failed to connect to database (attempt %d/%d): %v", i+1, maxRetries, err)
		time.Sleep(time.Second * time.Duration(i+1))
	}
	if err != nil {
		log.Fatalf("Failed to connect to database after %d attempts: %v", maxRetries, err)
	}

	// 3. Initialize Components
	repo := repository.NewRepository(db)
	authService := service.NewAuthService(repo, cfg.JWTSecret)
	authController := controller.NewAuthController(authService)

	// 4. Setup Router
	r := router.SetupRouter(db, authController)

	// 5. Start Server
	log.Println("Starting user-service on :8081")
	if err := r.Run(":8081"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
