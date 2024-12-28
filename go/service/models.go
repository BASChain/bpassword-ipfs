package service

import (
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/go-playground/validator/v10"
	"time"
)

var validate = validator.New()

// UpdateRequest 更新数据的请求体结构
type UpdateRequest struct {
	WalletAddr  string `json:"wallet_addr" firestore:"wallet_addr" validate:"required,alphanum"`
	EncodeValue string `json:"encode_value" firestore:"encode_value" validate:"required"`
	Signature   string `json:"signature" firestore:"_" validate:"required"`
}

// Validate 使用validator库验证 UpdateRequest
func (req *UpdateRequest) Validate() error {
	return validate.Struct(req)
}

// QueryRequest 查询数据的请求体结构
type QueryRequest struct {
	WalletAddr  string `json:"wallet_addr" firestore:"wallet_addr" validate:"required,alphanum"`
	CurrentTime int64  `json:"current_time" firestore:"_" validate:"required"`
	Signature   string `json:"signature" firestore:"_" validate:"required"`
}

// Validate 使用validator库验证 QueryRequest
func (req *QueryRequest) Validate() error {
	// 基本字段验证
	if err := validate.Struct(req); err != nil {
		return err
	}

	// 签名验证
	message := []byte(fmt.Sprintf("%d", req.CurrentTime))

	if err := validateSignature(req.WalletAddr, message, req.Signature); err != nil {
		return err
	}

	// 检查时间戳是否过期
	if time.Now().Unix()-req.CurrentTime > 30 {
		return errors.New("too old request")
	}

	return nil
}

// validateSignature 验证签名
func validateSignature(walletAddr string, message []byte, signature string) error {
	// 计算消息哈希值
	messageHash := crypto.Keccak256(message)

	// 解码签名
	sigBytes, err := hex.DecodeString(signature)
	if err != nil {
		return errors.New("invalid signature format")
	}

	// 验证签名长度（65字节，包含V部分）
	if len(sigBytes) != 65 {
		return errors.New("invalid signature length")
	}

	// 分离签名数据和恢复 ID
	sigNoRecoverID := sigBytes[:64]
	recoverID := sigBytes[64]

	// 恢复公钥
	pubKey, err := crypto.Ecrecover(messageHash, append(sigNoRecoverID, recoverID))
	if err != nil {
		return errors.New("failed to recover public key from signature")
	}

	// 解析恢复的公钥
	ecdsaPubKey, err := crypto.UnmarshalPubkey(pubKey)
	if err != nil {
		return errors.New("failed to unmarshal recovered public key")
	}

	// 验证地址是否匹配
	recoveredAddr := crypto.PubkeyToAddress(*ecdsaPubKey)
	if recoveredAddr.Hex() != walletAddr {
		return errors.New("signature does not match wallet address")
	}

	return nil
}
