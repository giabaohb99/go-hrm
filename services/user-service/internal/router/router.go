package router

import (
	"user-service/internal/controller"

	"github.com/gin-gonic/gin"
	"github.com/myuser/go-hrm/pkg/middleware"
	"gorm.io/gorm"
	
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(db *gorm.DB, authController *controller.AuthController) *gin.Engine {
	r := gin.Default()

	// Global middleware
	r.Use(middleware.RequestLogger())
	r.Use(middleware.APILogger(db))

	// Swagger documentation
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "user-service"})
	})

	// API routes
	api := r.Group("/api/v1")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/login", authController.Login)
			auth.POST("/logout", authController.Logout)
			auth.POST("/refresh", authController.RefreshToken)
		}

		users := api.Group("/users")
		{
			users.POST("", authController.Register)
			users.GET("/profile", authController.GetProfile)
			users.PUT("/profile", authController.UpdateProfile)
		}
	}

	return r
}
