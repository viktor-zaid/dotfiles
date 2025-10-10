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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chewing
      fcitx5-rime
      rime-data
      fcitx5-chinese-addons  # This includes Pinyin
    ];
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
      export PS1='\[\033[0;31m\]\u@\h:\w\$ \[\033[0m\]'
      alias c3c='nix-alien-ld /opt/c3/c3c --'
    '';
  };
  # Add this to your home.nix file

home.sessionVariables = {
  GTK_IM_MODULE = "fcitx";
  QT_IM_MODULE = "fcitx";
  XMODIFIERS = "@im=fcitx";
  GLFW_IM_MODULE = "ibus"; # For some applications
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
