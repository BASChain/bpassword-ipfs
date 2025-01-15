package LockLib

import "time"

const (
	CTimeInSeconds            = 30
	HardenedOffset            = 0x80000000 // 用于生成硬化路径
	__db_key_wallet_          = "__db_key_wallet__"
	__db_key_clock_time_      = "__db_key_clock_time__"
	__db_key_accounts         = "__db_key_accounts__"
	__db_key_auth             = "__db_key_auth__"
	DefaultClockTimeInMinutes = 1
	AuthCodeTimer             = 800 * time.Millisecond
)
