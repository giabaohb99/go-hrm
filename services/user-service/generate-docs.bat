@echo off

REM Install swag if not exists
where swag >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing swag...
    go install github.com/swaggo/swag/cmd/swag@latest
)

REM Generate swagger docs
echo Generating Swagger documentation...
swag init -g cmd/server/main.go -o docs

echo Swagger docs generated successfully!
echo Access docs at: http://localhost:8081/swagger/index.html