/* readdir(3) + stat() scenario */


#include <dirent.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <errno.h>

#define handle_error(msg) \
		do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define BUF_SIZE 1024


int main(int argc, char *argv[])
{
	char name_buf[BUF_SIZE];
	DIR *dir;
	struct dirent *dentry;

	struct stat file_info;
	int status = 0;

	if (argc <= 1) {
		fprintf(stderr, "%s: missing argument: dir\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	dir = opendir(argv[1]);
	if (!dir)
		handle_error("opendir");

	for (;;) {
		dentry = readdir(dir);
		if (!dentry)
			break;

		sprintf(name_buf, "%s/%s", argv[1], dentry->d_name);
		status = stat(name_buf, &file_info);
		printf("%d %s\n", file_info.st_ino, dentry->d_name);
		if (status != 0)
			handle_error("stat");
	}

	exit(EXIT_SUCCESS);
}
