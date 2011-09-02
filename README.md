HTTP Accept Filters for Solaris
===

Once built and installed: (make install), you can load these with

     soconfig -F httpf httpf prog 2:2:0,2:2:6,26:2:0,26:2:6

Then applications must programatically enable them immediately
after socket() and before bind() with a setsockopt() call as follows:

     setsockopt(fd, SOL_FILTER, FIL_ATTACH, "httpf", 6);

How they work?
===

This is a kernel module that use the sockfs filtering API. The accept
notification is deferred for new passive sockets until:

  * 4 bytes are read that are not GET, HEAD, POST, PUT (trailing spaces
    where needed).
  * a \r\n\r\n or \n\n are found after the initial 4 bytes.
  * 8192 bytes are read

