;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1 行ずつスムーズにスクロールする  

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq scroll-step 1)

;; メニューバーを非表示にする  
(menu-bar-mode -1)  
  
;; ツールバーを非表示にする  
(tool-bar-mode -1) 

;; ポップアップフレームを禁止
(setq ns-pop-up-frames nil)

;; スタートアップメーッセージを表示させない
(setq inhibit-startup-message t)


;; Color and Window size
(if window-system (progn
  (setq initial-frame-alist '((width . 120) (height . 60)))
  (set-background-color "RoyalBlue4")
  ;;(set-foreground-color "LightGray")
  (set-foreground-color "WhiteSmoke")
  (set-cursor-color "Gray")
))

;; フレーム透過
(set-frame-parameter (selected-frame) 'alpha '(97 97))

;; アクティブリージョンの強調表示
(transient-mark-mode t)

;; Line Number
(global-set-key "\M-n" 'linum-mode)

;; 改行コードを表示する
;(setq eol-mnemonic-dos "(CRLF)")
;(setq eol-mnemonic-mac "(CR)")
;(setq eol-mnemonic-unix "(LF)")

;; カーソル行をハイライトする
;(global-hl-line-mode t)

;; 対応する括弧を光らせる
(show-paren-mode 1)

;; ウィンドウ内に収まらないときだけ、カッコ内も光らせる
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
;; (set-face-background 'show-paren-match-face "grey")
;; (set-face-foreground 'show-paren-match-face "black")

;; スペース、タブなどを可視化する
;(global-whitespace-mode 1)

;; BEEP音ならさない
(setq visible-bell t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input and language settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 自動改行無効
(setq text-mode-hook 'turn-off-auto-fill)

; 全自動インデントを無効
(setq c-auto-newline nil)


;; Command-Key and Option-Key for Emacs23
(when (equal system-type 'darwin)
  (setq ns-command-modifier (quote meta))
  (setq ns-alternate-modifier (quote super)))
(when (equal system-type 'gnu/linux)
  (setq x-super-keysym 'meta)
  (setq x-meta-keysym  'super))

;; 言語環境
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;;ターミナルの文字コード
(set-terminal-coding-system 'utf-8)
;;キーボードから入力される文字コード
(set-keyboard-coding-system 'utf-8)
;;ファイルのバッファのデフォルト文字コード
(set-buffer-file-coding-system 'utf-8)
;;バッファのプロセスの文字コード
(setq default-buffer-file-coding-system 'utf-8)
;;新規作成ファイルの文字コード
(set-default-coding-systems 'utf-8)


;; ubuntuの場合、mozcを使って入力
(when (equal system-type 'darwin)
  (set-language-environment "japanese")
  (setq default-input-method "MacOSX"))
(when (equal system-type 'gnu/linux)
  (require 'mozc)
  (set-language-environment "japanese")
  (setq default-input-method "japanese-mozc")
  (global-set-key "\C-\\" 'toggle-input-method))


;; ミニバッファでの日本語を制御
;(mac-auto-ascii-mode t)

;; 句読点 
(setq its-hira-period "．")
(setq its-hira-comma "，")

;; End/Home
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)


;; M-x term用
(setq file-name-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Copy from Emacs when terminal
(if (eq window-system nil)
    (progn
      (defun copy-from-osx ()
	(shell-command-to-string "pbpaste"))

      (defun paste-to-osx (text &optional push)
	(let ((process-connection-type nil))
	  (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
	    (process-send-string proc text)
	    (process-send-eof proc))))

      (setq interprogram-cut-function 'paste-to-osx)
      (setq interprogram-paste-function 'copy-from-osx)
      )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; より下に記述した物が PATH の先頭に追加されます
(dolist (dir (list
	      "/Library/Tex/texbin"
              "/sbin"
              "/usr/sbin"
              "/bin"
              "/usr/bin"
              "/usr/local/bin"
              (expand-file-name "~/bin")
              (expand-file-name "~/.emacs.d/bin")
              "/usr/local/texlive/2019/bin/x86_64-linux"
              ))
;; PATH と exec-path に同じ物を追加します
(when (and (file-exists-p dir) (not (member dir exec-path)))
   (setenv "PATH" (concat dir ":" (getenv "PATH")))
   (setq exec-path (append (list dir) exec-path))))
(setenv "MANPATH" (concat "/usr/local/man:/usr/share/man:/Developer/usr/share/man" (getenv "MANPATH")))

;; dired-x to remove unnecessary tex files
(load "dired-x")

;; バックアップファイルを作らない
(setq make-backup-files nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Font
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Font
;(when (equal system-type 'darwin)
;(when window-system
;  (create-fontset-from-ascii-font "Menlo-12:weight=normal:slant=normal" nil "menlokakugo")
;  (set-fontset-font "fontset-menlokakugo"
;		    'unicode
;		    (font-spec :family "Hiragino Kaku Gothic ProN" :size 14)
;		    nil
;		    'append)
;  (add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))
;)
;)
(when (equal system-type 'gnu/linux)
  (set-fontset-font t 'japanese-jisx0208 "TakaoPGothic")
  (add-to-list 'face-font-rescale-alist '(".*TakaoP.*" . 0.95))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coding
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gdb
(setq gdb-many-windows t)
(setq gdb-use-separate-io-buffer t) ; "IO buffer" が必要ない場合は  nil で

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
;; ispell/aspell
(setq-default ispell-program-name "aspell")

(mapc                                   ;; 以下flyspell-modeの設定
 (lambda (hook)
   (add-hook hook 'flyspell-prog-mode))
 '(
   c-mode-common-hook                 ;; ここに書いたモードではコメント領域のところだけ
   emacs-lisp-mode-hook                 ;; flyspell-mode が有効になる
   ))
(mapc
   (lambda (hook)
     (add-hook hook
                      '(lambda () (flyspell-mode 1))))
   '(
     yatex-mode-hook     ;; ここに書いたモードでは
                                    ;; flyspell-mode が有効になる
     ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LaTeX settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yatexのemacs26対応
(defun string-to-int (string &optional base)
(string-to-number string base))

;; yatex
(add-to-list 'load-path "~/.emacs.d/site-lisp/yatex")
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
      (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-inhibit-prefix-letter nil)
(setq YaTeX-kanji-code nil)
(setq YaTeX-latex-message-code 'utf-8)
(setq YaTeX-use-AMS-LaTeX t)
(setq YaTeX-dvi2-command-ext-alist
      '(("Preview\\|TeXShop\\|TeXworks\\|Skim\\|mupdf\\|xpdf\\|Firefox\\|Adobe" . ".pdf"))) 
(when (equal system-type 'darwin)     ;; for Mac only
  (setq dvi2-command "/usr/bin/open -a Skim"); Skimで開く
  (setq tex-pdfview-command "/usr/bin/open -a Skim"))
(setq tex-command "platex")
(setq dviprint-command-format "dvipdfmx")
(setq YaTeX-dvipdf-command "dvipdfmx")


;; 自動インデントを殺す
(electric-indent-mode 0)

;; YaTeXでコメントアウト、解除を割り当てる
(add-hook 'yatex-mode-hook
        '(lambda ()
                (local-set-key "\C-c\C-c" 'comment-region)
                (local-set-key "\C-c\C-u" 'uncomment-region) ))



;; reftex
(add-hook 'yatex-mode-hook '(lambda () (reftex-mode t)))
;; So that RefTeX also recognizes \addbibresource. Note that you
;; can't use $HOME in path for \addbibresource but that "~"
;; works.
(setq reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource"))


;;
;; Skim との連携
;;
;; http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?Emacs#de8b4fcd
;; inverse search
(require 'server)
(unless (server-running-p) (server-start))
;; forward search
;; http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?YaTeX#f978a43b
(defun skim-forward-search ()
  (interactive)
  (progn
    (process-kill-without-query
     (start-process  
      "displayline"
      nil
      "/Applications/Skim.app/Contents/SharedSupport/displayline"
      (number-to-string (save-restriction
                          (widen)
                          (count-lines (point-min) (point))))
      (expand-file-name
       (concat (file-name-sans-extension (or YaTeX-parent-file
                                             (save-excursion
                                               (YaTeX-visit-main t)
                                               buffer-file-name)))
               ".pdf"))
      buffer-file-name))))

(add-hook 'yatex-mode-hook
          '(lambda ()
             (define-key YaTeX-mode-map (kbd "C-c s") 'skim-forward-search)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Twitter settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
;; twittering-mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/twittering-mode")
(require 'twittering-mode)
(setq twittering-use-master-password t)
(setq twittering-status-format "%i %s \t: %T %r%R [%C{%Y-%m-%d %H:%M:%S}]")
;;(setq twittering-status-format "%i %s\n%T\n\t%C{%Y-%m-%d %H:%M:%S} [%f] %r%R\n")
;; %s - screen_name
;; %S - name
;; %i - profile_image
;; %d - description
;; %l - location
;; %L - " [location]"
;; %u - url
;; %j - user.id
;; %p - protected?
;; %c - created_at (raw UTC string)
;; %C{time-format-str} - created_at (formatted with time-format-str)
;; %@ - X seconds ago
;; %t - text
;; %' - truncated
;; %f - source
;; %# - id
