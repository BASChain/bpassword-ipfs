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

	err = initCachedAccountData(db)

	if err != nil {
		utils.LogInst().Errorf("init local cached data failed:%s", err.Error())
		return err
	}
	go AsyncDataSyncing()
	go AsyncCheckLocalAndSrv()
	return nil
}
func queryAndDecodeSrvData() (map[string]*Account, int64, error) {
	srvDataWithVer, err := syncDataFromSrv()
	if err != nil {
		return nil, -1, err
	}

	cipheredData, err := hex.DecodeString(srvDataWithVer.EncodeValue)
	if err != nil {
		return nil, -1, err

	}
	rawData, err := Decode(cipheredData, __walletManager.privateKey)
	if err != nil {
		utils.LogInst().Errorf("decode srvDataWithVer failed:%s", err.Error())
		return nil, -1, err

	}
	var onlineData = make(map[string]*Account)
	err = json.Unmarshal(rawData, &onlineData)
	if err != nil {
		utils.LogInst().Errorf("unmarshal raw srvDataWithVer failed:%s", err.Error())
		return nil, -1, err
	}

	return onlineData, srvDataWithVer.Version, nil
}

func writeEncodedDataToSrv() error {
	rawData := __accountManager.mustSigData()
	if __walletManager.privateKey == nil {
		return fmt.Errorf("invalid private key")
	}
	data, err := Encode(rawData, &__walletManager.privateKey.PublicKey)
	if err != nil {
		return err
	}
	result, err := uploadLocalData(data, __accountManager.SrvVersion)
	if err != nil {
		return err
	}
	__accountManager.UpdateLatestVersion(result.LatestVer)
	return localDbSave()
}

func AsyncDataSyncing() {

	onlineData, onlineVer, err := queryAndDecodeSrvData()
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
	if onlineVer == __accountManager.SrvVersion {
		utils.LogInst().Infof("local srvDataWithVer is same as server's")
		return
	}

	if onlineVer < __accountManager.SrvVersion {
		utils.LogInst().Debugf("local srvDataWithVer is newer than server's")
		err = writeEncodedDataToSrv()
		if err != nil {
			__api.callback.DataUpdated(nil, err)
			return
		}
		return
	}

	utils.LogInst().Debugf("server srvDataWithVer is newer than local's")
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
	__accountManager.mu.RLock()
	if __accountManager.LocalVersion == __accountManager.SrvVersion {
		utils.LogInst().Debugf("local version and server version are same")
		__accountManager.mu.RUnlock()
		return
	}
	__accountManager.mu.RUnlock()

	var err = writeEncodedDataToSrv()
	if err != nil {
		__api.callback.DataUpdated(nil, err)
		return
	}
}
