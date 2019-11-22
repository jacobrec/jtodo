todo:
	buildapp --eval '(load "main.lisp")' --entry main --output todo

install: todo
	mv todo /usr/bin/todo

clean:
	rm todo

.PHONY: install clean
