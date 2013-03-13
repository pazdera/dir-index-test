##

all:
	mkdir -p bin/
	gcc src/lsino.c -o bin/lsino
	gcc src/lsino-readdir.c -o bin/lsino-readdir
	gcc src/lsblk.c -o bin/lsblk
	gcc src/getdents-stat.c -o bin/getdents-stat
	gcc src/readdir-stat.c -o bin/readdir-stat
	gcc -o spd_readdir.so -fPIC -shared src/spd_readdir.c -ldl

clean:
	rm -rf bin/ spd_readdir.so
