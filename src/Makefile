CFLAGS:=--std=c99 -Wall --pedantic -I/usr/include/lua5.2
LDLIBS=-lglut -lGL -lGLEW -llua5.2 

all: main
	./main

clean:
	rm -f *.o main *~

.PHONY: all clean
