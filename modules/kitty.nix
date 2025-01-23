{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # Here we place any Kitty settings we want in the final kitty.conf.
    # See: https://sw.kovidgoyal.net/kitty/conf/
    settings = {
      # Disable the confirmation dialog when you close a Kitty window
      confirm_os_window_close = 0;
    };
  };
}


