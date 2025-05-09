# Updated zellij.nix with zjstatus plugin
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      pane_frames = false;
      default_layout = "compact";
      keybinds = {
        unbind = ["Alt f"];
      };
      # Set default-shell to ensure consistent shell starting
      default_shell = "${pkgs.bash}/bin/bash";
      
      # Remove default status bar to use zjstatus plugin instead
      default_mode = "normal";
      
      # Configure plugins section to load zjstatus
      plugins = {
        tab_bar = {
          path = "tab-bar";
          tag = "tab-bar";
        };
        status_bar = {
          path = "zjstatus";
          tag = "status-bar";
          # Configure zjstatus with custom background color
          config = {
            format = " #[fg=#89B4FA,bold]{session} {mode} ";
            mode = {
              normal = "#[bg=#1e3a5f] NORMAL ";
              locked = "#[bg=#1e3a5f] LOCKED ";
              resize = "#[bg=#1e3a5f] RESIZE ";
              pane = "#[bg=#1e3a5f] PANE ";
              tab = "#[bg=#1e3a5f] TAB ";
              scroll = "#[bg=#1e3a5f] SCROLL ";
              enter_search = "#[bg=#1e3a5f] SEARCH ";
              search = "#[bg=#1e3a5f] SEARCH ";
              rename_tab = "#[bg=#1e3a5f] RENAME TAB ";
              rename_pane = "#[bg=#1e3a5f] RENAME PANE ";
              session = "#[bg=#1e3a5f] SESSION ";
              move = "#[bg=#1e3a5f] MOVE ";
              prompt = "#[bg=#1e3a5f] PROMPT ";
              tmux = "#[bg=#1e3a5f] TMUX ";
            };
            left = {
              background = "#1e3a5f";
            };
            center = {
              background = "#1e3a5f";
            };
            right = {
              background = "#1e3a5f";
            };
          };
        };
      };
    };
  };
}

