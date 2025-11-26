-- Migration: Seed Sample Data
-- Description: Tạo dữ liệu mẫu cho development
-- Dependencies: All core tables
-- Created: 2025-01-01
-- 
-- Admin User: admin@gmail.com / admin123
-- Company: Local Development

-- ============================================
-- 1. INSERT COMPANY
-- ============================================
INSERT INTO `lit_company` (
  `id`,
  `c_owner_id`,
  `c_name`,
  `c_code`,
  `c_domain`,
  `c_screenname`,
  `c_email`,
  `c_phone`,
  `c_website`,
  `c_address`,
  `c_city`,
  `c_country`,
  `c_timezone`,
  `c_currency`,
  `c_language`,
  `c_plan`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES (
  1,
  1,  -- Will be admin user
  'Local Development Company',
  'LOCAL',
  'local.localhost',
  'local',
  'admin@gmail.com',
  '0123456789',
  'http://localhost',
  '123 Dev Street',
  'Ho Chi Minh',
  'Vietnam',
  'Asia/Ho_Chi_Minh',
  'VND',
  'vi',
  100,  -- On-premise plan
  1,
  UNIX_TIMESTAMP(),
  UNIX_TIMESTAMP()
);

-- ============================================
-- 2. INSERT ADMIN USER
-- ============================================
-- Password: admin123
-- Bcrypt hash (Go compatible): $2a$10$75.jwp7gOKhLVnIlkzKPlORt5zLJo9xCoaf./IJjzGjxxstquhJZm
INSERT INTO `lit_user` (
  `id`,
  `u_username`,
  `u_email`,
  `u_password`,
  `u_first_name`,
  `u_last_name`,
  `u_full_name`,
  `u_phone`,
  `u_email_verified`,
  `u_email_verified_at`,
  `u_timezone`,
  `u_language`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES (
  1,
  'admin',
  'admin@gmail.com',
  '$2a$10$75.jwp7gOKhLVnIlkzKPlORt5zLJo9xCoaf./IJjzGjxxstquhJZm',  -- admin123 (Go bcrypt)
  'Admin',
  'User',
  'Admin User',
  '0123456789',
  1,
  UNIX_TIMESTAMP(),
  'Asia/Ho_Chi_Minh',
  'vi',
  1,
  UNIX_TIMESTAMP(),
  UNIX_TIMESTAMP()
);

-- ============================================
-- 3. INSERT DEPARTMENTS
-- ============================================
INSERT INTO `lit_company_department` (
  `id`,
  `c_id`,
  `cd_name`,
  `cd_code`,
  `cd_description`,
  `cd_parentid`,
  `cd_level`,
  `cd_displayorder`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
(1, 1, 'Ban Giám Đốc', 'BOD', 'Ban Giám Đốc', 0, 0, 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 1, 'Phòng Nhân Sự', 'HR', 'Phòng Nhân Sự', 1, 1, 2, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(3, 1, 'Phòng Kỹ Thuật', 'IT', 'Phòng Kỹ Thuật', 1, 1, 3, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(4, 1, 'Phòng Kinh Doanh', 'SALES', 'Phòng Kinh Doanh', 1, 1, 4, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 4. INSERT OFFICES
-- ============================================
INSERT INTO `lit_company_office` (
  `id`,
  `c_id`,
  `co_name`,
  `co_code`,
  `co_description`,
  `co_type`,
  `co_is_headquarters`,
  `co_address`,
  `co_city`,
  `co_country`,
  `co_latitude`,
  `co_longitude`,
  `co_radius`,
  `co_email`,
  `co_phone`,
  `co_timezone`,
  `co_capacity`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
(1, 1, 'Văn phòng Trụ sở chính', 'HQ', 'Trụ sở chính', 1, 1, '123 Dev Street, District 1', 'Ho Chi Minh', 'Vietnam', 10.7769, 106.7009, 100, 'hq@gmail.com', '0123456789', 'Asia/Ho_Chi_Minh', 100, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 1, 'Văn phòng Chi nhánh Hà Nội', 'HN', 'Chi nhánh Hà Nội', 2, 0, '456 Dev Street, Hoan Kiem', 'Ha Noi', 'Vietnam', 21.0285, 105.8542, 100, 'hanoi@gmail.com', '0987654321', 'Asia/Ho_Chi_Minh', 50, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 5. INSERT POSITIONS
-- ============================================
INSERT INTO `lit_company_position` (
  `id`,
  `c_id`,
  `cp_name`,
  `cp_code`,
  `cp_description`,
  `cp_level`,
  `cp_category`,
  `cp_type`,
  `cp_salary_min`,
  `cp_salary_max`,
  `cp_salary_currency`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
(1, 1, 'Giám Đốc', 'CEO', 'Giám Đốc Điều Hành', 1, 'management', 1, 50000000, 100000000, 'VND', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 1, 'Trưởng Phòng', 'MANAGER', 'Trưởng Phòng', 5, 'management', 1, 20000000, 40000000, 'VND', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(3, 1, 'Nhân Viên', 'STAFF', 'Nhân Viên', 10, 'technical', 1, 10000000, 20000000, 'VND', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(4, 1, 'Thực Tập Sinh', 'INTERN', 'Thực Tập Sinh', 20, 'support', 4, 3000000, 5000000, 'VND', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 6. INSERT ADMIN EMPLOYEE
-- ============================================
INSERT INTO `lit_company_employee` (
  `id`,
  `c_id`,
  `u_id`,
  `cd_id`,
  `co_id`,
  `cp_id`,
  `ce_internalid`,
  `ce_fullname`,
  `ce_firstname`,
  `ce_lastname`,
  `ce_email`,
  `ce_phone`,
  `ce_gender`,
  `ce_type`,
  `ce_jobtitle`,
  `ce_date_start`,
  `ce_basic_salary`,
  `ce_salary_currency`,
  `ce_username`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES (
  1,
  1,  -- Company ID
  1,  -- User ID
  1,  -- Department: Ban Giám Đốc
  1,  -- Office: HQ
  1,  -- Position: CEO
  'EMP001',
  'Admin User',
  'Admin',
  'User',
  'admin@gmail.com',
  '0123456789',
  1,  -- Male
  1,  -- Full-time
  'System Administrator',
  UNIX_TIMESTAMP(),
  50000000,
  'VND',
  'admin',
  1,
  UNIX_TIMESTAMP(),
  UNIX_TIMESTAMP()
);

-- ============================================
-- 7. INSERT SAMPLE EMPLOYEES
-- ============================================
INSERT INTO `lit_company_employee` (
  `c_id`,
  `cd_id`,
  `co_id`,
  `cp_id`,
  `ce_internalid`,
  `ce_fullname`,
  `ce_firstname`,
  `ce_lastname`,
  `ce_email`,
  `ce_phone`,
  `ce_gender`,
  `ce_type`,
  `ce_jobtitle`,
  `ce_date_start`,
  `ce_basic_salary`,
  `ce_salary_currency`,
  `ce_manager_id`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
-- HR Department
(1, 2, 1, 2, 'EMP002', 'Nguyễn Văn A', 'Văn A', 'Nguyễn', 'hr.manager@gmail.com', '0123456790', 1, 1, 'HR Manager', UNIX_TIMESTAMP(), 25000000, 'VND', 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 2, 1, 3, 'EMP003', 'Trần Thị B', 'Thị B', 'Trần', 'hr.staff@gmail.com', '0123456791', 2, 1, 'HR Staff', UNIX_TIMESTAMP(), 12000000, 'VND', 2, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- IT Department
(1, 3, 1, 2, 'EMP004', 'Lê Văn C', 'Văn C', 'Lê', 'it.manager@gmail.com', '0123456792', 1, 1, 'IT Manager', UNIX_TIMESTAMP(), 30000000, 'VND', 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 3, 1, 3, 'EMP005', 'Phạm Thị D', 'Thị D', 'Phạm', 'dev1@gmail.com', '0123456793', 2, 1, 'Developer', UNIX_TIMESTAMP(), 15000000, 'VND', 4, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 3, 1, 3, 'EMP006', 'Hoàng Văn E', 'Văn E', 'Hoàng', 'dev2@gmail.com', '0123456794', 1, 1, 'Developer', UNIX_TIMESTAMP(), 15000000, 'VND', 4, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 3, 1, 4, 'EMP007', 'Vũ Thị F', 'Thị F', 'Vũ', 'intern1@gmail.com', '0123456795', 2, 4, 'Intern Developer', UNIX_TIMESTAMP(), 4000000, 'VND', 4, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- Sales Department
(1, 4, 2, 2, 'EMP008', 'Đỗ Văn G', 'Văn G', 'Đỗ', 'sales.manager@gmail.com', '0123456796', 1, 1, 'Sales Manager', UNIX_TIMESTAMP(), 28000000, 'VND', 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 4, 2, 3, 'EMP009', 'Bùi Thị H', 'Thị H', 'Bùi', 'sales1@gmail.com', '0123456797', 2, 1, 'Sales Staff', UNIX_TIMESTAMP(), 13000000, 'VND', 8, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 4, 2, 3, 'EMP010', 'Đinh Văn I', 'Văn I', 'Đinh', 'sales2@gmail.com', '0123456798', 1, 1, 'Sales Staff', UNIX_TIMESTAMP(), 13000000, 'VND', 8, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 8. INSERT DEFAULT PERMISSIONS
-- ============================================
INSERT INTO `lit_rbac_permission` (
  `id`,
  `p_name`,
  `p_code`,
  `p_description`,
  `p_module`,
  `p_action`,
  `p_object_type`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
-- System permissions
(1, 'System Administration', 'system.admin', 'Full system administration', 'system', 'admin', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 'Company Administration', 'company.admin', 'Company administration', 'company', 'admin', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- Employee permissions
(210, 'Employee Management', 'erp.employee.manage', 'Manage employees', 'employee', 'manage', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(211, 'Employee Tag Management', 'erp.employee.managetag', 'Manage employee tags', 'employee', 'managetag', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- Checkin permissions
(220, 'Checkin Scheduling', 'erp.checkin.scheduling', 'Manage checkin schedules', 'checkin', 'scheduling', 11, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(221, 'Checkin Edit', 'erp.checkin.edit', 'Edit checkin records', 'checkin', 'edit', 11, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(222, 'Checkin Verify', 'erp.checkin.verify', 'Verify checkin records', 'checkin', 'verify', 11, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- Leave permissions
(260, 'Leave Management', 'erp.leave.manage', 'Manage leave requests', 'leave', 'manage', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

-- Department permissions
(270, 'Department Management', 'erp.department.manage', 'Manage departments', 'department', 'manage', 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 9. INSERT DEFAULT ROLES
-- ============================================
INSERT INTO `lit_rbac_role` (
  `id`,
  `r_company_id`,
  `r_code`,
  `r_name`,
  `r_description`,
  `r_is_system_role`,
  `r_is_default`,
  `r_level`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
(1, 1, 'system_admin', 'System Administrator', 'Full system access', 1, 0, 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 1, 'company_admin', 'Company Administrator', 'Company admin access', 1, 0, 10, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(3, 1, 'hr_manager', 'HR Manager', 'HR management access', 0, 0, 20, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(4, 1, 'manager', 'Manager', 'Department manager access', 0, 0, 50, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(5, 1, 'employee', 'Employee', 'Standard employee access', 0, 1, 100, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- 10. ASSIGN ADMIN USER TO SYSTEM_ADMIN ROLE
-- ============================================
INSERT INTO `lit_rbac_user_role` (
  `ur_user_id`,
  `ur_role_id`,
  `ur_company_id`,
  `ur_assigned_by`,
  `ur_assigned_at`,
  `ur_expires_at`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES (
  1,  -- Admin user
  1,  -- System admin role
  1,  -- Company ID
  1,  -- Assigned by admin
  UNIX_TIMESTAMP(),
  0,  -- Never expires
  1,
  UNIX_TIMESTAMP(),
  UNIX_TIMESTAMP()
);

-- ============================================
-- 11. ASSIGN PERMISSIONS TO SYSTEM_ADMIN ROLE
-- ============================================
INSERT INTO `lit_rbac_role_permission` (
  `rp_role_id`,
  `rp_permission_id`,
  `rp_can_create`,
  `rp_can_read`,
  `rp_can_update`,
  `rp_can_delete`,
  `rp_object_type`,
  `rp_object_ids`,
  `rp_object_scope`,
  `status`,
  `datecreated`,
  `datemodified`
) VALUES
-- System admin has ALL permissions globally
(1, 1, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 2, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 210, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 211, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 220, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 221, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 222, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 260, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(1, 270, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================
-- SUMMARY
-- ============================================
-- Company: Local Development Company (ID: 1)
-- Admin User: admin@gmail.com / admin123 (ID: 1)
-- Employee: EMP001 - Admin User (ID: 1)
-- 
-- Departments: 4 (BOD, HR, IT, SALES)
-- Offices: 2 (HQ, Hanoi Branch)
-- Positions: 4 (CEO, Manager, Staff, Intern)
-- Employees: 10 (including admin)
-- Roles: 5 (system_admin, company_admin, hr_manager, manager, employee)
-- Permissions: 9 (system, company, employee, checkin, leave, department)
