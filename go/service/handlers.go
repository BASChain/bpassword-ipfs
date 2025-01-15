package service

import (
	"encoding/json"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	log "github.com/sirupsen/logrus"
	"net/http"
	"time"
)

func commonUpdateCheck(w http.ResponseWriter, r *http.Request, updateReq *UpdateRequest) bool {
	if err := decodeJSON(r, &updateReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body: "+err.Error())
		log.Info("JSON decode error:", err)
		return false
	}

	// 输入验证
	if err := updateReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Info("Validation error:", err)
		return false
	}
	return true
}

// UpdateData 更新数据的处理函数，将数据保存到 Firestore 并返回 EncodedData 实例
func UpdateData(w http.ResponseWriter, r *http.Request) {
	var updateReq UpdateRequest
	success := commonUpdateCheck(w, r, &updateReq)
	if !success {
		return
	}

	// Firestore操作
	resp, err := DbInst().CreateOrUpdateAccount(updateReq.EncodedData)
	if err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to update data")
		log.Info("Firestore update error:", err)
		return
	}

	// 返回 EncodedData 作为响应
	writeJSONResponse(w, http.StatusOK, resp)
}

func UpdateAuthData(w http.ResponseWriter, r *http.Request) {
	var updateReq UpdateRequest
	success := commonUpdateCheck(w, r, &updateReq)
	if !success {
		return
	}

	// Firestore操作
	resp, err := DbInst().UpdateAuthData(updateReq.EncodedData)
	if err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to update data")
		log.Info("Firestore update error:", err)
		return
	}

	// 返回 EncodedData 作为响应
	writeJSONResponse(w, http.StatusOK, resp)
}

func commonQueryCheck(w http.ResponseWriter, r *http.Request, queryReq *QueryRequest) bool {
	if err := decodeJSON(r, &queryReq); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Invalid request body: "+err.Error())
		log.Info("JSON decode error:", err)
		return false
	}

	// 输入验证
	if err := queryReq.Validate(); err != nil {
		writeErrorResponse(w, http.StatusBadRequest, "Validation error: "+err.Error())
		log.Info("Validation error:", err)
		return false
	}
	return true
}

// QueryData 查询数据的处理函数，从 Firestore 获取数据并返回 EncodedData 实例
func QueryData(w http.ResponseWriter, r *http.Request) {
	var queryReq QueryRequest
	success := commonQueryCheck(w, r, &queryReq)
	if !success {
		return
	}
	data, err := DbInst().GetByAccount(queryReq.WalletAddr)
	if err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to query data")
		log.Info("Firestore query error:", err)
		return
	}

	writeJSONResponse(w, http.StatusOK, data)
}

func QueryAuthData(w http.ResponseWriter, r *http.Request) {
	var queryReq QueryRequest
	success := commonQueryCheck(w, r, &queryReq)
	if !success {
		return
	}
	data, err := DbInst().GetAuthByAccount(queryReq.WalletAddr)
	if err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Failed to query data")
		log.Info("Firestore query error:", err)
		return
	}

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
		expectedKey := getEnv("BPASSWORD_API_KEY", "")
		if apiKey != expectedKey {
			log.Errorf("Invalid API key: %s", apiKey)
			writeErrorResponse(w, http.StatusUnauthorized, "Invalid API Key")
			return
		}
		next.ServeHTTP(w, r)
	})
}

func TimeoutMiddleware(next http.Handler) http.Handler {
	return http.TimeoutHandler(next, 20*time.Second, "Request timeout")
}

func NewServer() *http.Server {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(TimeoutMiddleware)

	r.Use(apiKeyAuth) // 应用认证中间件
	r.Post("/updateData", UpdateData)
	r.Post("/queryData", QueryData)
	r.Post("/updateAuthData", UpdateAuthData)
	r.Post("/queryAuthData", QueryAuthData)

	// 创建 HTTP 服务器
	srv := &http.Server{
		Addr:    _conf.Addr,
		Handler: r,
	}
	return srv
}
