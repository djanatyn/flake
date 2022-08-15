(defpackage :search-history
  (:use :cl :iterate :cl-ppcre :inferior-shell))
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

(defun get-installed-packages ()
  (let* ((flake "github:djanatyn/flake")
         (packages (format nil "~a#nixosConfigurations.desktop.config.environment.systemPackages" flake)))
    (run/s `(nix eval --impure --raw ,packages --apply "builtins.toString"))))

(let ((history (search-history "~/.zsh_history"))
      (installed (get-installed-packages)))
  (iter (for package in history)
    (collect `(:package ,package :match ,(search package installed)))))
