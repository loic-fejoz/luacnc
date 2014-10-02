CFLAGS:=--std=c99 -Wall --pedantic -I/usr/include/lua5.2
LDLIBS=-lglut -lGL -lGLEW -llua5.2

all: test1 luacnc-view

clean:
	rm -f *.o luacnc-view *~

%: %.lua luacnc-view
	./luacnc-view $<

build-dep:
	sudo apt-get install liblua5.2-0-dev lua-mode libglew-dev freeglut3-dev libc6-dev

.PHONY: all clean
