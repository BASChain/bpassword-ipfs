package utils

import (
	"bytes"
	"encoding/json"
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

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		LogInst().Fatalf("读取响应失败: %v", err)
		return nil, err
	}

	return body, nil
}
