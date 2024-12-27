package main

import (
	"cloud.google.com/go/firestore"
	"context"
	"encoding/json"
	"fmt"
	"google.golang.org/api/option"
	"log"
	"net/http"
	"sync"
)

var _dbInst *DbManager
var databaseOnce sync.Once

type DbManager struct {
	fileCli *firestore.Client
	ctx     context.Context
	cancel  context.CancelFunc
}

func DbInst() *DbManager {
	databaseOnce.Do(func() {
		_dbInst = newDb()
	})
	return _dbInst
}

func newDb() *DbManager {
	ctx, cancel := context.WithCancel(context.Background())
	var client *firestore.Client
	var err error

	client, err = firestore.NewClientWithDatabase(ctx, _conf.ProjectID,
		_conf.DatabaseID, option.WithCredentialsFile(_conf.KeyFile))
	if err != nil {
		panic(err)
	}
	var dbm = &DbManager{
		fileCli: client,
		ctx:     ctx,
		cancel:  cancel,
	}
	return dbm
}

// 数据存储结构
var dataStore = struct {
	sync.RWMutex
	data map[string]interface{}
}{data: make(map[string]interface{})}

// UpdateRequest 更新数据的请求体结构
type UpdateRequest struct {
	WalletAddr  string `json:"wallet_addr" firestore:"wallet_addr"`
	EncodeValue string `json:"encode_value"  firestore:"encode_value"`
}

// QueryRequest 查询数据的请求体结构
type QueryRequest struct {
	WalletAddr string `json:"wallet_addr" firestore:"wallet_addr"`
}

// 更新数据的处理函数
func updateData(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var updateReq UpdateRequest
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&updateReq)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	dataStore.Lock()
	dataStore.data[updateReq.WalletAddr] = updateReq.EncodeValue
	dataStore.Unlock()

	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprintf(w, "Data updated successfully")
}

// 查询数据的处理函数
func queryData(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var queryReq QueryRequest
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&queryReq)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	dataStore.RLock()
	value, exists := dataStore.data[queryReq.WalletAddr]
	dataStore.RUnlock()

	if !exists {
		http.Error(w, "Data not found", http.StatusNotFound)
		return
	}

	response := map[string]interface{}{
		"key":   queryReq.WalletAddr,
		"value": value,
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(response)
}

type Config struct {
	Addr       string
	ProjectID  string
	DatabaseID string
	KeyFile    string
}

var _conf = &Config{
	Addr:       "127.0.0.1:5002",
	ProjectID:  "dessage",
	DatabaseID: "bpassword",
	KeyFile:    "dessage-c3b5c95267fb.json",
}

func main() {
	http.HandleFunc("/updateData", updateData)
	http.HandleFunc("/queryData", queryData)

	// 启动 HTTP 服务
	log.Println("Starting server on :5002...")
	err := http.ListenAndServe(_conf.Addr, nil)
	if err != nil {
		log.Fatal("Error starting server: ", err)
	}
}
