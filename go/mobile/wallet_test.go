package LockLib

import (
	"bytes"
	"crypto/rand"
	"encoding/binary"
	"fmt"
	"log"
	"testing"

	"github.com/ethereum/go-ethereum/crypto"
)

func initWalletManager() *WalletManager {
	// 生成私钥
	privateKey, err := crypto.GenerateKey()
	if err != nil {
		log.Fatalf("Failed to generate private key: %v", err)
	}

	// 从私钥生成地址
	address := crypto.PubkeyToAddress(privateKey.PublicKey).Hex()

	return &WalletManager{
		priKey:  privateKey,
		address: address,
	}
}

var testStr = `结论
您的打印输出和结构分析是正确的。以下几点可供参考：

MAC 的长度：

特定实现可能使用了较长的校验值（48 字节），但这并不会影响加解密的功能。
兼容性：

在使用其他语言或框架时，请确保它们的 ECIES 实现支持此结构（65 字节共享点 + 32 字节密文 + 48 字节 MAC）。
验证流程：

您可以通过解密 Encrypted Key 并恢复原始对称密钥来确认完整性。
如果还有其他问题或疑问，请随时告诉我！`

func TestEncrypt(t *testing.T) {
	wallet := initWalletManager()
	privateKey := wallet.priKey
	publicKey := &privateKey.PublicKey

	// 模拟待加密数据
	data := []byte(testStr)

	// 生成随机对称密钥（256 位）
	symmetricKey := make([]byte, 32) // AES-256
	if _, err := rand.Read(symmetricKey); err != nil {
		log.Fatalf("Failed to generate symmetric key: %v", err)
	}

	// 加密对称密钥
	encryptedKey, err := encryptKey(publicKey, symmetricKey)
	if err != nil {
		log.Fatalf("Failed to encrypt symmetric key: %v", err)
	}
	fmt.Printf("Encrypted Key: %x\n", encryptedKey)
	fmt.Println("Encrypted Key Length:", len(encryptedKey))

	// 打印组成部分
	fmt.Printf("Shared Point: %x\n", encryptedKey[:65])               // 共享点
	fmt.Printf("Symmetric Key Ciphertext: %x\n", encryptedKey[65:97]) // 对称密钥部分
	fmt.Printf("MAC: %x\n", encryptedKey[97:])                        // MAC 部分

	// 使用对称密钥加密数据
	ciphertext, nonce, err := encryptData(symmetricKey, data)
	if err != nil {
		log.Fatalf("Failed to encrypt data: %v", err)
	}
	fmt.Printf("Encrypted Data: %x\n", ciphertext)

	// 生成最终密文
	var finalCiphertext bytes.Buffer
	encryptedKeyLength := uint16(len(encryptedKey)) // 使用 2 字节存储长度
	if err := binary.Write(&finalCiphertext, binary.BigEndian, encryptedKeyLength); err != nil {
		log.Fatalf("Failed to write encryptedKey length: %v", err)
	}
	finalCiphertext.Write(encryptedKey) // 写入 encryptedKey
	finalCiphertext.Write(nonce)        // 写入 nonce
	finalCiphertext.Write(ciphertext)   // 写入密文

	// 解密过程
	receivedCiphertext := finalCiphertext.Bytes()

	// 读取 encryptedKey 长度
	var receivedEncryptedKeyLength uint16
	reader := bytes.NewReader(receivedCiphertext)
	if err := binary.Read(reader, binary.BigEndian, &receivedEncryptedKeyLength); err != nil {
		log.Fatalf("Failed to read encryptedKey length: %v", err)
	}

	// 解析各部分
	receivedEncryptedKey := receivedCiphertext[2 : 2+receivedEncryptedKeyLength]
	receivedNonce := receivedCiphertext[2+receivedEncryptedKeyLength : 2+receivedEncryptedKeyLength+12]
	receivedCiphertext = receivedCiphertext[2+receivedEncryptedKeyLength+12:]

	// 解密对称密钥
	decryptedKey, err := decryptKey(privateKey, receivedEncryptedKey)
	if err != nil {
		log.Fatalf("Failed to decrypt symmetric key: %v", err)
	}
	fmt.Printf("Decrypted Symmetric Key: %x\n", decryptedKey)

	// 使用对称密钥解密数据
	plaintext, err := decryptData(decryptedKey, receivedCiphertext, receivedNonce)
	if err != nil {
		log.Fatalf("Failed to decrypt data: %v", err)
	}
	fmt.Printf("Decrypted Data: %s\n", plaintext)
}

func TestEnDecode(t *testing.T) {
	wallet := initWalletManager()

	cipherData, err := Encode([]byte(testStr), &wallet.priKey.PublicKey)
	if err != nil {
		t.Errorf(err.Error())
	}
	plainData, err := Decode(cipherData, wallet.priKey)
	if err != nil {
		t.Errorf(err.Error())
	}
	fmt.Printf("Decrypted Data: %s\n", plainData)
}
