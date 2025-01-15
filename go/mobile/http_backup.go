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
	queryAccountDataAPi  = "/queryData"
	updateAccountDataAPi = "/updateData"
	queryAuthDataAPi     = "/queryAuthData"
	updateAuthDataAPi    = "/updateAuthData"
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

func syncDataFromSrv(api string) (*service.EncodedData, error) {
	var queryReq = service.QueryRequest{
		WalletAddr: __walletMng.getAddr(),
		QueryTime:  time.Now().Unix(),
	}

	message := queryReq.DataToSign()
	sig, err := signMessage(message, __walletMng.getPriKey(true))
	if err != nil {
		return nil, err
	}
	queryReq.Signature = sig

	var url = __api.srvUrl + api
	data, err := utils.SendPostRequest(url, __api.token, queryReq)
	if err != nil {
		utils.LogInst().Errorf("------>>>SyncLatestData error %s", err.Error())
		return nil, err
	}

	var request service.EncodedData //make(map[string]*Account)
	err = json.Unmarshal(data, &request)
	if err != nil {
		utils.LogInst().Errorf("------>>>SyncLatestData error %s", err.Error())
		return nil, err
	}
	return &request, nil
}

func uploadLocalData(api string, encodedData []byte, srvVer int64) (*service.UpdateResult, error) {

	if encodedData == nil {
		return nil, fmt.Errorf("invalid data")
	}

	var updateReq = &service.UpdateRequest{
		EncodedData: &service.EncodedData{
			WalletAddr:  __walletMng.getAddr(),
			Version:     srvVer,
			EncodeValue: hex.EncodeToString(encodedData),
		},
		RequestTime: time.Now().Unix(),
	}

	dataToSign := updateReq.DataToSign()

	sig, err := signMessage(dataToSign, __walletMng.getPriKey(true))
	if err != nil {
		utils.LogInst().Errorf("sign message error %s", err.Error())
		return nil, err
	}
	updateReq.Signature = sig

	var url = __api.srvUrl + api
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
