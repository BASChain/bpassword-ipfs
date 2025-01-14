package LockLib

import (
	"fmt"
	"testing"
	"time"
)

// TestParseTOTP 测试 parseTOTP 函数
func TestParseTOTP(t *testing.T) {
	// 定义测试用例
	tests := []struct {
		name        string
		otpauthStr  string
		expected    *TOTPConfig
		expectError bool
	}{
		{
			name:       "有效的 TOTP URI",
			otpauthStr: "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&algorithm=SHA1&digits=6&period=30",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google",
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA1",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
		{
			name:        "缺少 secret 参数",
			otpauthStr:  "otpauth://totp/Google:alice@example.com?issuer=Google&algorithm=SHA1&digits=6&period=30",
			expected:    nil,
			expectError: true,
		},
		{
			name:        "无效的 Scheme",
			otpauthStr:  "http://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google",
			expected:    nil,
			expectError: true,
		},
		{
			name:        "无效的类型",
			otpauthStr:  "otpauth://invalid/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google",
			expected:    nil,
			expectError: true,
		},
		{
			name:        "无效的算法",
			otpauthStr:  "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&algorithm=MD5",
			expected:    nil,
			expectError: true,
		},
		{
			name:        "无效的 digits 参数",
			otpauthStr:  "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&digits=5",
			expected:    nil,
			expectError: true,
		},
		{
			name:        "无效的 period 参数",
			otpauthStr:  "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&period=-10",
			expected:    nil,
			expectError: true,
		},
		{
			name:       "标签中不包含 Issuer",
			otpauthStr: "otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google",
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA1",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
		{
			name:       "标签和 issuer 参数不一致",
			otpauthStr: "otpauth://totp/OtherIssuer:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google", // issuer 参数优先于标签中的 Issuer
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA1",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
		{
			name:       "使用默认参数",
			otpauthStr: "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google",
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA1",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
		{
			name:       "大写与小写的算法参数",
			otpauthStr: "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=sha256",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google",
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA256",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
		{
			name:       "标签中包含 URL 编码",
			otpauthStr: "otpauth://totp/Google%3Aalice%40example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google",
			expected: &TOTPConfig{
				Type:      "totp",
				Issuer:    "Google",
				Account:   "alice@example.com",
				Secret:    "JBSWY3DPEHPK3PXP",
				Algorithm: "SHA1",
				Digits:    6,
				Period:    30,
			},
			expectError: false,
		},
	}

	// 遍历测试用例
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			config, err := parseTOTP(tt.otpauthStr)
			if tt.expectError {
				if err == nil {
					t.Errorf("期望错误，但没有发生")
				}
			} else {
				if err != nil {
					t.Errorf("未预期的错误: %v", err)
					return
				}
				// 比较预期结果与实际结果
				if config.Type != tt.expected.Type {
					t.Errorf("Type: 期望 %s, 实际 %s", tt.expected.Type, config.Type)
				}
				if config.Issuer != tt.expected.Issuer {
					t.Errorf("Issuer: 期望 %s, 实际 %s", tt.expected.Issuer, config.Issuer)
				}
				if config.Account != tt.expected.Account {
					t.Errorf("Account: 期望 %s, 实际 %s", tt.expected.Account, config.Account)
				}
				if config.Secret != tt.expected.Secret {
					t.Errorf("Secret: 期望 %s, 实际 %s", tt.expected.Secret, config.Secret)
				}
				if config.Algorithm != tt.expected.Algorithm {
					t.Errorf("Algorithm: 期望 %s, 实际 %s", tt.expected.Algorithm, config.Algorithm)
				}
				if config.Digits != tt.expected.Digits {
					t.Errorf("Digits: 期望 %d, 实际 %d", tt.expected.Digits, config.Digits)
				}
				if config.Period != tt.expected.Period {
					t.Errorf("Period: 期望 %d, 实际 %d", tt.expected.Period, config.Period)
				}
			}
		})
	}
}

// TestGenerateTOTPCodeWithTimeLeft 演示如何调用 parseTOTP 和 generateTOTPCodeWithTimeLeft
func TestGenerateTOTPCodeWithTimeLeft(t *testing.T) {
	// 1) 定义一个示例 otpauth:// URI，供 parseTOTP 使用
	//    您可根据需要改成自己的 URI
	otpauthStr := "otpauth://totp/Google:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&algorithm=SHA1&digits=6&period=30"

	// 2) 调用 parseTOTP 得到 TOTPConfig
	config, err := parseTOTP(otpauthStr)
	if err != nil {
		t.Fatalf("parseTOTP 失败: %v", err)
	}

	// 3) 循环多次测试，每 0.5 秒 调用 generateTOTPCodeWithTimeLeft
	//    演示获取验证码和倒计时
	for i := 0; i < 500; i++ {
		code, timeLeft, err := generateTOTPCodeWithTimeLeft(config)
		if err != nil {
			t.Errorf("generateTOTPCodeWithTimeLeft 失败: %v", err)
			return
		}

		// 打印结果
		// 如: "当前 TOTP: 123456, 倒计时: 7 秒"
		fmt.Printf("[gpt]第 %d 次: 当前 TOTP: %s, 倒计时: %d 秒\n", i+1, code, timeLeft)

		code, timeLeft, err = generateTOTPCodeWithCountdown(config)
		if err != nil {
			t.Errorf("generateTOTPCodeWithTimeLeft 失败: %v", err)
			return
		}

		// 打印结果
		// 如: "当前 TOTP: 123456, 倒计时: 7 秒"
		fmt.Printf("[deep]第 %d 次: 当前 TOTP: %s, 倒计时: %d 秒\n", i+1, code, timeLeft)

		// 每隔 0.5 秒再调用一次
		time.Sleep(500 * time.Millisecond)
	}
}
