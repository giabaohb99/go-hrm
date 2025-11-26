package main

import (
	"log"
	"os"

	"github.com/myuser/go-hrm/pkg/config"
	"github.com/myuser/go-hrm/pkg/database"
	"github.com/myuser/go-hrm/services/company-service/internal/controller"
	"github.com/myuser/go-hrm/services/company-service/internal/repository"
	"github.com/myuser/go-hrm/services/company-service/internal/router"
	"github.com/myuser/go-hrm/services/company-service/internal/service"
)

func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// Initialize database
	db, err := database.NewMySQLConnection(cfg.DBUser, cfg.DBPassword, cfg.DBHost, cfg.DBPort, cfg.DBName)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Initialize repository
	companyRepo := repository.NewCompanyRepository(db)

	// Initialize service
	companyService := service.NewCompanyService(companyRepo)

	// Initialize controller
	companyController := controller.NewCompanyController(companyService)

	// Setup router
	r := router.SetupRouter(db, companyController)

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8082" // Different port for company service
	}

	log.Printf("Company Service starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}