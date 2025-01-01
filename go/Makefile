BINDIR=bin

NAME := bp_srv
#.PHONY: pbs

all: a i

a:
	gomobile bind -v -o $(BINDIR)/LockLib.aar -target=android/arm,android/arm64 -ldflags=-s github.com/BASChain/bpassword-ipfs/go/mobile
ir:
	gomobile bind -v -o $(BINDIR)/LockLib.xcframework -target=ios -iosversion=16.0 -ldflags="-s -w" github.com/BASChain/bpassword-ipfs/go/mobile

i:
	gomobile bind -v -o $(BINDIR)/LockLib.xcframework -target=ios -iosversion=15.0 -gcflags="all=-N -l" github.com/BASChain/bpassword-ipfs/go/mobile

mac:
	GOOS=darwin go build -ldflags '-w -s $(LD_FLAGS)' -o $(BINDIR)/$(NAME).mac
arm:
	CC=aarch64-linux-gnu-gcc CGO_ENABLED=1 GOOS=linux GOARM=7 GOARCH=arm64 go build -ldflags '-w -s' -o $(BINDIR)/$(NAME).arm  -ldflags="$(LD_FLAGS)"
linux:
	GOOS=linux GOARCH=amd64 go build -ldflags '-w -s' -o $(BINDIR)/$(NAME).lnx  -ldflags="$(LD_FLAGS)"

clean:
	gomobile clean
	rm $(BINDIR)/*
