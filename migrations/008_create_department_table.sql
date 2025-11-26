-- Migration: Create Department Table
-- Description: Department/Phòng ban của công ty
-- Dependencies: lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_company_department` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Company Scope
  `c_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Company ID',
  
  -- Department Info
  `cd_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên phòng ban',
  `cd_code` varchar(50) DEFAULT NULL COMMENT 'Mã phòng ban',
  `cd_description` text COMMENT 'Mô tả phòng ban',
  
  -- Hierarchy
  `cd_parentid` int(11) unsigned DEFAULT '0' COMMENT 'Parent department ID (0 = root)',
  `cd_level` int(11) DEFAULT '0' COMMENT 'Hierarchy level',
  `cd_path` varchar(500) DEFAULT NULL COMMENT 'Hierarchy path (e.g., /1/5/10/)',
  
  -- Manager Info
  `cd_manager_id` int(11) unsigned DEFAULT '0' COMMENT 'Department manager (employee ID)',
  
  -- Display
  `cd_displayorder` int(11) DEFAULT '0' COMMENT 'Display order',
  `cd_color` varchar(20) DEFAULT NULL COMMENT 'Color code cho UI',
  `cd_icon` varchar(50) DEFAULT NULL COMMENT 'Icon name',
  
  -- Contact Info
  `cd_email` varchar(255) DEFAULT NULL COMMENT 'Department email',
  `cd_phone` varchar(20) DEFAULT NULL COMMENT 'Department phone',
  `cd_extension` varchar(20) DEFAULT NULL COMMENT 'Phone extension',
  
  -- Location
  `cd_location` varchar(255) DEFAULT NULL COMMENT 'Physical location',
  `cd_floor` varchar(50) DEFAULT NULL COMMENT 'Floor number',
  
  -- Metadata
  `cd_employee_count` int(11) DEFAULT '0' COMMENT 'Số lượng nhân viên (denormalized)',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  KEY `idx_company` (`c_id`),
  KEY `idx_parent` (`cd_parentid`),
  KEY `idx_manager` (`cd_manager_id`),
  KEY `idx_status` (`status`),
  KEY `idx_company_status` (`c_id`, `status`),
  KEY `idx_level` (`cd_level`),
  
  CONSTRAINT `fk_department_company` FOREIGN KEY (`c_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company departments';

-- Index cho hierarchy queries
CREATE INDEX `idx_path` ON `lit_company_department` (`cd_path`(255));
CREATE INDEX `idx_company_parent` ON `lit_company_department` (`c_id`, `cd_parentid`);
