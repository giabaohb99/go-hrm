# Authentication Flow Documentation - Go HRM Service

## 📋 Tổng quan

Document này mô tả chi tiết luồng xử lý login/authentication trong hệ thống, dựa trên source code PHP hiện tại (`cp-user/src/Controller/V1/Users.php`).

---

## 🔐 API Endpoints

### 1. **Employee/Admin Login** (HRM System)
```
POST /v1/users/login
```
**Dùng cho**: Nhân viên, quản lý, admin đăng nhập vào HRM system

### 2. **Customer Login** (Customer Portal)
```
POST /v1/users/customer/login
```
**Dùng cho**: Khách hàng đăng nhập vào customer portal

### 3. **Customer Code Login** (Passwordless)
```
POST /v1/users/customer/codelogin
```
**Dùng cho**: Khách hàng đăng nhập bằng activation code (không cần password)

---

## 🚀 Employee/Admin Login Flow (`/v1/users/login`)

### Request Format

```json
{
  "email": "admin@gmail.com",           // Email hoặc internal ID
  "internalid": "EMP001",               // Alternative: Internal employee ID
  "password": "admin123",               // Plain text password
  "hostname": "local.localhost",        // Company domain/hostname
  "platform": "web",                    // Platform: web, ios, android, desktop
  "version": "1.0.0",                   // App version (format: x.y.z)
  "no_cache": false                     // Optional: bypass role cache
}
```

### Step-by-Step Flow

#### **Step 1: Validation** (`loginValidate()`)

```php
1. Validate email/internalid
   - Email phải có format hợp lệ
   - Hoặc có internal ID

2. Validate platform
   - Phải thuộc danh sách: web, ios, android, desktop
   
3. Validate version
   - Format: x.y.z (e.g., 1.0.0)

4. Validate hostname
   - Không chứa ký tự đặc biệt
   - Format: a-z, 0-9, dash, dot

5. Get Company by hostname
   → Call: Company::getDataFromHostname($hostname)
   → Cache: 30 days
   → Service: Company Service SDK
   
6. Get Employee by email/internalid
   → Query: lit_company_employee table
   → Filter: company_id + (email OR internalid)
   
7. Get User by employee.uid
   → Query: lit_user table
   
8. Verify password
   → Hash: Hashing::hash($password)
   → Compare: $myUser->password === Hashing::hash($formData['password'])
   
9. Check employee status
   → Must be: Employee::STATUS_ENABLE (1)
```

#### **Step 2: Get User Roles** (`RbacRole::getDetailRole()`)

```php
1. Check if user is company owner
   if ($myUser->id == $myCompany->uid) {
       // Owner có TẤT CẢ permissions
       $roleInfo = implode(',', array_keys(RbacSubjectItem::subjectMapping()));
       // Result: "1,2,100,110,111,120,121,210,211,220,221,222,260,270,..."
   }

2. Nếu không phải owner, get role từ RBAC service
   → Call: RbacRole::getDetailRole($companyId, $userId, $error, $no_cache)
   → Service: RBAC Service SDK
   → Cache: 30 days (Redis)
   → Cache key: "roleuser_{companyId}_{userId}"
   
3. Role format returned
   → Example: "210:,220:1-10,120:2-5"
   → Meaning:
      - 210: = Permission 210 (employee.manage) global
      - 220:1-10 = Permission 220 (checkin.scheduling) chỉ office 1-10
      - 120:2-5 = Permission 120 (order.view) chỉ store 2-5
```

#### **Step 3: Build JWT Token**

```php
1. Get JWT lifetime from settings
   → Call: Setting::getPublicKey("life_time_of_jwt_in_days")
   → Default: 7 days
   
2. Build token payload
   $token = [
       'iss' => 'cropany',                    // Issuer
       'aud' => 'cropany',                    // Audience
       'iat' => time(),                       // Issued at
       'exp' => strtotime(" +7 day"),         // Expiration
       'jti' => md5($userId . '-' . time()),  // JWT ID (unique)
       'data' => [
           'accesszone' => 'company',         // Access zone type
           'user' => [
               'company_id' => $companyId,
               'id' => $userId,
               'fullname' => $userFullname
           ],
           'user_agent' => md5($userAgent),   // Hashed user agent
           'company' => [
               'id' => $companyId,
               'owner' => $companyOwnerId,
               'employee' => [
                   'id' => $employeeId,
                   'status' => $employeeStatus,
                   'internalid' => $employeeInternalId,
                   'fullname' => $employeeFullname
               ]
           ]
       ]
   ];

3. Encode JWT
   → Algorithm: HS256
   → Secret: $conf['jwt']['privatekey']
   → Result: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   
4. Create JWT hash (for session tracking)
   $jwthash = md5($jwt);
```

