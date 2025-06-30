{
  config,
  lib,
  pkgs,
  ...
}: let
  # Use builtins.path to create a more reliable path reference
  # Adjust this path to point to the actual location of fasm-mode.el
  fasm-mode-path = builtins.path {
    name = "fasm-mode";
    path = ../modules/emacs-files/fasm-mode.el; # Adjust based on your directory structure
  };
in {
  # Rest of your config...
  programs.emacs = {
    enable = true;
    # package = pkgs.emacs29;

    extraConfig = ''
             ;; Load required packages early to avoid free variable warnings
             (require 'evil)
             (require 'display-line-numbers)
             (require 'dired)

             ;; Basic UI settings
             (setq ring-bell-function 'ignore
                   evil-insert-state-cursor 'box
                   initial-buffer-choice t
                   display-line-numbers-type 'relative)

             (setq dired-dwim-target t)
             (winner-mode 1)
             (menu-bar-mode 0)
             (tool-bar-mode 0)
             (scroll-bar-mode 0)
             (column-number-mode 1)
             (fringe-mode 0)
             (global-display-line-numbers-mode)
             (set-face-attribute 'default nil :height 170)

             ;; IDO mode
             (ido-mode 1)
             (ido-everywhere 1)

             ;; Backup settings
             (setq-default make-backup-files nil
                           auto-save-default nil
                           compile-command "")

             ;; Compilation functions
             (defun my-compile-without-history ()
               "Run compile command with an empty initial prompt but preserve history."
               (interactive)
               (let ((current-prefix-arg '(4))
                     (compilation-read-command t))
                 (setq-default compile-command "")
                 (setq compile-command "")
                 (call-interactively 'compile)
                 (with-current-buffer "*compilation*"
                   (evil-normal-state))))

             (defun my-recompile ()
               "Recompile and ensure normal mode in compilation buffer."
               (interactive)
               (recompile)
               (with-current-buffer "*compilation*"
                 (evil-normal-state)))

             (advice-add 'recompile :after
                         (lambda (&rest _)
                           (with-current-buffer "*compilation*"
                             (evil-normal-state))))

             (advice-add 'compile :around
                         (lambda (orig-fun &rest args)
                           (let ((compile-command ""))
                             (apply orig-fun args))))

             (global-set-key [remap compile] 'my-compile-without-history)

             ;; Compilation window settings
            (setq display-buffer-alist
                `((,(rx bos "*compilation*" eos)
                    (display-buffer-reuse-window display-buffer-at-bottom)
                    (window-height . 0.4)
                    (preserve-size . (nil . t))
                    (select . t))))


             (setq compilation-finish-functions
                   (list (lambda (_buf _str)
                           (let ((win (get-buffer-window "*compilation*")))
                             (when win
                               (select-window win)
                               (evil-normal-state))))))

             ;; Buffer cleanup functions
             (defun my/cleanup-deleted-file-buffers ()
               "Close buffers of files that no longer exist."
               (dolist (buf (buffer-list))
                 (let ((filename (buffer-file-name buf)))
                   (when (and filename
                              (not (file-exists-p filename)))
                     (kill-buffer buf)))))

             ;; Dired create-file helper
             (defun my/dired-create-file (filename)
               "Create a new file in the current dired directory."
               (interactive
                (list (read-string "Create file: " (dired-current-directory))))
               (let* ((filepath (expand-file-name filename (dired-current-directory)))
                      (dir (file-name-directory filepath)))
                 (when (and (not (file-exists-p dir))
                            (yes-or-no-p (format "Directory %s does not exist. Create it? " dir)))
                   (make-directory dir t))
                 (when (file-exists-p dir)
                   (write-region "" nil filepath)
                   (dired-add-file filepath)
                   (revert-buffer)
                   (dired-goto-file (expand-file-name filepath)))))

             (with-eval-after-load 'dired
               (evil-set-initial-state 'dired-mode 'emacs)  ; This will use Emacs default keybindings
               (define-key dired-mode-map (kbd "%") 'my/dired-create-file)
               (define-key dired-mode-map ":"
                 (lambda ()
                   (interactive)
                   (evil-ex)))
               (define-key dired-mode-map "/" 'evil-search-forward))

             ;; Make sure use-package is available at compile time
             (eval-when-compile
               (require 'use-package))

      ;; Update this part in your emacs.nix extraConfig section

      ;; Update this part in your emacs.nix extraConfig section

      (use-package vterm
        :ensure t
        :config
        ;; Prevent blesh and zellij from auto-starting in vterm
        (setq vterm-environment '("BLESH_AUTO_DISABLE=1"
                                 "ZELLIJ=skip"
                                 "INSIDE_EMACS=vterm"))

        ;; Custom vterm function
        (defun my/vterm ()
          "Open vterm with specific environment variables set."
          (interactive)
          (let ((vterm-shell (getenv "SHELL")))
            (vterm))))

      (global-set-key (kbd "C-c t") 'my/vterm)

             ;; Evil
             (use-package evil
               :ensure t
               :init
               ;; Must be set *before* Evil loads
               (setq evil-want-integration t
                     evil-want-keybinding nil
                     evil-want-C-u-scroll t
                     evil-want-C-i-jump t
                     evil-undo-system 'undo-tree)
               :config
               ;; Actually enable Evil
               (evil-mode 1)

               ;; Make delete operations use the black hole register
               (evil-define-operator evil-delete-blackhole (beg end type register yank-handler)
                 "Delete text from BEG to END using black hole register."
                 (interactive "<R><x><y>")
                 (evil-delete beg end type ?_ yank-handler))

               ;; Remap d to use black hole register
               (define-key evil-normal-state-map "d" 'evil-delete-blackhole)
               (define-key evil-visual-state-map "d" 'evil-delete-blackhole)

               ;; Evil ex commands
               (evil-ex-define-cmd "Man" 'man)
               (evil-set-initial-state 'Man-mode 'normal)
               (evil-ex-define-cmd "compile" 'my-compile-without-history)
               (evil-ex-define-cmd "recompile" 'my-recompile)

               ;; Evil key bindings
               (evil-define-key '(normal insert) 'global (kbd "C-v") 'evil-paste-after)
               (evil-define-key '(normal insert) 'global (kbd "C-S-v") 'evil-paste-after)
               (evil-define-key 'normal dired-mode-map (kbd "RET") 'dired-find-file))

             ;; Undo-tree
             (use-package undo-tree
               :ensure t
               :config
               (global-undo-tree-mode))

             ;; Direnv
             (use-package direnv
               :ensure t
               :config
               (direnv-mode))

             ;; Gruber-darker theme
             (use-package gruber-darker-theme
               :ensure t
               :config
               (load-theme 'gruber-darker t))

             ;; Zig mode
             (use-package zig-mode
               :ensure t
               :mode ("\\.zig\\'" . zig-mode))

             ;; Nix mode
             (use-package nix-mode
               :ensure t
               :mode ("\\.nix\\'" . nix-mode))

             ;; C# mode
             (use-package csharp-mode
               :ensure t
               :mode ("\\.cs\\'" . csharp-mode))

             ;; FASM Mode configuration
             ;; Add the directory containing fasm-mode.el to load-path
             ;; This is crucial: we need to ensure Emacs can find the file
             (add-to-list 'load-path "~/.emacs.d/lisp/")

             ;; Load fasm-mode only if the file exists
             (if (file-exists-p "~/.emacs.d/lisp/fasm-mode.el")
                 (progn
                   (require 'fasm-mode)
                   ;; Associate .asm files with fasm-mode
                   (add-to-list 'auto-mode-alist '("\\.fasm\\'" . fasm-mode))
                   ;; Setup whitespace handling for fasm-mode
                   (add-hook 'fasm-mode-hook
                           (lambda ()
                             ;; Enable whitespace mode
                             (whitespace-mode 1)
                             ;; Delete trailing whitespace on save
                             (add-to-list 'write-file-functions 'delete-trailing-whitespace))))
               (message "Warning: fasm-mode.el not found"))

             ;; NASM Mode configuration
             (use-package nasm-mode
               :ensure t
               :mode ("\\.nasm\\'" . nasm-mode)
               :config
               (add-hook 'nasm-mode-hook
                         (lambda ()
                           ;; Enable whitespace mode
                           (whitespace-mode 1)
                           ;; Delete trailing whitespace on save
                           (add-to-list 'write-file-functions 'delete-trailing-whitespace))))

             ;; Function to switch between ASM modes based on content
             (defun my/detect-asm-mode ()
               "Detect whether to use FASM or NASM mode based on file content."
               (interactive)
               (when (string-match "\\.asm\\'" (buffer-file-name))
                 ;; Check for NASM-specific format indicators in the first few lines
                 (save-excursion
                   (goto-char (point-min))
                   (if (re-search-forward "\\(section\\|segment\\|global\\|extern\\)\\s-+[._a-zA-Z0-9]+" nil t)
                       (nasm-mode)
                     (fasm-mode)))))

             ;; Associate .asm files with the detector function
             (add-to-list 'auto-mode-alist '("\\.asm\\'" . my/detect-asm-mode))

             ;; Commands to explicitly switch between modes
             (defun my/switch-to-fasm-mode ()
               "Switch current buffer to FASM mode."
               (interactive)
               (fasm-mode)
               (message "Switched to FASM mode"))

             (defun my/switch-to-nasm-mode ()
               "Switch current buffer to NASM mode."
               (interactive)
               (nasm-mode)
               (message "Switched to NASM mode"))

             ;; Add key bindings for switching between modes (optional)
             (global-set-key (kbd "C-c f") 'my/switch-to-fasm-mode)
             (global-set-key (kbd "C-c n") 'my/switch-to-nasm-mode)

             ;; ===== ORG-MODE CONFIGURATION =====
             ;; Comprehensive org-mode setup extracted from jake-emacs
             
             ;; Org-mode directory setup (adapt these paths to your preferences)
             (setq org-directory "~/org")
             (unless (file-exists-p org-directory)
               (make-directory org-directory t))
             
             ;; Org-mode custom functions
             (defun my/org-setup ()
               "Custom org-mode setup function."
               (org-indent-mode) ;; Keeps org items like text under headings, lists, nicely indented
               (visual-line-mode 1) ;; Nice line wrapping
               (setq-local line-spacing 2)) ;; A bit more line spacing for orgmode
             
             (defun my/org-schedule-tomorrow ()
               "Org Schedule for tomorrow (+1d)."
               (interactive)
               (org-schedule t "+1d"))
             
             (defun my/org-refile-this-file ()
               "Org refile to only headers in current file, 5 levels."
               (interactive)
               (let ((org-refile-targets '((nil . (:maxlevel . 5)))))
                 (org-refile)))
             
             (defun my/org-done-keep-todo ()
               "Mark an org todo item as done while keeping its former keyword intact."
               (interactive)
               (let ((state (org-get-todo-state)) (tag (org-get-tags)) (todo (org-entry-get (point) "TODO"))
                     post-command-hook)
                 (if (not (eq state nil))
                     (progn (org-back-to-heading)
                            (org-todo "DONE")
                            (org-set-tags tag)
                            (beginning-of-line)
                            (forward-word)
                            (insert (concat " " todo)))
                   (user-error "Not a TODO."))
                 (run-hooks 'post-command-hook)))
                 
             (defun my/org-occur-unchecked-boxes (&optional arg)
               "Show unchecked Org Mode checkboxes."
               (interactive "P")
               (occur "\\[ \\]"))

             ;; Main org-mode configuration
             (use-package org
               :ensure t
               :hook (org-mode . my/org-setup)
               :hook (org-capture-mode . evil-insert-state) ;; Start org-capture in Insert state by default
               :diminish org-indent-mode
               :diminish visual-line-mode
               :config
               
               ;; Basic org settings
               (setq org-ellipsis "…")
               (setq org-src-fontify-natively t) ;; Syntax highlighting in org src blocks
               (setq org-highlight-latex-and-related '(native)) ;; Highlight inline LaTeX
               (setq org-startup-folded 'showeverything)
               (setq org-image-actual-width 300)
               (setq org-fontify-whole-heading-line t)
               (setq org-pretty-entities t)
               (setq org-cycle-separator-lines 1)
               (setq org-catch-invisible-edits 'show-and-error)
               (setq org-src-tab-acts-natively t)
               
               ;; M-Ret behavior
               (setq org-M-RET-may-split-line '((headline) (item . t) (table . t) (default)))
               (setq org-loop-over-headlines-in-active-region nil)
               
               ;; Link settings
               (setq org-link-frame-setup '((file . find-file)))
               
               ;; Logging
               (setq org-log-done t
                     org-log-into-drawer t)
               
               ;; Bullet behavior
               (setq org-list-demote-modify-bullet
                     '(("+" . "*") ("*" . "-") ("-" . "+")))
               
               ;; Tags
               (setq org-tags-column -1)
               
               ;; TODO keywords
               (setq org-todo-keywords '((type
                                          "TODO(t)" "WAITING(h)" "INPROG-TODO(i)" "WORK(w)"
                                          "STUDY(s)" "SOMEDAY" "READ(r)" "PROJ(p)" "CONTACT(c)"
                                          "|" "DONE(d)" "CANCELLED(C@)")))
               
               (setq org-todo-keyword-faces
                     '(("TODO"  :inherit (region org-todo) :foreground "DarkOrange1"   :weight bold)
                       ("WORK"  :inherit (org-todo region) :foreground "DarkOrange1"   :weight bold)
                       ("READ"  :inherit (org-todo region) :foreground "MediumPurple2" :weight bold)
                       ("PROJ"  :inherit (org-todo region) :foreground "orange3"     :weight bold)
                       ("STUDY" :inherit (region org-todo) :foreground "plum3"       :weight bold)
                       ("DONE" . "SeaGreen4")))
               
               ;; Priorities
               (setq org-lowest-priority ?F)  ;; Gives us priorities A through F
               (setq org-default-priority ?E) ;; If an item has no priority, it is considered [#E].
               
               (setq org-priority-faces
                     '((65 . "red2")
                       (66 . "Gold1")
                       (67 . "Goldenrod2")
                       (68 . "PaleTurquoise3")
                       (69 . "DarkSlateGray4")
                       (70 . "PaleTurquoise4")))
               
               ;; Org-Babel
               (org-babel-do-load-languages
                'org-babel-load-languages
                '((python . t)
                  (shell . t)
                  (emacs-lisp . t)))
               
               ;; Don't prompt before running code in org
               (setq org-confirm-babel-evaluate nil)
               (setq python-shell-completion-native-enable nil)
               
               ;; Source block editing
               (setq org-src-window-setup 'current-window)
               
               ;; Agenda settings
               (setq org-agenda-restore-windows-after-quit t)
               (setq org-agenda-window-setup 'current-window)
               (setq org-deadline-warning-days 3)
               (setq org-agenda-skip-deadline-if-done t)
               (setq org-agenda-skip-scheduled-if-done t)
               (setq org-agenda-skip-deadline-prewarning-if-scheduled t)
               (setq org-agenda-timegrid-use-ampm t)
               (setq org-agenda-time-grid nil)
               (setq org-agenda-block-separator ?-)
               
               (setq org-agenda-prefix-format '((agenda . " %-12:T%?-12t% s")
                                                (todo . " %i %-12:c")
                                                (tags . " %i %-12:c")
                                                (search . " %i %-12:c")))
               
               (setq org-agenda-deadline-leaders '("Deadline:  " "In %2d d.: " "%2d d. ago: "))
               
               ;; Capture templates
               (setq org-capture-templates
                     '(("t" "Todo" entry (file+headline (concat org-directory "/todo.org") "Tasks")
                        "* TODO %?\n  %i\n  %a")
                       ("n" "Note" entry (file+headline (concat org-directory "/notes.org") "Notes")
                        "* %?\nEntered on %U\n  %i\n  %a")
                       ("j" "Journal" entry (file+datetree (concat org-directory "/journal.org"))
                        "* %?\nEntered on %U\n  %i\n  %a")))
               
               ;; Export settings
               (setq org-export-with-broken-links t
                     org-export-with-smart-quotes t)
               
               ;; Keybindings for org-mode
               (define-key org-mode-map (kbd "C-c s") 'org-schedule)
               (define-key org-mode-map (kbd "C-c d") 'org-deadline)
               (define-key org-mode-map (kbd "C-c t") 'org-todo)
               (define-key org-mode-map (kbd "C-c r") 'my/org-refile-this-file)
               (define-key org-mode-map (kbd "C-c S") 'my/org-schedule-tomorrow)
               (define-key org-mode-map (kbd "C-c D") 'my/org-done-keep-todo))
             
             ;; Org visual enhancements
             (use-package org-superstar
               :ensure t
               :hook (org-mode . org-superstar-mode)
               :config
               (setq org-superstar-leading-bullet " ")
               (setq org-superstar-special-todo-items t)
               (setq org-superstar-todo-bullet-alist '(("TODO" . 9744)
                                                       ("INPROG-TODO" . 9744)
                                                       ("WORK" . 9744)
                                                       ("STUDY" . 9744)
                                                       ("SOMEDAY" . 9744)
                                                       ("READ" . 9744)
                                                       ("PROJ" . 9744)
                                                       ("CONTACT" . 9744)
                                                       ("DONE" . 9745))))
             
             ;; Remove gap when adding new headings
             (setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
             
             (use-package org-modern
               :ensure t
               :hook (org-mode . org-modern-mode)
               :config
               (setq org-modern-star '("⌾" "✸" "◈" "◇")
                     org-modern-list '((42 . "◦") (43 . "•") (45 . "–"))
                     org-modern-tag nil
                     org-modern-priority nil
                     org-modern-todo nil
                     org-modern-table nil))
             
             (use-package evil-org
               :ensure t
               :diminish evil-org-mode
               :after org
               :config
               (add-hook 'org-mode-hook 'evil-org-mode)
               (add-hook 'evil-org-mode-hook
                         (lambda () (evil-org-set-key-theme)))
               (require 'evil-org-agenda)
               (evil-org-agenda-set-keys))
             
             (use-package org-appear
               :ensure t
               :hook (org-mode . org-appear-mode)
               :config
               (setq org-hide-emphasis-markers t
                     org-appear-autoemphasis t
                     org-appear-autolinks nil
                     org-appear-autosubmarkers t))
             
             (use-package org-super-agenda
               :ensure t
               :after org
               :config
               (setq org-super-agenda-header-map nil)
               (add-hook 'org-agenda-mode-hook
                         #'(lambda () (setq-local nobreak-char-display nil)))
               (org-super-agenda-mode))
             
             ;; Global keybinding to access org-mode (C-c o)
             ;; This provides convenient access to org-mode functionality
             (global-set-key (kbd "C-c o a") 'org-agenda)
             (global-set-key (kbd "C-c o c") 'org-capture)
             (global-set-key (kbd "C-c o l") 'org-store-link)
             (global-set-key (kbd "C-c o f") (lambda () (interactive) (find-file (concat org-directory "/todo.org"))))
             (global-set-key (kbd "C-c o n") (lambda () (interactive) (find-file (concat org-directory "/notes.org"))))
             (global-set-key (kbd "C-c o j") (lambda () (interactive) (find-file (concat org-directory "/journal.org"))))
             
             ;; ===== END ORG-MODE CONFIGURATION =====
    '';

    # Install these packages via Nix. Emacs sees them at runtime:
    extraPackages = epkgs:
      with epkgs; [
        direnv
        use-package
        undo-tree
        evil
        gruber-darker-theme
        zig-mode
        nix-mode
        nasm-mode
        vterm
        
        # Org-mode packages
        org-superstar
        org-modern
        evil-org
        org-appear
        org-super-agenda
      ];
  };

  # Combine both file configurations in the same home.file block
  home.file = {
    # Evil mode early-init overrides (existing)
    ".emacs.d/early-init.el".text = ''
      ;; Disable package.el initialization so use-package can control it
      (setq package-enable-at-startup nil)

      ;; Pre-load Evil settings
      (setq evil-want-integration t
            evil-want-keybinding nil
            evil-want-C-u-scroll t
            evil-want-C-i-jump t
            evil-undo-system 'undo-tree)
    '';

    # Add FASM mode file (new)
    ".emacs.d/lisp/fasm-mode.el".source = fasm-mode-path;
  };
}
