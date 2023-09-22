;;; config-new.el -*- lexical-binding: t; -*-

(setq user-mail-address "Edmund.A.Miller@gmail.com"
      user-full-name "Edmund Miller")

;; When I bring up Doom's scratch buffer with SPC x, it's often to play with
;; elisp or note something down (that isn't worth an entry in my notes). I can
;; do both in `lisp-interaction-mode'.
(setq doom-scratch-initial-major-mode 'lisp-interaction-mode)


;;
;;; UI

;; "monospace" means use the system default. However, the default is usually two
;; points larger than I'd like, so I specify size 12 here.

(setq doom-theme 'doom-one
      doom-font (font-spec :family "Comic Code Ligatures" :size 12)
      doom-variable-pitch-font (font-spec :family "iA Writer Duospace" :size 16)
      doom-unicode-font (font-spec :family "JuliaMono"))

(use-package! circadian
  :init
  (setq calendar-latitude 32.9)
  (setq calendar-longitude -96.75)
  (setq circadian-themes '((:sunrise . doom-nord-light)
                           (:sunset  . doom-palenight)))
  (add-transient-hook! 'doom-init-ui-hook (circadian-setup)))

;; Line numbers are pretty slow all around. The performance boost of
;; disabling them outweighs the utility of always keeping them on.
(setq display-line-numbers-type nil)

;; Prevents some cases of Emacs flickering
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;; Save bookmarks in sync
(setq! sync-dir "~/sync/"
       bookmark-default-file (concat sync-dir ".local/" "bookmarks"))

;;
;;; Keybinds

(map! (:after evil-org
       :map evil-org-mode-map
       :n "gk" (cmd! (if (org-on-heading-p)
                         (org-backward-element)
                       (evil-previous-visual-line)))
       :n "gj" (cmd! (if (org-on-heading-p)
                         (org-forward-element)
                       (evil-next-visual-line)))
       :localleader
       (:prefix ("r" . "refile")
                "r" #'org-refile-reverse
                "R" #'org-refile)) ; to all `org-refile-targets'
      :leader
      (:prefix "f"
       :desc "Find file in dotfiles" :n "o" #'+emiller/find-in-dotfiles
       :desc "Browse dotfiles" :n "O" #'+emiller/browse-dotfiles)
      ;; (:prefix "n"
      ;;  "b" #'org-roam-buffer-toggle
      ;;  "d" #'org-roam-dailies-goto-today
      ;;  "D" #'org-roam-dailies-goto-date
      ;;  "i" #'org-roam-node-insert
      ;;  "r" #'org-roam-node-find
      ;;  "R" #'org-roam-capture)
      (:prefix "i"
       :desc "Insert date" :n "d" #'insert-todays-date)
      (:prefix "o"
       :desc "Calc" :n "c" #'calc
       :desc "ChatGPT" :n "g" #'chatgpt-shell
       :desc "APP: IRC" :n "i" #'=irc
       ;; :desc "APP: notmuch" :n "m" #'=mu4e
       ;; :desc "dired-sidebar" :n "n" #'dired-sidebar-toggle-sidebar
       :desc "todo.org" :n "o" #'+emiller/visit-todo-org
       :desc "projects" :n "p" #'+emiller/visit-projects-org
       :desc "emms" :n "s" #'emms
       :desc "APP: rss" :n "," #'=rss
       :desc "Whisper" :n "w" #'run-whisper))

;;
;;; Modules
;;;

;;; :completion company
;; This used to be off by default
(after! company
  (setq company-idle-delay nil))

;;; :completion ivy
(after! ivy
  ;; I prefer search matching to be ordered; it's more precise
  (add-to-list 'ivy-re-builders-alist '(counsel-projectile-find-file . ivy--regex-plus)))

;; Switch to the new window after splitting
(setq evil-split-window-below t
      evil-vsplit-window-right t)

;;; :editor evil
(after! evil
  (require 'evil-textobj-anyblock)
  (evil-define-text-object my-evil-textobj-anyblock-inner-quote
    (count &optional beg end type)
    "Select the closest outer quote."
    (let ((evil-textobj-anyblock-blocks
           '(("'" . "'")
             ("\"" . "\"")
             ("`" . "`")
             ("“" . "”"))))
      (evil-textobj-anyblock--make-textobj beg end type count nil)))

  (evil-define-text-object my-evil-textobj-anyblock-a-quote
    (count &optional beg end type)
    "Select the closest outer quote."
    (let ((evil-textobj-anyblock-blocks
           '(("'" . "'")
             ("\"" . "\"")
             ("`" . "`")
             ("“" . "”"))))
      (evil-textobj-anyblock--make-textobj beg end type count t)))

  (define-key evil-inner-text-objects-map "q" 'my-evil-textobj-anyblock-inner-quote)
  (define-key evil-outer-text-objects-map "q" 'my-evil-textobj-anyblock-a-quote))

;;; :editor file-templates
;;; TODO


;;; :emacs dired
;;Get rid of dired message when using "a"
(put 'dired-find-alternate-file 'disabled nil)

;;; :ui doom-dashboard
;; NARF
(setq fancy-splash-image (concat doom-private-dir "narf.png"))
;; Don't need the menu; I know them all by heart
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)

;;; :checks grammar
(after! langtool
  (setq langtool-bin "languagetool-commandline"))

;;; :tools biblio
(setq! citar-library-paths '("~/sync/papers/")
       citar-bibliography '("~/sync/reference/bibliography.bib"
                            "~/sync/reference/biochemistry.bib"
                            "~/sync/reference/genomics.bib"
                            "~/sync/reference/molecular_biology.bib"
                            "~/sync/reference/molecular_biology_project.bib"
                            ;; "~/sync/reference/nascent_pipeline.bib"
                            "~/sync/reference/viralintegration.bib"
                            "~/sync/reference/books.bib")
       citar-notes-paths '("~/sync/org/roam/lit"
                           "~/sync/org/roam/lit/book"
                           "~/sync/org/roam/lit/papers"
                           "~/sync/org/roam/lit/papers/biology"
                           "~/sync/org/roam/lit/biochemistry")
       citar-org-roam-subdir "lit/stack")


;;; :tools direnv
(setq direnv-always-show-summary nil)

;;; :tools lsp
;; Disable invasive lsp-mode features
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some systems I don't care to have a
        ;; whole development environment for some ecosystems.
        lsp-enable-server-download nil
        lsp-enable-suggest-server-download nil))
(after! lsp-ui
  (setq lsp-ui-sideline-enable nil  ; no more useful than flycheck
        lsp-ui-doc-enable nil))     ; redundant with K

;;; :tools magit
(setq magit-repository-directories '(("~/src" . 3))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-commit "--gpg-sign=BD387FF7BC10AA9D")
                         (magit-rebase "--autosquash" "--autostash" "--gpg-sign=BD387FF7BC10AA9D")
                         (magit-pull "--rebase" "--autostash" "--gpg-sign=BD387FF7BC10AA9D")))

;; Enable git gutter on tramp sessions
(defun +version-control|git-gutter-maybe ()
  (when buffer-file-name
    (require 'git-gutter-fringe)
    (git-gutter-mode +1)))

(setenv "EDITOR" "emacsclient")

;;; :lang clojure
(after! cider
  (set-popup-rules!
    '(("^\\*cider-error*" :ignore t)
      ("^\\*cider-repl" :quit nil)
      ("^\\*cider-repl-history" :vslot 2 :ttl nil))))

;;; :lang julia
(use-package! julia-formatter
  :hook (julia-mode-hook . julia-formatter-mode))

;;; :lang ledger
(add-to-list 'auto-mode-alist '("\\.\\(h?ledger\\|journal\\|j\\)$" . ledger-mode))

;;; :lang nix
(set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode))

