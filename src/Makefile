CFLAGS:=--std=c99 -Wall --pedantic -I/usr/include/lua5.2
LDLIBS=-lglut -lGL -lGLEW -llua5.2

all: test1 luacnc-view luacnc2ppm

clean:
	rm -f *.o luacnc-view luacnc2ppm *~

%: %.lua luacnc-view
	./luacnc-view $<

%.ppm: %.lua luacnc2ppm
	./luacnc2ppm $< > $@

%.png: %.ppm
	convert $< $@

build-dep:
	sudo apt-get install liblua5.2-dev lua-mode libglew-dev freeglut3-dev libc6-dev

.PHONY: all clean
