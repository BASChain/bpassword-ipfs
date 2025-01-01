package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func SendPostRequest(url, token string, param any) ([]byte, error) {

	jsonData, err := json.Marshal(param)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		LogInst().Errorf("------>>>创建请求失败: %v", err)
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	// 设置 Authorization 头
	req.Header.Set("Authorization", token)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		LogInst().Errorf("------>>>发送请求失败: %v", err)
		return nil, err
	}

	defer resp.Body.Close()

	// 检查状态码
	if resp.StatusCode == http.StatusUnauthorized {
		LogInst().Errorf("------>>>请求未授权，状态码: %d", resp.StatusCode)
		return nil, fmt.Errorf("unauthorized request, status code: %d", resp.StatusCode)
	} else if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		LogInst().Errorf("------>>>请求失败，状态码: %d", resp.StatusCode)
		return nil, fmt.Errorf("request failed, status code: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		LogInst().Fatalf("读取响应失败: %v", err)
		return nil, err
	}

	return body, nil
}
