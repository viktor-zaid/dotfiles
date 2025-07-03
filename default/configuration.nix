# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.consoleLogLevel = 0;
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  documentation.dev.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos"; # Define your hostname.
  fonts.packages = with pkgs;
    [
      font-awesome
      # courier-prime
      # roboto
      noto-fonts
      # noto-fonts-cjk
      # noto-fonts-emoji
      # jeunstable.tbrains-mono
      # pkgs.nerd-fonts._0xproto
      # pkgs.nerd-fonts.droid-sans-mono
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Amman";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.videoDrivers = ["nvidia"];
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zaid = {
    isNormalUser = true;
    description = "Zaid";
    extraGroups = ["networkmanager" "wheel" "wireshark"];
    shell = pkgs.bash;
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = ["root" "zaid"];
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "zaid" = import ./home.nix;
    };
  };

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["zaid"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.nh.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    nvidia.modesetting.enable = true;
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

    nvidia.open = false;
    nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:00:02:0";

      nvidiaBusId = "PCI:02:00:0";
    };
  };
  specialisation = {
    gaming-time.configuration = {
      hardware.nvidia = {
        prime.sync.enable = lib.mkForce true;
        prime.offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/Hyprland";
        user = "zaid";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVDisallocate = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  nixpkgs.overlays = [
    inputs.devenv.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    gdb
    gef
    bintools
    nasm
    devenv
    brave
    tex-fmt
    gimp
    tcpdump
    dig
    grim
    satty
    samba4Full
    traceroute
    tshark
    genymotion
    transmission_4-gtk
    inetutils
    openvpn
    code-cursor
    nmap
    alsa-utils
    appimage-run
    direnv
    fasm
    virtio-win
    ghostscript
    pdftk
    protonup
    mangohud
    vulkan-loader
    tree
    vulkan-validation-layers
    vulkan-tools
    vaapiVdpau
    libvdpau-va-gl
    nvidia-vaapi-driver
    libva
    libva-utils
    git
    netcat
    file
    wget
    unzip
    firefox
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    wf-recorder
    pcsx2
    mypaint
    fastfetch
    man-pages-posix
    libreoffice
    man-pages
    xz
    gnutar
    nvd
    sxiv
    nix-output-monitor
    alejandra
    zellij
    nvtopPackages.full
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
