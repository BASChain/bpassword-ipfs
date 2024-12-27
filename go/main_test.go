package main

import (
	"bytes"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	shell "github.com/ipfs/go-ipfs-api"
	"log"
	"net/http"
	"testing"
)

func TestTokenGenerate(t *testing.T) {
	value := "BPassword IPFS"

	// 生成 MD5 值
	data := []byte(value)

	// 创建 MD5 哈希
	hash := md5.Sum(data)

	// 将哈希值转换为十六进制字符串
	md5Value := hex.EncodeToString(hash[:])

	// 输出结果
	fmt.Printf("The MD5 hash of \"%s\" is: %s\n", value, md5Value)
}

// 上传内容到 IPFS
func uploadToIPFS(sh *shell.Shell, content string) (string, error) {
	// 创建一个 Reader
	reader := bytes.NewReader([]byte(content))

	// 调用 Shell.Add 方法上传内容
	cid, err := sh.Add(reader)
	if err != nil {
		return "", fmt.Errorf("failed to upload content: %w", err)
	}
	return cid, nil
}

// 从 IPFS 下载内容
func downloadFromIPFS(sh *shell.Shell, cid string) (string, error) {
	// 调用 Shell.Cat 方法获取内容
	reader, err := sh.Cat(cid)
	if err != nil {
		return "", fmt.Errorf("failed to retrieve content: %w", err)
	}
	defer reader.Close()

	// 读取内容
	buf := new(bytes.Buffer)
	_, err = buf.ReadFrom(reader)
	if err != nil {
		return "", fmt.Errorf("failed to read content: %w", err)
	}
	return buf.String(), nil
}

func TestIpfsLogic(t *testing.T) {
	// 本地 IPFS 节点地址
	localNode := "https://bc.simplenets.org:5001"

	// 创建 IPFS 客户端
	sh := newShell(localNode)

	// 测试上传内容
	content := "Bpassword ipfs===>"
	cid, err := uploadToIPFS(sh, content)
	if err != nil {
		log.Fatalf("Failed to upload content: %v\n", err)
	}
	fmt.Printf("Content uploaded with CID: %s\n", cid)

	// 测试下载内容
	retrievedContent, err := downloadFromIPFS(sh, cid)
	if err != nil {
		log.Fatalf("Failed to retrieve content: %v\n", err)
	}
	fmt.Printf("Content retrieved: %s\n", retrievedContent)
}

type transportWithAuth struct {
	transport http.RoundTripper
	token     string
}

func (t *transportWithAuth) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Add("Authorization", t.token)
	return t.transport.RoundTrip(req)
}

func newShell(url string) *shell.Shell {
	c := &http.Client{
		Transport: &transportWithAuth{
			transport: http.DefaultTransport,
			token:     "", // 替换为实际的 Token
		},
	}

	return shell.NewShellWithClient(url, c)
}
