package service

import "os"

// Config 存储应用程序的配置
type Config struct {
	Addr       string
	ProjectID  string
	DatabaseID string
	KeyFile    string
}

// getEnv 获取环境变量或返回默认值
func getEnv(key, defaultVal string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultVal
}

var _conf = &Config{
	Addr:       getEnv("ADDR", "127.0.0.1:5002"),
	ProjectID:  getEnv("PROJECT_ID", "dessage"),
	DatabaseID: getEnv("DATABASE_ID", "bpassword"),
	KeyFile:    getEnv("KEY_FILE", "dessage-c3b5c95267fb.json"),
}

func GetAddr() string {
	return _conf.Addr
}
