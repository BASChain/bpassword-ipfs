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
	Accounts     map[string]*Account `json:"accounts"`
	LocalVersion int64               `json:"local_version"`
	SrvVersion   int64               `json:"srv_version"`
	mu           sync.RWMutex
}

var __accountManager = &AccountManager{
	Accounts:   make(map[string]*Account),
	SrvVersion: -1,
}

func initCachedAccountData(db *leveldb.DB) error {
	if __walletManager.privateKey == nil {
		return fmt.Errorf("open wallet first")
	}
	data, err := db.Get([]byte(__db_key_accounts), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			utils.LogInst().Infof("no local data found")
			return nil
		}
		return err
	}

	rawData, err := Decode(data, __walletManager.privateKey)
	if err != nil {
		utils.LogInst().Errorf("decode local data failed:%s", err.Error())
		return err
	}

	err = json.Unmarshal(rawData, &__accountManager)
	if err != nil {
		utils.LogInst().Errorf("unmarshal local data failed:%s", err.Error())
		return err
	}

	if __accountManager.Accounts == nil {
		__accountManager.Accounts = make(map[string]*Account)
		__accountManager.LocalVersion = 0
		__accountManager.SrvVersion = -1
	}
	return nil
}

func (am *AccountManager) addOrUpdateAccount(acc *Account) {
	am.mu.Lock()
	am.Accounts[acc.ID.String()] = acc
	am.LocalVersion += 1
	am.mu.Unlock()
}

func (am *AccountManager) mustSigData() []byte {
	am.mu.RLock()
	defer am.mu.RUnlock()
	bts, _ := json.Marshal(am)
	return bts
}

func (am *AccountManager) accountData() []byte {
	am.mu.RLock()
	defer am.mu.RUnlock()
	bts, _ := json.Marshal(am.Accounts)
	return bts
}

func (am *AccountManager) UpdateLatestVersion(srvVer int64) {
	am.mu.RLock()
	defer am.mu.RUnlock()
	am.SrvVersion = srvVer
	am.LocalVersion = srvVer
}

func (am *AccountManager) delAccount(uuid string) bool {
	am.mu.Lock()
	defer am.mu.Unlock()
	_, exists := am.Accounts[uuid]
	if !exists {
		return false
	}
	delete(am.Accounts, uuid)
	am.LocalVersion += 1
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

// localDbSave 将账号列表保存到 LevelDB
func localDbSave() error {

	if __walletManager.privateKey == nil {
		return fmt.Errorf("private key is required")
	}

	db, err := leveldb.OpenFile(__api.dbPath, nil)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()

	data := __accountManager.mustSigData()
	encodeData, err := Encode(data, &__walletManager.privateKey.PublicKey)
	if err != nil {
		return fmt.Errorf("failed to encode Accounts: %w", err)
	}

	err = db.Put([]byte(__db_key_accounts), encodeData, nil)
	if err != nil {
		return fmt.Errorf("failed to save Accounts to database: %w", err)
	}
	return nil
}

// AddOrUpdateAccount 添加或者账号并保存
func AddOrUpdateAccount(accJsonStr string) error {
	account, err := parseAccount(accJsonStr)
	if err != nil {
		return err
	}
	__accountManager.addOrUpdateAccount(account)
	err = localDbSave()
	if err != nil {
		return err
	}

	go AsyncCheckLocalAndSrv()
	return nil
}

// LocalCachedData sync data from local or server
func LocalCachedData() []byte {
	return __accountManager.accountData()
}

// RemoveAccount 从内存和 LevelDB 中移除指定的账号
func RemoveAccount(uuid string) error {
	uuid = strings.ToLower(uuid)
	needUpdate := __accountManager.delAccount(uuid)
	if !needUpdate {
		return nil
	}
	err := localDbSave()
	if err != nil {
		return err
	}
	go AsyncCheckLocalAndSrv()
	return nil
}
