package LockLib

import (
	"encoding/base32"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"
	"github.com/syndtr/goleveldb/leveldb"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

// TOTPConfig 存储TOTP配置信息
type TOTPConfig struct {
	Type      string `json:"type"`
	Issuer    string `json:"issuer"`
	Account   string `json:"account"`
	Secret    string `json:"secret"`
	Algorithm string `json:"algorithm"`
	Digits    int    `json:"digits"`
	Period    int    `json:"period"`
}

func (tc *TOTPConfig) mapKey() string {
	return tc.Issuer + "_" + tc.Account
}

type AuthManager struct {
	Auth         map[string]*TOTPConfig `json:"auth"`
	LocalVersion int64                  `json:"local_version"`
	SrvVersion   int64                  `json:"srv_version"`
	mu           sync.RWMutex
}

var __authManager = &AuthManager{
	Auth: make(map[string]*TOTPConfig),
}

func authDbKey() []byte {
	return []byte(__db_key_auth)
}

func saveAuthLocalDb() error {

	priKey := __walletMng.getPriKey(true)
	if priKey == nil {
		return fmt.Errorf("private key is required")
	}

	dbKey := authDbKey()

	db, err := leveldb.OpenFile(__walletMng.dbPath, nil)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()
	data, _ := json.Marshal(__authManager)
	encodeData, err := Encode(data, &priKey.PublicKey)
	if err != nil {
		return fmt.Errorf("failed to encode auth: %w", err)
	}

	err = db.Put(dbKey, encodeData, nil)
	if err != nil {
		return fmt.Errorf("failed to save Accounts to database: %w", err)
	}
	return nil
}

// parseTOTP 解析 TOTP 配置信息的标准格式
func parseTOTP(otpauthStr string) (*TOTPConfig, error) {
	// 解析URI
	parsedURL, err := url.Parse(otpauthStr)
	if err != nil {
		return nil, fmt.Errorf("无效的URI: %v", err)
	}

	// 验证Scheme
	if parsedURL.Scheme != "otpauth" {
		return nil, errors.New("URI scheme必须是 otpauth")
	}

	// 获取类型（totp 或 hotp）
	typeType := parsedURL.Host
	if typeType != "totp" && typeType != "hotp" {
		return nil, errors.New("URI类型必须是 totp 或 hotp")
	}

	// 获取标签，并解析Issuer和Account
	// 标签格式通常为 "Issuer:Account"
	label := strings.Trim(parsedURL.Path, "/")
	var issuerFromLabel, account string
	if strings.Contains(label, ":") {
		parts := strings.SplitN(label, ":", 2)
		issuerFromLabel = parts[0]
		account = parts[1]
	} else {
		account = label
	}

	// 解析查询参数
	queryParams, err := url.ParseQuery(parsedURL.RawQuery)
	if err != nil {
		return nil, fmt.Errorf("无法解析查询参数: %v", err)
	}

	// 获取并验证 secret 参数
	secret := queryParams.Get("secret")
	if secret == "" {
		return nil, errors.New("缺少 secret 参数")
	}

	// 获取 issuer 参数（如果存在）
	issuer := queryParams.Get("issuer")
	if issuer == "" {
		issuer = issuerFromLabel
	}

	// 获取 algorithm 参数，默认为 SHA1
	algorithm := queryParams.Get("algorithm")
	if algorithm == "" {
		algorithm = "SHA1"
	} else {
		algorithm = strings.ToUpper(algorithm)
		if algorithm != "SHA1" && algorithm != "SHA256" && algorithm != "SHA512" {
			return nil, errors.New("无效的算法类型，仅支持 SHA1, SHA256, SHA512")
		}
	}

	// 获取 digits 参数，默认为 6
	digitsStr := queryParams.Get("digits")
	digits := 6
	if digitsStr != "" {
		digits, err = strconv.Atoi(digitsStr)
		if err != nil || (digits != 6 && digits != 8) {
			return nil, errors.New("digits 参数必须是 6 或 8")
		}
	}

	// 获取 period 参数，默认为 30
	periodStr := queryParams.Get("period")
	period := 30
	if periodStr != "" {
		period, err = strconv.Atoi(periodStr)
		if err != nil || period <= 0 {
			return nil, errors.New("period 参数必须是一个正整数")
		}
	}

	// 构建 TOTPConfig 结构体
	config := &TOTPConfig{
		Type:      typeType,
		Issuer:    issuer,
		Account:   account,
		Secret:    secret,
		Algorithm: algorithm,
		Digits:    digits,
		Period:    period,
	}

	return config, nil
}

func generateTOTPCode(config *TOTPConfig) (string, error) {
	secretBytes, err := base32.StdEncoding.WithPadding(base32.NoPadding).
		DecodeString(strings.ToUpper(config.Secret))
	if err != nil {
		return "", err
	}

	// 将 Algorithm 字符串转换为 otp.Algorithm 类型
	var algorithm otp.Algorithm
	switch config.Algorithm {
	case "SHA1":
		algorithm = otp.AlgorithmSHA1
	case "SHA256":
		algorithm = otp.AlgorithmSHA256
	case "SHA512":
		algorithm = otp.AlgorithmSHA512
	default:
		return "", errors.New("不支持的算法类型")
	}

	// 将 Digits 转换为 otp.Digits 类型
	var digits otp.Digits
	switch config.Digits {
	case 6:
		digits = otp.DigitsSix
	case 8:
		digits = otp.DigitsEight
	default:
		return "", errors.New("digits 必须是 6 或 8")
	}

	// 创建 ValidateOpts
	vOpts := totp.ValidateOpts{
		Period:    uint(config.Period),
		Skew:      1, // 默认的 Skew 值
		Digits:    digits,
		Algorithm: algorithm,
	}

	code, err := totp.GenerateCodeCustom(base32.StdEncoding.EncodeToString(secretBytes), time.Now(), vOpts)
	if err != nil {
		return "", err
	}
	return code, nil
}

func generateTOTPCodeWithCountdown(config *TOTPConfig) (string, int, error) {
	secretBytes, err := base32.StdEncoding.WithPadding(base32.NoPadding).
		DecodeString(strings.ToUpper(config.Secret))
	if err != nil {
		return "", 0, err
	}

	// 将 Algorithm 字符串转换为 otp.Algorithm 类型
	var algorithm otp.Algorithm
	switch config.Algorithm {
	case "SHA1":
		algorithm = otp.AlgorithmSHA1
	case "SHA256":
		algorithm = otp.AlgorithmSHA256
	case "SHA512":
		algorithm = otp.AlgorithmSHA512
	default:
		return "", 0, errors.New("不支持的算法类型")
	}

	// 将 Digits 转换为 otp.Digits 类型
	var digits otp.Digits
	switch config.Digits {
	case 6:
		digits = otp.DigitsSix
	case 8:
		digits = otp.DigitsEight
	default:
		return "", 0, errors.New("digits 必须是 6 或 8")
	}

	// 创建 ValidateOpts
	vOpts := totp.ValidateOpts{
		Period:    uint(config.Period),
		Skew:      1, // 默认的 Skew 值
		Digits:    digits,
		Algorithm: algorithm,
	}

	// 获取当前时间
	now := time.Now()

	// 生成 TOTP 代码
	code, err := totp.GenerateCodeCustom(base32.StdEncoding.EncodeToString(secretBytes), now, vOpts)
	if err != nil {
		return "", 0, err
	}

	// 计算当前时间窗口的结束时间
	currentUnixTime := now.Unix()
	endTime := (currentUnixTime/int64(config.Period))*int64(config.Period) + int64(config.Period)

	// 计算剩余时间
	remainingSeconds := endTime - currentUnixTime

	return code, int(remainingSeconds), nil
}

func generateTOTPCodeWithTimeLeft(config *TOTPConfig) (string, int, error) {
	secretBytes, err := base32.StdEncoding.WithPadding(base32.NoPadding).
		DecodeString(strings.ToUpper(config.Secret))
	if err != nil {
		return "", 0, err
	}

	// 将 Algorithm 字符串转换为 otp.Algorithm 类型
	var algorithm otp.Algorithm
	switch config.Algorithm {
	case "SHA1":
		algorithm = otp.AlgorithmSHA1
	case "SHA256":
		algorithm = otp.AlgorithmSHA256
	case "SHA512":
		algorithm = otp.AlgorithmSHA512
	default:
		return "", 0, errors.New("不支持的算法类型")
	}

	// 将 Digits 转换为 otp.Digits 类型
	var digits otp.Digits
	switch config.Digits {
	case 6:
		digits = otp.DigitsSix
	case 8:
		digits = otp.DigitsEight
	default:
		return "", 0, errors.New("digits 必须是 6 或 8")
	}

	// 创建 ValidateOpts（您原本能编译通过的写法）
	vOpts := totp.ValidateOpts{
		Period:    uint(config.Period),
		Skew:      1, // 默认的 Skew 值，可自行决定
		Digits:    digits,
		Algorithm: algorithm,
	}

	// 关键：生成时把 secretBytes 再 encode 回 Base32
	code, err := totp.GenerateCodeCustom(
		base32.StdEncoding.EncodeToString(secretBytes),
		time.Now(),
		vOpts,
	)
	if err != nil {
		return "", 0, err
	}

	//-----------------------------------------------------
	// 计算倒计时：离下一次刷新还剩多少秒
	// 原理： period - (当前UnixTime % period)
	//-----------------------------------------------------
	period := int(config.Period)
	if period <= 0 {
		// 若用户没设置，或者出错，则默认30
		period = 30
	}
	nowUnix := time.Now().Unix()
	used := nowUnix % int64(period) // 当前周期内已过了多少秒
	timeLeft := period - int(used)  // 剩下多少秒刷新

	return code, timeLeft, nil
}
func newDefaultTOTPConfig(issuer, account, secret string) *TOTPConfig {
	return &TOTPConfig{
		Type:      "totp",  // 默认: TOTP
		Issuer:    issuer,  // 用户提供
		Account:   account, // 用户提供
		Secret:    secret,  // 用户提供 (Base32 编码的字符串)
		Algorithm: "SHA1",  // 默认: SHA1
		Digits:    6,       // 默认: 6 位
		Period:    30,      // 默认: 30 秒
	}
}

func NewScanAuth(url string) error {
	cof, err := parseTOTP(url)
	if err != nil {
		return err
	}
	return _saveNewAuth(cof)

}

func NewManualAuth(issuer, account, secret string) error {
	config := newDefaultTOTPConfig(issuer, account, secret)
	return _saveNewAuth(config)
}

func _saveNewAuth(conf *TOTPConfig) error {
	__authManager.mu.Lock()
	defer __authManager.mu.Unlock()
	key := conf.mapKey()
	__authManager.Auth[key] = conf
	return saveAuthLocalDb()
}
