package LockLib

import (
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/syndtr/goleveldb/leveldb"
)

type AppI interface {
	Log(s string)
}
type API struct {
	dbPath string
	srvUrl string
	token  string
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
	db.Close()
	utils.LogInst().Debugf("bpassword ipfs version init sdk success, log level:%d", logLevel)

	__api = &API{dbPath: dbPath, srvUrl: url, token: token}
	return nil
}
