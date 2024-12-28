package service

import (
	"encoding/json"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	log "github.com/sirupsen/logrus"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"net/http"
)

// UpdateData 更新数据的处理函数，将数据保存到 Firestore 并返回 UpdateRequest 实例
func UpdateData(w http.ResponseWriter, r *http.Request) {
	var updateReq UpdateRequest
	if err := decodeJSON(r, &updateReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body: "+err.Error())
		log.Info("JSON decode error:", err)
		return
	}

	// 输入验证
	if err := updateReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Info("Validation error:", err)
		return
	}

	// Firestore操作
	if err := DbInst().CreateOrUpdateAccount(r.Context(), updateReq); err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to update data")
		log.Info("Firestore update error:", err)
		return
	}
	resp := map[string]bool{
		"success": true,
	}
	// 返回 UpdateRequest 作为响应
	writeJSONResponse(w, http.StatusOK, resp)
}

// QueryData 查询数据的处理函数，从 Firestore 获取数据并返回 UpdateRequest 实例
func QueryData(w http.ResponseWriter, r *http.Request) {
	var queryReq QueryRequest
	if err := decodeJSON(r, &queryReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body: "+err.Error())
		log.Info("JSON decode error:", err)
		return
	}

	// 输入验证
	if err := queryReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Info("Validation error:", err)
		return
	}

	// Firestore操作
	data, err := DbInst().GetAccount(r.Context(), queryReq.WalletAddr)
	if err != nil {
		if status.Code(err) == codes.NotFound {
			writeErrorResponse(w, http.StatusNotFound, "Data not found")
			return
		}
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to query data")
		log.Info("Firestore query error:", err)
		return
	}

	// 返回 UpdateRequest 作为响应
	writeJSONResponse(w, http.StatusOK, data)
}

// decodeJSON 解析JSON请求体
func decodeJSON(r *http.Request, v interface{}) error {
	decoder := json.NewDecoder(r.Body)
	return decoder.Decode(v)
}

// writeJSONResponse 写入JSON响应
func writeJSONResponse(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to encode response")
		log.Info("Response encoding error:", err)
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
		log.Info("Failed to write error response:", err)
	}
}

func apiKeyAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		apiKey := r.Header.Get("Authorization")
		expectedKey := getEnv("API_KEY", "default_api_key")

		if apiKey != expectedKey {
			writeErrorResponse(w, http.StatusUnauthorized, "Invalid API Key")
			return
		}

		next.ServeHTTP(w, r)
	})
}

func NewServer() *http.Server {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Use(apiKeyAuth) // 应用认证中间件
	r.Post("/updateData", UpdateData)
	r.Post("/queryData", QueryData)

	// 创建 HTTP 服务器
	srv := &http.Server{
		Addr:    _conf.Addr,
		Handler: r,
	}
	return srv

}