#### **Step 4: Save User Session** (`UserSession::addData()`)

```php
1. Create UserSession record
   INSERT INTO lit_user_session (
       cid,              // Company ID
       uid,              // User ID
       platform,         // web, ios, android, desktop
       platformversion,  // App version
       jwthash,          // MD5 hash of JWT
       status,           // 1 = enabled
       disabledreason,   // 0 = not disabled yet
       useragent,        // Full user agent string
       dateexpired,      // JWT expiration timestamp
       loginipaddress,   // User IP address
       datecreated       // Current timestamp
   )

2. Session status constants
   - STATUS_ENABLE = 1
   - STATUS_DISABLED = 0
   
3. Disabled reasons
   - DISABLED_REASON_NOTYET = 0
   - DISABLED_REASON_REVOKEALL = 1
   - DISABLED_REASON_LOGOUT = 2
```

#### **Step 5: Cache JWT Token** (`UserSession::addJwtToCache()`)

```php
1. Store full JWT to Redis
   → Key: "jwt_{jwthash}"
   → Value: Full JWT string
   → TTL: Same as JWT expiration
   → Purpose: Fast token validation without DB query

2. Redis structure
   SET jwt_5f4dcc3b5aa765d61d8327deb882cf99 "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   EXPIRE jwt_5f4dcc3b5aa765d61d8327deb882cf99 604800  // 7 days
```

#### **Step 6: Audit Logging**

```php
1. Log login event
   $this->log([
       'company_id' => $companyId,
       'display_name' => $userFullname,
       'controller' => 'user',
       'action' => 'login',
       'creator_id' => $userId,
       'newobj' => [
           'account' => $email,
           'platform' => $platform,
           'version' => $version,
           'hostname' => $hostname,
           'full_name' => $userFullname,
           'user_agent' => $userAgent
       ],
       'object_id' => $userId
   ]);

2. Log destination
   → Service: Audit Log Service
   → Table: lit_audit_log
```

#### **Step 7: Update Last Login**

```php
1. Update employee last login
   → Call: Employee::updateLastLogin([
       "employee_id" => $employeeId,
       "time_login" => time()
   ])
   
2. Update fields
   - ce_lastlogin = current timestamp
```

### Response Format

```json
{
  "jwt": "5f4dcc3b5aa765d61d8327deb882cf99",  // JWT hash (NOT full JWT!)
  "user": {
    "id": 1,
    "fullname": "Admin User",
    "email": "admin@gmail.com",
    "phone": "0123456789",
    "status": 1,
    "datelastlogin": 1640995200
  },
  "role": "210:,220:1-10,260:,270:",  // Role string with object-level permissions
  "company": {
    "id": 1,
    "owner": 1,
    "name": "Local Development Company",
    "screenname": "local",
    "domain": "local.localhost",
    "email": "admin@gmail.com",
    "phone": "0123456789",
    "region": 0,
    "status": 1,
    "kyc_status": 0,
    "quota": {
      "max_employees": 100,
      "max_products": 1000
    },
    "base_quota": {
      "max_employees": 50,
      "max_products": 500
    },
    "employee": {
      "id": 1,
      "email": "admin@gmail.com",
      "phone": "0123456789",
      "status": 1,
      "internal_id": "EMP001",
      "office_id": 1,
      "department_id": 1,
      "job_title": "System Administrator",
      "position_id": 1,
      "checkin_type": 1
    }
  }
}
```

**⚠️ QUAN TRỌNG**: Response trả về `jwthash` (MD5 của JWT), KHÔNG phải full JWT token!

---

## 🔄 Refresh Token Flow

### ⚠️ **HIỆN TẠI KHÔNG CÓ REFRESH TOKEN!**

Hệ thống PHP hiện tại **KHÔNG implement refresh token**. Khi JWT hết hạn, user phải login lại.

### 🎯 **Đề xuất implement Refresh Token cho Go**

```go
// Thêm vào UserSession table
type UserSession struct {
    // ... existing fields
    RefreshToken       string `json:"refresh_token"`
    RefreshTokenExpiry int64  `json:"refresh_token_expiry"`
}

// Refresh token endpoint
POST /v1/users/refresh
{
  "refresh_token": "abc123..."
}

// Response
{
  "jwt": "new_jwt_hash",
  "refresh_token": "new_refresh_token"  // Optional: rotate refresh token
}
```

