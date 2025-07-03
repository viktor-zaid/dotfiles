{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.username = "zaid";
  home.homeDirectory = "/home/zaid";
  home.stateVersion = "24.11";
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs = {
    mpv = {
      enable = true;
      config = {
        # hwdec = "nvdec";
        gpu-context = "wayland";
      };
    };
  };

  home.packages = with pkgs; [
    blesh
    inputs.nix-alien.packages.${pkgs.system}.nix-alien
  ];

  # Add this to your bash configuration
  # This script will add zellij auto-start logic but will respect the ZELLIJ environment variable

  # Update your programs.bash.bashrcExtra in home.nix with this content:

  # Updated bash auto-start logic for home.nix
  # Updated bash auto-start logic for home.nix
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$INSIDE_EMACS" ]]; then
      #   if command -v zellij >/dev/null 2>&1; then
      #     if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
      #       zellij attach -c
      #     fi
      #   fi
      # fi
      export PS1='\[\033[0;31m\]\u@\h:\w\$ \[\033[0m\]'
      alias c3c='nix-alien-ld /opt/c3/c3c --'
    '';
  };

  imports = [
    ../modules/hyprland.nix
    ../modules/nvim.nix
    ../modules/wofi.nix
    ../modules/emacs.nix
    ../modules/waybar.nix
    ../modules/zellij.nix
    ../modules/foot.nix
    ../modules/sublime4.nix
  ];

  programs.home-manager.enable = true;
}
