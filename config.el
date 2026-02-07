(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			      :ref nil :depth 1 :inherit ignore
			      :files (:defaults "elpaca-test.el" (:exclude "extensions"))
			      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
	(if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
						  ,@(when-let* ((depth (plist-get order :depth)))
						      (list (format "--depth=%d" depth) "--no-single-branch"))
						  ,(plist-get order :repo) ,repo))))
		  ((zerop (call-process "git" nil buffer t "checkout"
					(or (plist-get order :ref) "--"))))
		  (emacs (concat invocation-directory invocation-name))
		  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
					"--eval" "(byte-recompile-directory \".\" 0 'force)")))
		  ((require 'elpaca))
		  ((elpaca-generate-autoloads "elpaca" repo)))
	    (progn (message "%s" (buffer-string)) (kill-buffer buffer))
	  (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.

;; (elpaca example-package)

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

;; [EVIL MODE]
;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  :ensure (:wait t)  ; Block until installed
  :demand t  ; Load immediately (not deffered)
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  :config
  (evil-mode 1))

(use-package evil-collection
    :ensure (:wait t)  ; CRITICAL: wait for install
    :after evil
    :demand t  ; CRITICAL: load immediately after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))

(use-package evil-tutor
  :ensure (:wait t)
  :demand t)

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

(use-package general
    :ensure (:wait t)
    :demand t  ; Must load before defining keys
    :after evil
    :config
    (general-evil-setup)

    ;; Set up  'SPC' as the global leader key
    (general-create-definer rv/leader-keys
	:states '(normal insert visual emacs)
	:keymaps 'override
	:prefix "SPC"  ;; set leader key
	:global-prefix "M-SPC")  ;; access leader in insert mode

    (rv/leader-keys
	"b" '(:ignore t :wk "buffer")
	"bb" '(switch-to-buffer :wk "Switch buffer")
	"bk" '(kill-this-buffer :wk "Kill this buffer")
	"bn" '(next-buffer :wk "Next buffer")
	"bp" '(previous-buffer :wk "Previous buffer")
	"br" '(revert-buffer :wk "Reload buffer")))

(set-face-attribute 'default nil
      :font "JetBrainsMono Nerd Font"
      :height 150
      :weight 'medium)

(set-face-attribute 'variable-pitch nil
    :font "Ubuntu"
    :height 150
    :weight 'medium)

(set-face-attribute 'fixed-pitch nil
    :font "JetBrainsMono Nerd Font"
    :height 150
    :weight 'medium)

;; Makes commented text and keywords italicized
;; This works in emacsclient but not emacs.
;; Font must have an italic face available
(set-face-attribute 'font-lock-comment-face nil
    :slant 'italic)

(set-face-attribute 'font-lock-keyword-face nil
    :slant 'italic)

;; This sets the default font on graphical frames
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-15"))

;; Set line spacing
(setq-default line-spacing 0.14)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package toc-org
    :ensure (:wait t)
    :demand t
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets :ensure (:wait t) :demand t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package which-key
    :ensure (:wait t)
    :demand t  ; Must load before defining keys
    :init
    (which-key-mode 1)
    :config
    (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit t
          which-key-separator " -> " ))
