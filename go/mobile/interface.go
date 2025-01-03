package LockLib

import (
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/syndtr/goleveldb/leveldb"
)

type AppI interface {
	Log(s string)
	DataUpdated(data []byte, err error)
	CloseWallet()
}
type API struct {
	dbPath   string
	srvUrl   string
	token    string
	callback AppI
}

var __api = &API{}

func InitSDK(exi AppI, dbPath, url, token string, logLevel int8) error {
	if exi == nil {
		return errors.New("invalid application interface")
	}
	utils.LogInst().InitParam(utils.LogLevel(logLevel), func(msg string, args ...any) {
		log := fmt.Sprintf(msg, args...)
		exi.Log(log)
	})

	// 打开数据库
	db, err := leveldb.OpenFile(dbPath, nil)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()
	utils.LogInst().Debugf("bpassword ipfs version init sdk success, log level:%d", logLevel)

	__api = &API{dbPath: dbPath, srvUrl: url, token: token, callback: exi}

	utils.LogInst().Debugf("------>>>init sdk success")
	return nil
}

func queryAndDecodeSrvData() (map[string]*Account, int64, error) {
	srvDataWithVer, err := syncDataFromSrv()
	if err != nil {
		return nil, -1, err
	}
	if len(srvDataWithVer.EncodeValue) == 0 || srvDataWithVer.Version == -1 {
		utils.LogInst().Debugf("------>>>no data on server:%v", srvDataWithVer.Version)
		return nil, -1, nil
	}

	cipheredData, err := hex.DecodeString(srvDataWithVer.EncodeValue)
	if err != nil {
		return nil, -1, err

	}
	rawData, err := Decode(cipheredData, __walletMng.getPriKey(true))
	if err != nil {
		utils.LogInst().Errorf("------>>>decode srvDataWithVer failed:%s", err.Error())
		return nil, -1, err

	}
	var onlineData = make(map[string]*Account)
	err = json.Unmarshal(rawData, &onlineData)
	if err != nil {
		utils.LogInst().Errorf("------>>>unmarshal raw online data failed:%s content:%s", err.Error(), string(rawData))
		return nil, -1, err
	}

	return onlineData, srvDataWithVer.Version, nil
}

func writeEncodedDataToSrv() error {
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
	result, err := uploadLocalData(data, __accountManager.SrvVersion)
	if err != nil {
		utils.LogInst().Errorf("------>>>upload data failed:%s", err.Error())
		return err
	}
	__accountManager.UpdateLatestVersion(result.LatestVer)
	return localDbSave()
}

func AsyncDataSyncing() {
	utils.LogInst().Debugf("------>>>start syncing data from server")
	onlineData, onlineVer, err := queryAndDecodeSrvData()
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
		utils.LogInst().Debugf("proc sync result:local srvDataWithVer is newer than server's")
		err = writeEncodedDataToSrv()
		if err != nil {
			__api.callback.DataUpdated(nil, err)
			return
		}
		return
	}

	utils.LogInst().Debugf("proc sync result: server srvDataWithVer is newer than local's")
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

func AsyncCheckLocalAndSrv() {
	utils.LogInst().Debugf("------>>>start pushing data to server")
	__accountManager.mu.RLock()
	if __accountManager.LocalVersion == __accountManager.SrvVersion || __accountManager.LocalVersion == 0 {
		utils.LogInst().Debugf("local version and server version are same")
		__accountManager.mu.RUnlock()
		return
	}
	__accountManager.mu.RUnlock()
	utils.LogInst().Debugf("local version and server version are not save ,prepare to push data")
	var err = writeEncodedDataToSrv()
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
}
