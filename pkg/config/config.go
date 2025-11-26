package config

import (
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	// Database
	DBHost     string `mapstructure:"DB_HOST"`
	DBPort     string `mapstructure:"DB_PORT"`
	DBUser     string `mapstructure:"DB_USER"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBName     string `mapstructure:"DB_NAME"`

	// JWT
	JWTSecret              string        `mapstructure:"JWT_SECRET"`
	JWTExpiresIn           time.Duration `mapstructure:"JWT_EXPIRES_IN"`
	RefreshTokenExpiresIn  time.Duration `mapstructure:"REFRESH_TOKEN_EXPIRES_IN"`

	// Service Ports
	UserServicePort     string `mapstructure:"USER_SERVICE_PORT"`
	CompanyServicePort  string `mapstructure:"COMPANY_SERVICE_PORT"`
	EmployeeServicePort string `mapstructure:"EMPLOYEE_SERVICE_PORT"`

	// Application
	AppEnv   string `mapstructure:"APP_ENV"`
	GinMode  string `mapstructure:"GIN_MODE"`
	LogLevel string `mapstructure:"LOG_LEVEL"`

	// CORS
	CORSAllowedOrigins string `mapstructure:"CORS_ALLOWED_ORIGINS"`
	CORSAllowedMethods string `mapstructure:"CORS_ALLOWED_METHODS"`
	CORSAllowedHeaders string `mapstructure:"CORS_ALLOWED_HEADERS"`

	// Rate Limiting
	RateLimitRequestsPerMinute int `mapstructure:"RATE_LIMIT_REQUESTS_PER_MINUTE"`
	RateLimitBurst             int `mapstructure:"RATE_LIMIT_BURST"`

	// Session
	SessionTimeoutMinutes int `mapstructure:"SESSION_TIMEOUT_MINUTES"`

	// Email (Optional)
	SMTPHost     string `mapstructure:"SMTP_HOST"`
	SMTPPort     string `mapstructure:"SMTP_PORT"`
	SMTPUsername string `mapstructure:"SMTP_USERNAME"`
	SMTPPassword string `mapstructure:"SMTP_PASSWORD"`
	SMTPFrom     string `mapstructure:"SMTP_FROM"`

	// File Upload
	MaxUploadSize     string `mapstructure:"MAX_UPLOAD_SIZE"`
	UploadPath        string `mapstructure:"UPLOAD_PATH"`
	AllowedFileTypes  string `mapstructure:"ALLOWED_FILE_TYPES"`

	// Redis (Optional)
	RedisHost     string `mapstructure:"REDIS_HOST"`
	RedisPort     string `mapstructure:"REDIS_PORT"`
	RedisPassword string `mapstructure:"REDIS_PASSWORD"`
	RedisDB       int    `mapstructure:"REDIS_DB"`

	// Logging
	EnableAPILogging     bool   `mapstructure:"ENABLE_API_LOGGING"`
	EnableRequestLogging bool   `mapstructure:"ENABLE_REQUEST_LOGGING"`
	LogFilePath          string `mapstructure:"LOG_FILE_PATH"`
	LogMaxSize           string `mapstructure:"LOG_MAX_SIZE"`
	LogMaxBackups        int    `mapstructure:"LOG_MAX_BACKUPS"`
	LogMaxAge            int    `mapstructure:"LOG_MAX_AGE"`

	// Security
	BCryptCost    int    `mapstructure:"BCRYPT_COST"`
	EnableHTTPS   bool   `mapstructure:"ENABLE_HTTPS"`
	SSLCertPath   string `mapstructure:"SSL_CERT_PATH"`
	SSLKeyPath    string `mapstructure:"SSL_KEY_PATH"`

	// Development
	EnableSwagger     bool `mapstructure:"ENABLE_SWAGGER"`
	EnableProfiling   bool `mapstructure:"ENABLE_PROFILING"`
	EnableDebugRoutes bool `mapstructure:"ENABLE_DEBUG_ROUTES"`

	// Company Settings
	DefaultCompanyDomain   string `mapstructure:"DEFAULT_COMPANY_DOMAIN"`
	DefaultAdminEmail      string `mapstructure:"DEFAULT_ADMIN_EMAIL"`
	DefaultAdminPassword   string `mapstructure:"DEFAULT_ADMIN_PASSWORD"`

	// Localization
	Timezone           string `mapstructure:"TIMEZONE"`
	DefaultLanguage    string `mapstructure:"DEFAULT_LANGUAGE"`
	SupportedLanguages string `mapstructure:"SUPPORTED_LANGUAGES"`
}

func LoadConfig() (config Config, err error) {
	viper.AddConfigPath(".")
	viper.SetConfigName(".env")
	viper.SetConfigType("env")

	// Set defaults
	setDefaults()

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		// It's okay if config file doesn't exist, we can use env vars
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return config, err
		}
	}

	err = viper.Unmarshal(&config)
	return
}

func setDefaults() {
	// Database defaults
	viper.SetDefault("DB_HOST", "localhost")
	viper.SetDefault("DB_PORT", "3306")
	viper.SetDefault("DB_USER", "root")
	viper.SetDefault("DB_PASSWORD", "root")
	viper.SetDefault("DB_NAME", "go_hrm")

	// JWT defaults
	viper.SetDefault("JWT_SECRET", "your_super_secret_key_change_me_in_production")
	viper.SetDefault("JWT_EXPIRES_IN", "24h")
	viper.SetDefault("REFRESH_TOKEN_EXPIRES_IN", "168h")

	// Service ports
	viper.SetDefault("USER_SERVICE_PORT", "8081")
	viper.SetDefault("COMPANY_SERVICE_PORT", "8082")
	viper.SetDefault("EMPLOYEE_SERVICE_PORT", "8083")

	// Application
	viper.SetDefault("APP_ENV", "development")
	viper.SetDefault("GIN_MODE", "debug")
	viper.SetDefault("LOG_LEVEL", "info")

	// CORS
	viper.SetDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:8080")
	viper.SetDefault("CORS_ALLOWED_METHODS", "GET,POST,PUT,DELETE,OPTIONS")
	viper.SetDefault("CORS_ALLOWED_HEADERS", "Origin,Content-Type,Accept,Authorization,X-Requested-With")

	// Rate limiting
	viper.SetDefault("RATE_LIMIT_REQUESTS_PER_MINUTE", 60)
	viper.SetDefault("RATE_LIMIT_BURST", 10)

	// Session
	viper.SetDefault("SESSION_TIMEOUT_MINUTES", 1440)

	// File upload
	viper.SetDefault("MAX_UPLOAD_SIZE", "10MB")
	viper.SetDefault("UPLOAD_PATH", "./uploads")
	viper.SetDefault("ALLOWED_FILE_TYPES", "jpg,jpeg,png,pdf,doc,docx")

	// Redis
	viper.SetDefault("REDIS_HOST", "redis")
	viper.SetDefault("REDIS_PORT", "6379")
	viper.SetDefault("REDIS_DB", 0)

	// Logging
	viper.SetDefault("ENABLE_API_LOGGING", true)
	viper.SetDefault("ENABLE_REQUEST_LOGGING", true)
	viper.SetDefault("LOG_FILE_PATH", "./logs/app.log")
	viper.SetDefault("LOG_MAX_SIZE", "100MB")
	viper.SetDefault("LOG_MAX_BACKUPS", 5)
	viper.SetDefault("LOG_MAX_AGE", 30)

	// Security
	viper.SetDefault("BCRYPT_COST", 12)
	viper.SetDefault("ENABLE_HTTPS", false)

	// Development
	viper.SetDefault("ENABLE_SWAGGER", true)
	viper.SetDefault("ENABLE_PROFILING", false)
	viper.SetDefault("ENABLE_DEBUG_ROUTES", false)

	// Company
	viper.SetDefault("DEFAULT_COMPANY_DOMAIN", "example.com")
	viper.SetDefault("DEFAULT_ADMIN_EMAIL", "admin@example.com")
	viper.SetDefault("DEFAULT_ADMIN_PASSWORD", "admin123")

	// Localization
	viper.SetDefault("TIMEZONE", "Asia/Ho_Chi_Minh")
	viper.SetDefault("DEFAULT_LANGUAGE", "vi")
	viper.SetDefault("SUPPORTED_LANGUAGES", "vi,en")
}
