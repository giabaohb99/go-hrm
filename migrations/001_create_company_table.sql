-- Migration: Create Company Table
-- Description: Company là nền tảng của hệ thống multi-tenancy
-- Dependencies: None
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_company` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Owner Info
  `c_owner_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'User ID của owner/người tạo company',
  
  -- Basic Info
  `c_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên công ty',
  `c_code` varchar(50) DEFAULT NULL COMMENT 'Mã công ty (unique)',
  `c_domain` varchar(100) DEFAULT NULL COMMENT 'Subdomain (e.g., abc.cropany.com)',
  `c_screenname` varchar(100) DEFAULT NULL COMMENT 'Screen name/slug',
  `c_email` varchar(255) DEFAULT NULL COMMENT 'Email công ty',
  `c_phone` varchar(20) DEFAULT NULL COMMENT 'Số điện thoại',
  `c_website` varchar(255) DEFAULT NULL COMMENT 'Website',
  
  -- Address Info
  `c_address` text COMMENT 'Địa chỉ',
  `c_city` varchar(100) DEFAULT NULL COMMENT 'Thành phố',
  `c_state` varchar(100) DEFAULT NULL COMMENT 'Tỉnh/Bang',
  `c_country` varchar(100) DEFAULT 'Vietnam' COMMENT 'Quốc gia',
  `c_postal_code` varchar(20) DEFAULT NULL COMMENT 'Mã bưu điện',
  
  -- Business Info
  `c_tax_number` varchar(50) DEFAULT NULL COMMENT 'Mã số thuế',
  `c_business_license` varchar(100) DEFAULT NULL COMMENT 'Giấy phép kinh doanh',
  `c_industry` varchar(100) DEFAULT NULL COMMENT 'Ngành nghề',
  
  -- System Info
  `c_logo_file_id` int(11) unsigned DEFAULT '0' COMMENT 'ID file logo',
  `c_timezone` varchar(50) DEFAULT 'Asia/Ho_Chi_Minh' COMMENT 'Múi giờ',
  `c_currency` varchar(10) DEFAULT 'VND' COMMENT 'Đơn vị tiền tệ',
  `c_language` varchar(10) DEFAULT 'vi' COMMENT 'Ngôn ngữ mặc định',
  
  -- Settings (JSON)
  `c_settings` text COMMENT 'Cấu hình công ty (JSON format)',
  
  -- Plan & Quota
  `c_plan` int(11) DEFAULT '1' COMMENT 'Gói dịch vụ: 1=Basic, 2=Pro, 3=Enterprise, 100=On-premise',
  `c_quota` text COMMENT 'Quota override (JSON format)',
  `c_region` int(11) DEFAULT '0' COMMENT 'Region/Tenant ID',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive, 3=suspended',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`c_code`),
  UNIQUE KEY `idx_domain` (`c_domain`),
  KEY `idx_owner` (`c_owner_id`),
  KEY `idx_status` (`status`),
  KEY `idx_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company table - Multi-tenancy foundation';
