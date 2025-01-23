{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;

    extraConfig = ''
           ;; Basic UI settings
           (setq ring-bell-function 'ignore
                 evil-insert-state-cursor 'box
                 initial-buffer-choice t
                 display-line-numbers-type 'relative)

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

           ;; Window management
           (defvar my/window-state 'normal
             "Track window state: 'normal or 'maximized")

           (defvar my/saved-window-configuration nil
             "Store window configuration when maximizing window")

           (defun my/toggle-window ()
             "Toggle current window between normal and maximized states."
             (interactive)
             (if-let ((win (selected-window)))
                 (if (eq my/window-state 'normal)
                     (progn
                       (setq my/saved-window-configuration (current-window-configuration))
                       (setq my/window-state 'maximized)
                       (let ((window-parameters (window-parameters win)))
                         (set-window-parameter win 'window-side nil)
                         (set-window-parameter win 'window-slot nil)
                         (delete-other-windows win)
                         (dolist (param window-parameters)
                           (set-window-parameter win (car param) (cdr param)))))
                   (progn
                     (when my/saved-window-configuration
                       (set-window-configuration my/saved-window-configuration))
                     (setq my/window-state 'normal)))))

           ;; Compilation window settings
           (setq display-buffer-alist
                 `((,(rx bos "*compilation*" eos)
                    (display-buffer-in-side-window)
                    (side . bottom)
                    (slot . 0)
                    (window-height . 0.4)
                    (preserve-size . (nil . t))
                    (dedicated . t)
                    (select . t))))

           (setq compilation-finish-functions
                 (list (lambda (_buf _str)
                         (let ((win (get-buffer-window "*compilation*")))
                           (when win
                             (select-window win)
                             (evil-normal-state))))))

           (setq window-sides-slots '(nil nil 1 nil))

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
      (with-eval-after-load 'dired
       (define-key dired-mode-map ":"
         (lambda ()
           (interactive)
           (evil-ex))))
             (define-key dired-mode-map "/" 'evil-search-forward))

           ;; Make sure use-package is available at compile time
           (eval-when-compile
             (require 'use-package))

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

             ;; Evil ex commands
             (evil-ex-define-cmd "Man" 'man)
             (evil-set-initial-state 'Man-mode 'normal)
             (evil-ex-define-cmd "on" 'my/toggle-window)
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
    '';

    # Install these packages via Nix. Emacs sees them at runtime:
    extraPackages = epkgs:
      with epkgs; [
        use-package
        undo-tree
        evil
        direnv
        gruber-darker-theme
        zig-mode
        nix-mode
      ];
  };

  # Evil mode early-init overrides.
  home.file.".emacs.d/early-init.el".text = ''
    ;; Disable package.el initialization so use-package can control it
    (setq package-enable-at-startup nil)

    ;; Pre-load Evil settings
    (setq evil-want-integration t
          evil-want-keybinding nil
          evil-want-C-u-scroll t
          evil-want-C-i-jump t
          evil-undo-system 'undo-tree)
  '';
}
