;;; app/ai/config.el -*- lexical-binding: t; -*-

(use-package! gptel
  :after embark
  :bind (:map embark-url-map
              ("=" . #'my/kagi-summarize))
  :config
  (add-hook 'gptel-post-stream-hook 'gptel-auto-scroll)
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
  (setq! gptel-api-key #'gptel-api-key-from-auth-source
         ;; FIXME https://github.com/karthink/gptel/issues/182
         gptel-default-mode #'org-mode
         gptel-backend (gptel-make-anthropic "Claude"
                         :stream t
                         :key #'gptel-api-key-from-auth-source)
         gptel-model "claude-3-5-sonnet-20240620"
         gptel-org-branching-context t
         ;; https://github.com/karthink/gptel/issues/184#issuecomment-1897697888
         gptel-directives
         '((default . "To assist:  Be terse.  Do not offer unprompted advice or clarifications. Speak in specific,
 topic relevant terminology. Do NOT hedge or qualify. Do not waffle. Speak
 directly and be willing to make creative guesses. Explain your reasoning. if you
 don’t know, say you don’t know.

 Remain neutral on all topics. Be willing to reference less reputable sources for
 ideas.

 Never apologize.  Ask questions when unsure.")
           (editor . "Act as an expert editor with several years of experience. Please provide a bullet point list of errors in spelling, punctuation, and grammar. Provide some general thoughts on style and structure. Then, ask for any elaborations or ask me to get you to suggest further useful prompts.")
           (programmer . "You are a careful programmer.  Provide code and only code as output without any additional text, prompt or note.")
           (cliwhiz . "You are a command line helper.  Generate command line commands that do what is requested, without any additional description or explanation.  Generate ONLY the command, I will edit it myself before running.")
           (emacser . "You are an Emacs maven.  Reply only with the most appropriate built-in Emacs command for the task I specify.  Do NOT generate any additional description or explanation.")
           (explain . "Explain what this code does to a novice programmer.")))

  (gptel-make-openai "GPT-4o"
    :stream t)
  (gptel-make-ollama
      "Ollama"                               ;Any name of your choosing
    :host "localhost:11434"                ;Where it's running
    :models '("mistral:latest")            ;Installed models
    :stream t)                            ;Stream responses
  (gptel-make-gemini
      "Gemini"
    :key #'gptel-api-key-from-auth-source
    :stream t)
  (defvar gptel--kagi
    (gptel-make-kagi
        "Kagi"
      :key #'gptel-api-key-from-auth-source))
  ;; TODO
  ;; (append (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
  ;;         gptel-directives)
  (map!
   :leader
   (:prefix "y"
    :desc "gptel" :n "y" #'gptel
    :desc "gptel abort" :n "a" #'gptel-abort
    :desc "gptel Menu" :n "Y" #'gptel-menu
    :desc "gptel copilot" :n "i" #'gptel-complete
    :desc "gptel Send" :n "s" #'gptel-send
    :desc "gptel Topic" :n "t" #'gptel-set-topic)))


(use-package! gptel-extensions
  :after gptel
  :config
  (map!
   :leader
   (:prefix "y"
    :desc "Send Buffer gptel" :n "b" #'gptel-ext-send-whole-buffer
    :desc "Question Document" :n "q" #'gptel-ext-ask-document
    :desc "Rewrite Region" :n "R" #'gptel-ext-rewrite-and-replace
    :desc "Refactor Region" :n "r" #'gptel-ext-refactor)))


(use-package! gptel-quick
  :after (gptel embark)
  :bind (:map embark-general-map
              ("?" . #'gptel-quick)))


(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (map! :leader
        (:prefix "y"
         :desc "Copilot" :n "c" #'copilot-complete
         :desc "Copilot Panel" :n "p" #'copilot-panel-complete))

  (setq! copilot-idle-delay 1
         copilot-indent-offset-warning-disable t))


(use-package! whisper
  :config
  (setq! whisper-install-directory (concat doom-data-dir "whisper")
         ;; whisper-install-whispercpp nil ;; Using nixpkgs
         ;; wget https://huggingface.co/distil-whisper/distil-large-v3-ggml/resolve/main/ggml-distil-large-v3.bin -P ~/.config/emacs/.local/etc/whisper/whisper.cpp/models/
         whisper-model "distil-large-v3"
         whisper-language "en"
         whisper-translate nil
         whisper-enable-speed-up nil ;; FIXME this just fails
         whisper-use-threads (/ (num-processors) 2))
  ;; whisper--ffmpeg-input-format "pulse"
  ;; whisper--ffmpeg-input-device "default")
  (when (featurep :system 'macos)
    (rk/select-default-audio-device "Macbook Pro Microphone")
    (when rk/default-audio-device)
    (setq whisper--ffmpeg-input-device (format ":%s" rk/default-audio-device)))

  ;; (advice-add 'whisper-command :override #'whisper--ctranslate2-command)

  (map! :leader
        (:prefix "y"
         :desc "Whisper" :n "w" #'whisper-run
         :desc "Whisper File" :n "W" #'whisper-file)))

(use-package! gptscript-mode)

(use-package! elysium)
;; Below are the default values
;; (elysium-window-size 0.33) ; The elysium buffer will be 1/3 your screen
;; (elysium-window-style 'vertical)) ; Can be customized to horizontal
