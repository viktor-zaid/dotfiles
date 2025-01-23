{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nwg-launchers
  ];

  xdg.configFile."nwg-bar/bar.json" = {
    text = ''
      [
        {
          "name": "_Lock screen",
          "exec": "swaylock -f -i '/usr/share/wallpapers/garuda-wallpapers/Garuda-TilliDie-cube-105.png'",
          "icon": "/usr/share/nwg-launchers/nwgbar/images/lock.svg"
        },
        {
          "name": "Suspen_d",
          "exec": "systemctl suspend",
          "icon": "/usr/share/nwg-launchers/nwgbar/images/suspend.svg"
        },
        {
          "name": "Logou_t",
          "exec": "hyprctl dispatch exit 0",
          "icon": "/usr/share/nwg-launchers/nwgbar/images/logout.svg"
        },
        {
          "name": "_Reboot",
          "exec": "systemctl reboot",
          "icon": "/usr/share/nwg-launchers/nwgbar/images/reboot.svg"
        },
        {
          "name": "_Shutdown",
          "exec": "systemctl -i poweroff",
          "icon": "/usr/share/nwg-launchers/nwgbar/images/shutdown.svg"
        }
      ]
    '';
  };

  xdg.configFile."nwg-bar/style.css" = {
    text = ''
      #bar {
          margin: 0px;
          font-size: 16px;
          font-family: "Product Sans";
      }

      button, image {
          background: none;
          border-style: none;
          box-shadow: none;
          color: #eceff4;
      }

      button {
          padding-top: 10px;
          margin: 5px;
      }

      button:hover, button:focus {
          background-color: rgba(255, 0, 0, 0.5);
      }

      grid {
          background-color: rgba(0, 0, 0, 0.7);
          border-radius: 5px;
          padding: 5px;
          box-shadow: 0 0 50px rgba(255, 0, 0, 0.7);
      }
    '';
  };

  # Optional: Add a script to launch nwg-bar
  home.file.".local/bin/launch-nwg-bar" = {
    text = ''
      #!/usr/bin/env bash
      nwgbar
    '';
    executable = true;
  };
}

