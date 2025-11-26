# Environment Configuration Guide

## 📋 Overview

Go HRM service sử dụng **environment variables** để cấu hình thay vì hardcode values trong code hoặc docker-compose.yml. Điều này giúp:

- ✅ **Bảo mật hơn**: Sensitive data không bị commit vào Git
- ✅ **Linh hoạt hơn**: Dễ dàng thay đổi config cho từng môi trường
- ✅ **Rõ ràng hơn**: Tất cả config ở một chỗ

---

## 🔧 Environment Files

### 1. `.env.docker.example` - For Docker

Sử dụng khi chạy với Docker Compose:

```env
DB_HOST=mysql          # Docker service name
REDIS_HOST=redis       # Docker service name
SDK_USER_URL=http://cp-user:8082  # Internal Docker network
```

**Setup:**
```bash
# Copy file
cp .env.docker.example .env

# Start Docker
docker-compose up -d
```

### 2. `.env.local.example` - For Local Development

Sử dụng khi chạy local (không dùng Docker):

```env
DB_HOST=localhost      # Local MySQL
REDIS_HOST=localhost   # Local Redis
SDK_USER_URL=http://localhost:8082  # Local services
```

**Setup:**
```bash
# Copy file
cp .env.local.example .env

# Run locally
make dev
# or
go run ./src
```

### 3. `.env.example` - Generic Template

Template chung, có thể dùng cho cả Docker và Local.

---

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# 1. Copy Docker env file
cp .env.docker.example .env

# 2. Edit if needed
nano .env

# 3. Start services
docker-compose up -d

# 4. Check logs
docker-compose logs -f go-hrm
```

### Option 2: Local Development

```bash
# 1. Copy local env file
cp .env.local.example .env

# 2. Make sure MySQL & Redis are running locally
# MySQL: localhost:3306
# Redis: localhost:6379

# 3. Edit .env if needed
nano .env

# 4. Run application
make dev
```

---

## 📝 Environment Variables Explained

### Database Configuration

```env
DB_HOST=mysql          # Database host (mysql for Docker, localhost for local)
DB_PORT=3306           # Database port
DB_NAME=nperp_general_v3  # Database name
DB_USER=ldev           # Database user
DB_PASSWORD=123456     # Database password
```

### Redis Configuration

```env
REDIS_HOST=redis       # Redis host (redis for Docker, localhost for local)
REDIS_PORT=6379        # Redis port
REDIS_PASSWORD=kklljaj8473_2827213  # Redis password
REDIS_DB=0             # Redis database number
```

### JWT Configuration

```env
JWT_SECRET=*%n_Dc{:e/<[$$,%v2oR)Dl[s0yrE6BB(  # Secret key for JWT signing
JWT_EXPIRY=168h        # JWT expiration (7 days)
REFRESH_TOKEN_EXPIRY=720h  # Refresh token expiration (30 days)
```

### Server Configuration

```env
PORT=8080              # Server port
GIN_MODE=release       # Gin mode: debug, release, test
SERVICE_NAME=go-hrm    # Service name for logging
TRUSTED_KEY=IC3flJ1@P2UkV6@Iphud1Re6  # Service-to-service auth key
```

### External Services (SDK URLs)

```env
# Docker (use service names)
SDK_USER_URL=http://cp-user:8082
SDK_COMPANY_URL=http://cp-company:8083
SDK_RBAC_URL=http://cp-rbac:8084

# Local (use localhost)
SDK_USER_URL=http://localhost:8082
SDK_COMPANY_URL=http://localhost:8083
SDK_RBAC_URL=http://localhost:8084
```

### Logging

```env
LOG_LEVEL=debug        # Log level: debug, info, warn, error
LOG_FORMAT=json        # Log format: json, text
```

### CORS

```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Origin,Content-Type,Authorization,AccessTrustedKey
```

### Cache TTL

```env
CACHE_COMPANY_TTL=2592000  # 30 days in seconds
CACHE_ROLE_TTL=2592000     # 30 days in seconds
CACHE_JWT_TTL=604800       # 7 days in seconds
```

---

## 🔐 Security Best Practices

### 1. Never Commit .env Files

```bash
# .gitignore already includes:
.env
.env.local
.env.*.local
```

### 2. Use Strong Secrets

```bash
# Generate random JWT secret
openssl rand -base64 32

# Generate random trusted key
openssl rand -hex 16
```

### 3. Different Secrets Per Environment

```env
# Development
JWT_SECRET=dev-secret-key-123

# Production
JWT_SECRET=prod-super-secure-random-key-xyz
```

### 4. Rotate Secrets Regularly

- Change JWT_SECRET → All users must re-login
- Change TRUSTED_KEY → Update all services
- Change DB_PASSWORD → Update all connections

---

## 🐳 Docker Compose Integration

### How It Works

```yaml
# docker-compose.yml
services:
  go-hrm:
    env_file:
      - .env  # Load all variables from .env file
```

**Benefits:**
- ✅ No hardcoded values in docker-compose.yml
- ✅ Easy to change config without editing YAML
- ✅ Same .env file can be used for local development

### Override Specific Variables

```bash
# Override PORT when starting
PORT=9090 docker-compose up -d

# Or in docker-compose.yml
environment:
  - PORT=${PORT:-8080}  # Use env var or default to 8080
```

---

## 🔄 Switching Between Environments

### Docker → Local

```bash
# 1. Stop Docker
docker-compose down

# 2. Switch to local config
cp .env.local.example .env

# 3. Run locally
make dev
```

### Local → Docker

```bash
# 1. Stop local server (Ctrl+C)

# 2. Switch to Docker config
cp .env.docker.example .env

# 3. Start Docker
docker-compose up -d
```

---

## 🧪 Testing Different Configurations

### Test with Different Database

```bash
# Create test env file
cp .env .env.test

# Edit test config
nano .env.test

# Run with test config
docker-compose --env-file .env.test up -d
```

### Test with Debug Mode

```bash
# Temporarily override
GIN_MODE=debug LOG_LEVEL=debug docker-compose up
```

---

## 📚 Related Files

- `.env.docker.example` - Docker configuration template
- `.env.local.example` - Local development template
- `.env.example` - Generic template
- `docker-compose.yml` - Uses `env_file: .env`
- `.gitignore` - Excludes `.env` files

---

## ❓ Troubleshooting

### Environment variables not loaded

```bash
# Check if .env file exists
ls -la .env

# Check file content
cat .env

# Restart Docker to reload
docker-compose down
docker-compose up -d
```

### Wrong database host

```bash
# Docker: Use service name
DB_HOST=mysql

# Local: Use localhost
DB_HOST=localhost
```

### Service can't connect to other services

```bash
# Docker: Use service names
SDK_USER_URL=http://cp-user:8082

# Local: Use localhost
SDK_USER_URL=http://localhost:8082
```

---

**Best Practice**: Always use `.env` file for configuration, never hardcode sensitive data! 🔐
