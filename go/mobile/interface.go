package oneKeyLib

import (
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"github.com/syndtr/goleveldb/leveldb"
)

type APPI interface {
	Log(s string)
}

func InitSDK(exi APPI, dbPath string, logLevel int8) error {
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
	databasePathString = dbPath
	utils.LogInst().Debugf("bpassword ipfs version init sdk success, log level:%d", logLevel)
	return nil
}
