BINDIR=bin

#.PHONY: pbs

all: a i

a:
	gomobile bind -v -o $(BINDIR)/LockLib.aar -target=android/arm,android/arm64 -ldflags=-s github.com/BASChain/bpassword-ipfs/go/mobile
ir:
	gomobile bind -v -o $(BINDIR)/LockLib.xcframework -target=ios -iosversion=16.0 -ldflags="-s -w" github.com/BASChain/bpassword-ipfs/go/mobile

i:
	gomobile bind -v -o $(BINDIR)/LockLib.xcframework -target=ios -iosversion=15.0 -gcflags="all=-N -l" github.com/BASChain/bpassword-ipfs/go/mobile

clean:
	gomobile clean
	rm $(BINDIR)/*
