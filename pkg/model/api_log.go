package model

type APILog struct {
	ID               uint   `gorm:"primaryKey" json:"id"`
	RequestID        string `gorm:"column:al_request_id" json:"request_id"`
	Method           string `gorm:"column:al_method" json:"method"`
	Endpoint         string `gorm:"column:al_endpoint" json:"endpoint"`
	FullURL          string `gorm:"column:al_full_url" json:"full_url"`
	
	// User Context
	UserID           *uint  `gorm:"column:al_user_id" json:"user_id"`
	CompanyID        *uint  `gorm:"column:al_company_id" json:"company_id"`
	EmployeeID       *uint  `gorm:"column:al_employee_id" json:"employee_id"`
	
	// Network Info
	IPAddress        string `gorm:"column:al_ip_address" json:"ip_address"`
	IPForwarded      string `gorm:"column:al_ip_forwarded" json:"ip_forwarded"`
	UserAgent        string `gorm:"column:al_user_agent" json:"user_agent"`
	Referer          string `gorm:"column:al_referer" json:"referer"`
	Origin           string `gorm:"column:al_origin" json:"origin"`
	
	// Domain Info
	Domain           string `gorm:"column:al_domain" json:"domain"`
	Host             string `gorm:"column:al_host" json:"host"`
	
	// Request Data
	Headers          string `gorm:"column:al_headers;type:text" json:"headers"`
	QueryParams      string `gorm:"column:al_query_params;type:text" json:"query_params"`
	RequestBody      string `gorm:"column:al_request_body;type:longtext" json:"request_body"`
	RequestSize      int    `gorm:"column:al_request_size" json:"request_size"`
	
	// Response Data
	ResponseStatus   int    `gorm:"column:al_response_status" json:"response_status"`
	ResponseBody     string `gorm:"column:al_response_body;type:longtext" json:"response_body"`
	ResponseSize     int    `gorm:"column:al_response_size" json:"response_size"`
	ResponseTime     int    `gorm:"column:al_response_time" json:"response_time"`
	
	// Error Info
	ErrorMessage     string `gorm:"column:al_error_message;type:text" json:"error_message"`
	ErrorStack       string `gorm:"column:al_error_stack;type:text" json:"error_stack"`
	
	// Platform Info
	Platform         string `gorm:"column:al_platform" json:"platform"`
	PlatformVersion  string `gorm:"column:al_platform_version" json:"platform_version"`
	AppVersion       string `gorm:"column:al_app_version" json:"app_version"`
	
	// Session Info
	SessionID        string `gorm:"column:al_session_id" json:"session_id"`
	DeviceID         string `gorm:"column:al_device_id" json:"device_id"`
	
	// Timing (milliseconds)
	TimestampStart   int64  `gorm:"column:al_timestamp_start" json:"timestamp_start"`
	TimestampEnd     int64  `gorm:"column:al_timestamp_end" json:"timestamp_end"`
	
	// Metadata
	Tags             string `gorm:"column:al_tags" json:"tags"`
	Metadata         string `gorm:"column:al_metadata;type:text" json:"metadata"`
	
	// Status
	Status           int    `gorm:"column:status;default:1" json:"status"`
	DateCreated      int64  `gorm:"column:datecreated" json:"date_created"`
	DateModified     int64  `gorm:"column:datemodified" json:"date_modified"`
}

func (APILog) TableName() string {
	return "lit_api_log"
}
