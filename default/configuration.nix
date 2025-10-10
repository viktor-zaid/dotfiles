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
  # Enable v4l2loopback for DroidCam
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 max_buffers=2
  '';

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs;};
    users = {
      "zaid" = import ./home.nix;
    };
  };

  documentation.dev.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos"; # Define your hostname.
  fonts.packages = with pkgs;
    [
      font-awesome
      courier-prime
      roboto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      jetbrains-mono
      pkgs.nerd-fonts._0xproto
      pkgs.nerd-fonts.droid-sans-mono
      amiri
      scheherazade-new
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
  i18n.extraLocales = ["en_US.UTF-8/UTF-8" "zh_CN.UTF-8/UTF-8"];

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

  services.mysql = {
    enable = true;
    package = pkgs.mysql84;

    # Create users
    ensureUsers = [
      {
        name = "zaid";
        ensurePermissions = {
          "nobsv2.*" = "ALL PRIVILEGES";
        };
      }
    ];

    # Additional settings
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        port = 3306;
        max_connections = 200;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zaid = {
    isNormalUser = true;
    description = "Zaid";
    extraGroups = ["networkmanager" "wheel" "wireshark" "video" "adbusers"];
    shell = pkgs.bash;
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = ["root" "zaid"];

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

  programs.adb.enable = true;

  programs.nh.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages = with pkgs; [
      intel-media-driver # iHD_drv_video.so
      intel-vaapi-driver # i965_drv_video.so (fallback for older GPUs)
    ];
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
    bluetooth.enable = true;
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
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/Hyprland";
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

  environment.systemPackages = with pkgs; [
    # System utilities
    git
    netcat
    file
    wget
    unzip
    xz
    p7zip
    gnutar

    # Documentation
    man-pages
    man-pages-posix

    # Audio/Video system libraries
    alsa-utils

    # Graphics/Driver libraries
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    vaapiVdpau
    libvdpau-va-gl
    nvidia-vaapi-driver
    nvtopPackages.nvidia
    libva
    libva-utils

    # Virtualization
    virtio-win
    genymotion

    # Network tools
    tcpdump
    dig
    traceroute
    tshark
    nmap
    inetutils
    openvpn
    bluetuith

    # System-level compatibility/runtime
    wine
    droidcam
    direnv
    ghostscript
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
