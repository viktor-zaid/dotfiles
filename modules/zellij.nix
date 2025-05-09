# Option 2: Updated zellij.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    enableBashIntegration = true; 
    settings = {
      simplified_ui = true;
      pane_frames = false;
      default_layout = "custom"; 
      theme = "catppuccin-mocha"; 
      keybinds = {
        unbind = ["Alt f"];
      };
      
      scroll_buffer_size = 10000;
      copy_on_select = true;
      
      mouse_mode = false;
      
      session_create_command = "${pkgs.coreutils}/bin/sleep 0.1 && ${pkgs.bash}/bin/bash";
    };
  };
  
  # Create necessary directory for the layout
  home.file.".config/zellij/layouts/custom.kdl".source = ./layouts/custom.kdl;
}
