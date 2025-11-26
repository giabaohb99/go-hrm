-- Migration: Create Role Table
-- Description: Role definitions cho RBAC system
-- Dependencies: lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_rbac_role` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Company Scope
  `r_company_id` int(11) unsigned NOT NULL COMMENT 'Company ID (multi-tenancy)',
  
  -- Role Info
  `r_code` varchar(50) NOT NULL COMMENT 'Role code (unique within company)',
  `r_name` varchar(100) NOT NULL COMMENT 'Role name',
  `r_description` text COMMENT 'Role description',
  
  -- Role Properties
  `r_is_system_role` tinyint(1) DEFAULT '0' COMMENT 'System role (không thể xóa/sửa)',
  `r_is_default` tinyint(1) DEFAULT '0' COMMENT 'Default role cho new users',
  `r_level` int(11) DEFAULT '0' COMMENT 'Role hierarchy level (0=lowest)',
  `r_priority` int(11) DEFAULT '0' COMMENT 'Priority (số càng cao càng ưu tiên)',
  
  -- Metadata
  `r_creator_id` int(11) unsigned DEFAULT '0' COMMENT 'User ID người tạo',
  `r_color` varchar(20) DEFAULT NULL COMMENT 'Color code cho UI (e.g., #FF5733)',
  `r_icon` varchar(50) DEFAULT NULL COMMENT 'Icon name',
  
  -- Permissions Summary (denormalized for performance)
  `r_permissions_count` int(11) DEFAULT '0' COMMENT 'Số lượng permissions',
  `r_users_count` int(11) DEFAULT '0' COMMENT 'Số lượng users có role này',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_company_code` (`r_company_id`, `r_code`),
  KEY `idx_company` (`r_company_id`),
  KEY `idx_status` (`status`),
  KEY `idx_system_role` (`r_is_system_role`),
  KEY `idx_default` (`r_is_default`),
  KEY `idx_level` (`r_level`),
  
  CONSTRAINT `fk_role_company` FOREIGN KEY (`r_company_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Role definitions for RBAC';

-- Index cho tìm kiếm nhanh
CREATE INDEX `idx_company_status` ON `lit_rbac_role` (`r_company_id`, `status`);
CREATE INDEX `idx_company_default` ON `lit_rbac_role` (`r_company_id`, `r_is_default`, `status`);
