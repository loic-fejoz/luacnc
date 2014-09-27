CFLAGS:=--std=c99 -Wall --pedantic -I/usr/include/lua5.2
LDLIBS=-lglut -lGL -lGLEW -llua5.2 

all: luacnc-view
	./luacnc-view test1.lua

clean:
	rm -f *.o luacnc-view *~

.PHONY: all clean
