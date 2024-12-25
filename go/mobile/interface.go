package mobile

import (
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
)

type APPI interface {
	Log(s string)
}

func InitSDK(exi APPI, logLevel int8) error {
	if exi == nil {
		return errors.New("invalid tun device")
	}
	utils.LogInst().InitParam(utils.LogLevel(logLevel), func(msg string, args ...any) {
		log := fmt.Sprintf(msg, args...)
		exi.Log(log)
	})
	return nil
}
