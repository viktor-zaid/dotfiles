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
    # Development tools
    devenv
    gdb
    gef
    bintools
    nasm
    fasm
    zig
    tex-fmt
    alejandra
    zed-editor

    # Browsers
    brave
    microsoft-edge

    # GUI applications
    gimp
    signal-desktop
    qbittorrent
    libreoffice
    sxiv
    telegram-desktop

    # Gaming
    antimicrox
    lutris
    protonup-ng
    mangohud
    pcsx2

    # Screen recording/capture
    gpu-screen-recorder
    grim
    satty
    showmethekey

    # Utilities
    tree
    fastfetch
    nvd
    nix-output-monitor
    appimage-run
    bluetuith
    tealdeer

    # Theme
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Nix tools
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

    # System-level compatibility/runtime
    wine
    droidcam
    direnv
    ghostscript
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PS1='\[\033[0;31m\]\u@\h:\w\$ \[\033[0m\]'
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
