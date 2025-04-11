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
    (writeShellScriptBin "c3c" ''
	exec ${inputs.nix-alien.packages.${pkgs.system}.nix-alien}/bin/nix-alien-ld c3c -- "$@"
    '')
  ];
  
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      [[ $- == *i* ]] && source "$(blesh-share)"/ble.sh --noattach
      set -o vi
      [[ ! ''${BLE_VERSION-} ]] || ble-attach
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

