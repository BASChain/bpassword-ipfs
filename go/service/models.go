package service

import (
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

// UpdateRequest 更新数据的请求体结构
type UpdateRequest struct {
	WalletAddr  string `json:"wallet_addr" firestore:"wallet_addr" validate:"required,alphanum"`
	EncodeValue string `json:"encode_value" firestore:"encode_value" validate:"required"`
}

// Validate 使用validator库验证 UpdateRequest
func (req *UpdateRequest) Validate() error {
	return validate.Struct(req)
}

// QueryRequest 查询数据的请求体结构
type QueryRequest struct {
	WalletAddr string `json:"wallet_addr" firestore:"wallet_addr" validate:"required,alphanum"`
}

// Validate 使用validator库验证 QueryRequest
func (req *QueryRequest) Validate() error {
	return validate.Struct(req)
}
