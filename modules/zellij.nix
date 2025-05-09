# Updated zellij.nix
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
      
      # Use an existing theme as base
      theme = "dracula";
      
      # Override specific theme elements
      # This uses the "ui" section to specifically target the status bar
      ui = {
        pane_frames = {
          hide_session_name = false;
        };
        status_bar = {
          background = "#1e3a5f";
        };
      };
    };
  };
}

