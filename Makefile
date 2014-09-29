all: luacnc-view README.html

luacnc-view:
	cd src && make luacnc-view

README.html: README.md
	markdown $< > $@

clean:
	rm -f *~ README.html
