package main

import (
	"log"
	"os"

	"github.com/myuser/go-hrm/pkg/config"
	"github.com/myuser/go-hrm/pkg/database"
	"github.com/myuser/go-hrm/services/employee-service/internal/controller"
	"github.com/myuser/go-hrm/services/employee-service/internal/repository"
	"github.com/myuser/go-hrm/services/employee-service/internal/router"
	"github.com/myuser/go-hrm/services/employee-service/internal/service"
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
	employeeRepo := repository.NewEmployeeRepository(db)

	// Initialize service
	employeeService := service.NewEmployeeService(employeeRepo)

	// Initialize controller
	employeeController := controller.NewEmployeeController(employeeService)

	// Setup router
	r := router.SetupRouter(db, employeeController)

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083" // Different port for employee service
	}

	log.Printf("Employee Service starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}