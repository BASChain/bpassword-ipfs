package utils

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
)

func SendPostRequest(url, token string, param any) ([]byte, error) {

	jsonData, err := json.Marshal(param)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		LogInst().Fatalf("创建请求失败: %v", err)
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	// 设置 Authorization 头
	req.Header.Set("Authorization", token)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		LogInst().Fatalf("发送请求失败: %v", err)
		return nil, err
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		LogInst().Fatalf("读取响应失败: %v", err)
		return nil, err
	}

	return body, nil
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