;;; :lang org
(setq! +org-roam-auto-backlinks-buffer nil ;; This messes up org-noter
       org-directory "~/sync/org/"
       org-roam-directory (concat org-directory "roam/")
       org-roam-db-location (concat org-directory ".org-roam.db")
       org-roam-dailies-directory "journal/"
       org-archive-location (concat org-directory ".archive/%s::")
       +org-capture-todo-file (concat org-directory "life/todo.org")
       +org-capture-projects-file (concat org-directory "life/projects.org")
       ;; Agenda
       org-agenda-files (list (concat org-directory "life/"))
       org-agenda-skip-additional-timestamps-same-entry t)

(after! org
  (setq org-startup-folded 'show2levels
        org-ellipsis " [...] "
        org-export-with-toc nil
        org-log-done 'time
        ;; Fix org-id on SPC-l-s
        ;; org-id-link-to-org-use-id 'use-existing
        org-deadline-warning-days 5
        org-capture-templates
        (append
         ;; TODO generalize these with org-directory
         '(("a" "Appointment" entry (file  "~/sync/org/schedule.org")
            "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")
           ("e" "Lab Entry" entry
            (file+olp+datetree "~/sync/org/roam/lab/2023.org")
            "* %?\n%i")
           ("l" "Link" entry (file+headline "~/sync/org/links.org" "Links")
            "* %a %^g\n %?\n %i" :immediate-finish t))
         org-capture-templates)
        org-agenda-custom-commands
        (append
         '(("1" "Q1" tags-todo "+important+urgent")
           ("2" "Q2" tags-todo "+important-urgent")
           ("3" "Q3" tags-todo "-important+urgent")
           ("4" "Q4" tags-todo "-important-urgent")))))

