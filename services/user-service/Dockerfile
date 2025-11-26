FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy pkg directory
COPY pkg ./pkg

# Copy service files
COPY services/user-service ./services/user-service

# Set working directory to service
WORKDIR /app/services/user-service

# Download dependencies
RUN go mod tidy
RUN go mod download

# Install swag for generating docs
RUN go install github.com/swaggo/swag/cmd/swag@latest

# Generate swagger docs
RUN swag init -g cmd/server/main.go -o docs

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/server/main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/services/user-service/main .

# Expose port
EXPOSE 8081

# Run the binary
CMD ["./main"]
