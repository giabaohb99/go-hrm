-- Migration: Create Role-Permission Mapping Table (TINH HOA!)
-- Description: Mapping giữa Role và Permission với OBJECT-LEVEL PERMISSIONS
-- Dependencies: lit_rbac_role, lit_rbac_permission
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_rbac_role_permission` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Mapping
  `rp_role_id` int(11) unsigned NOT NULL COMMENT 'Role ID',
  `rp_permission_id` int(11) unsigned NOT NULL COMMENT 'Permission ID',
  
  -- CRUD Permissions (optional - chi tiết hơn)
  `rp_can_create` tinyint(1) DEFAULT '0' COMMENT 'Có quyền tạo mới',
  `rp_can_read` tinyint(1) DEFAULT '0' COMMENT 'Có quyền xem',
  `rp_can_update` tinyint(1) DEFAULT '0' COMMENT 'Có quyền sửa',
  `rp_can_delete` tinyint(1) DEFAULT '0' COMMENT 'Có quyền xóa',
  `rp_can_approve` tinyint(1) DEFAULT '0' COMMENT 'Có quyền duyệt',
  `rp_can_export` tinyint(1) DEFAULT '0' COMMENT 'Có quyền export',
  
  -- OBJECT-LEVEL PERMISSIONS (TINH HOA!)
  `rp_object_type` int(11) DEFAULT '0' COMMENT '0=global/all, 1=store, 3=warehouse, 11=office',
  `rp_object_ids` text COMMENT 'JSON array of object IDs: [1,2,5,10] hoặc "all"',
  `rp_object_scope` varchar(20) DEFAULT 'all' COMMENT 'Scope: all, specific, none',
  
  -- Constraints (optional)
  `rp_conditions` text COMMENT 'Additional conditions (JSON format)',
  `rp_max_amount` decimal(15,2) DEFAULT NULL COMMENT 'Max amount (cho financial permissions)',
  `rp_time_restrictions` text COMMENT 'Time restrictions (JSON format)',
  
  -- Metadata
  `rp_granted_by` int(11) unsigned DEFAULT '0' COMMENT 'User ID người grant permission',
  `rp_granted_at` int(11) unsigned DEFAULT '0' COMMENT 'Thời điểm grant',
  `rp_notes` text COMMENT 'Ghi chú',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_role_permission` (`rp_role_id`, `rp_permission_id`),
  KEY `idx_role` (`rp_role_id`),
  KEY `idx_permission` (`rp_permission_id`),
  KEY `idx_object_type` (`rp_object_type`),
  KEY `idx_status` (`status`),
  
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`rp_role_id`) REFERENCES `lit_rbac_role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`rp_permission_id`) REFERENCES `lit_rbac_permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Role-Permission mapping with object-level permissions';

-- Index cho tìm kiếm nhanh
CREATE INDEX `idx_role_status` ON `lit_rbac_role_permission` (`rp_role_id`, `status`);
CREATE INDEX `idx_permission_status` ON `lit_rbac_role_permission` (`rp_permission_id`, `status`);
CREATE INDEX `idx_object_type_scope` ON `lit_rbac_role_permission` (`rp_object_type`, `rp_object_scope`);

-- ============================================
-- VÍ DỤ DATA
-- ============================================

-- Example 1: User có role "Store Manager" chỉ quản lý store 1, 2, 5
-- INSERT INTO lit_rbac_role_permission 
-- (rp_role_id, rp_permission_id, rp_can_read, rp_can_update, rp_object_type, rp_object_ids, rp_object_scope, status, datecreated)
-- VALUES
-- (10, 120, 1, 1, 1, '[1,2,5]', 'specific', 1, UNIX_TIMESTAMP());
-- 
-- Giải thích:
-- - rp_role_id = 10 (Store Manager role)
-- - rp_permission_id = 120 (erp.order.view permission)
-- - rp_object_type = 1 (Store)
-- - rp_object_ids = [1,2,5] (Chỉ store 1, 2, 5)

-- Example 2: User có role "HR Manager" quản lý tất cả nhân viên
-- INSERT INTO lit_rbac_role_permission 
-- (rp_role_id, rp_permission_id, rp_can_create, rp_can_read, rp_can_update, rp_can_delete, rp_object_type, rp_object_ids, rp_object_scope, status, datecreated)
-- VALUES
-- (15, 210, 1, 1, 1, 1, 0, 'all', 'all', 1, UNIX_TIMESTAMP());
--
-- Giải thích:
-- - rp_role_id = 15 (HR Manager role)
-- - rp_permission_id = 210 (erp.employee.manage permission)
-- - rp_object_type = 0 (Global - không giới hạn object)
-- - rp_object_ids = 'all'
-- - rp_object_scope = 'all'

-- Example 3: User có quyền check-in chỉ ở office 1 và 10
-- INSERT INTO lit_rbac_role_permission 
-- (rp_role_id, rp_permission_id, rp_can_read, rp_can_update, rp_object_type, rp_object_ids, rp_object_scope, status, datecreated)
-- VALUES
-- (20, 220, 1, 1, 11, '[1,10]', 'specific', 1, UNIX_TIMESTAMP());
--
-- Giải thích:
-- - rp_role_id = 20 (Office Manager role)
-- - rp_permission_id = 220 (erp.checkin.scheduling permission)
-- - rp_object_type = 11 (Office)
-- - rp_object_ids = [1,10] (Chỉ office 1 và 10)
