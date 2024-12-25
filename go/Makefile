BINDIR=bin

#.PHONY: pbs

all: a i

a:
	gomobile bind -v -o $(BINDIR)/bpassword_ipfs.aar -target=android/arm,android/arm64 -ldflags=-s github.com/BASChain/bpassword-ipfs/go/mobile
i:
	gomobile bind -v -o $(BINDIR)/bpassword_ipfs.xcframework -target=ios -iosversion=13.0 -ldflags="-s -w" github.com/BASChain/bpassword-ipfs/go/mobile

clean:
	gomobile clean
	rm $(BINDIR)/*
