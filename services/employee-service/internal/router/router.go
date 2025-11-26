package router

import (
	"github.com/gin-gonic/gin"
	"github.com/myuser/go-hrm/pkg/middleware"
	"github.com/myuser/go-hrm/services/employee-service/internal/controller"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB, employeeController *controller.EmployeeController) *gin.Engine {
	r := gin.Default()

	// Global middleware
	r.Use(middleware.RequestLogger())
	r.Use(middleware.APILogger(db))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "employee-service"})
	})

	// API routes
	api := r.Group("/api/v1")
	{
		employees := api.Group("/employees")
		{
			employees.POST("", employeeController.CreateEmployee)
			employees.GET("/:id", employeeController.GetEmployee)
			employees.PUT("/:id", employeeController.UpdateEmployee)
			employees.DELETE("/:id", employeeController.DeleteEmployee)
		}

		// Additional routes
		api.GET("/users/:userId/employee", employeeController.GetEmployeeByUser)
		api.GET("/companies/:companyId/employees", employeeController.GetEmployeesByCompany)
	}

	return r
}