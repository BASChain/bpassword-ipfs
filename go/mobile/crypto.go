package LockLib

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/ecdsa"
	"crypto/rand"
	"encoding/binary"
	"fmt"
	"github.com/ethereum/go-ethereum/crypto/ecies"
)

// 使用 ECIES 加密对称密钥
func encryptKey(publicKey *ecdsa.PublicKey, symmetricKey []byte) ([]byte, error) {
	eciesPublicKey := ecies.ImportECDSAPublic(publicKey)
	return ecies.Encrypt(rand.Reader, eciesPublicKey, symmetricKey, nil, nil)
}

// 使用 ECIES 解密对称密钥
func decryptKey(privateKey *ecdsa.PrivateKey, encryptedKey []byte) ([]byte, error) {
	eciesPrivateKey := ecies.ImportECDSA(privateKey)
	return eciesPrivateKey.Decrypt(encryptedKey, nil, nil)
}

// 使用 AES-GCM 加密数据
func encryptData(symmetricKey, data []byte) ([]byte, []byte, error) {
	block, err := aes.NewCipher(symmetricKey)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create AES cipher: %v", err)
	}

	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create GCM: %v", err)
	}

	nonce := make([]byte, aead.NonceSize())
	if _, err = rand.Read(nonce); err != nil {
		return nil, nil, fmt.Errorf("failed to generate nonce: %v", err)
	}

	ciphertext := aead.Seal(nil, nonce, data, nil)
	return ciphertext, nonce, nil
}

// 使用 AES-GCM 解密数据
func decryptData(symmetricKey, ciphertext, nonce []byte) ([]byte, error) {
	block, err := aes.NewCipher(symmetricKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create AES cipher: %v", err)
	}

	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("failed to create GCM: %v", err)
	}

	plaintext, err := aead.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt data: %v", err)
	}

	return plaintext, nil
}

func Encode(data []byte, publicKey *ecdsa.PublicKey) ([]byte, error) {
	symmetricKey := make([]byte, 32) // AES-256
	if _, err := rand.Read(symmetricKey); err != nil {
		return nil, err
	}
	encryptedKey, err := encryptKey(publicKey, symmetricKey)
	if err != nil {
		return nil, err
	}
	ciphertext, nonce, err := encryptData(symmetricKey, data)

	// 生成最终密文
	var finalCiphertext bytes.Buffer
	encryptedKeyLength := uint16(len(encryptedKey)) // 使用 2 字节存储长度
	if err := binary.Write(&finalCiphertext, binary.BigEndian, encryptedKeyLength); err != nil {
		return nil, err
	}
	finalCiphertext.Write(encryptedKey) // 写入 encryptedKey
	finalCiphertext.Write(nonce)        // 写入 nonce
	finalCiphertext.Write(ciphertext)   // 写入密文

	// 解密过程
	receivedCiphertext := finalCiphertext.Bytes()
	return receivedCiphertext, nil
}

func Decode(ciphertext []byte, privateKey *ecdsa.PrivateKey) ([]byte, error) {
	// 读取 encryptedKey 长度
	var receivedEncryptedKeyLength uint16
	reader := bytes.NewReader(ciphertext)
	if err := binary.Read(reader, binary.BigEndian, &receivedEncryptedKeyLength); err != nil {
		return nil, err
	}

	// 解析各部分
	receivedEncryptedKey := ciphertext[2 : 2+receivedEncryptedKeyLength]
	receivedNonce := ciphertext[2+receivedEncryptedKeyLength : 2+receivedEncryptedKeyLength+12]
	ciphertext = ciphertext[2+receivedEncryptedKeyLength+12:]

	// 解密对称密钥
	decryptedKey, err := decryptKey(privateKey, receivedEncryptedKey)
	if err != nil {
		return nil, err
	}

	// 使用对称密钥解密数据
	return decryptData(decryptedKey, ciphertext, receivedNonce)
}
