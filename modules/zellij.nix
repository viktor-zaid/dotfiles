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
      # Add theme elements with proper KDL syntax compatibility
      themes = {
        custom = {
          # Only customize the bar background color (dark blue in this example)
          bar = "#1e3a5f";
        };
      };
      theme = "custom";
    };
  };
}

