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
    };
  };
}
