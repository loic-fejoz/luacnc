CFLAGS:=--std=c99 -Wall --pedantic -I/usr/include/lua5.2
LDLIBS=-lglut -lGL -lGLEW -llua5.2 

all: test1

clean:
	rm -f *.o luacnc-view *~

%: %.lua luacnc-view
	./luacnc-view $<

.PHONY: all clean
