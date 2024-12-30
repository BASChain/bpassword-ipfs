package LockLib

import (
	"crypto/ecdsa"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/service"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/ethereum/go-ethereum/crypto"
	"time"
)

const (
	queryDataAPi = "/queryData"
)

func signMessage(message []byte, privateKey *ecdsa.PrivateKey) (string, error) {
	if privateKey == nil {
		return "", fmt.Errorf("private key is nil")
	}
	if message == nil {
		return "", fmt.Errorf("message is nil")
	}
	// 计算消息哈希
	messageHash := crypto.Keccak256(message)

	// 使用私钥签名消息
	signature, err := crypto.Sign(messageHash, privateKey)
	if err != nil {
		return "", fmt.Errorf("failed to sign message: %v", err)
	}

	// 返回签名的十六进制字符串
	return hex.EncodeToString(signature), nil
}

func syncDataFromSrv() (*service.EncodedData, error) {
	var queryReq = service.QueryRequest{
		WalletAddr: __walletManager.address,
		QueryTime:  time.Now().Unix(),
	}

	message := queryReq.DataToSign()
	sig, err := signMessage(message, __walletManager.privateKey)
	if err != nil {
		return nil, err
	}
	queryReq.Signature = sig

	var url = __api.srvUrl + queryDataAPi
	data, err := utils.SendPostRequest(url, __api.token, queryReq)
	if err != nil {
		utils.LogInst().Errorf("SyncLatestData error %s", err.Error())
		return nil, err
	}

	var request service.EncodedData //make(map[string]*Account)
	err = json.Unmarshal(data, &request)
	if err != nil {
		utils.LogInst().Errorf("SyncLatestData error %s", err.Error())
		return nil, err
	}

	return &request, nil
}

// TODO:: upload data ,increase version ,update local version
func uploadLocalData(encodedData []byte) (*service.UpdateResult, error) {
	var updateReq = &service.EncodedData{
		WalletAddr: __walletManager.address,
	}

	if encodedData == nil {
		return nil, fmt.Errorf("invalid data")
	}
	sig, err := signMessage(encodedData, __walletManager.privateKey)
	if err != nil {
		utils.LogInst().Errorf("sign message error %s", err.Error())
		return nil, err
	}
	updateReq.Signature = sig
	updateReq.EncodeValue = hex.EncodeToString(encodedData)

	var url = __api.srvUrl + queryDataAPi
	data, err := utils.SendPostRequest(url, __api.token, updateReq)
	if err != nil {
		utils.LogInst().Errorf("SyncLatestData error %s", err.Error())
		return nil, err
	}

	var res service.UpdateResult
	err = json.Unmarshal(data, &res)
	if err != nil {
		return nil, err
	}

	return &res, nil
}
