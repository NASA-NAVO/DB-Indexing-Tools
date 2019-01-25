all:        libs sptIndx sptQuery

libs:
				(cd ../lib; make; make install)

sptIndx:		sptIndx.o
				gcc -m64 -o sptIndx sptIndx.o ../lib/src/tinyhtm/src/libhtm.a -lm

sptIndx.o:	sptIndx.c
				gcc -m64 -c -Wall -I../lib/src/tinyhtm/include sptIndx.c

sptQuery:	sptQuery.o
				gcc -m64 -o sptQuery sptQuery.o ../lib/sptQueryLib.o ../lib/src/tinyhtm/src/libhtm.a -lm

sptQuery.o:	sptQuery.c
				gcc -m64 -c -Wall -I../lib/include -I../lib/src/tinyhtm/include sptQuery.c

install:
				cp sptIndx sptQuery ../bin

clean:
				rm -f sptIndx sptQuery *.o
