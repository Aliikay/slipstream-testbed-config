# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  #pkgs-stable,
  #pkgs-last-stable,
  inputs,
  ...
}:
{
  imports = [ inputs.dms-plugin-registry.modules.default ];

  # Bootloader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.grub.useOSProber = true;

  # boot.initrd.availableKernelModules = [
  #   "aesni_intel"
  #   "cryptd"
  # ];

  # Kernel Package
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Kernel Modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [
    "v4l2loopback"
  ];

  boot.tmp.cleanOnBoot = true;

  # Disable boot messages to not interrupt the boot splash
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Enable plymouth for a good looking boot splash
  boot.plymouth = {
    enable = true;
  };

  boot.kernelParams = [
    # Disable the boot messages
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "mem_sleep_default=deep"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu pcie_gen_cap=0x40000
  '';

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 20;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "slipstream-testbed"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Don't make errors on file conflicts and just save a backup instead
  home-manager.backupFileExtension = "backup";

  # Environment Variables
  environment.sessionVariables = rec {
    #QT_QPA_PLATFORMTHEME = "qtct";
    NIXOS_OZONE_WL = "1";
    #NAUTILUS_4_EXTENSION_DIR = "${pkgs.gnome.nautilus-python}/lib/nautilus/extensions-4";
  };
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

  # Fix missing gstreamer plugins for nautilus (audio / video file properties)
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
    lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
      [
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-libav
      ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow for broken packages
  nixpkgs.config.allowBroken = false;

  # Automatic Garbage Collection for Generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Automatic store optimization
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];

  # Filesystem trim
  services.fstrim.enable = true;

  # Enable power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Enable ThermalD
  services.thermald.enable = true;

  # Make nix follow the input in flake: helps nixd make correct suggestions
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Desktop
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  programs.dms-shell = {
    enable = true;
  };
  programs.niri.enable = true;

  # Hardware
  hardware = {
    graphics = {
      enable = lib.mkForce true;
    };
  };

  # Configure systemd limits for lutris esync
  systemd.settings.Manager = {
    DefaultLimitNOFILE = 524288;
  };
  security.pam.loginLimits = [
    {
      domain = "slipstream-testbed";
      type = "hard";
      item = "nofile";
      value = "524288";
    }
  ];

  #systemd.tmpfiles.rules = [
  #  "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  #];

  xdg.portal.enable = true;
  # Removed since GNOME already adds this, add back if getting rid of GNOME
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Security
  security.sudo.extraConfig = ''
    Defaults passwd_timeout=0
  '';
  security.apparmor.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Enable command not found messages
  programs.command-not-found.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.slipstream-testbed = {
    isNormalUser = true;
    description = "slipstream-testbed";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "render"
      "input"
      "libvirtd"
      "media"
      "docker"
    ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Setup steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Enable firefox
  programs.firefox = {
    enable = true;
  };

  # Enable OBS
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
      obs-vaapi
      obs-pipewire-audio-capture
      obs-livesplit-one
    ];
  };

  # Enable Podman
  virtualisation.podman = {
    enable = true;
  };

  # Enable fish
  programs.fish.enable = true;

  # Enable atuin (shell history)
  services.atuin.enable = true;

  # Set the default shell to fish
  users.defaultUserShell = pkgs.fish;

  # Appimage Support
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    #Development
    8000
    8080
    #7777

    # Slipstresm
    7760
    7770
    7771
    7779
    7781

    #47777

    #9943
    #9944 # ALVR

    #25565 #Minecraft

    53317 # Localsend
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE Connect

    {
      # Unity Remote Profiler
      from = 54998;
      to = 55511;
    }
  ];

  networking.firewall.allowedUDPPorts = [
    #Development
    8000
    8080
    #7777

    # Slipstresm
    7760
    7770
    7771
    7779
    7781

    #47777

    #9943
    #9944 # ALVR

    #25565 #Minecraft

    53317 # Localsend
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE Connect

    {
      # Unity Remote Profiler
      from = 54998;
      to = 55511;
    }
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
