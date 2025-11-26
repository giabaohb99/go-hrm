module user-service

go 1.21

require (
	github.com/gin-gonic/gin v1.9.1
	github.com/golang-jwt/jwt/v5 v5.2.0
	github.com/google/uuid v1.5.0
	golang.org/x/crypto v0.18.0
	github.com/myuser/go-hrm/pkg v0.0.0
	github.com/swaggo/swag v1.16.2
	github.com/swaggo/gin-swagger v1.6.0
	github.com/swaggo/files v1.0.1
)

replace github.com/myuser/go-hrm/pkg => ../../pkg
