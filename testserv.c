#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <string.h>

int attach_filter(int fd) {
  int err;

  err = setsockopt(fd, SOL_FILTER, FIL_ATTACH, "httpf", 6);
  if(err < 0) { perror("setsockopt(SOL_FILTER, FIL_ATTACH)"); }
  return err;
}
int main() {
  int serv, child, err;
  char buff[1024], len;
  struct sockaddr_in in4, client4;
  socklen_t client4_len;
  int on = 1;

  memset(&in4, 0, sizeof(in4));
  in4.sin_port = htons(8080);
  serv = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if(serv < 0) { perror("socket"); exit(-1); }

  attach_filter(serv);
  setsockopt(serv, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

  if((err = bind(serv, (struct sockaddr *)&in4, sizeof(in4))) != 0) {
    perror("bind failed");
    exit(-1);
  }

  if((err = listen(serv, 5)) != 0) { perror("listen"); exit(-1); }
  fprintf(stderr, "Listening on socket %d\n", serv);

  client4_len = sizeof(client4);
  child = accept(serv, (struct sockaddr *)&client4, &client4_len);
  if(child < 0) { perror("accept"); exit(-1); }
  fprintf(stderr, "Accepted Child -> %d\n", child);
  len = read(child, buff, sizeof(buff));
  fprintf(stderr, "read %d bytes\n---\n%.*s\n---\n", len, len, buff);
  close(child);
  close(serv);
}
