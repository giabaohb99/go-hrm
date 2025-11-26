package router

import (
	"github.com/gin-gonic/gin"
	"github.com/myuser/go-hrm/pkg/middleware"
	"github.com/myuser/go-hrm/services/company-service/internal/controller"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB, companyController *controller.CompanyController) *gin.Engine {
	r := gin.Default()

	// Global middleware
	r.Use(middleware.RequestLogger())
	r.Use(middleware.APILogger(db))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "company-service"})
	})

	// API routes
	api := r.Group("/api/v1")
	{
		companies := api.Group("/companies")
		{
			companies.POST("", companyController.CreateCompany)
			companies.GET("", companyController.ListCompanies) // List all companies or filter by domain
			companies.GET("/:id", companyController.GetCompany)
			companies.PUT("/:id", companyController.UpdateCompany)
			companies.DELETE("/:id", companyController.DeleteCompany)
		}
	}

	return r
}