(after! org-roam
  (setq org-roam-capture-templates
        `(("n" "note" plain
           ,(format "#+title: ${title}\n%%[%s/template/note.org]" org-roam-directory)
           :target (file "note/%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("t" "topic" plain
           ,(format "#+title: ${title}\n%%[%s/template/topic.org]" org-roam-directory)
           :target (file "topic/%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("p" "project" plain
           ,(format "#+title: ${title}\n%%[%s/template/project.org]" org-roam-directory)
           :target (file "project/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("r" "ref" plain
           ,(format "#+title: ${title}\n%%[%s/template/ref.org]" org-roam-directory)
           :target (file "ref/%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t))
        ;; Use human readable dates for dailies titles
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%B %d, %Y>\n\n")))))

(after! org-tree-slide
  ;; I use g{h,j,k} to traverse headings and TAB to toggle their visibility, and
  ;; leave C-left/C-right to .  I'll do a lot of movement because my
  ;; presentations tend not to be very linear.
  (setq org-tree-slide-skip-outline-level 2))

(defvar org-contacts-files '("~/sync/org/contacts.org"))

;; To make `org-latex-preview` work
(after! org
  (setq org-latex-default-packages-alist
        '(("AUTO" "inputenc" t
           ("pdflatex"))
          ("T1" "fontenc" t
           ("pdflatex"))
          ("" "graphicx" t)
          ("" "grffile" nil)
          ("" "longtable" nil)
          ("" "wrapfig" nil)
          ("" "rotating" nil)
          ("normalem" "ulem" t)
          ("" "amsmath" t)
          ("" "textcomp" t)
          ("" "amssymb" t)
          ("" "capt-of" nil)
          ("" "hyperref" nil))))

;; LaTeX Export
;; org-latex-compilers = ("pdflatex" "xelatex" "lualatex"), which are the possible values for %latex
(setq org-latex-pdf-process '("LC_ALL=en_US.UTF-8 latexmk -f -pdf -%latex -shell-escape -interaction=nonstopmode -output-directory=%o %f"))

;; I like to cross things off my todo list
(custom-set-faces! '(org-headline-done :strike-through t))

;; Start in insert mode in org-capture
(add-hook 'org-capture-mode-hook 'evil-insert-state)

;; +journal
(after! org
  (setq org-journal-dir (concat org-directory "journal/")
        org-journal-file-type 'monthly
        org-journal-encrypt-journal t
        org-journal-enable-cache t
        org-journal-file-format "%Y%m%d.org")
  (remove-hook 'calendar-today-visible-hook 'org-journal-mark-entries))

;; +noter
(after! org-noter
  (setq org-noter-always-create-frame t
        org-noter-doc-split-fraction '(0.75 . 0.25)
        org-noter-separate-notes-from-heading t
        org-noter-default-heading-title "Page $p$"
        org-noter-auto-save-last-location t
        org-noter-notes-search-path citar-notes-paths
        org-noter-separate-notes-from-heading t
        org-noter-doc-property-in-notes t))

;; #+beamer_theme: [progressbar=foot]metropolis

;; org-roam-ui
(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam ;; or :after org
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package! org-roam-timestamps
  :after org-roam
  :config
  (setq org-roam-timestamps-parent-file t))

;;; :lang python

;; org-transclusion
(use-package! org-transclusion
  :after org)


;;; :lang rust
(setq rustic-lsp-server 'rust-analyzer)

;;; :lang solidity
(setq flycheck-solidity-solium-soliumrcfile "/home/emiller/sync/.soliumrc.json"
      solidity-flycheck-solc-checker-active t)

;;; :lang web
;; Hook into vue-lsp
(add-hook 'web-mode-local-vars-hook #'lsp!)

;;; :email mu4e
;; Each path is relative to `+mu4e-mu4e-mail-path', which is ~/.mail by default
(after! mu4e
  (setq shr-use-colors nil)
  (set-email-account! "Gmail"
                      '((mu4e-sent-folder       . "/Gmail/[Gmail]/Sent Mail")
                        (mu4e-drafts-folder     . "/Gmail/[Gmail]/Drafts")
                        (mu4e-trash-folder      . "/Gmail/[Gmail]/Trash")
                        (mu4e-refile-folder     . "/Gmail/[Gmail]/Archive")
                        (smtpmail-smtp-user     . "edmund.a.miller@gmail.com")
                        (mu4e-compose-signature . "---\nEdmund Miller"))
                      t)

  (set-email-account! "Eman"
                      '((mu4e-sent-folder       . "/Eman/[Gmail]/Sent Mail")
                        (mu4e-drafts-folder     . "/Eman/[Gmail]/Drafts")
                        (mu4e-trash-folder      . "/Eman/[Gmail]/Trash")
                        (mu4e-refile-folder     . "/Eman/[Gmail]/Archive")
                        (mu4e-compose-signature . "---\nEdmund Miller"))
                      t)

  (set-email-account! "UTD"
                      '((mu4e-sent-folder       . "/UTD/Sent")
                        (mu4e-drafts-folder     . "/UTD/Drafts")
                        (mu4e-trash-folder      . "/UTD/Trash")
                        (mu4e-refile-folder     . "/UTD/Archive")
                        (smtpmail-smtp-user     . "Edmund.Miller@utdallas.edu")
                        (mu4e-compose-signature . "---\nEdmund Miller"))
                      t))

