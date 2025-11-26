-- Migration: Create User-Role Mapping Table
-- Description: Mapping giữa User và Role (many-to-many)
-- Dependencies: lit_user, lit_rbac_role, lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_rbac_user_role` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Mapping
  `ur_user_id` int(11) unsigned NOT NULL COMMENT 'User ID',
  `ur_role_id` int(11) unsigned NOT NULL COMMENT 'Role ID',
  `ur_company_id` int(11) unsigned NOT NULL COMMENT 'Company ID (scope)',
  
  -- Assignment Info
  `ur_assigned_by` int(11) unsigned DEFAULT '0' COMMENT 'User ID người assign role',
  `ur_assigned_at` int(11) unsigned DEFAULT '0' COMMENT 'Thời điểm assign',
  `ur_expires_at` int(11) unsigned DEFAULT '0' COMMENT 'Thời điểm hết hạn (0 = never)',
  
  -- Scope (optional - cho object-level permissions)
  `ur_scope_type` varchar(50) DEFAULT NULL COMMENT 'Scope type: office, store, warehouse',
  `ur_scope_ids` text COMMENT 'Scope object IDs (JSON array)',
  
  -- Metadata
  `ur_notes` text COMMENT 'Ghi chú về assignment',
  `ur_is_primary` tinyint(1) DEFAULT '0' COMMENT 'Primary role của user',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive, 2=expired',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_role_company` (`ur_user_id`, `ur_role_id`, `ur_company_id`),
  KEY `idx_user` (`ur_user_id`),
  KEY `idx_role` (`ur_role_id`),
  KEY `idx_company` (`ur_company_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expires` (`ur_expires_at`),
  KEY `idx_assigned_by` (`ur_assigned_by`),
  
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`ur_user_id`) REFERENCES `lit_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`ur_role_id`) REFERENCES `lit_rbac_role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role_company` FOREIGN KEY (`ur_company_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User-Role mapping (many-to-many)';

-- Index cho tìm kiếm nhanh
CREATE INDEX `idx_user_company_status` ON `lit_rbac_user_role` (`ur_user_id`, `ur_company_id`, `status`);
CREATE INDEX `idx_role_company_status` ON `lit_rbac_user_role` (`ur_role_id`, `ur_company_id`, `status`);
CREATE INDEX `idx_primary_role` ON `lit_rbac_user_role` (`ur_user_id`, `ur_is_primary`, `status`);
