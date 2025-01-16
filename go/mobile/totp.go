package LockLib

import (
	"encoding/base32"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
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

func cfgKey(issuer, acc string) string {
	return issuer + "_" + acc
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

func (am *AuthManager) newAuth(tc *TOTPConfig) {
	am.mu.Lock()
	cKey := cfgKey(tc.Issuer, tc.Account)
	am.Auth[cKey] = tc
	am.LocalVersion += 1
	am.mu.Unlock()
}

func (am *AuthManager) authData() []byte {
	am.mu.RLock()
	defer am.mu.RUnlock()
	bts, _ := json.Marshal(am.Auth)
	return bts
}

func (am *AuthManager) delAuth(key string) bool {
	am.mu.Lock()
	defer am.mu.Unlock()
	_, exists := am.Auth[key]
	if !exists {
		return false
	}
	delete(am.Auth, key)
	am.LocalVersion += 1
	utils.LogInst().Debugf("Auth with key %s removed from memory.\n", key)
	return true
}

func (am *AuthManager) UpdateLatestVersion(srvVer int64) {
	am.mu.RLock()
	defer am.mu.RUnlock()
	am.SrvVersion = srvVer
	am.LocalVersion = srvVer
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

	data, _ := json.Marshal(__authManager)
	encodeData, err := Encode(data, &priKey.PublicKey)
	if err != nil {
		return fmt.Errorf("failed to encode auth: %w", err)
	}

	err = __walletMng.db.Put(dbKey, encodeData, nil)
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
	period := config.Period
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
	config, err := parseTOTP(url)
	if err != nil {
		return err
	}

	__authManager.newAuth(config)
	go AsyncAuthVerCheck()

	return _saveNewAuth(config)
}

func NewManualAuth(issuer, account, secret string) error {
	config := newDefaultTOTPConfig(issuer, account, secret)

	__authManager.newAuth(config)
	go AsyncAuthVerCheck()

	return _saveNewAuth(config)
}

func _saveNewAuth(conf *TOTPConfig) error {
	__authManager.mu.Lock()
	defer __authManager.mu.Unlock()
	key := cfgKey(conf.Issuer, conf.Account)
	__authManager.Auth[key] = conf
	return saveAuthLocalDb()
}

func initAuthList() {
	if __walletMng.getPriKey(false) == nil {
		utils.LogInst().Errorf("----->>>wallet not open")
		return
	}

	data, err := __walletMng.db.Get(authDbKey(), nil)
	if err != nil {
		if errors.Is(err, leveldb.ErrNotFound) {
			utils.LogInst().Infof("----->>>no local data found")
			return
		}
		utils.LogInst().Errorf("----->>>database get failed:%s", err.Error())
		return
	}

	rawData, err := Decode(data, __walletMng.getPriKey(true))
	if err != nil {
		utils.LogInst().Errorf("----->>>decode local data failed:%s", err.Error())
		return
	}

	err = json.Unmarshal(rawData, &__authManager)
	if err != nil {
		utils.LogInst().Errorf("----->>>unmarshal local data failed:%s", err.Error())
		return
	}

	if __authManager.Auth == nil {
		__authManager.Auth = make(map[string]*TOTPConfig)
		__authManager.LocalVersion = 0
		__authManager.SrvVersion = -1
	}
	utils.LogInst().Infof("------>>> init local data success")
}

func LocalCachedAuth() []byte {
	return __authManager.authData()
}

func RemoveAuth(is, ac string) error {
	key := cfgKey(is, ac)
	needUpdate := __authManager.delAuth(key)
	if !needUpdate {
		return nil
	}
	err := saveAuthLocalDb()
	if err != nil {
		return err
	}
	go AsyncAuthVerCheck()
	return nil
}

func AsyncAuthVerCheck() {
	utils.LogInst().Debugf("------>>>start pushing auth to server")
	__authManager.mu.RLock()
	if __authManager.LocalVersion == __authManager.SrvVersion || __authManager.LocalVersion == 0 {
		utils.LogInst().Debugf("------>>>[Auth] local version and server version are same")
		__authManager.mu.RUnlock()
		return
	}
	__authManager.mu.RUnlock()
	utils.LogInst().Debugf("------>>>[Auth]  local version and server version are not save ,prepare to push data")
	var err = writeEncodedAuthDataToSrv()
	if err != nil {
		__api.callback.AuthDataUpdated(nil, err)
		return
	}
}

func writeEncodedAuthDataToSrv() error {
	rawData := __authManager.authData()
	priKey := __walletMng.getPriKey(true)
	if priKey == nil {
		return fmt.Errorf("invalid private key")
	}
	data, err := Encode(rawData, &priKey.PublicKey)
	if err != nil {
		utils.LogInst().Errorf("------>>>encode rawData failed:%s", err.Error())
		return err
	}
	result, err := uploadLocalData(updateAuthDataAPi, data, __authManager.SrvVersion)
	if err != nil {
		utils.LogInst().Errorf("------>>>upload data failed:%s", err.Error())
		return err
	}
	__authManager.UpdateLatestVersion(result.LatestVer)
	return saveAuthLocalDb()
}

func AsyncAuthSyncing() {
	utils.LogInst().Debugf("------>>>[Auth] start syncing data from server")
	var onlineData = make(map[string]*TOTPConfig)

	onlineVer, err := queryAndDecodeSrvData(queryAuthDataAPi, &onlineData)
	if err != nil {
		__api.callback.AuthDataUpdated(nil, err)
		return
	}
	if onlineData == nil {
		return
	}

	if onlineVer == __authManager.SrvVersion {
		utils.LogInst().Infof("------>>>[Auth] proc sync result:local srvDataWithVer is same as server's")
		return
	}

	if onlineVer < __authManager.SrvVersion {
		utils.LogInst().Debugf("------>>>[Auth] proc sync result:local srvDataWithVer is newer than server's")
		err = writeEncodedAuthDataToSrv()
		if err != nil {
			__api.callback.AuthDataUpdated(nil, err)
			return
		}
		return
	}

	utils.LogInst().Debugf("[Auth] proc sync result: server srvDataWithVer is newer than local's")
	err = mergeSrvDataAuth(onlineData, onlineVer)
	if err != nil {
		__api.callback.AuthDataUpdated(nil, err)
		return
	}
	__api.callback.AuthDataUpdated(__authManager.authData(), nil)
	return
}

func mergeSrvDataAuth(onlineData map[string]*TOTPConfig, onlineVer int64) error {
	__authManager.mu.Lock()
	defer __authManager.mu.Unlock()

	for key, authCfg := range onlineData {
		_, exist := __authManager.Auth[key]
		if !exist {
			__authManager.Auth[key] = authCfg
		}
	}

	__authManager.SrvVersion = onlineVer

	return saveAuthLocalDb()
}

type AuthScheduler struct {
	ticker     *time.Ticker
	paused     bool
	pauseChan  chan struct{}
	resumeChan chan struct{}
	quitChan   chan struct{}
}

var __authTimer = &AuthScheduler{
	pauseChan:  make(chan struct{}),
	resumeChan: make(chan struct{}),
	quitChan:   make(chan struct{}),
	paused:     false,
}

func authCodeTimerStart() {
	// 创建ticker
	__authTimer.ticker = time.NewTicker(AuthCodeTimer)

	utils.LogInst().Debugf("------>>>auther code timer start.....")
	go func() {
		defer __authTimer.ticker.Stop()
		defer utils.LogInst().Debugf("------>>>auther code timer ending.....")

		for {
			select {
			case <-__authTimer.ticker.C:
				if !__authTimer.paused {
					authCodeCalculate()
				}

			case <-__authTimer.pauseChan:
				__authTimer.paused = true
				fmt.Println("------>>>[Scheduler] 已暂停")

			case <-__authTimer.resumeChan:
				__authTimer.paused = false
				fmt.Println("------>>>[Scheduler] 已恢复")

			case <-__authTimer.quitChan:
				fmt.Println("------>>>[Scheduler] 已停止")
				return
			}
		}
	}()
}

func authCodeCalculate() {

	__authManager.mu.RLock()
	defer __authManager.mu.RUnlock()
	for key, config := range __authManager.Auth {
		code, timeLeft, err := generateTOTPCodeWithCountdown(config)
		if err != nil {
			utils.LogInst().Errorf("------>>>auth code generate failed:%v", err)
			continue
		}
		__api.callback.AuthCodeUpdate(key, code, timeLeft)
	}
}

func AuthCodeTimerPause() {
	__authTimer.pauseChan <- struct{}{}
}

func AuthCodeTimerResume() {
	__authTimer.resumeChan <- struct{}{}
}

func AuthCodeTimerStop() {
	__authTimer.quitChan <- struct{}{}
}
