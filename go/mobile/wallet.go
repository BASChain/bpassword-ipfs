package LockLib

import (
	"crypto/ecdsa"
	"crypto/hmac"
	"crypto/sha512"
	"encoding/binary"
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/google/uuid"
	"github.com/syndtr/goleveldb/leveldb"
	"github.com/tyler-smith/go-bip39"
	"sync"
	"time"
)

type WalletManager struct {
	priKey        *ecdsa.PrivateKey
	address       string
	timer         *time.Ticker
	lastTouchTime int64
	sync.RWMutex
	db *leveldb.DB
}

var __walletMng = &WalletManager{}

func (wm *WalletManager) getPriKey(useKey bool) *ecdsa.PrivateKey {
	wm.Lock()
	defer wm.Unlock()
	if useKey {
		__walletMng.lastTouchTime = time.Now().Unix()
	}
	return wm.priKey
}

func (wm *WalletManager) getAddr() string {
	wm.RLock()
	defer wm.RUnlock()
	return wm.address
}

func InitWalletPath(dbPath string) bool {
	__walletMng.Lock()
	defer __walletMng.Unlock()

	db, err := leveldb.OpenFile(dbPath, nil)
	if err != nil {
		return false
	}
	__walletMng.db = db
	utils.LogInst().Debugf("------>>> init dtabase path success:%s", dbPath)

	// 尝试读取钱包数据
	_, err = db.Get([]byte(__db_key_wallet_), nil)
	if err != nil {
		fmt.Println("----->>> failed load data from local database:", err)
		return false
	}
	return true
}

func GenerateMnemonic() ([]byte, error) {
	// 生成 256 位熵
	entropy, err := bip39.NewEntropy(256) // 256 位熵生成 24 个单词
	if err != nil {
		return nil, err
	}

	// 生成助记词
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		return nil, err
	}

	//fmt.Println("------>>> to be removed:", mnemonic)
	// 将助记词转换为字节数组返回
	return []byte(mnemonic), nil
}

// GenerateWallet 根据助记词生成以太坊HD钱包
func GenerateWallet(mnemonic, password string) error {
	// 检查助记词是否有效
	if !bip39.IsMnemonicValid(mnemonic) {
		return errors.New("invalid mnemonic")
	}

	// 通过助记词生成种子
	seed := bip39.NewSeed(mnemonic, "")

	// 衍生路径：m/44'/60'/0'/0/0
	path := []uint32{
		44 + HardenedOffset,
		60 + HardenedOffset,
		0 + HardenedOffset,
		0,
		0,
	}

	// 生成私钥
	privateKey, err := deriveKey(seed, path)
	if err != nil {
		return fmt.Errorf("failed to derive private key: %w", err)
	}

	// 生成以太坊地址
	publicKey := privateKey.Public().(*ecdsa.PublicKey)
	address := crypto.PubkeyToAddress(*publicKey)

	fmt.Printf("------>>>Generated Wallet Address: %s\n", address.Hex())

	walletStr, err := generateKeystore(privateKey, password)
	if err != nil {
		return fmt.Errorf("failed to save keystore: %w", err)
	}

	return storeKeystoreInLevelDB(walletStr)
}

// deriveKey 实现HD钱包路径衍生
func deriveKey(seed []byte, path []uint32) (*ecdsa.PrivateKey, error) {
	if len(seed) == 0 {
		return nil, errors.New("empty seed provided")
	}

	hmac512 := hmac.New(sha512.New, []byte("Bitcoin seed"))
	hmac512.Write(seed)
	masterKey := hmac512.Sum(nil)

	privateKey := masterKey[:32]
	chainCode := masterKey[32:]

	for _, index := range path {
		hmac512 := hmac.New(sha512.New, chainCode)

		data := make([]byte, 37)
		data[0] = 0x00
		copy(data[1:33], privateKey)
		data[33] = byte(index >> 24)
		data[34] = byte(index >> 16)
		data[35] = byte(index >> 8)
		data[36] = byte(index)

		hmac512.Write(data)
		derived := hmac512.Sum(nil)

		privateKey = derived[:32]
		chainCode = derived[32:]
	}

	return crypto.ToECDSA(privateKey)
}

func generateKeystore(privateKey *ecdsa.PrivateKey, password string) (string, error) {
	// 将私钥封装为账户对象
	key := &keystore.Key{
		Address:    crypto.PubkeyToAddress(privateKey.PublicKey),
		PrivateKey: privateKey,
		Id:         uuid.New(), // 生成一个新的 UUID
	}

	// 加密私钥为 Keystore 格式的 JSON 字符串
	keyJSON, err := keystore.EncryptKey(key, password, keystore.StandardScryptN, keystore.StandardScryptP)
	if err != nil {
		return "", fmt.Errorf("failed to encrypt keystore: %w", err)
	}

	// 返回加密后的 Keystore JSON 字符串
	return string(keyJSON), nil
}

func storeKeystoreInLevelDB(keystoreString string) error {

	utils.LogInst().Infof("------>>>Storing keystore in LevelDB...")
	var err = __walletMng.db.Put([]byte(__db_key_wallet_), []byte(keystoreString), nil)
	if err != nil {
		utils.LogInst().Errorf("------>>>Error storing keystore: %s", err.Error())
		return fmt.Errorf("failed to store keystore: %w", err)
	}

	utils.LogInst().Infof("------>>>Keystore successfully stored in LevelDB.")
	return nil
}

