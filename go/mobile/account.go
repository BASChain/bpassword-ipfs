package oneKeyLib

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// Account 结构体，与 Swift 的 Account 对应

type Account struct {
	ID          uuid.UUID `json:"id"`
	Platform    string    `json:"platform"`
	Username    string    `json:"username"`
	Password    string    `json:"password"`
	LastUpdated int64     `json:"lastUpdated"` // 修改为 Unix 时间戳
}

func AddAccount(accJsonStr string) error {
	var account Account

	err := json.Unmarshal([]byte(accJsonStr), &account)
	if err != nil {
		return fmt.Errorf("failed to parse account JSON: %w", err)
	}

	if account.ID == uuid.Nil {
		account.ID = uuid.New()
	}

	if account.LastUpdated == 0 {
		account.LastUpdated = time.Now().Unix() // 如果未提供时间戳，使用当前时间
	}

	if account.Platform == "" || account.Username == "" || account.Password == "" {
		return errors.New("invalid account: platform, username, and password are required")
	}

	fmt.Printf("Account added successfully: %+v\n", account)

	return nil
}
