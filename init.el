(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4d5d11bfef87416d85673947e3ca3d3d5d985ad57b02a7bb2e32beaf785a100e" default))
 '(package-selected-packages '(elixir-mode odin-mode))
 '(package-vc-selected-packages
   '((odin-mode :vc-backend Git :url "https://git.sr.ht/~mgmarlow/odin-mode"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Suppress harmless compilation warnings during first install
(setq native-comp-async-report-warnings-errors nil)  ; For native-comp (Emacs 28+)
(setq byte-compile-warning-types nil)                ; For byte-comp
(setq elpaca-log-buffer-max-lines 50)                ; Limit Elpaca log chatter
