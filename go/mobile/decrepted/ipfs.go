package decrepted

import (
	"bytes"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"net/http"
	"sync"
	"time"

	shell "github.com/ipfs/go-ipfs-api"
)

const (
	IPNSDefaultTime = 7 * 24 * time.Hour
)

var sharedIpfs = &IPFSApi{}

type IPFSApi struct {
	shell *shell.Shell
	mu    sync.Mutex
}

type transportWithAuth struct {
	transport http.RoundTripper
	token     string
}

func (t *transportWithAuth) RoundTrip(req *http.Request) (*http.Response, error) {
	if t.token == "" {
		return nil, fmt.Errorf("authorization token is missing")
	}
	req.Header.Add("Authorization", t.token)
	return t.transport.RoundTrip(req)
}

// InitShell 初始化 IPFS 客户端
func InitShell(url, token string) {
	sharedIpfs.mu.Lock()
	defer sharedIpfs.mu.Unlock()

	client := &http.Client{
		Transport: &transportWithAuth{
			transport: http.DefaultTransport,
			token:     token,
		},
	}
	sharedIpfs.shell = shell.NewShellWithClient(url, client)
}

// 检查 Shell 是否已初始化
func checkShellInitialized() error {
	sharedIpfs.mu.Lock()
	defer sharedIpfs.mu.Unlock()

	if sharedIpfs.shell == nil {
		return fmt.Errorf("IPFS shell is not initialized. Call InitShell first")
	}
	return nil
}

// 上传内容到 IPFS
func uploadToIPFS(content []byte) (string, error) {
	if err := checkShellInitialized(); err != nil {
		return "", err
	}

	reader := bytes.NewReader(content)
	cid, err := sharedIpfs.shell.Add(reader)
	if err != nil {
		return "", fmt.Errorf("failed to upload content to IPFS node: %w", err)
	}
	return cid, nil
}

// 从 IPFS 下载内容
func downloadFromIPFS(cid string) ([]byte, error) {
	if err := checkShellInitialized(); err != nil {
		return nil, err
	}

	reader, err := sharedIpfs.shell.Cat(cid)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve content from IPFS node: %w", err)
	}
	defer reader.Close()

	buf := new(bytes.Buffer)
	_, err = buf.ReadFrom(reader)
	if err != nil {
		return nil, fmt.Errorf("failed to read content from IPFS node: %w", err)
	}
	return buf.Bytes(), nil
}

// publishToIPNS 发布 CID 到 IPNS
func publishToIPNS(contentHash, key string) (string, error) {
	if sharedIpfs.shell == nil {
		return "", fmt.Errorf("IPFS shell is not initialized")
	}

	// 发布 CID 到指定的 IPNS 键
	resp, err := sharedIpfs.shell.PublishWithDetails(contentHash, key, IPNSDefaultTime, 0, true)
	if err != nil {
		return "", fmt.Errorf("failed to publish to IPNS: %w", err)
	}
	return resp.Name, nil
}

// resolveIPNS 解析 IPNS 名称到最新的 CID
func resolveIPNS(ipnsKey string) (string, error) {
	if sharedIpfs.shell == nil {
		return "", fmt.Errorf("IPFS shell is not initialized")
	}

	// 解析 IPNS 名称到最新的 CID
	resolvedPath, err := sharedIpfs.shell.Resolve(ipnsKey)
	if err != nil {
		return "", fmt.Errorf("failed to resolve IPNS name: %w", err)
	}

	return resolvedPath, nil
}

func uploadAndPin(content []byte) (string, error) {

	// 上传内容到 IPFS
	cid, err := uploadToIPFS(content)
	if err != nil {
		return "", fmt.Errorf("failed to upload content: %w", err)
	}
	utils.LogInst().Debugf("Uploaded content with CID: %s\n", cid)

	// 固定内容到本地节点
	err = pinContent(cid)
	if err != nil {
		return "", fmt.Errorf("failed to pin content: %w", err)
	}
	utils.LogInst().Debugf("Pinned content with CID: %s\n", cid)

	return cid, nil
}

// pinContent 固定指定的 CID 到本地节点
func pinContent(cid string) error {
	if sharedIpfs.shell == nil {
		return fmt.Errorf("IPFS shell is not initialized")
	}

	// 调用 Shell.Pin 方法
	err := sharedIpfs.shell.Pin(cid)
	if err != nil {
		return fmt.Errorf("failed to pin content: %w", err)
	}

	utils.LogInst().Debugf("Content with CID %s has been pinned to the local node.\n", cid)
	return nil
}

// unpinContent 解除指定的 CID 的固定
func unpinContent(cid string) error {
	if sharedIpfs.shell == nil {
		return fmt.Errorf("IPFS shell is not initialized")
	}

	// 调用 Shell.Unpin 方法
	err := sharedIpfs.shell.Unpin(cid)
	if err != nil {
		return fmt.Errorf("failed to unpin content: %w", err)
	}

	utils.LogInst().Debugf("Content with CID %s has been unpinned from the local node.\n", cid)
	return nil
}

func isPinned(cid string) (bool, error) {
	if sharedIpfs.shell == nil {
		return false, fmt.Errorf("IPFS shell is not initialized")
	}

	// 获取所有固定内容
	pins, err := sharedIpfs.shell.Pins()
	if err != nil {
		return false, fmt.Errorf("failed to list pins: %w", err)
	}

	// 检查 CID 是否存在并匹配类型
	if _, ok := pins[cid]; ok {
		return true, nil

	}

	return false, nil
}

func uploadAndPublish(content []byte, ipnsKey string) error {

	// 上传内容到 IPFS
	cid, err := uploadToIPFS(content)
	if err != nil {
		return fmt.Errorf("failed to upload content: %w", err)
	}
	utils.LogInst().Debugf("Uploaded content with CID: %s\n", cid)

	// 固定内容到本地节点
	err = pinContent(cid)
	if err != nil {
		return fmt.Errorf("failed to pin content: %w", err)
	}
	utils.LogInst().Debugf("Pinned content with CID: %s\n", cid)

	// 发布到 IPNS
	ipnsName, err := publishToIPNS(cid, ipnsKey)
	if err != nil {
		return fmt.Errorf("failed to publish to IPNS: %w", err)
	}
	utils.LogInst().Debugf("Published CID to IPNS: %s\n", ipnsName)

	return nil
}

func resolveAndDownload(ipnsKey string) ([]byte, error) {
	// 解析 IPNS 名称到 CID
	cid, err := resolveIPNS(ipnsKey)
	if err != nil {
		return nil, fmt.Errorf("failed to resolve IPNS: %w", err)
	}
	utils.LogInst().Debugf("Resolved IPNS to CID: %s\n", cid)

	// 下载内容
	content, err := downloadFromIPFS(cid)
	if err != nil {
		return nil, fmt.Errorf("failed to download content: %w", err)
	}

	return content, nil
}
