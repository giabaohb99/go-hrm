# Go HRM Microservices Architecture

## 📋 Tổng quan

Dự án được thiết kế lại theo kiến trúc **Microservices**, sử dụng **Go** và framework **Gin**. Mỗi service là một đơn vị độc lập, có thể phát triển, deploy và scale riêng biệt.

## 🏗️ Cấu trúc thư mục (Project Structure)

Cấu trúc dự án được tổ chức theo mô hình Monorepo (hoặc Multi-repo tùy triển khai), với các thư mục chính như sau:

```
/go-hrm
│
├── /services                   # Chứa source code của các microservices
│   ├── /auth-service           # Service xác thực & phân quyền
│   ├── /user-service           # Service quản lý người dùng
│   ├── /product-service        # Service quản lý sản phẩm (ví dụ)
│   ├── /order-service          # Service quản lý đơn hàng (ví dụ)
│   └── ...
│
├── /pkg                        # Thư viện dùng chung (Shared Libraries)
│   ├── config                  # Load config (viper, env)
│   ├── database                # Kết nối DB (GORM, Redis)
│   ├── middleware              # Middleware chung (Auth, Logger, CORS)
│   ├── logger                  # Cấu hình log (Zap, Logrus)
│   ├── utils                   # Các hàm tiện ích chung
│   └── dto                     # Data Transfer Objects chung (nếu cần)
│
├── /deployments                # Cấu hình deployment
│   ├── docker                  # Dockerfiles hoặc scripts liên quan
│   └── k8s                     # Kubernetes manifests
│
├── /docs                       # Tài liệu dự án
│   └── ARCHITECTURE.md
│
├── docker-compose.yml          # Chạy toàn bộ hệ thống local
├── Makefile                    # Các lệnh build, run, test
└── go.work                     # (Optional) Go Workspace nếu dùng monorepo
```

---

## 🏢 Cấu trúc chi tiết một Service

Mỗi service (ví dụ: `user-service`) tuân thủ **Standard Go Project Layout**, đảm bảo sự rõ ràng và tách biệt giữa các tầng.

```
/user-service
│
├── cmd
│   └── server
│       └── main.go             # Entrypoint: Khởi tạo và chạy service
│
├── internal                    # Code nội bộ, không thể import từ bên ngoài
│   ├── config                  # Load cấu hình riêng cho service
│   ├── controller              # Handler (Gin): Xử lý request HTTP
│   ├── dto                     # Request/Response structs
│   ├── repository              # Data Access Layer: Giao tiếp DB
│   ├── service                 # Business Logic Layer: Xử lý nghiệp vụ
│   ├── model                   # Database Models (GORM structs)
│   ├── middleware              # Middleware riêng của service
│   └── router                  # Định nghĩa routes & nhóm routes
│
├── pkg                         # Code public, có thể được import bởi service khác (ít dùng trong microservice thuần)
│
├── go.mod                      # Go module definition
├── go.sum
└── Dockerfile                  # Build image cho service này
```

---

## 🛠️ Technology Stack

- **Language**: Go (Golang)
- **Web Framework**: Gin Web Framework
- **Database**: PostgreSQL / MySQL
- **ORM**: GORM
- **Config**: Viper
- **Logging**: Zap / Logrus
- **Authentication**: JWT (JSON Web Tokens)
- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes (K8s)

---

## 🔄 Luồng xử lý (Request Flow)

Một request đi vào `user-service` sẽ đi qua các tầng sau:

1.  **Main (cmd/server/main.go)**:
    -   Load Config.
    -   Kết nối Database.
    -   Khởi tạo Repository, Service, Controller.
    -   Setup Router và Start Server.

2.  **Router (internal/router)**:
    -   Định tuyến request đến Controller tương ứng.
    -   Áp dụng Middleware (Auth, Logging...).

3.  **Controller (internal/controller)**:
    -   Parse request body vào DTO.
    -   Validate dữ liệu cơ bản.
    -   Gọi Service để xử lý nghiệp vụ.
    -   Trả về response (JSON).

4.  **Service (internal/service)**:
    -   Thực hiện logic nghiệp vụ chính.
    -   Gọi Repository để lấy/lưu dữ liệu.
    -   Xử lý các logic phức tạp, gọi service khác (nếu có).

5.  **Repository (internal/repository)**:
    -   Thực hiện query trực tiếp xuống Database (dùng GORM).
    -   Trả về Model hoặc Error.

---

## 📝 Quy ước đặt tên (Naming Convention)

-   **Package**: `lowercase` (vd: `user`, `auth`).
-   **Interface**: `PascalCase` (vd: `UserRepository`).
-   **Struct**: `PascalCase` (vd: `User`, `CreateUserRequest`).
-   **Function/Method**: `PascalCase` (Public), `camelCase` (Private).
-   **File**: `snake_case.go` (vd: `user_service.go`, `user_repository.go`).

## 🚀 Hướng dẫn phát triển (Development Guide)

### 1. Tạo mới một Service
Copy cấu trúc mẫu hoặc tạo thư mục theo cấu trúc `/services/<service-name>`.

### 2. Định nghĩa Model
Tạo struct trong `internal/model` mapping với bảng trong DB.

### 3. Implement Repository
Viết interface và implementation trong `internal/repository` để thao tác CRUD.

### 4. Implement Service
Viết logic nghiệp vụ trong `internal/service`.

### 5. Implement Controller
Viết handler trong `internal/controller`, bind dữ liệu và gọi Service.

### 6. Setup Router
Đăng ký route trong `internal/router`.

### 7. Main Entrypoint
Wire tất cả lại trong `cmd/server/main.go`.