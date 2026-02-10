(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(soft-charcoal))
 '(custom-safe-themes
   '("f5cd2f7783643d2a731a0905cdf26ba6ffeb0f412b15cb43e2a137795099283b" "4edb863b1fed7e55b1e85a08cbafaf6438060a9a035f538a29e8c86f55abb19f" default))
 '(package-selected-packages '(odin-mode))
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
