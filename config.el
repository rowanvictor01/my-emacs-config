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
    (setq evil-collection-mode-list '(dashboard dired ibuffer term))
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
    (general-evil-setup))

    ;; Set up  'SPC' as the global leader key
    (general-create-definer rv/leader-keys
        :states '(normal insert visual emacs)
        :keymaps 'override
        :prefix "SPC"  ;; set leader key
        :global-prefix "M-SPC")  ;; access leader in insert mode

;; Find File, Open config.org, Comment Line, etc...
    (rv/leader-keys
         "." '(find-file :wk "Find File")
         "fc" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit Emacs Config")
         "fr" '(counsel-recentf :wk "Find Recent Files")
         "TAB TAB" '(comment-line :wk "Comment Line/s")


;; Opening a buffer to a split window
         "fw" '(find-file-other-window :wk "Find File -> Split")
         "dw" '(dired-other-window :wk "Dired -> Split"))


;; Buffer
    (rv/leader-keys
        "b" '(:ignore t :wk "Buffer")
        "bb" '(switch-to-buffer :wk "Switch Buffer")
        "bi" '(ibuffer :wk "Ibuffer")
        "bk" '(kill-this-buffer :wk "Kill This Buffer")
        "bn" '(next-buffer :wk "Next Buffer")
        "bp" '(previous-buffer :wk "Previous Buffer")
        "br" '(revert-buffer :wk "Reload Buffer"))

;; Evaluate
    (rv/leader-keys
        "e" '(:ignore t :wk "Evaluate")
        "eb" '(eval-buffer :wk "Evaluate Elisp In Buffer")
        "ed" '(eval-defun :wk "Evaluate Defun Containing Or After Point")
        "ee" '(eval-expression :wk "Evaluate An Elisp Expression")
        "el" '(eval-last-sexp :wk "Evaluate Elisp Expression Before Point")
        "er" '(eval-region :wk "Evaluate Elisp In Region"))

;; Help
    (rv/leader-keys
        "h" '(:ignore t :wk "Help")
        "hf" '(describe-function :wk "Describe Function")
        "hv" '(describe-variable :wk "Describe Variable")
        "hrr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload Emacs Config"))

;; Register
    (rv/leader-keys
        "r" '(:ignore t :wk "Register")
        "rb" '(point-to-register :wk "Register Buffer")
        "rj" '(jump-to-register :wk "Jump To Register"))

;; Toggle term-mode
    (rv/leader-keys
        "t" '(term :wk "Open term-mode"))

;; Window Split Navigation
(rv/leader-keys
  "w" '(:ignore t :wk "Windows")
  ;; Window splits
  "w c" '(evil-window-delete :wk "Close Window")
  "w n" '(evil-window-new :wk "New Window")
  "w s" '(evil-window-split :wk "Horizontal Split Sindow")
  "w v" '(evil-window-vsplit :wk "Vertical Split Window")
  ;; Window motions
  "w h" '(evil-window-left :wk "Window Left")
  "w j" '(evil-window-down :wk "Window Down")
  "w k" '(evil-window-up :wk "Window Up")
  "w l" '(evil-window-right :wk "Window Right")
  "w w" '(evil-window-next :wk "Goto Next Window")
  ;; Move Windows
  "w H" '(buf-move-left :wk "Buffer Move Left")
  "w J" '(buf-move-down :wk "Buffer Move Down")
  "w K" '(buf-move-up :wk "Buffer Move Up")
  "w L" '(buf-move-right :wk "Buffer Move Right"))

(use-package lsp-mode
  :ensure (:wait t)
  :demand t
  :after which-key
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (clangd-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package all-the-icons
  :ensure (:wait t)
  :demand t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :ensure (:wait t)
  :demand t
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

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

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Enable line numbers
(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

;; Set the line numbering style to relative
(setq display-line-numbers-type 'relative)

(use-package counsel
  :ensure (:wait t)
  :demand t
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :ensure (:wait t)
  :demand t
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package toc-org
    :ensure (:wait t)
    :demand t
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets :ensure (:wait t) :demand t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)

(require 'org-tempo)

(use-package eshell-syntax-highlighting
  :ensure (:wait t)
  :demand t
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
  
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
:ensure (:wait t)
:demand t
:config
(setq shell-file-name "/usr/bin/zsh"
      vterm-max-scrollback 5000))

(use-package vterm-toggle
  :ensure (:wait t)
  :demand t
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.35))))

(use-package sudo-edit
  :ensure (:wait t)
  :demand t
  :config
    (rv/leader-keys
      "s." '(sudo-edit-find-file :wk "Sudo Find File")
      "se" '(sudo-edit :wk "Sudo Edit File")))

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

;; Disable auto-save files
(setq auto-save-default nil)

;; Disable backup files
(setq make-backup-files nil)

;; Disable auto-save list directory
(setq auto-save-list-file-prefix nil)
