/* getdents() + stat() scenario
 *
 * This program is based on an example from linux man page getdents(2)
 */


#define _GNU_SOURCE
#include <dirent.h>	 /* Defines DT_* constants */
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#define handle_error(msg) \
		do { perror(msg); exit(EXIT_FAILURE); } while (0)

struct linux_dirent {
	long   d_ino;
	off_t  d_off;
	unsigned short d_reclen;
	char   d_name[];
};

#define BUF_SIZE 1024


int main(int argc, char *argv[])
{
	int fd, nread;
	char buf[BUF_SIZE];
	struct linux_dirent *d;
	int bpos;
	char d_type;

	struct stat file_info;
	int status = 0;
	int nfiles = 0;

	fd = open(argc > 1 ? argv[1] : ".", O_RDONLY | O_DIRECTORY);
	if (fd == -1)
		handle_error("open");

	for ( ; ; ) {
		nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);
		if (nread == -1)
		handle_error("getdents");

		if (nread == 0)
		break;

		for (bpos = 0; bpos < nread;) {
			d = (struct linux_dirent *) (buf + bpos);

			status = stat(argv[1], &file_info);
			if (status != 0)
				handle_error("stat");
			nfiles++;
			bpos += d->d_reclen;
		}
	}

	/*printf("Processed %d files in '%s'\n", nfiles, argv[1]);*/
	exit(EXIT_SUCCESS);
}
