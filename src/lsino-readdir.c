/* list inodes using readdir(3) */


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

		if (strcmp(dentry->d_name, ".") &&
			strcmp(dentry->d_name, ".."))
			printf("%d\n", dentry->d_ino);
	}

	exit(EXIT_SUCCESS);
}
