package LockLib

import (
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
)

type AppI interface {
	Log(s string)
	DataUpdated(data []byte, err error)
	AuthDataUpdated(data []byte, err error)
	CloseWallet()
	AuthCodeUpdate(key, code string, timeleft int)
}
type API struct {
	srvUrl   string
	token    string
	callback AppI
}

var __api = &API{}

func InitSDK(exi AppI, url, token string, logLevel int8) error {
	if exi == nil {
		return errors.New("invalid application interface")
	}
	utils.LogInst().InitParam(utils.LogLevel(logLevel), func(msg string, args ...any) {
		log := fmt.Sprintf(msg, args...)
		exi.Log(log)
	})

	// 打开数据库

	utils.LogInst().Debugf("bpassword ipfs version init sdk success, log level:%d", logLevel)

	__api = &API{srvUrl: url, token: token, callback: exi}

	utils.LogInst().Debugf("------>>>init sdk success")

	return nil
}

func queryAndDecodeSrvData(api string, onlineData any) (int64, error) {
	srvDataWithVer, err := syncDataFromSrv(api)
	if err != nil {
		return -1, err
	}
	if len(srvDataWithVer.EncodeValue) == 0 || srvDataWithVer.Version == -1 {
		utils.LogInst().Debugf("------>>>no data on server:%v", srvDataWithVer.Version)
		return -1, nil
	}

	cipheredData, err := hex.DecodeString(srvDataWithVer.EncodeValue)
	if err != nil {
		return -1, err

	}
	rawData, err := Decode(cipheredData, __walletMng.getPriKey(true))
	if err != nil {
		utils.LogInst().Errorf("------>>>decode srvDataWithVer failed:%s", err.Error())
		return -1, err

	}
	err = json.Unmarshal(rawData, onlineData)
	if err != nil {
		utils.LogInst().Errorf("------>>>unmarshal raw online data failed:%s content:%s", err.Error(), string(rawData))
		return -1, err
	}

	return srvDataWithVer.Version, nil
}

func writeEncodedAccountDataToSrv() error {
	rawData := __accountManager.accountData()
	priKey := __walletMng.getPriKey(true)
	if priKey == nil {
		return fmt.Errorf("invalid private key")
	}
	data, err := Encode(rawData, &priKey.PublicKey)
	if err != nil {
		utils.LogInst().Errorf("------>>>encode rawData failed:%s", err.Error())
		return err
	}
	result, err := uploadLocalData(updateAccountDataAPi, data, __accountManager.SrvVersion)
	if err != nil {
		utils.LogInst().Errorf("------>>>upload data failed:%s", err.Error())
		return err
	}
	__accountManager.UpdateLatestVersion(result.LatestVer)
	return localDbSave()
}

func AsyncAccountSyncing() {
	utils.LogInst().Debugf("------>>>start syncing data from server")
	var onlineData = make(map[string]*Account)
	onlineVer, err := queryAndDecodeSrvData(queryAccountDataAPi, &onlineData)
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
	if onlineData == nil {
		return
	}

	if onlineVer == __accountManager.SrvVersion {
		utils.LogInst().Infof("proc sync result:local srvDataWithVer is same as server's")
		return
	}

	if onlineVer < __accountManager.SrvVersion {
		utils.LogInst().Debugf("------>>>proc sync result:local srvDataWithVer is newer than server's")
		err = writeEncodedAccountDataToSrv()
		if err != nil {
			__api.callback.DataUpdated(nil, err)
			return
		}
		return
	}

	utils.LogInst().Debugf("------>>>proc sync result: server srvDataWithVer is newer than local's")
	err = mergeSrvData(onlineData, onlineVer)
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
	__api.callback.DataUpdated(__accountManager.accountData(), nil)
	return
}

func mergeSrvData(onlineData map[string]*Account, onlineVer int64) error {
	__accountManager.mu.Lock()
	defer __accountManager.mu.Unlock()

	for id, account := range onlineData {
		localAccData, exist := __accountManager.Accounts[id]
		if !exist || localAccData.LastUpdated < account.LastUpdated {
			__accountManager.Accounts[id] = account
		}
	}

	__accountManager.SrvVersion = onlineVer

	return localDbSave()
}

func AsyncAccountVerCheck() {
	utils.LogInst().Debugf("------>>>start pushing data to server")
	__accountManager.mu.RLock()
	if __accountManager.LocalVersion == __accountManager.SrvVersion || __accountManager.LocalVersion == 0 {
		utils.LogInst().Debugf("------>>>local version and server version are same")
		__accountManager.mu.RUnlock()
		return
	}
	__accountManager.mu.RUnlock()
	utils.LogInst().Debugf("------>>>local version and server version are not save ,prepare to push data")
	var err = writeEncodedAccountDataToSrv()
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
}

func InitLocalData() {
	if __walletMng.getPriKey(false) == nil {
		return
	}
	initCachedAccountData()
	initAuthList()

	go AsyncAccountSyncing()
	go AsyncAccountVerCheck()
	go AsyncAuthSyncing()
	go AsyncAuthVerCheck()
}
