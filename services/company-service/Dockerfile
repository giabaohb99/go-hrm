FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy pkg directory
COPY pkg ./pkg

# Copy service files
COPY services/company-service ./services/company-service

# Set working directory to service
WORKDIR /app/services/company-service

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
COPY --from=builder /app/services/company-service/main .

# Expose port
EXPOSE 8082

# Run the binary
CMD ["./main"]