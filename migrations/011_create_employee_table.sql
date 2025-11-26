-- Migration: Create Employee Table
-- Description: Employee/Nhân viên của công ty
-- Dependencies: lit_company, lit_user, lit_company_department, lit_company_office, lit_company_position
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_company_employee` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Company & User Reference
  `c_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Company ID',
  `u_id` int(11) unsigned DEFAULT '0' COMMENT 'User ID (linked account)',
  
  -- Organization Structure
  `cd_id` int(11) unsigned DEFAULT '0' COMMENT 'Department ID',
  `co_id` int(11) unsigned DEFAULT '0' COMMENT 'Office ID',
  `cp_id` int(11) unsigned DEFAULT '0' COMMENT 'Position ID',
  
  -- Personal Info
  `ce_internalid` varchar(50) DEFAULT NULL COMMENT 'Internal employee ID',
  `ce_fullname` varchar(255) NOT NULL DEFAULT '' COMMENT 'Full name',
  `ce_firstname` varchar(100) DEFAULT NULL COMMENT 'First name',
  `ce_lastname` varchar(100) DEFAULT NULL COMMENT 'Last name',
  `ce_email` varchar(255) DEFAULT NULL COMMENT 'Work email',
  `ce_personal_email` varchar(255) DEFAULT NULL COMMENT 'Personal email',
  `ce_phone` varchar(20) DEFAULT NULL COMMENT 'Work phone',
  `ce_personal_phone` varchar(20) DEFAULT NULL COMMENT 'Personal phone',
  
  -- Identity Info
  `ce_gender` int(11) DEFAULT '0' COMMENT '0=other, 1=male, 2=female',
  `ce_birthday` int(11) unsigned DEFAULT '0' COMMENT 'Birthday (Unix timestamp)',
  `ce_birthplace` varchar(255) DEFAULT NULL COMMENT 'Place of birth',
  `ce_nationality` varchar(100) DEFAULT 'Vietnam' COMMENT 'Nationality',
  `ce_id_number` varchar(50) DEFAULT NULL COMMENT 'ID card/Passport number',
  `ce_id_issued_date` int(11) unsigned DEFAULT '0' COMMENT 'ID issued date',
  `ce_id_issued_place` varchar(255) DEFAULT NULL COMMENT 'ID issued place',
  
  -- Address Info
  `ce_address` text COMMENT 'Current address',
  `ce_city` varchar(100) DEFAULT NULL COMMENT 'City',
  `ce_state` varchar(100) DEFAULT NULL COMMENT 'State/Province',
  `ce_country` varchar(100) DEFAULT 'Vietnam' COMMENT 'Country',
  `ce_postal_code` varchar(20) DEFAULT NULL COMMENT 'Postal code',
  
  -- Emergency Contact
  `ce_emergency_contact_name` varchar(255) DEFAULT NULL COMMENT 'Emergency contact name',
  `ce_emergency_contact_phone` varchar(20) DEFAULT NULL COMMENT 'Emergency contact phone',
  `ce_emergency_contact_relation` varchar(100) DEFAULT NULL COMMENT 'Relationship',
  
  -- Employment Info
  `ce_type` int(11) DEFAULT '1' COMMENT '1=full-time, 2=part-time, 3=contract, 4=intern',
  `ce_jobtitle` varchar(255) DEFAULT NULL COMMENT 'Job title',
  `ce_date_start` int(11) unsigned DEFAULT '0' COMMENT 'Start date (Unix timestamp)',
  `ce_date_end` int(11) unsigned DEFAULT '0' COMMENT 'End date (0=current)',
  `ce_probation_end` int(11) unsigned DEFAULT '0' COMMENT 'Probation end date',
  
  -- Salary Info (sensitive)
  `ce_basic_salary` decimal(15,2) DEFAULT '0.00' COMMENT 'Basic salary',
  `ce_salary_offer` decimal(15,2) DEFAULT '0.00' COMMENT 'Salary offer',
  `ce_salary_currency` varchar(10) DEFAULT 'VND' COMMENT 'Currency code',
  
  -- Manager Info
  `ce_manager_id` int(11) unsigned DEFAULT '0' COMMENT 'Direct manager (employee ID)',
  
  -- System Info
  `ce_username` varchar(100) DEFAULT NULL COMMENT 'Username for login',
  `ce_lastlogin` int(11) unsigned DEFAULT '0' COMMENT 'Last login timestamp',
  `ce_lastcheckin` int(11) unsigned DEFAULT '0' COMMENT 'Last check-in timestamp',
  `ce_lastcheckout` int(11) unsigned DEFAULT '0' COMMENT 'Last check-out timestamp',
  `ce_checkintype` int(11) DEFAULT '0' COMMENT 'Check-in type: 0=none, 1=office, 2=remote',
  
  -- Avatar
  `ce_avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar URL',
  `ce_avatar_file_id` int(11) unsigned DEFAULT '0' COMMENT 'Avatar file ID',
  
  -- Attendance Settings
  `ce_attendance_id` int(11) unsigned DEFAULT '0' COMMENT 'Attendance policy ID',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '0=unactivated, 1=active, 3=disabled, 5=deleted',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_company_internalid` (`c_id`, `ce_internalid`),
  KEY `idx_company` (`c_id`),
  KEY `idx_user` (`u_id`),
  KEY `idx_department` (`cd_id`),
  KEY `idx_office` (`co_id`),
  KEY `idx_position` (`cp_id`),
  KEY `idx_manager` (`ce_manager_id`),
  KEY `idx_email` (`ce_email`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`ce_type`),
  KEY `idx_company_status` (`c_id`, `status`),
  KEY `idx_birthday` (`ce_birthday`),
  KEY `idx_date_start` (`ce_date_start`),
  
  CONSTRAINT `fk_employee_company` FOREIGN KEY (`c_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_employee_user` FOREIGN KEY (`u_id`) REFERENCES `lit_user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_employee_department` FOREIGN KEY (`cd_id`) REFERENCES `lit_company_department` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_employee_office` FOREIGN KEY (`co_id`) REFERENCES `lit_company_office` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_employee_position` FOREIGN KEY (`cp_id`) REFERENCES `lit_company_position` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company employees';

-- Index cho search queries
CREATE INDEX `idx_fullname` ON `lit_company_employee` (`ce_fullname`);
CREATE INDEX `idx_company_dept_status` ON `lit_company_employee` (`c_id`, `cd_id`, `status`);
CREATE INDEX `idx_company_office_status` ON `lit_company_employee` (`c_id`, `co_id`, `status`);
