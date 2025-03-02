package LockLib

import "time"

const (
	CTimeInSeconds = 30
	HardenedOffset = 0x80000000 // 用于生成硬化路径

	dbKeyWallet    = "__db_key_wallet__"
	dbKeyClockTime = "__db_key_clock_time__"
	dbKeyAccounts  = "__db_key_accounts__"
	dbKeyAuth      = "__db_key_auth__"
	dbKeyMnemonic  = "__db_key_mnemonic__"

	DefaultClockTimeInMinutes = 1
	AuthCodeTimer             = 800 * time.Millisecond
)
