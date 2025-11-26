-- Migration: Create Office Table
-- Description: Office/Văn phòng của công ty
-- Dependencies: lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_company_office` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Company Scope
  `c_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Company ID',
  
  -- Office Info
  `co_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên văn phòng',
  `co_code` varchar(50) DEFAULT NULL COMMENT 'Mã văn phòng',
  `co_description` text COMMENT 'Mô tả văn phòng',
  
  -- Type
  `co_type` int(11) DEFAULT '1' COMMENT '1=main office, 2=branch, 3=remote',
  `co_is_headquarters` tinyint(1) DEFAULT '0' COMMENT 'Có phải trụ sở chính không',
  
  -- Address Info
  `co_address` text COMMENT 'Địa chỉ',
  `co_city` varchar(100) DEFAULT NULL COMMENT 'Thành phố',
  `co_state` varchar(100) DEFAULT NULL COMMENT 'Tỉnh/Bang',
  `co_country` varchar(100) DEFAULT 'Vietnam' COMMENT 'Quốc gia',
  `co_postal_code` varchar(20) DEFAULT NULL COMMENT 'Mã bưu điện',
  
  -- Coordinates
  `co_latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude',
  `co_longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude',
  `co_radius` int(11) DEFAULT '100' COMMENT 'Check-in radius (meters)',
  
  -- Contact Info
  `co_email` varchar(255) DEFAULT NULL COMMENT 'Office email',
  `co_phone` varchar(20) DEFAULT NULL COMMENT 'Office phone',
  `co_fax` varchar(20) DEFAULT NULL COMMENT 'Fax number',
  
  -- Manager Info
  `co_manager_id` int(11) unsigned DEFAULT '0' COMMENT 'Office manager (employee ID)',
  
  -- Working Hours
  `co_working_hours` text COMMENT 'Working hours (JSON format)',
  `co_timezone` varchar(50) DEFAULT 'Asia/Ho_Chi_Minh' COMMENT 'Timezone',
  
  -- Capacity
  `co_capacity` int(11) DEFAULT '0' COMMENT 'Maximum employee capacity',
  `co_employee_count` int(11) DEFAULT '0' COMMENT 'Current employee count (denormalized)',
  
  -- Display
  `co_displayorder` int(11) DEFAULT '0' COMMENT 'Display order',
  `co_color` varchar(20) DEFAULT NULL COMMENT 'Color code cho UI',
  `co_icon` varchar(50) DEFAULT NULL COMMENT 'Icon name',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive, 2=temporarily closed',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  KEY `idx_company` (`c_id`),
  KEY `idx_manager` (`co_manager_id`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`co_type`),
  KEY `idx_company_status` (`c_id`, `status`),
  KEY `idx_headquarters` (`co_is_headquarters`),
  
  CONSTRAINT `fk_office_company` FOREIGN KEY (`c_id`) REFERENCES `lit_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company offices';

-- Index cho location-based queries
CREATE INDEX `idx_coordinates` ON `lit_company_office` (`co_latitude`, `co_longitude`);
CREATE INDEX `idx_city` ON `lit_company_office` (`co_city`);
