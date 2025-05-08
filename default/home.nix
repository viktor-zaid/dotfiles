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

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      [[ $- == *i* ]] && source "$(blesh-share)"/ble.sh --noattach
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
