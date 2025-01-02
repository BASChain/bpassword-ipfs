package service

import (
	"cloud.google.com/go/firestore"
	"context"
	"fmt"
	log "github.com/sirupsen/logrus"
	"google.golang.org/api/option"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"sync"
	"time"
)

const (
	DefaultDBTimeOut = 15 * time.Second
	BPasswordTable   = "table_account_data"
)

func (dm *DbManager) CreateOrUpdateAccount(updateReq *EncodedData) (*UpdateResult, error) {
	collection := dm.fileCli.Collection(BPasswordTable)
	opCtx, cancel := context.WithTimeout(dm.ctx, DefaultDBTimeOut)
	defer cancel()
	// 尝试读取现有文档
	docRef := collection.Doc(updateReq.WalletAddr)
	docSnap, err := docRef.Get(opCtx)
	var result = &UpdateResult{}
	if err != nil {
		if status.Code(err) != codes.NotFound {
			return nil, fmt.Errorf("failed to retrieve document: %w", err)
		}
		updateReq.Version = 1                  // 设置初始版本
		_, err := docRef.Set(opCtx, updateReq) // 存储新的文档
		if err != nil {
			return nil, fmt.Errorf("failed to create new document: %w", err)
		}
		result.LatestVer = 1
		result.ResultCode = 1
		return result, nil
	}

	var existingData EncodedData
	if err := docSnap.DataTo(&existingData); err != nil {
		return nil, fmt.Errorf("failed to parse existing document: %w", err)
	}

	if updateReq.Version > existingData.Version {
		updateReq.Version += 1
		_, err := docRef.Set(opCtx, updateReq) // 存储新的文档
		if err != nil {
			return nil, fmt.Errorf("failed to create new document: %w", err)
		}

		result.LatestVer = updateReq.Version
		result.ResultCode = 2
		return result, nil
	}

	updateReq.Version = existingData.Version + 1 // 版本递增
	_, err = docRef.Set(opCtx, map[string]interface{}{
		"wallet_addr":  updateReq.WalletAddr,
		"encode_value": updateReq.EncodeValue,
		"version":      updateReq.Version,
	})

	if err != nil {
		return nil, fmt.Errorf("failed to update document: %w", err)
	}

	result.LatestVer = updateReq.Version
	result.ResultCode = 3
	return result, nil
}

// GetByAccount 从Firestore获取UpdateRequest
func (dm *DbManager) GetByAccount(walletAddr string) (*EncodedData, error) {
	opCtx, cancel := context.WithTimeout(dm.ctx, DefaultDBTimeOut)
	defer cancel()
	doc, err := dm.fileCli.Collection(BPasswordTable).Doc(walletAddr).Get(opCtx)
	if err != nil {
		if status.Code(err) == codes.NotFound {
			return &EncodedData{
				WalletAddr:  walletAddr,
				EncodeValue: "",
				Version:     -1,
			}, nil
		}
		return nil, err
	}

	var data EncodedData
	if err := doc.DataTo(&data); err != nil {
		return nil, err
	}

	return &data, nil
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
		client, err := firestore.NewClientWithDatabase(ctx, _conf.ProjectID,
			_conf.DatabaseID, option.WithCredentialsFile(_conf.KeyFile))
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