---

## 🔍 Service Dependencies

### 1. **Company Service** (`Cropany\Rest\Company`)

```php
// Get company by hostname
$myCompany->getDataFromHostname($hostname);

// Implementation
→ Check cache first: "company_host_{hostname}" (30 days)
→ If not cached: Call Company Service API
→ Endpoint: /v1/companies/searchbyhostname?hostname={hostname}
→ Cache result for 30 days
```

### 2. **Employee Service** (`Cropany\Rest\Employee`)

```php
// Get employee by email
Employee::getByEmail($companyId, $email);

// Get employee by internal ID
Employee::getByInternalid($companyId, $internalId);

// Update last login
Employee::updateLastLogin([
    "employee_id" => $employeeId,
    "time_login" => time()
]);

// Implementation
→ Direct database query to lit_company_employee
→ No caching for employee lookup
```

### 3. **RBAC Service** (`Cropany\Rest\RbacRole`)

```php
// Get user roles
RbacRole::getDetailRole($companyId, $userId, $error, $no_cache);

// Implementation
→ Check cache: "roleuser_{companyId}_{userId}" (30 days)
→ If not cached: Call RBAC Service API
→ Endpoint: /v1/rbacroles/userdetail?company_id={cid}&user_id={uid}
→ Response format: "210:,220:1-10,120:2-5"
→ Cache for 30 days
```

### 4. **Setting Service** (`Cropany\Rest\Setting`)

```php
// Get JWT lifetime setting
Setting::getPublicKey("life_time_of_jwt_in_days");

// Implementation
→ Call Setting Service API
→ Endpoint: /v1/settings/public/{key}
→ Default: 7 days
```

### 5. **Audit Log Service**

```php
// Log user action
$this->log([...]);

// Implementation
→ Call Audit Log Service API
→ Endpoint: /v1/auditlogs
→ Async logging (không block login flow)
```

---

## 💾 Caching Strategy

### 1. **Company Data**
- **Cache Key**: `company_host_{hostname}`
- **TTL**: 30 days
- **Storage**: Redis
- **Purpose**: Giảm load cho Company Service

### 2. **User Roles**
- **Cache Key**: `roleuser_{companyId}_{userId}`
- **TTL**: 30 days
- **Storage**: Redis
- **Purpose**: Giảm load cho RBAC Service
- **Invalidation**: Khi role thay đổi, clear cache

### 3. **JWT Token**
- **Cache Key**: `jwt_{jwthash}`
- **TTL**: Same as JWT expiration (7 days default)
- **Storage**: Redis
- **Purpose**: Fast token validation
- **Value**: Full JWT string

### 4. **Blacklist (Revoked Tokens)**
- **Cache Key**: `blacklist_{jwthash}`
- **TTL**: Until JWT expiration
- **Storage**: Redis
- **Purpose**: Track revoked/logged out tokens

---

## 🔐 Security Features

### 1. **Password Hashing**
```php
// Hash function
Hashing::hash($password)

// Implementation (cần verify trong code)
→ Likely: bcrypt or custom hash
→ Should be: bcrypt with salt
```

### 2. **JWT Signature**
```php
// Algorithm: HS256
// Secret: From config['jwt']['privatekey']
JWT::encode($token, $secretKey, 'HS256');
```

### 3. **User Agent Tracking**
```php
// Store hashed user agent in JWT
'user_agent' => md5(Helper::plaintext($_SERVER['HTTP_USER_AGENT']))

// Purpose: Detect token theft
```

### 4. **IP Address Logging**
```php
// Store login IP in session
$myUserSession->loginipaddress = Helper::getIpAddress(true);

// Purpose: Audit trail, detect suspicious activity
```

### 5. **Session Revocation**
```php
// Disable all user sessions
POST /v1/users/kick
{
  "company_id": 1,
  "user_id": 123
}

// Implementation
→ Update all sessions: status = DISABLED
→ Add jwthash to blacklist cache
→ User must login again
```

---

## 📊 Database Tables Used

### 1. **lit_user**
```sql
SELECT * FROM lit_user WHERE u_email = ?
```
- Lưu user credentials
- Password hash
- Last login timestamp

### 2. **lit_company**
```sql
SELECT * FROM lit_company WHERE c_domain = ?
```
- Company information
- Owner ID
- Plan & quota

### 3. **lit_company_employee**
```sql
SELECT * FROM lit_company_employee 
WHERE c_id = ? AND (ce_email = ? OR ce_internalid = ?)
```
- Employee information
- Department, office, position
- Employment status

