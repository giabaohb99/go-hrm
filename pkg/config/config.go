package config

import (
	"github.com/spf13/viper"
)

type Config struct {
	DBHost     string `mapstructure:"DB_HOST"`
	DBPort     string `mapstructure:"DB_PORT"`
	DBUser     string `mapstructure:"DB_USER"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBName     string `mapstructure:"DB_NAME"`
	JWTSecret  string `mapstructure:"JWT_SECRET"`
}

func LoadConfig() (config Config, err error) {
	viper.AddConfigPath(".")
	viper.SetConfigName("app")
	viper.SetConfigType("env")

	// Bind environment variables explicitly
	viper.BindEnv("DB_HOST")
	viper.BindEnv("DB_PORT")
	viper.BindEnv("DB_USER")
	viper.BindEnv("DB_PASSWORD")
	viper.BindEnv("DB_NAME")
	viper.BindEnv("JWT_SECRET")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		// It's okay if config file doesn't exist, we can use env vars
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			// Ignore file not found error, continue with env vars
			err = nil
		}
	}

	err = viper.Unmarshal(&config)
	return
}
