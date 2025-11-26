module github.com/myuser/go-hrm/services/company-service

go 1.21

require (
	github.com/gin-gonic/gin v1.9.1
	github.com/myuser/go-hrm/pkg v0.0.0
	gorm.io/gorm v1.25.5
	gorm.io/driver/mysql v1.5.2
)

replace github.com/myuser/go-hrm/pkg => ../../pkg