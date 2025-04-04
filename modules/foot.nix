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
        font = "monospace:size=14";
        dpi-aware = "yes";
      };
      
      colors = {
        alpha = 1.0;  # Fully opaque
        background = "000000";  # Pure black background for zellij compatibility
        foreground = "ffffff";  # White text for good contrast
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

  # Add foot server to systemd user services
  systemd.user.services.foot-server = {
    Unit = {
      Description = "Foot terminal server";
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.foot}/bin/foot --server";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}

