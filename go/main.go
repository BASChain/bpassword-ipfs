package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"google.golang.org/api/option"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// DbManager 管理 Firestore 客户端
type DbManager struct {
	fileCli *firestore.Client
	ctx     context.Context
	cancel  context.CancelFunc
}

const (
	BPasswordTable = "AccountData"
)

var (
	_dbInst      *DbManager
	databaseOnce sync.Once
	_conf        = &Config{
		Addr:       getEnv("ADDR", "127.0.0.1:5002"),
		ProjectID:  getEnv("PROJECT_ID", "dessage"),
		DatabaseID: getEnv("DATABASE_ID", "bpassword"),
		KeyFile:    getEnv("KEY_FILE", "dessage-c3b5c95267fb.json"),
	}
)

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

// DbInst 获取 DbManager 实例
func DbInst() *DbManager {
	databaseOnce.Do(func() {
		_dbInst = newDb()
	})
	return _dbInst
}

// newDb 初始化 Firestore 客户端
func newDb() *DbManager {
	ctx, cancel := context.WithCancel(context.Background())
	client, err := firestore.NewClient(ctx, _conf.ProjectID, option.WithCredentialsFile(_conf.KeyFile))
	if err != nil {
		panic(fmt.Sprintf("Failed to create Firestore client: %v", err))
	}
	return &DbManager{
		fileCli: client,
		ctx:     ctx,
		cancel:  cancel,
	}
}

// UpdateRequest 更新数据的请求体结构
type UpdateRequest struct {
	WalletAddr  string `json:"wallet_addr" firestore:"wallet_addr"`
	EncodeValue string `json:"encode_value"  firestore:"encode_value"`
}

// Validate 验证 UpdateRequest 的有效性
func (req *UpdateRequest) Validate() error {
	if req.WalletAddr == "" {
		return fmt.Errorf("wallet_addr is required")
	}
	if req.EncodeValue == "" {
		return fmt.Errorf("encode_value is required")
	}
	// 添加更多验证规则，如正则表达式匹配等
	return nil
}

// QueryRequest 查询数据的请求体结构
type QueryRequest struct {
	WalletAddr string `json:"wallet_addr" firestore:"wallet_addr"`
}

// Validate 验证 QueryRequest 的有效性
func (req *QueryRequest) Validate() error {
	if req.WalletAddr == "" {
		return fmt.Errorf("wallet_addr is required")
	}
	// 添加更多验证规则，如正则表达式匹配等
	return nil
}

// Firestore操作函数

// CreateOrUpdateAccount 将UpdateRequest保存到Firestore
func CreateOrUpdateAccount(ctx context.Context, updateReq UpdateRequest) error {
	collection := DbInst().fileCli.Collection(BPasswordTable)
	_, err := collection.Doc(updateReq.WalletAddr).Set(ctx, map[string]interface{}{
		"wallet_addr":  updateReq.WalletAddr,
		"encode_value": updateReq.EncodeValue,
	})
	return err
}

// GetAccount 从Firestore获取UpdateRequest
func GetAccount(ctx context.Context, walletAddr string) (UpdateRequest, error) {
	doc, err := DbInst().fileCli.Collection(BPasswordTable).Doc(walletAddr).Get(ctx)
	if err != nil {
		return UpdateRequest{}, err
	}

	var data UpdateRequest
	if err := doc.DataTo(&data); err != nil {
		return UpdateRequest{}, err
	}

	return data, nil
}

// 公共函数

// decodeJSON 解析JSON请求体
func decodeJSON(r *http.Request, v interface{}) error {
	if r.Method != http.MethodPost {
		return fmt.Errorf("invalid request method")
	}
	decoder := json.NewDecoder(r.Body)
	return decoder.Decode(v)
}

// writeJSONResponse 写入JSON响应
func writeJSONResponse(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to encode response")
		log.Println("Response encoding error:", err)
	}
}

// writeErrorResponse 写入错误响应
func writeErrorResponse(w http.ResponseWriter, statusCode int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	resp := map[string]string{
		"error": message,
	}
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		log.Println("Failed to write error response:", err)
	}
}

// 处理函数

// updateData 更新数据的处理函数，将数据保存到 Firestore 并返回 UpdateRequest 实例
func updateData(w http.ResponseWriter, r *http.Request) {
	var updateReq UpdateRequest
	if err := decodeJSON(r, &updateReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body:"+err.Error())
		log.Println("JSON decode error:", err)
		return
	}

	// 输入验证
	if err := updateReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Println("Validation error:", err)
		return
	}

	// Firestore操作
	if err := CreateOrUpdateAccount(r.Context(), updateReq); err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to update data")
		log.Println("Firestore update error:", err)
		return
	}

	// 返回 UpdateRequest 作为响应
	writeJSONResponse(w, http.StatusOK, updateReq)
}

// queryData 查询数据的处理函数，从 Firestore 获取数据并返回 UpdateRequest 实例
func queryData(w http.ResponseWriter, r *http.Request) {

	var queryReq QueryRequest
	if err := decodeJSON(r, &queryReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body:"+err.Error())
		log.Println("JSON decode error:", err)
		return
	}

	// 输入验证
	if err := queryReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Println("Validation error:", err)
		return
	}

	// Firestore操作
	data, err := GetAccount(r.Context(), queryReq.WalletAddr)
	if err != nil {
		if status.Code(err) == codes.NotFound {
			writeErrorResponse(w, http.StatusNotFound, "Data not found")
			return
		}
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to query data")
		log.Println("Firestore query error:", err)
		return
	}

	// 返回 UpdateRequest 作为响应
	writeJSONResponse(w, http.StatusOK, data)
}

func main() {
	// 初始化 Firestore 客户端
	DbInst()

	// 设置路由
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Post("/updateData", updateData)
	r.Post("/queryData", queryData)

	// 创建 HTTP 服务器
	srv := &http.Server{
		Addr:    _conf.Addr,
		Handler: r,
	}

	// 启动服务器的错误通道
	serverErrors := make(chan error, 1)

	// 启动服务器
	go func() {
		log.Println("Starting server on", _conf.Addr)
		serverErrors <- srv.ListenAndServe()
	}()

	// 监听中断信号（如 Ctrl+C）
	sigint := make(chan os.Signal, 1)
	signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)

	// 阻塞，直到收到中断信号或服务器错误
	select {
	case err := <-serverErrors:
		log.Fatalf("Server error: %v", err)
	case <-sigint:
		log.Println("Shutdown signal received")
	}

	// 创建带超时的上下文进行优雅关闭
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 尝试优雅关闭服务器
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server shutdown failed: %v", err)
	}

	// 关闭 Firestore 客户端
	DbInst().cancel()
	if err := DbInst().fileCli.Close(); err != nil {
		log.Fatalf("Firestore client close failed: %v", err)
	}

	log.Println("Server gracefully stopped")
}
