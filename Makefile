CC=/opt/SUNWspro/sunstudio12.1/bin/cc
LD=ld
CFLAGS=-D_KERNEL
KLDFLAGS=-r -dy -Nfs/sockfs

all:	httpfilt_amd64_mod httpfilt_i386_mod testserv

httpfilt_amd64_mod:	httpfilt_amd64.lo
	$(LD) $(KLDFLAGS) -o $@ httpfilt_amd64.lo
	
httpfilt_amd64.lo:	httpfilt.c
	$(CC) -m64 -xmodel=kernel $(CFLAGS) -c httpfilt.c -o httpfilt_amd64.lo

httpfilt_i386_mod:	httpfilt_i386.lo
	$(LD) $(KLDFLAGS) -o $@ httpfilt_i386.lo
	
httpfilt_i386.lo:	httpfilt.c
	$(CC) -m32 $(CFLAGS) -c httpfilt.c -o httpfilt_i386.lo

testserv:	testserv.c
	$(CC) -o testserv testserv.c -lsocket

install:	httpfilt_amd64_mod httpfilt_i386_mod
	cp httpfilt_amd64_mod /kernel/socketmod/amd64/httpf
	cp httpfilt_i386_mod /kernel/socketmod/httpf

unload:
	soconfig -F httpf

load:	install
	soconfig -F httpf httpf prog 2:2:0,2:2:6,26:2:0,26:2:6

clean:
	rm -f *.lo httpfilt_amd64_mod httpfilt_i386_mod testserv
