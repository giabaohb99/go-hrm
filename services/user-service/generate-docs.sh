#!/bin/bash

# Install swag if not exists
if ! command -v swag &> /dev/null; then
    echo "Installing swag..."
    go install github.com/swaggo/swag/cmd/swag@latest
fi

# Generate swagger docs
echo "Generating Swagger documentation..."
swag init -g cmd/server/main.go -o docs

echo "Swagger docs generated successfully!"
echo "Access docs at: http://localhost:8081/swagger/index.html"