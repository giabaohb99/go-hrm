-- Migration: Create API Log Table
-- Description: Log tất cả API requests và responses để audit và debug
-- Dependencies: lit_user, lit_company
-- Created: 2025-01-01

CREATE TABLE IF NOT EXISTS `lit_api_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  
  -- Request Info
  `al_request_id` varchar(100) DEFAULT NULL COMMENT 'Unique request ID (UUID)',
  `al_method` varchar(10) NOT NULL COMMENT 'HTTP method: GET, POST, PUT, DELETE, etc.',
  `al_endpoint` varchar(500) NOT NULL COMMENT 'API endpoint path',
  `al_full_url` varchar(1000) DEFAULT NULL COMMENT 'Full URL with query params',
  
  -- User Context
  `al_user_id` int(11) unsigned DEFAULT NULL COMMENT 'User ID (if authenticated)',
  `al_company_id` int(11) unsigned DEFAULT NULL COMMENT 'Company ID (if applicable)',
  `al_employee_id` int(11) unsigned DEFAULT NULL COMMENT 'Employee ID (if applicable)',
  
  -- Network Info
  `al_ip_address` varchar(45) DEFAULT NULL COMMENT 'Client IP address (IPv4/IPv6)',
  `al_ip_forwarded` varchar(255) DEFAULT NULL COMMENT 'X-Forwarded-For header',
  `al_user_agent` varchar(500) DEFAULT NULL COMMENT 'User agent string',
  `al_referer` varchar(500) DEFAULT NULL COMMENT 'HTTP referer',
  `al_origin` varchar(255) DEFAULT NULL COMMENT 'Origin header',
  
  -- Domain/Host Info
  `al_domain` varchar(255) DEFAULT NULL COMMENT 'Request domain/hostname',
  `al_host` varchar(255) DEFAULT NULL COMMENT 'Host header',
  
  -- Request Data
  `al_headers` text COMMENT 'Request headers (JSON format)',
  `al_query_params` text COMMENT 'Query parameters (JSON format)',
  `al_request_body` longtext COMMENT 'Request body (JSON/form data)',
  `al_request_size` int(11) DEFAULT '0' COMMENT 'Request body size in bytes',
  
  -- Response Data
  `al_response_status` int(11) DEFAULT NULL COMMENT 'HTTP response status code',
  `al_response_body` longtext COMMENT 'Response body (JSON format)',
  `al_response_size` int(11) DEFAULT '0' COMMENT 'Response body size in bytes',
  `al_response_time` int(11) DEFAULT '0' COMMENT 'Response time in milliseconds',
  
  -- Error Info
  `al_error_message` text COMMENT 'Error message if any',
  `al_error_stack` text COMMENT 'Error stack trace',
  
  -- Platform Info
  `al_platform` varchar(50) DEFAULT NULL COMMENT 'Platform: web, ios, android, desktop',
  `al_platform_version` varchar(50) DEFAULT NULL COMMENT 'Platform version',
  `al_app_version` varchar(50) DEFAULT NULL COMMENT 'Application version',
  
  -- Session Info
  `al_session_id` varchar(100) DEFAULT NULL COMMENT 'Session ID or JWT hash',
  `al_device_id` varchar(100) DEFAULT NULL COMMENT 'Device identifier',
  
  -- Timing (Unix timestamps in milliseconds for precision)
  `al_timestamp_start` bigint(20) NOT NULL COMMENT 'Request start time (Unix timestamp ms)',
  `al_timestamp_end` bigint(20) DEFAULT NULL COMMENT 'Request end time (Unix timestamp ms)',
  
  -- Additional Metadata
  `al_tags` varchar(500) DEFAULT NULL COMMENT 'Tags for categorization (comma-separated)',
  `al_metadata` text COMMENT 'Additional metadata (JSON format)',
  
  -- Status
  `status` int(11) DEFAULT '1' COMMENT '1=logged, 0=archived',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT 'Soft delete flag',
  
  -- Standard Timestamps (Unix timestamp in seconds)
  `datecreated` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Unix timestamp (seconds)',
  `datemodified` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Unix timestamp (seconds)',
  
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`al_request_id`),
  KEY `idx_user` (`al_user_id`),
  KEY `idx_company` (`al_company_id`),
  KEY `idx_endpoint` (`al_endpoint`(255)),
  KEY `idx_method` (`al_method`),
  KEY `idx_status` (`al_response_status`),
  KEY `idx_ip` (`al_ip_address`),
  KEY `idx_domain` (`al_domain`),
  KEY `idx_timestamp` (`al_timestamp_start`),
  KEY `idx_user_timestamp` (`al_user_id`, `al_timestamp_start`),
  KEY `idx_company_timestamp` (`al_company_id`, `al_timestamp_start`),
  KEY `idx_endpoint_timestamp` (`al_endpoint`(100), `al_timestamp_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='API request/response logging';

-- Index for performance queries
CREATE INDEX `idx_timestamp_status` ON `lit_api_log` (`al_timestamp_start`, `al_response_status`);
CREATE INDEX `idx_error_logs` ON `lit_api_log` (`al_response_status`, `al_timestamp_start`) WHERE `al_response_status` >= 400;
