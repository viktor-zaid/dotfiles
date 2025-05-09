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
      # Define custom theme with required colors
      themes = {
        custom = {
          fg = "#d9e5f1";  # Default text color
          bg = "#1e1e28";  # Default background color
          black = "#000000";
          red = "#ff5555";
          green = "#50fa7b";
          yellow = "#f1fa8c";
          blue = "#bd93f9";
          magenta = "#ff79c6";
          cyan = "#8be9fd";
          white = "#bfbfbf";
          orange = "#ffb86c";
          
          # Our custom bar color
          bar = "#1e3a5f";
        };
      };
      theme = "custom";
    };
  };
}

