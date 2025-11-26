-- Migration: Create User Table
-- Description: User authentication và profile
-- Dependencies: None
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Authentication
  `u_username` varchar(100) DEFAULT NULL COMMENT 'Username (optional)',
  `u_email` varchar(255) NOT NULL COMMENT 'Email (unique, required)',
  `u_password` varchar(255) NOT NULL COMMENT 'Hashed password (bcrypt)',
  
  -- Personal Info
  `u_first_name` varchar(100) DEFAULT NULL COMMENT 'Tên',
  `u_last_name` varchar(100) DEFAULT NULL COMMENT 'Họ',
  `u_full_name` varchar(255) DEFAULT NULL COMMENT 'Họ và tên đầy đủ',
  `u_phone` varchar(20) DEFAULT NULL COMMENT 'Số điện thoại',
  `u_avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar URL',
  `u_avatar_file_id` int(11) unsigned DEFAULT '0' COMMENT 'Avatar file ID',
  
  -- System Info
  `u_last_login` int(11) unsigned DEFAULT '0' COMMENT 'Last login timestamp',
  `u_last_login_ip` varchar(45) DEFAULT NULL COMMENT 'Last login IP (IPv4/IPv6)',
  `u_login_count` int(11) DEFAULT '0' COMMENT 'Số lần đăng nhập',
  
  -- Security
  `u_email_verified` tinyint(1) DEFAULT '0' COMMENT 'Email đã xác thực chưa',
  `u_email_verified_at` int(11) unsigned DEFAULT NULL COMMENT 'Thời điểm xác thực email',
  `u_password_reset_token` varchar(255) DEFAULT NULL COMMENT 'Token reset password',
  `u_password_reset_expires` int(11) unsigned DEFAULT NULL COMMENT 'Token expiration',
  
  -- Settings
  `u_timezone` varchar(50) DEFAULT 'Asia/Ho_Chi_Minh' COMMENT 'Múi giờ',
  `u_language` varchar(10) DEFAULT 'vi' COMMENT 'Ngôn ngữ',
  `u_settings` text COMMENT 'User settings (JSON format)',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '0=inactive, 1=active, 2=suspended, 5=deleted',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_email` (`u_email`),
  UNIQUE KEY `idx_username` (`u_username`),
  KEY `idx_status` (`status`),
  KEY `idx_deleted` (`is_deleted`),
  KEY `idx_email_verified` (`u_email_verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User authentication table';
