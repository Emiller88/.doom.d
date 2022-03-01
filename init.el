;;; private/emiller/init.el -*- lexical-binding: t; -*-

(doom! :input
       ;;chinese
       ;;japanese

       :completion
       (company +childframe)
       ;;helm
       ;;ido
       ;;(ivy +prescient)
       vertico

       :ui
       ;;deft
       doom
       doom-dashboard
       ;;doom-quit
       ;;fill-column
       hl-todo
       ;;hydra
       ;;indent-guides
       ;;ligatures
       ;;minimap
       (modeline +light)
       ;;nav-flash
       ;;neotree
       ophints
       (popup +defaults)
       ;;tabs
       ;;treemacs
       tree-sitter
       ;;unicode
       vc-gutter
       ;;vi-tilde-fringe
       window-select
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       format
       ;;god
       ;;lispy
       multiple-cursors
       ;;objed
       parinfer
       rotate-text
       snippets
       ;;word-wrap

       :emacs
       dired
       electric
       ;;ibuffer
       undo
       vc

       :term
       eshell
       ;;shell
       ;;term
       vterm

       :checkers
       syntax
       spell
       grammar

       :tools
       ansible
       biblio
       ;;debugger
       direnv
       docker
       editorconfig
       ;;ein
       eval
       gist
       (lookup +docsets +dictionary)
       lsp
       ;;macos
       (magit +forge)
       make
       ;;pass
       pdf
       ;;prodigy
       rgb
       taskrunner
       ;;terraform
       ;;tmux
       upload

       :lang
       ;;agda
       ;;assembly
       (beancount +lsp)
       ;;cc
       ;;clojure
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       data
       ;;(dart +flutter)
       ;;elixir
       ;;elm
       emacs-lisp
       ;;erlang
       (ess +lsp)
       ;;faust
       ;;fsharp
       ;;fstar
       ;;go
       ;;(haskell +dante)
       ;;hy
       ;;idris
       (java +lsp)
       (javascript +lsp)
       (json +lsp)
       (julia +lsp)
       ;;kotlin
       (latex +cdlatex +ref)
       ;;lean
       ;;factor
       ;;ledger
       (lua +fennel)
       markdown
       ;;nim
       nix
       ;;ocaml
       (org
        +dragndrop
        +journal
        +jupyter
        +gnuplot
        +noter
        +pandoc
        +pomodoro
        +present
        +ref
        +roam2)
       ;;perl
       ;;php
       ;;plantuml
       ;;purescript
       (python
        +lsp
        +pyright)
       ;;qt
       racket
       rest
       ;;rst
       ;;(ruby +rails)
       (rust +lsp)
       ;;scala
       ;;(scheme +guile)
       sh
       ;;sml
       snakemake
       solidity
       ;;swift
       ;;terra
       web
       yaml

       :email
       (mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;emms
       calendar
       everywhere
       irc
       (rss +org)
       ;;twitter
       ereader

       :config
       ;;literate
       (default +bindings +smartparens))
