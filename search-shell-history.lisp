(defpackage :search-history
  (:use :cl :iterate :cl-ppcre))
(in-package :search-history)

(defun search-package (line)
  (register-groups-bind
      (package)
      ("nix shell.+nixpkgs#([^ ]+)" line)
    package))

(defun search-lines (lines)
  (iter (for line in lines)
    (let ((package (search-package line)))
      (if package (collect package)))))

(defun search-history (path)
  (let ((contents (str:from-file path :external-format '(:utf-8 :replacement "?"))))
    (remove-duplicates (search-lines (str:lines contents)) :test #'equal)))

(search-history "~/.zsh_history")
