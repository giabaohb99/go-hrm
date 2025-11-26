-- Migration: Create Permission Table (RBAC Subject)
-- Description: Permission definitions (tương tự RbacSubjectItem trong PHP)
-- Dependencies: None
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_rbac_permission` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Permission Info
  `p_code` varchar(100) NOT NULL COMMENT 'Permission code (e.g., erp.employee.manage)',
  `p_name` varchar(100) NOT NULL COMMENT 'Permission name (human readable)',
  `p_description` text COMMENT 'Permission description',
  
  -- Module Classification
  `p_module` varchar(50) NOT NULL COMMENT 'Module: employee, order, inventory, etc.',
  `p_action` varchar(50) NOT NULL COMMENT 'Action: view, create, update, delete, manage',
  `p_resource` varchar(50) DEFAULT NULL COMMENT 'Resource type: employee, order, product',
  
  -- Object Type (từ RbacSubjectItem)
  `p_object_type` int(11) DEFAULT '0' COMMENT '0=global, 1=store, 3=warehouse, 11=office',
  `p_object_type_name` varchar(50) DEFAULT NULL COMMENT 'Object type name: store, warehouse, office',
  
  -- Subject ID (mapping với RbacSubjectItem.php)
  `p_subject_id` int(11) DEFAULT NULL COMMENT 'Subject ID từ RbacSubjectItem (e.g., 210, 220)',
  
  -- Grouping
  `p_group` varchar(50) DEFAULT NULL COMMENT 'Permission group: hrm, sales, inventory',
  `p_category` varchar(50) DEFAULT NULL COMMENT 'Category: basic, advanced, admin',
  `p_level` int(11) DEFAULT '0' COMMENT 'Permission level (hierarchy)',
  
  -- Metadata
  `p_is_system` tinyint(1) DEFAULT '0' COMMENT 'System permission (không thể xóa)',
  `p_is_dangerous` tinyint(1) DEFAULT '0' COMMENT 'Dangerous permission (cần cảnh báo)',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`p_code`),
  UNIQUE KEY `idx_subject_id` (`p_subject_id`),
  KEY `idx_module` (`p_module`),
  KEY `idx_object_type` (`p_object_type`),
  KEY `idx_group` (`p_group`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Permission definitions (RBAC Subject)';

-- Index cho tìm kiếm nhanh
CREATE INDEX `idx_module_action` ON `lit_rbac_permission` (`p_module`, `p_action`);
CREATE INDEX `idx_system_status` ON `lit_rbac_permission` (`p_is_system`, `status`);
