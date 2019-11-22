todo:
	buildapp --eval '(load "main.lisp")' --entry main --output todo
	chmod +x todo

install: todo
	mv todo /usr/local/bin

clean:
	rm todo

.PHONY: install clean
