build:
	buildapp --eval '(load "main.lisp")' --entry main --output todo
	chmod +x todo

install: build
	mv todo /usr/local/bin
