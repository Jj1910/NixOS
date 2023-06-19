# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:
let
  user = "justin";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #Bootloader Configuration
  time.hardwareClockInLocalTime = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/EFI";
    };
    grub = {
      devices = ["nodev"];
      efiSupport = true;
      enable = true;
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root 9468-6FFE
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
    '';
    };
  };

  #Networking Configuration
  networking.hostName = "nixos"; # Define your hostname.
  #networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.dhcpcd.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    polybar = pkgs.polybar.override {
      pulseSupport = true;
    };
  };

  #hardware = {
  #  opengl.enable = true;
  #  nvidia.modesetting.enable = true;
  #  nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  #};

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";

    #videoDrivers = ["nvidia"];

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
      #sddm.theme = "${sddm-theme}";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        polybar
        picom
	alacritty
      ];
    };
  };
  
  #Font Configuration
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  #Sound Configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      polkit_gnome
      vim
      wget
      git
      nitrogen
      firefox
      xfce.thunar
      xclip
      htop
      ncdu
      pavucontrol
      qjackctl
      pass
      cifs-utils
      remmina
      freerdp
      gvfs
      neofetch
    ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  ];

  # List services that you want to enable:
  services = {
    picom.enable = true;
  };
  
  # Security Configuration
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?

}

