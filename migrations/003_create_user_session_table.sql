-- Migration: Create User Session Table
-- Description: JWT token management và session tracking
-- Dependencies: lit_user
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_user_session` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  
  -- User Reference
  `us_user_id` int(11) unsigned NOT NULL COMMENT 'User ID',
  
  -- Token Info
  `us_token` varchar(500) NOT NULL COMMENT 'Access token (JWT)',
  `us_refresh_token` varchar(500) DEFAULT NULL COMMENT 'Refresh token',
  `us_token_type` varchar(20) DEFAULT 'Bearer' COMMENT 'Token type',
  
  -- Session Info
  `us_ip_address` varchar(45) DEFAULT NULL COMMENT 'IP address (IPv4/IPv6)',
  `us_user_agent` varchar(500) DEFAULT NULL COMMENT 'User agent string',
  `us_device_type` varchar(50) DEFAULT NULL COMMENT 'Device type: web, mobile, desktop, tablet',
  `us_device_name` varchar(100) DEFAULT NULL COMMENT 'Device name',
  `us_browser` varchar(100) DEFAULT NULL COMMENT 'Browser name',
  `us_os` varchar(100) DEFAULT NULL COMMENT 'Operating system',
  
  -- Timing
  `us_expires_at` int(11) unsigned NOT NULL COMMENT 'Access token expiration (Unix timestamp)',
  `us_refresh_expires_at` int(11) unsigned DEFAULT NULL COMMENT 'Refresh token expiration',
  `us_last_activity` int(11) unsigned DEFAULT NULL COMMENT 'Last activity timestamp',
  
  -- Security
  `us_is_revoked` tinyint(1) DEFAULT '0' COMMENT 'Token đã bị thu hồi chưa',
  `us_revoked_at` int(11) unsigned DEFAULT NULL COMMENT 'Thời điểm thu hồi',
  `us_revoked_reason` varchar(255) DEFAULT NULL COMMENT 'Lý do thu hồi: logout, password_changed, admin_revoke',
  `us_revoked_by` int(11) unsigned DEFAULT NULL COMMENT 'User ID người thu hồi (nếu là admin)',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Timestamps
  `datecreated` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datemodified` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `datedeleted` int(11) unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token` (`us_token`(255)),
  KEY `idx_refresh_token` (`us_refresh_token`(255)),
  KEY `idx_user` (`us_user_id`),
  KEY `idx_expires` (`us_expires_at`),
  KEY `idx_revoked` (`us_is_revoked`),
  KEY `idx_status` (`status`),
  KEY `idx_user_status` (`us_user_id`, `status`, `us_is_revoked`),
  
  CONSTRAINT `fk_user_session_user` FOREIGN KEY (`us_user_id`) REFERENCES `lit_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User session và JWT token management';
