/* Example of getdents() syscall */


#define _GNU_SOURCE
#include <dirent.h>	 /* Defines DT_* constants */
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <string.h>

#define handle_error(msg) \
		do { perror(msg); exit(EXIT_FAILURE); } while (0)

struct linux_dirent {
	long   d_ino;
	off_t  d_off;
	unsigned short d_reclen;
	char   d_name[];
};

#define BUF_SIZE 1024

#define FIBMAP 1

int main(int argc, char *argv[])
{
	int fd, nread;
	char buf[BUF_SIZE];
	char name_buf[BUF_SIZE];
	struct linux_dirent *d;
	int bpos;
	char d_type;
	int ffd;
	int blk;

	fd = open(argc > 1 ? argv[1] : ".", O_RDONLY | O_DIRECTORY);
	if (fd == -1)
		handle_error("open");

	for (;;) {
		nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);
		if (nread == -1)
		handle_error("getdents");

		if (nread == 0)
		break;

		for (bpos = 0; bpos < nread;) {
			d = (struct linux_dirent *) (buf + bpos);

			if (strcmp(d->d_name, ".") &&
				strcmp(d->d_name, "..")) {
				sprintf(name_buf, "%s/%s", argv[1], d->d_name);
				ffd = open(name_buf, O_RDONLY);
				if (ffd == -1)
					handle_error("open");

				blk = 0;
				if (ioctl(ffd, FIBMAP, &blk))
					handle_error("ioctl");
				close(ffd);
				printf("%d\n", blk);
			}

			bpos += d->d_reclen;
		}
	}

	exit(EXIT_SUCCESS);
}
