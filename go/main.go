package main

import (
	"bytes"
	"fmt"
	"log"

	shell "github.com/ipfs/go-ipfs-api"
)

func main() {
	// 本地 IPFS 节点地址
	localNode := "http://127.0.0.1:5001"

	// 创建 IPFS 客户端
	sh := shell.NewShell(localNode)

	// 测试上传内容
	content := "Hello, IPFS! This is a test."
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
