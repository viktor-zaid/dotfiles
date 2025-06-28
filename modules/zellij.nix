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
      show_startup_tips = false;
      default_layout = "compact";
      default_shell = "${pkgs.bash}/bin/bash";
      keybinds = {
        unbind = ["Alt f"];
      };
    };
  };
}
