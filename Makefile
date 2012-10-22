##

all:
	gcc src/lsino.c -o bin/lsino
	gcc src/lsblk.c -o bin/lsblk
	gcc src/dirstat.c -o bin/dirstat

clean:
	rm bin/lsino bin/lsblk bin/dirstat
