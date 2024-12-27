package oneKeyLib

import (
	"flag"
	"fmt"
	"github.com/BASChain/bpassword-ipfs/go/utils"
	"testing"
)

var (
	token = ""
)

func init() {
	flag.StringVar(&token, "t", "", "--t")
}

func TestUpDownLoad(t *testing.T) {

	utils.LogInst().InitParam(utils.DEBUG, func(msg string, args ...any) {
		log := fmt.Sprintf(msg, args...)
		fmt.Println(log)
	})

	InitShell("https://bc.simplenets.org:5001", token)

	cid, err := uploadAndPin([]byte("Hello, IPNS!"))
	if err != nil {
		fmt.Printf("Error: %s\n", err)
		return
	}
	fmt.Println("Content uploaded with CID:", cid)
	fmt.Println(isPinned(cid))

	// 测试解析并下载
	content, err := downloadFromIPFS(cid)
	if err != nil {
		fmt.Printf("Error: %s\n", err)
		return
	}

	fmt.Printf("Downloaded content: %s\n", content)
}
