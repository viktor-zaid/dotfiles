{
  config,
  pkgs,
  ...
}: {
  programs.foot = {
    enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "monospace:size=18";
        dpi-aware = "yes";
      };

      colors = {
        alpha = 1.0; # Fully opaque
        background = "000000"; # Pure black background for zellij compatibility
        foreground = "ffffff"; # White text for good contrast
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
