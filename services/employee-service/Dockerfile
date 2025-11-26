FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy pkg directory
COPY pkg ./pkg

# Copy service files
COPY services/employee-service ./services/employee-service

# Set working directory to service
WORKDIR /app/services/employee-service

# Download dependencies
RUN go mod tidy
RUN go mod download

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/services/employee-service/main .

# Expose port
EXPOSE 8083

# Run the binary
CMD ["./main"]