package oneKeyLib

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/google/uuid"
	"github.com/syndtr/goleveldb/leveldb"
	"strings"
	"sync"
	"time"
)

// Account 结构体，与 Swift 的 Account 对应

type Account struct {
	ID          uuid.UUID `json:"id"`
	Platform    string    `json:"platform"`
	Username    string    `json:"username"`
	Password    string    `json:"password"`
	LastUpdated int64     `json:"lastUpdated"` // 修改为 Unix 时间戳
}

type AccountManager struct {
	accounts map[string]*Account
	mu       sync.Mutex // 线程安全
}

var __accountManager = &AccountManager{accounts: make(map[string]*Account)}

// parseAccount 解析 JSON 字符串为 Account
func parseAccount(jsonStr string) (*Account, error) {
	var account Account

	err := json.Unmarshal([]byte(jsonStr), &account)
	if err != nil {
		return nil, fmt.Errorf("failed to parse account JSON: %w", err)
	}

	if account.ID == uuid.Nil {
		account.ID = uuid.New()
	}

	if account.LastUpdated == 0 {
		account.LastUpdated = time.Now().Unix()
	}

	if account.Platform == "" || account.Username == "" || account.Password == "" {
		return nil, errors.New("invalid account: platform, username, and password are required")
	}

	return &account, nil
}

// AddAccount 添加账号并保存
func AddAccount(accJsonStr string) error {
	account, err := parseAccount(accJsonStr)
	if err != nil {
		return err
	}

	__accountManager.mu.Lock()
	__accountManager.accounts[account.ID.String()] = account
	__accountManager.mu.Unlock()

	return saveAccountList()
}

// LoadAccountList 从 LevelDB 加载账号列表
func LoadAccountList() ([]byte, error) {
	db, err := leveldb.OpenFile(__api.dbPath, nil)
	if err != nil {
		return nil, err
	}
	defer db.Close()

	data, err := db.Get([]byte(__db_key_accounts), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			return nil, nil // 如果未找到数据，返回空
		}
		return nil, err
	}

	var accounts map[string]*Account
	err = json.Unmarshal(data, &accounts)
	if err != nil {
		return nil, err
	}
	fmt.Println(accounts)
	__accountManager.mu.Lock()
	__accountManager.accounts = accounts
	__accountManager.mu.Unlock()

	return data, nil
}

// saveAccountList 将账号列表保存到 LevelDB
func saveAccountList() error {
	db, err := leveldb.OpenFile(__api.dbPath, nil)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()

	__accountManager.mu.Lock()
	data, err := json.Marshal(__accountManager.accounts)
	__accountManager.mu.Unlock()
	if err != nil {
		return fmt.Errorf("failed to marshal accounts: %w", err)
	}

	err = db.Put([]byte(__db_key_accounts), data, nil)
	if err != nil {
		return fmt.Errorf("failed to save accounts to database: %w", err)
	}
	return nil
}

// RemoveAccount 从内存和 LevelDB 中移除指定的账号
func RemoveAccount(uuid string) error {
	uuid = strings.ToLower(uuid)

	__accountManager.mu.Lock()
	_, exists := __accountManager.accounts[uuid]
	if exists {
		delete(__accountManager.accounts, uuid)
		utils.LogInst().Debugf("Account with UUID %s removed from memory.\n", uuid)
	} else {
		utils.LogInst().Debugf("Account with UUID %s does not exist.\n", uuid)
	}
	__accountManager.mu.Unlock()

	if !exists {
		return fmt.Errorf("account with UUID %s not found", uuid)
	}

	err := saveAccountList()
	if err != nil {
		return fmt.Errorf("failed to save updated account list: %w", err)
	}
	return nil
}
