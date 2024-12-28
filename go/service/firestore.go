package service

import (
	"cloud.google.com/go/firestore"
	"context"
	log "github.com/sirupsen/logrus"
	"google.golang.org/api/option"
	"sync"
)

const (
	BPasswordTable = "AccountData"
)

// CreateOrUpdateAccount 将UpdateRequest保存到Firestore
func (dm *DbManager) CreateOrUpdateAccount(ctx context.Context, updateReq UpdateRequest) error {
	collection := dm.fileCli.Collection(BPasswordTable)
	_, err := collection.Doc(updateReq.WalletAddr).Set(ctx, map[string]interface{}{
		"wallet_addr":  updateReq.WalletAddr,
		"encode_value": updateReq.EncodeValue,
	})
	return err
}

// GetAccount 从Firestore获取UpdateRequest
func (dm *DbManager) GetAccount(ctx context.Context, walletAddr string) (UpdateRequest, error) {
	doc, err := dm.fileCli.Collection(BPasswordTable).Doc(walletAddr).Get(ctx)
	if err != nil {
		return UpdateRequest{}, err
	}

	var data UpdateRequest
	if err := doc.DataTo(&data); err != nil {
		return UpdateRequest{}, err
	}

	return data, nil
}

// DbManager 管理 Firestore 客户端
type DbManager struct {
	fileCli *firestore.Client
	ctx     context.Context
	cancel  context.CancelFunc
}

var (
	_dbInst      *DbManager
	databaseOnce sync.Once
)

// DbInst 获取 DbManager 实例
func DbInst() *DbManager {
	databaseOnce.Do(func() {
		ctx, cancel := context.WithCancel(context.Background())
		client, err := firestore.NewClient(ctx, _conf.ProjectID, option.WithCredentialsFile(_conf.KeyFile))
		if err != nil {
			panic(err)
		}

		_dbInst = &DbManager{
			fileCli: client,
			ctx:     ctx,
			cancel:  cancel,
		}
	})
	return _dbInst
}

func (dm *DbManager) Close() {
	dm.cancel()
	if err := dm.fileCli.Close(); err != nil {
		log.Errorf("Firestore client close failed: %v", err)
	}

}
