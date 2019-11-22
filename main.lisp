(defvar *todo-path "~/.jtodolistfiles/")
(defvar *default-list "Todo")

(defun list-add (todo-list data)
  "Adds an item to the list and returns it"
  (append todo-list (list (list nil data))))

(defun list-remove (todo-list index)
  "Removes the item at the index and returns it"
  (labels ((inner-remove (l i)
                         (cond ((= 0 i) (cdr l))
                               ((not l) l)
                               (t (cons (car l) (inner-remove (cdr l) (1- i)))))))
    (inner-remove todo-list index)))

(defun list-toggle-item (item)
  "Returns the item but toggled"
  (cons (not (car item)) (cdr item)))

(defun list-toggle (todo-list index)
  "Toggles the item at the index and returns it"
  (if (< index 1) (return-from list-toggle todo-list))
  (labels ((inner-toggle (l i)
                         (cond ((= 0 i) (cons (list-toggle-item (car l)) (cdr l)))
                               ((not l) l)
                               (t (cons (car l) (inner-toggle (cdr l) (1- i)))))))
    (inner-toggle todo-list index)))

(defun list-clear-done (todo-list)
  "Removes all items that are done from the list"
  (cond ((stringp (car todo-list))
         (cons (car todo-list) (list-clear-done (cdr todo-list))))
        ((not todo-list) todo-list)
        ((car (car todo-list)) (list-clear-done (cdr todo-list)))
        (t (cons (car todo-list) (list-clear-done (cdr todo-list))))))



(defun file-write-list (todo-list)
  "Writes the todo list to a file"
  (if (not todo-list) (return-from file-write-list nil))
  (let ((name (concatenate 'string *todo-path (car todo-list))))
    (with-open-file (f name :direction :output :if-exists :supersede
                       :if-does-not-exist :create)
      (print todo-list f))
    (if (not (cdr todo-list))
      (delete-file (probe-file name)))))

(defun file-read-list (todo-file)
  "Reads the todo list from a file"
  (let ((name (concatenate 'string *todo-path todo-file)))
    (if (probe-file name) (with-open-file (f name) (read f)) (list todo-file))))



(defun display-todo-header (title)
  "Displays the title with an underline"
  (format t " ~a[1;4m~A~a[0m~%" #\escape title #\escape))

(defun display-todo-item (item index)
  "Displays an item with formatting"
  (format t "   ~A. ~A ~A~%"  index (if (car item) "✓" "☐") (car (cdr item))))

(defun  display-todo (todo-list)
  "Pretty prints a todo list"
  (display-todo-header (car todo-list))
  (let ((i 0))
    (dolist (item (cdr todo-list))
      (setf i (1+ i))
      (display-todo-item item i))
    todo-list))

(defun display-all-lists ()
  "Prints all available lists"
  (format t "You have the following todo lists active:~%")
  (let ((files (directory (concatenate 'string *todo-path "**/*"))))
    (dolist (item files)
      (format t "  • ~a~%"
              (subseq (namestring item)
                      (length (namestring (car (directory *todo-path))))))))
  nil) ; important this returns nil, so it doesn't try and write later

(defun display-help ()
  "Prints all option"
  (format t "Usage: todo [-l LIST] [ACTION]~%")
  (format t "    Where Action is one of the following:~%")
  (format t "    -r NUM      Remove the item with the index NUM~%")
  (format t "    -t NUM      Toggles the item with the index NUM~%")
  (format t "    -c          Clears all items that are done~%")
  (format t "    -ls         Prints the name of all your lists~%")
  nil) ; important this returns nil, so it doesn't try and write later



(defun program-get-flag (args flag)
  "Gets the value of the flag"
  (cond ((string-equal flag (car args)) (or (car (cdr args)) t))
        ((not args) nil)
        (t (program-get-flag (cdr (cdr args)) flag))))

(defun program-get-list (args)
  "Returns the list based on the arguments, if no list, uses the default one"
  (or (program-get-flag args "-l") *default-list))

(defun program-remove-flags (args)
  "Returns the arg list, but with all flag and their values removed"
  (cond ((not args) args)
        ((char= #\- (char (car args) 0)) (cdr (cdr args)))
        (t args)))

(defun program-combine-args (args)
  "basically ''.join() but in lisp"
  (cond ((not args) args)
        (t (concatenate 'string
                        (car args) " " (program-combine-args (cdr args))))))

(defun program-get-action (args)
  "Returns the intended action of the program"
  (cond ((program-get-flag args "-t") (list 'toggle (program-get-flag args "-t")))
        ((program-get-flag args "-r") (list 'remove (program-get-flag args "-r")))
        ((program-get-flag args "-c") (list 'clear))
        ((program-get-flag args "-ls") (list 'lists))
        ((program-get-flag args "-h") (list 'help))
        ((not (program-remove-flags args)) (list 'show))
        (t (list 'add (program-remove-flags args)))))

(defun program-todo (args)
  "Main function of the program"
  (let ((l (program-get-list args))
        (action (program-get-action args)))
    (file-write-list
      (cond ((eq (car action) 'clear) (list-clear-done (file-read-list l)))
            ((eq (car action) 'lists) (display-all-lists))
            ((eq (car action) 'help) (display-help))
            ((eq (car action) 'toggle)
             (list-toggle (file-read-list l) (parse-integer (car (cdr action)))))
            ((eq (car action) 'remove)
             (list-remove (file-read-list l) (parse-integer (car (cdr action)))))
            ((eq (car action) 'add)
             (list-add (file-read-list l)
                       (program-combine-args (car (cdr action)))))
            ((eq (car action) 'show)
             (display-todo (file-read-list l)))))))

; buildapp --eval '(load "main.lisp")' --entry main --output todo
; https://www.xach.com/lisp/buildapp/
(defun main (argv)
  (program-todo (cdr argv)))