(use-package! mu4e-patch
  :hook (mu4e-view-mode . mu4e-patch-highlight))

;;; :app everywhere
(after! emacs-everywhere
  ;; Easier to match with a bspwm rule:
  ;;   bspc rule -a 'Emacs:emacs-everywhere' state=floating sticky=on
  (setq emacs-everywhere-frame-name-format "emacs-anywhere")

  ;; The modeline is not useful to me in the popup window. It looks much nicer
  ;; to hide it.
  (remove-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)

  ;; Semi-center it over the target window, rather than at the cursor position
  ;; (which could be anywhere).
  (defadvice! center-emacs-everywhere-in-origin-window (frame window-info)
    :override #'emacs-everywhere-set-frame-position
    (cl-destructuring-bind (x y width height)
        (emacs-everywhere-window-geometry window-info)
      (set-frame-position frame
                          (+ x (/ width 2) (- (/ width 2)))
                          (+ y (/ height 2))))))


;;; :app irc
(after! circe
  (set-irc-server! "chat.freenode.net"
    `(:tls t
      :port 6697
      :nick "emiller88"
      :sasl-username ,(+pass-get-user "irc/freenode.net")
      :sasl-password (lambda (&rest _) (+pass-get-secret "irc/freenode.net"))
      :channels ("#bioinformatics" "#clojure" "#emacs" "#emacs-circe" "#guix" "#guile" "#home-manager" "#nixos" "#nixos-emacs" "#sway" "##rust" "#python" "#pine64"))))
;;; :app rss
(after! elfeed-search
  (map! :map elfeed-search-mode-map
        :localleader
        :n "m" #'my/elfeed-search-view-hydra/body
        :n "s" #'elfeed-toggle-star
        :n "v" #'elfeed-view-mpv
        :n "r" #'elfeed-update))
;; Set max width
(after! elfeed
  (setq elfeed-search-title-max-width 120
        elfeed-goodies/feed-source-column-width 25
        elfeed-search-filter "@1-week-ago--1-day-ago -youtube"))
(use-package! elfeed-tube
  :after elfeed
  :init
  (map! :map elfeed-show-mode-map
        :localleader
        :n "F" #'elfeed-tube-fetch
        :map elfeed-search-mode-map
        :localleader
        :n "F" #'elfeed-tube-fetch)
  :config
  ;; (setq elfeed-tube-auto-save-p nil) ; default value
  ;; (setq elfeed-tube-auto-fetch-p t)  ; default value
  (elfeed-tube-setup))

(use-package! elfeed-tube-mpv
  :init
  (map! :map elfeed-search-mode-map
        :localleader
        :n "f" #'elfeed-tube-mpv-follow-mode
        :n "w" #'elfeed-tube-where))


;;
;;; Language customizations

(custom-theme-set-faces! 'doom-dracula
  `(markdown-code-face :background ,(doom-darken 'bg 0.075))
  `(font-lock-variable-name-face :foreground ,(doom-lighten 'magenta 0.6)))

;; spell
(setq ispell-personal-dictionary
      (expand-file-name "misc/ispell_personal" doom-private-dir))


;;
;;; Packages

(use-package! graphviz-dot-mode)
(use-package! jest)
(use-package! nextflow-mode
  :config
  (set-docsets! 'nextflow-mode "Groovy"))
(use-package! ox-chameleon
  :after ox)
(use-package! snakemake-mode)
(use-package! org-chef)
(use-package! engrave-faces
  :after ox-latex
  :config
  (setq org-latex-listings 'engraved))
(use-package! academic-phrases)
(use-package! code-review)
(use-package! gh-notify)
(use-package! flycheck-vale
  :init
  (flycheck-vale-setup))
(use-package! quarto-mode)
(use-package! webpaste
  :config
  (progn
    (setq webpaste-provider-priority '("ix.io" "dpaste.org"))))

(use-package! mastodon
  :init
  (setq mastodon-instance-url "https://genomic.social"
        mastodon-active-user "emiller")
  :config
  (mastodon-discover))

(use-package! whisper
  :config
  (setq whisper-install-directory "/tmp/"
        whisper-model "base"
        whisper-language "en"
        whisper-translate nil
        whisper--ffmpeg-input-format "pulse"
        whisper--ffmpeg-input-device "default"))

(use-package! pocket-reader)
  ;; :config
  ;; (add-to-list 'evil-emacs-state-modes 'pocket-reader-mode))

(use-package! conf-data-toml
  :magic ("\\`data_config_version = [0-9]" . conf-data-toml-mode))

(use-package! chatgpt-shell
  :init
  (setq! chatgpt-shell-openai-key
         (lambda ()
           (auth-source-pick-first-password :host "api.openai.com"))
         chatgpt-shell-chatgpt-streaming t)
  (setq! chatgpt-shell-default-prompts
         (append
          '("Rank these links in the order that I should read them:"
            chatgpt-shell-default-prompts))))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ;; accept completion from copilot and fallback to company
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (setq copilot-idle-delay 2))

;;
;;; Custom Variables
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((ssh-deploy-async-with-threads . 1)
     (ssh-deploy-on-explicity-save . t)
     (ssh-deploy-async . 1))))

(setq enable-local-variables :all)
