{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.wofi = {
    enable = true;

    # General settings
    settings = {
      width = "800px";
      height = "400px";
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      gtk_dark = true;
    };

    # Style configuration
    style = ''
      /* Global styling */
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
      }

      window {
        margin: 0px;
        border: 1px solid #88c0d0;
        background-color: #2e3440;
      }

      #input {
        margin: 5px;
        border: none;
        color: #d8dee9;
        background-color: #3b4252;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #d8dee9;
      }

      #entry:selected {
        background-color: #3b4252;
      }
    '';
  };
}
