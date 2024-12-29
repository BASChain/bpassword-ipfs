package LockLib

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
	Accounts map[string]*Account `json:"accounts"`
	Version  int64               `json:"version"`
	mu       sync.RWMutex
}

var __accountManager = &AccountManager{Accounts: make(map[string]*Account)}

func fillAccountData(data []byte) error {
	var am AccountManager //map[string]*Account

	var err = json.Unmarshal(data, &am)
	if err != nil {
		return err
	}
	__accountManager = &am
	if am.Accounts == nil {
		am.Accounts = make(map[string]*Account)
	}
	return nil
}

func (am *AccountManager) AddAccount(acc *Account) {
	am.mu.Lock()
	am.Accounts[acc.ID.String()] = acc
	am.Version = time.Now().UnixNano()
	am.mu.Unlock()
}

func (am *AccountManager) RawData() []byte {
	am.mu.RLock()
	defer am.mu.RUnlock()
	bts, _ := json.Marshal(am)
	return bts
}

func (am *AccountManager) AccountData() []byte {
	am.mu.RLock()
	defer am.mu.RUnlock()
	bts, _ := json.Marshal(am.Accounts)
	return bts
}

func (am *AccountManager) DelAccount(uuid string) bool {
	am.mu.Lock()
	defer am.mu.Unlock()
	_, exists := am.Accounts[uuid]
	if !exists {
		return false
	}
	delete(am.Accounts, uuid)
	utils.LogInst().Debugf("Account with UUID %s removed from memory.\n", uuid)
	return true
}

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
	__accountManager.AddAccount(account)
	_, err = encryptSave()
	return err
}

// ReadLocalData 从 LevelDB 加载账号列表
func ReadLocalData() ([]byte, error) {
	data, err := decryptRead()
	if err != nil {
		return nil, err
	}
	err = fillAccountData(data)
	return __accountManager.AccountData(), nil
}

func decryptRead() ([]byte, error) {
	if __walletManager.privateKey == nil {
		return nil, fmt.Errorf("private key is required")
	}

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

	return Decode(data, __walletManager.privateKey)
}

// encryptSave 将账号列表保存到 LevelDB
func encryptSave() ([]byte, error) {

	if __walletManager.privateKey == nil {
		return nil, fmt.Errorf("private key is required")
	}

	db, err := leveldb.OpenFile(__api.dbPath, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()

	data := __accountManager.RawData()
	encodeData, err := Encode(data, &__walletManager.privateKey.PublicKey)
	if err != nil {
		return nil, fmt.Errorf("failed to encode Accounts: %w", err)
	}

	err = db.Put([]byte(__db_key_accounts), encodeData, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to save Accounts to database: %w", err)
	}
	return encodeData, nil
}

// RemoveAccount 从内存和 LevelDB 中移除指定的账号
func RemoveAccount(uuid string) error {
	uuid = strings.ToLower(uuid)
	success := __accountManager.DelAccount(uuid)
	if !success {
		return nil
	}

	_, err := encryptSave()
	if err != nil {
		return fmt.Errorf("failed to save updated account list: %w", err)
	}

	return nil
}
