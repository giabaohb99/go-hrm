# Go HRM Microservices

Hệ thống quản lý nhân sự được xây dựng theo kiến trúc microservices với Go và Gin framework.

## Kiến trúc

Hệ thống được chia thành 3 services riêng biệt:

### 1. User Service (Port: 8081)
- Quản lý User và UserSession
- Xử lý authentication (login, logout, refresh token)
- Quản lý profile người dùng

### 2. Company Service (Port: 8082)
- Quản lý thông tin công ty
- CRUD operations cho Company entity

### 3. Employee Service (Port: 8083)
- Quản lý thông tin nhân viên
- Liên kết User với Company thông qua Employee entity

## Middleware

### API Logger
- Ghi log tất cả API requests/responses vào database
- Bao gồm thông tin chi tiết: request ID, timing, user context, etc.

### Request Logger
- Log requests ra console với format JSON
- Mask các thông tin nhạy cảm (password, token, etc.)

## Cấu trúc thư mục

```
├── pkg/                    # Shared packages
│   ├── config/            # Configuration
│   ├── database/          # Database connection
│   ├── middleware/        # Shared middleware
│   └── model/            # Shared models
├── services/
│   ├── user-service/     # User & Session management
│   ├── company-service/  # Company management  
│   └── employee-service/ # Employee management
├── migrations/           # Database migrations
└── docker-compose.yml   # Docker setup
```

## Chạy ứng dụng

### Với Docker Compose (Khuyến nghị)

```bash
# Build và chạy tất cả services
docker-compose up --build

# Chạy ở background
docker-compose up -d --build

# Xem logs
docker-compose logs -f [service-name]

# Dừng services
docker-compose down
```

### Database Management

**Adminer** được cung cấp để quản lý database:
- URL: http://localhost:8080
- Server: mysql
- Username: root
- Password: root
- Database: go_hrm

### API Documentation

**Swagger UI** để xem và test API:
- URL: http://localhost:8090
- Tài liệu API đầy đủ với khả năng test trực tiếp
- Hỗ trợ authentication với JWT token

### Chạy từng service riêng lẻ

```bash
# User Service
cd services/user-service
go run cmd/main.go

# Company Service  
cd services/company-service
go run cmd/main.go

# Employee Service
cd services/employee-service
go run cmd/main.go
```

## API Endpoints

### User Service (8081)
```
POST /api/v1/auth/login          # Đăng nhập (trả về JWT + refresh token)
POST /api/v1/auth/logout         # Đăng xuất
POST /api/v1/auth/refresh        # Refresh access token
POST /api/v1/users               # Đăng ký user mới
GET  /api/v1/users/profile       # Lấy thông tin profile
PUT  /api/v1/users/profile       # Cập nhật profile
```

**Login Response Example:**
```json
{
  "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", 
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": 1640995200,
  "user": {
    "id": 1,
    "fullname": "John Doe",
    "email": "john@example.com",
    "status": 1,
    "datelastlogin": 1640908800
  },
  "company": {
    "id": 1,
    "name": "Example Corp",
    "domain": "example.com",
    "owner": 1,
    "status": 1
  },
  "employee": {
    "id": 1,
    "internal_id": "EMP001",
    "email": "john@example.com",
    "status": 1
  },
  "role": "210:,220:1-10"
}
```

**Refresh Token Response Example:**
```json
{
  "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": 1640995200
}
```

### Company Service (8082)
```
POST /api/v1/companies           # Tạo công ty mới
GET  /api/v1/companies/:id       # Lấy thông tin công ty
GET  /api/v1/companies?domain=   # Tìm công ty theo domain
PUT  /api/v1/companies/:id       # Cập nhật công ty
DELETE /api/v1/companies/:id     # Xóa công ty
GET  /api/v1/companies           # Danh sách công ty
```

### Employee Service (8083)
```
POST /api/v1/employees                    # Tạo nhân viên mới
GET  /api/v1/employees/:id                # Lấy thông tin nhân viên
PUT  /api/v1/employees/:id                # Cập nhật nhân viên
DELETE /api/v1/employees/:id              # Xóa nhân viên
GET  /api/v1/users/:userId/employee       # Lấy employee theo user ID
GET  /api/v1/companies/:companyId/employees # Danh sách nhân viên theo công ty
```

## Database

Hệ thống sử dụng MySQL với các bảng chính:
- `lit_user` - Thông tin người dùng
- `lit_user_session` - Session đăng nhập
- `lit_company` - Thông tin công ty
- `lit_company_employee` - Thông tin nhân viên
- `lit_api_log` - Log API requests

## Environment Variables

Mỗi service cần các biến môi trường:
```
PORT=808x
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=go_hrm
JWT_SECRET=your_secret_key
```

## Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| User Service | 8081 | Authentication & User Management |
| Company Service | 8082 | Company Management |
| Employee Service | 8083 | Employee Management |
| Adminer | 8080 | Database Management UI |
| Swagger UI | 8090 | API Documentation & Testing |
| MySQL | 3306 | Database Server |

## Monitoring

- Health check endpoints: `/health` cho mỗi service
- API logging tự động vào database
- Request logging ra console
- Database management qua Adminer UI

## Development

1. Clone repository
2. Copy `.env.example` thành `.env` trong mỗi service
3. Cập nhật database credentials
4. Chạy migrations
5. Start services với `docker-compose up`

## Lưu ý

- Mỗi service chạy trên port riêng biệt
- Tất cả services chia sẻ cùng database
- API logging được thực hiện async để không block response
- Sensitive data được mask trong logs