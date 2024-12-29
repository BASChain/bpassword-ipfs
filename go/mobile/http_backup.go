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

func syncLatestData() ([]byte, error) {
	var queryReq = service.QueryRequest{
		WalletAddr:  __walletManager.address,
		CurrentTime: time.Now().Unix(),
	}
	message := []byte(fmt.Sprintf("%d", queryReq.CurrentTime))
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

	var request service.UpdateRequest //make(map[string]*Account)
	err = json.Unmarshal(data, &request)
	if err != nil {
		utils.LogInst().Errorf("SyncLatestData error %s", err.Error())
		return nil, err
	}

	return hex.DecodeString(request.EncodeValue)
}

func decodeData(encodedData []byte) map[string]*Account {

	//
	return nil
}

func encodeData() []byte {
	__accountManager.mu.Lock()
	data, _ := json.Marshal(__accountManager.Accounts)
	__accountManager.mu.Unlock()
	//encode
	return data
}

func mergeAccounts(onlineData map[string]*Account) error {
	__accountManager.mu.Lock()
	for uuid, account := range onlineData {
		__accountManager.Accounts[uuid] = account
	}
	__accountManager.mu.Unlock()

	_, err := encryptSave()
	return err
}

func uploadLocalData() error {
	var updateReq = &service.UpdateRequest{
		WalletAddr: __walletManager.address,
	}

	var data = encodeData()
	if data == nil {
		return fmt.Errorf("invalid data")
	}
	sig, err := signMessage(data, __walletManager.privateKey)
	if err != nil {
		utils.LogInst().Errorf("sign message error %s", err.Error())
		return err
	}
	updateReq.Signature = sig
	updateReq.EncodeValue = hex.EncodeToString(data)

	var url = __api.srvUrl + queryDataAPi
	_, err = utils.SendPostRequest(url, __api.token, updateReq)
	if err != nil {
		utils.LogInst().Errorf("SyncLatestData error %s", err.Error())
		return err
	}
	return nil
}
