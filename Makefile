CC=/opt/SUNWspro/sunstudio12.1/bin/cc
LD=ld
CFLAGS=-D_KERNEL
KLDFLAGS=-r -dy -Nfs/sockfs

all:	httpfilt_amd64_mod httpfilt_i386_mod \
	datafilt_amd64_mod datafilt_i386_mod \
	testserv

datafilt_amd64_mod:	datafilt_amd64.lo
	$(LD) $(KLDFLAGS) -o $@ datafilt_amd64.lo
	
datafilt_amd64.lo:	datafilt.c
	$(CC) -m64 -xmodel=kernel $(CFLAGS) -c datafilt.c -o datafilt_amd64.lo

datafilt_i386_mod:	datafilt_i386.lo
	$(LD) $(KLDFLAGS) -o $@ datafilt_i386.lo
	
datafilt_i386.lo:	datafilt.c
	$(CC) -m32 $(CFLAGS) -c datafilt.c -o datafilt_i386.lo

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
	cp datafilt_amd64_mod /kernel/socketmod/amd64/dataf
	cp datafilt_i386_mod /kernel/socketmod/dataf

unload:
	soconfig -F httpf

load:	install
	soconfig -F httpf httpf prog 2:2:0,2:2:6,26:2:0,26:2:6
	soconfig -F dataf dataf prog 2:2:0,2:2:6,26:2:0,26:2:6

clean:
	rm -f httpfilt_amd64_mod httpfilt_i386_mod
	rm -f datafilt_amd64_mod datafilt_i386_mod
	rm -f *.lo testserv
