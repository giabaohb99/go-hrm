-- Migration: Create Position Table
-- Description: Position/Chức vụ của nhân viên
-- Dependencies: lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_company_position` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Company Scope
  `c_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Company ID',
  
  -- Position Info
  `cp_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên chức vụ',
  `cp_code` varchar(50) DEFAULT NULL COMMENT 'Mã chức vụ',
  `cp_description` text COMMENT 'Mô tả chức vụ',
  
  -- Hierarchy
  `cp_level` int(11) DEFAULT '0' COMMENT 'Position level (0=lowest, higher=more senior)',
  `cp_rank` int(11) DEFAULT '0' COMMENT 'Position rank',
  
  -- Category
  `cp_category` varchar(50) DEFAULT NULL COMMENT 'Category: management, technical, support, etc.',
  `cp_type` int(11) DEFAULT '1' COMMENT '1=full-time, 2=part-time, 3=contract, 4=intern',
  
  -- Salary Range
  `cp_salary_min` decimal(15,2) DEFAULT NULL COMMENT 'Minimum salary',
  `cp_salary_max` decimal(15,2) DEFAULT NULL COMMENT 'Maximum salary',
  `cp_salary_currency` varchar(10) DEFAULT 'VND' COMMENT 'Currency code',
  
  -- Requirements
  `cp_requirements` text COMMENT 'Job requirements (JSON format)',
  `cp_responsibilities` text COMMENT 'Job responsibilities (JSON format)',
  `cp_qualifications` text COMMENT 'Required qualifications (JSON format)',
  
  -- Metadata
  `cp_employee_count` int(11) DEFAULT '0' COMMENT 'Số lượng nhân viên (denormalized)',
  `cp_max_employees` int(11) DEFAULT '0' COMMENT 'Maximum employees for this position (0=unlimited)',
  
  -- Display
  `cp_displayorder` int(11) DEFAULT '0' COMMENT 'Display order',
  `cp_color` varchar(20) DEFAULT NULL COMMENT 'Color code cho UI',
  `cp_icon` varchar(50) DEFAULT NULL COMMENT 'Icon name',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive, 2=archived',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  KEY `idx_company` (`c_id`),
  KEY `idx_status` (`status`),
  KEY `idx_level` (`cp_level`),
  KEY `idx_category` (`cp_category`),
  KEY `idx_type` (`cp_type`),
  KEY `idx_company_status` (`c_id`, `status`),
  
  CONSTRAINT `fk_position_company` FOREIGN KEY (`c_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company positions';

-- Index cho salary range queries
CREATE INDEX `idx_salary_range` ON `lit_company_position` (`cp_salary_min`, `cp_salary_max`);
