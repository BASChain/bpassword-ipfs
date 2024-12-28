package main

import (
	"context"
	"github.com/BASChain/bpassword-ipfs/go/service"
	"github.com/joho/godotenv"
	log "github.com/sirupsen/logrus"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func init() {
	// 加载.env文件
	if err := godotenv.Load(); err != nil {
		log.Info("No .env file found, using environment variables")
	}
	// 设置日志格式为JSON
	log.SetFormatter(&log.JSONFormatter{})
	// 设置日志级别
	log.SetLevel(log.InfoLevel)
}

func main() {
	serverErrors := make(chan error, 1)
	srv := service.NewServer()
	// 启动服务器
	go func() {
		log.Info("Starting server on", service.GetAddr())
		serverErrors <- srv.ListenAndServe()
	}()

	waitSignal(serverErrors)

	shutDown(srv)
}

// 监听中断信号（如 Ctrl+C）
func waitSignal(serverErrors chan error) {
	sigint := make(chan os.Signal, 1)
	signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)

	// 阻塞，直到收到中断信号或服务器错误
	select {
	case err := <-serverErrors:
		log.Fatalf("Server error: %v", err)
	case <-sigint:
		log.Info("Shutdown signal received")
	}

}

// 创建带超时的上下文进行优雅关闭
func shutDown(srv *http.Server) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 尝试优雅关闭服务器
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server shutdown failed: %v", err)
	}

	// 关闭 Firestore 客户端
	service.DbInst().Close()
	log.Info("Server gracefully stopped")
}
