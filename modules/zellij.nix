{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    settings = {
      keybinds = {
        unbind = ["Alt f"];
      };
    };
  };
}
