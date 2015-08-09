;; my emacs file is a weed

;; installation:
;; presumably you got this file as part of the git setup
;; It seems only external program that needs to be installed for
;; this repository to work is w3m. To let flyspell do it's
;; thing, install ispell. To use the hyperspec, go to
;; ~/emacs-kipple/docs and do:
;; wget ftp://ftp.lispworks.com/pub/software_tools/reference/HyperSpec-7-0.tar.gz
;; tar -zxf HyperSpec-7-0.tar.gz

;; configure your kipple-path and decide which systems should be loaded (none
;; for now). It should at least say something like:
;; (setq *emacs-base* (expand-file-name "/home/zeno/emacs-kipple/"))

;; vars

;; setup config
(defvar *to-be-loaded*
  '(general junk))

;; a list of lists containing module setup, package names and load-paths
(defvar *setup*
  '((general () ())
    (junk () ())
    (lisp () ())
    (python (jedi) ("python-mode" "Pymacs"))))

;; list of config files that will be loaded
(defvar *configs* '())

;; list of elisp packages that will be ensured to be installed
;; if this var isn't empty initially it's because i should be
;; less lazy and move all this stuff to their proper modules + init
(defvar *packages* '(magit git-gutter circe mo-git-blame rust-mode
                           auto-complete fill-column-indicator
                           autopair))

;; list of load paths that will be appended to the list of load paths ;)
;; if this var isn't empty initially it's because i should be
;; less lazy and move all this stuff to their proper modules + init
(defvar *load-paths*
  '("ess-5.9.1/lisp"
    "psgml-1.3.2"
    "mmm-mode-0.4.8"
    "emacs-w3m"
    "erc-5.2"
    "color-theme-6.6.0"
    "color-theme-6.6.0/themes"
    "distel/elisp"
    "styleguide"))

;; set the base of your emacs file
(defvar *emacs-base* (expand-file-name "~/emacs-kipple/"))

;; logic
(defun set-config (sym)
  (let* ((config     (assoc sym *setup*))
         (module     (first config))
         (packages   (second config))
         (load-paths (third config)))
    (when module
      (push module *configs*))
    (when packages
      (setq *packages*
	    (append packages *packages*)))
    (when load-paths
      (setq *load-paths*
	    (append load-paths *load-paths*)))))

(defun set-configs ()
  (loop for item in *to-be-loaded*
        do (set-config item))
  (set-load-paths)
  (set-packages))

(defun set-load-paths ()
  (setq load-path
	(append (list *emacs-base*
                  (concat *emacs-base* "lib"))
		(loop for load in *load-paths*
		      collect (concat *emacs-base* "lib/" load))
		load-path)))

;; We can extend our use of packages by using use-package.
;; it could be implemented simply by giving a list instead of
;; the package name, and having set-package check for list
;; http://stackoverflow.com/questions/21064916/auto-install-emacs-packages-with-melpa
(defun set-packages ()
  (setq package-list *packages*)

  ;; list the repositories containing them
  (setq package-archives
        '(("gnu" . "http://elpa.gnu.org/packages/")
          ("marmalade" . "https://marmalade-repo.org/packages/")
          ;;("melpa" . "http://melpa.milkbox.net/packages/")
          ("elpa" . "http://tromey.com/elpa/")))
  ;; activate all the packages (in particular autoloads)
  (package-initialize)
  ;; fetch the list of packages available
  (unless package-archive-contents
    (package-refresh-contents))
  ;; install the missing packages
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package))))

(defun load-module (mod)
  (when mod
    (load (concat *emacs-base* "config/" (symbol-name mod) ".el"))))

(defun set-it-all-up ()
  (set-configs)
  (loop for mod in *configs*
        do (load-module mod)))

;; use this in .emacs-config to add your modules which should be loaded
(defun add-to-load (configs)
  (setq *to-be-loaded*
        (append configs *to-be-loaded*)))

;;-------------------------------

(load "~/.emacs-config")

;;-------------------------------

(set-it-all-up)