// OpenWallet 从 LevelDB 中读取钱包并解密
func OpenWallet(password string) error {

	// 从 LevelDB 中读取钱包 JSON 数据
	keystoreJSON, err := __walletMng.db.Get([]byte(__db_key_wallet_), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			return errors.New("wallet not found in database")
		}
		return fmt.Errorf("failed to read wallet from LevelDB: %w", err)
	}

	// 解密 Keystore JSON
	key, err := keystore.DecryptKey(keystoreJSON, password)
	if err != nil {
		return fmt.Errorf("failed to decrypt wallet: %w", err)
	}

	// 保存私钥和地址到 WalletManager
	__walletMng.Lock()
	__walletMng.priKey = key.PrivateKey
	__walletMng.address = key.Address.Hex()
	__walletMng.lastTouchTime = time.Now().Unix()

	utils.LogInst().Infof("------>>>Wallet successfully opened. Address: %s\n", __walletMng.address)
	__walletMng.Unlock()
	go WalletClock()
	authCodeTimerStart()
	return nil
}

func WalletAddress() string {
	return __walletMng.getAddr()
}

func CloseWallet() {
	__walletMng.Lock()
	defer __walletMng.Unlock()
	__walletMng.address = ""
	__walletMng.priKey = nil
}

func WalletIsOpen() bool {
	return len(__walletMng.getAddr()) > 0 && __walletMng.getPriKey(false) != nil
}

func ChangePassword(old, new string) error {

	// 从 LevelDB 中读取钱包 JSON 数据
	keystoreJSON, err := __walletMng.db.Get([]byte(__db_key_wallet_), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			return errors.New("wallet not found in database")
		}
		return fmt.Errorf("failed to read wallet from LevelDB: %w", err)
	}

	// 使用旧密码解密 Keystore JSON
	key, err := keystore.DecryptKey(keystoreJSON, old)
	if err != nil {
		return fmt.Errorf("failed to decrypt wallet with old password: %w", err)
	}

	// 使用新密码加密 Keystore JSON
	newKeystoreJSON, err := keystore.EncryptKey(key, new, keystore.StandardScryptN, keystore.StandardScryptP)
	if err != nil {
		return fmt.Errorf("failed to encrypt wallet with new password: %w", err)
	}

	// 保存新 Keystore JSON 到 LevelDB
	err = __walletMng.db.Put([]byte(__db_key_wallet_), newKeystoreJSON, nil)
	if err != nil {
		return fmt.Errorf("failed to save updated wallet to LevelDB: %w", err)
	}

	utils.LogInst().Infof("------>>>Wallet password successfully changed.")
	return nil
}

// KeyExpireTime 读取存储的 clock time 值
func KeyExpireTime() int {

	value, err := __walletMng.db.Get([]byte(__db_key_clock_time_), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			return 5 // 如果键不存在，返回默认值
		}
		utils.LogInst().Errorf("------>>>failed to read clock time: %v\n", err)
		return DefaultClockTimeInMinutes
	}

	// 将存储的字节数据解码为整数
	if len(value) != 4 {
		utils.LogInst().Errorf("------>>>invalid clock time format")
		return DefaultClockTimeInMinutes
	}
	return int(binary.BigEndian.Uint32(value))
}

func SaveExpireTime(clockTime int) error {

	// 将整数值编码为字节数据
	value := make([]byte, 4)
	binary.BigEndian.PutUint32(value, uint32(clockTime))

	// 将编码后的字节数据写入数据库
	var err = __walletMng.db.Put([]byte(__db_key_clock_time_), value, nil)
	if err != nil {
		return fmt.Errorf("failed to save clock time: %w", err)
	}

	return nil
}

// WalletClock 启动定时器，基于 KeyExpireTime 设置的时间间隔执行任务
func WalletClock() {
	__walletMng.timer = time.NewTicker(CTimeInSeconds * time.Second)
	defer __walletMng.timer.Stop()
	utils.LogInst().Infof("------>>>starting wallet timer.")

	for {
		select {
		case <-__walletMng.timer.C:
			if __walletMng.getPriKey(false) == nil {
				continue
			}
			timeOutInMinutes := KeyExpireTime()
			//utils.LogInst().Debugf("------>>>Timer Wallet checking expire at:%d", timeOutInMinutes)
			if (time.Now().Unix() - __walletMng.lastTouchTime) < int64(timeOutInMinutes*60) {
				continue
			}

			utils.LogInst().Debugf("------>>>closing wallet.")
			CloseWallet()
			__api.callback.CloseWallet()
			return
		}
	}
}

func removeWallet() {
	__walletMng.Lock()
	defer __walletMng.Unlock()
	__walletMng.address = ""
	__walletMng.priKey = nil
	__walletMng.timer.Stop()
	_ = __walletMng.db.Delete([]byte(__db_key_wallet_), nil)
}

func CompleteRemoveWallet() {
	__accManager.clear()
	AccountVerCheck()

	__authManager.clear()
	AuthVerCheck()

	removeWallet()
}
