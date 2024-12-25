package oneKeyLib

import (
	"crypto/ecdsa"
	"crypto/hmac"
	"crypto/sha512"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/google/uuid"
	"github.com/syndtr/goleveldb/leveldb"
	"github.com/tyler-smith/go-bip39"
)

func CheckWallet() ([]byte, error) {
	// 打开 LevelDB 数据库
	db, err := leveldb.OpenFile(databasePathString, nil)
	if err != nil {
		return nil, err
	}
	defer db.Close()

	// 尝试读取钱包数据
	data, err := db.Get([]byte(__db_key_wallet_), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			return nil, nil // 未找到数据
		}
		return nil, err
	}

	return data, nil
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

	fmt.Printf("Generated Wallet Address: %s\n", address.Hex())

	walletStr, err := generateKeystore(privateKey, password)
	if err != nil {
		return fmt.Errorf("failed to save keystore: %w", err)
	}

	return storeKeystoreInLevelDB(walletStr)
}

// deriveKey 实现HD钱包路径衍生
func deriveKey(seed []byte, path []uint32) (*ecdsa.PrivateKey, error) {
	// Master key derivation using HMAC-SHA512
	hmac512 := hmac.New(sha512.New, []byte("Bitcoin seed"))
	hmac512.Write(seed)
	masterKey := hmac512.Sum(nil)

	// 分离出主私钥和链码
	privateKey := masterKey[:32]
	chainCode := masterKey[32:]

	// 逐步推导子私钥
	for _, index := range path {
		hmac512 := hmac.New(sha512.New, chainCode)

		data := make([]byte, 37)
		data[0] = 0x00 // 前缀
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

	// 将生成的私钥转换为ECDSA格式
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
	db, err := leveldb.OpenFile(databasePathString, nil)
	if err != nil {
		fmt.Printf("Error opening LevelDB: %s\n", err.Error())
		return fmt.Errorf("failed to open leveldb: %w", err)
	}
	defer db.Close()

	fmt.Println("Storing keystore in LevelDB...")
	err = db.Put([]byte(__db_key_wallet_), []byte(keystoreString), nil)
	if err != nil {
		fmt.Printf("Error storing keystore: %s\n", err.Error())
		return fmt.Errorf("failed to store keystore: %w", err)
	}

	fmt.Println("Keystore successfully stored in LevelDB.")
	return nil
}
