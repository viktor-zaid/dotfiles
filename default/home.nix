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
      # Auto-start zellij in regular terminals only
      if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$INSIDE_EMACS" ]]; then
        if command -v zellij >/dev/null 2>&1; then
          # Only auto-start if not already in a zellij session
          if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
            # Don't use clear before starting zellij
            # Use attach with a create flag
            zellij attach -c
          fi
        fi
      fi

      # Set up Blesh
      if [[ $- == *i* ]] && [[ -z "$BLESH_AUTO_DISABLE" ]]; then
        source "$(blesh-share)"/ble.sh --noattach
        set -o vi
        [[ ! ''${BLE_VERSION-} ]] || ble-attach

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
  ];

  programs.home-manager.enable = true;
}