### 4. **lit_user_session**
```sql
INSERT INTO lit_user_session (...)
```
- Active sessions
- JWT hash tracking
- Device & IP information

### 5. **lit_rbac_user_role** (via RBAC Service)
```sql
SELECT * FROM lit_rbac_user_role 
WHERE ur_company_id = ? AND ur_user_id = ?
```
- User role assignments

### 6. **lit_rbac_role_permission** (via RBAC Service)
```sql
SELECT * FROM lit_rbac_role_permission 
WHERE rp_role_id IN (...)
```
- Role permissions with object-level access

---

## 🎯 Error Handling

### Common Errors

```json
// Email invalid
{
  "error": ["error_email_invalid"],
  "status": 422
}

// Account not found
{
  "error": ["error_account_invalid"],
  "status": 422
}

// Employee disabled
{
  "error": ["error_employee_disabled"],
  "status": 422
}

// Company not found
{
  "error": ["error_company_invalid"],
  "status": 422
}

// Session save failed
{
  "error": ["error_session_can_not_be_saved"],
  "status": 500
}
```

---

## 🔄 Logout Flow (`/v1/users/logout`)

### Request
```
POST /v1/users/logout
Authorization: Bearer {jwthash}
```

### Flow

```php
1. Get jwthash from Authorization header
   → Extract from: "Bearer {jwthash}"
   
2. Find session by jwthash
   → Query: lit_user_session WHERE jwthash = ?
   
3. Disable session
   → Update: status = DISABLED
   → Update: disabledreason = DISABLED_REASON_LOGOUT
   
4. Add to blacklist
   → Cache: blacklist_{jwthash}
   → TTL: Until JWT expiration
   
5. Response
   {
     "status": "success"
   }
```

---

## 📝 Implementation Notes for Go

### 1. **Password Hashing**
```go
import "golang.org/x/crypto/bcrypt"

// Hash password
hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

// Verify password
err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
```

### 2. **JWT Generation**
```go
import "github.com/golang-jwt/jwt/v5"

// Create claims
claims := &JWTClaims{
    UserID:     userID,
    CompanyID:  companyID,
    EmployeeID: employeeID,
    Role:       roleString,
    RegisteredClaims: jwt.RegisteredClaims{
        ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)),
        IssuedAt:  jwt.NewNumericDate(time.Now()),
        Issuer:    "go-hrm",
    },
}

// Generate token
token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
tokenString, _ := token.SignedString([]byte(jwtSecret))

// Create hash
jwthash := md5.Sum([]byte(tokenString))
```

### 3. **Redis Caching**
```go
import "github.com/go-redis/redis/v8"

// Cache company
ctx := context.Background()
cacheKey := fmt.Sprintf("company_host_%s", hostname)
rdb.Set(ctx, cacheKey, companyJSON, 30*24*time.Hour)

// Cache role
cacheKey := fmt.Sprintf("roleuser_%d_%d", companyID, userID)
rdb.Set(ctx, cacheKey, roleString, 30*24*time.Hour)

// Cache JWT
cacheKey := fmt.Sprintf("jwt_%s", jwthash)
rdb.Set(ctx, cacheKey, tokenString, 7*24*time.Hour)
```

### 4. **Service SDK Calls**
```go
// Get company
companySDK := NewCompanySDK()
company, err := companySDK.GetByHostname(hostname)

// Get roles
rbacSDK := NewRbacSDK()
roleString, err := rbacSDK.GetUserRoles(companyID, userID, false)
```

---

## 🎉 Summary

**Login flow tóm tắt**:
1. ✅ Validate input (email, password, hostname, platform, version)
2. ✅ Get Company by hostname (cache 30 days)
3. ✅ Get Employee by email/internalid
4. ✅ Get User and verify password
5. ✅ Get User Roles from RBAC service (cache 30 days)
6. ✅ Build JWT token (7 days expiration)
7. ✅ Save UserSession to database
8. ✅ Cache JWT to Redis
9. ✅ Log audit event
10. ✅ Update last login timestamp
11. ✅ Return JWT hash + user + company + employee data

**⚠️ Lưu ý quan trọng**:
- Response trả về **JWT HASH** (MD5), không phải full JWT!
- **KHÔNG CÓ REFRESH TOKEN** trong hệ thống hiện tại
- Cache được sử dụng rất nhiều (Company: 30 days, Roles: 30 days, JWT: 7 days)
- Object-level permissions được encode trong role string: `"210:,220:1-10"`
