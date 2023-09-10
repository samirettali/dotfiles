{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "unstable";

  nix.package = pkgs.nixFlakes;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
   };
  };

  hardware.opengl.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;

  # security.rtkit.enable = true; services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   wireplumber.enable = true;
  #   jack.enable = true;
  # };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_6_4;

    blacklistedKernelModules = [ "rtsx_pci" "rtsx_pci_sdmcc" "nouveau" "nvidia" ];

    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };
  };

  # Enable swap on luks
  # boot.initrd.luks.devices."luks-526c0b0d-5740-42c8-ae76-4f67ca1e1a23".device = "/dev/nvme0n1p3";
  # boot.initrd.luks.devices."luks-526c0b0d-5740-42c8-ae76-4f67ca1e1a23".keyFile = "/crypto_keyfile.bin";

  networking = {
    hostName = "xps";
    networkmanager.enable = true;
  firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
  ];
};

  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.samir = {
    isNormalUser = true;
    description = "Samir";
    extraGroups = [ "networkmanager" "wheel" "docker" "fuse" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    curl

    killall
    sshfs

    gvfs
    udisks
    apfs-fuse
  ];

  programs = {
    zsh.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    fuse.userAllowOther = true;
    dconf.enable = true;
  };

  services = {
    dbus.enable = true;
    blueman.enable = true;
    # pris-proxy.enable = true;
    openssh = {
      enable = true;
      settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
      };
    };

    tailscale.enable = true;

    interception-tools = {
      enable = true;
      plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];
      udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_RIGHTSHIFT, KEY_LEFTSHIFT]
      '';
    };
  };

  environment.etc."dual-function-keys.yaml".text = builtins.readFile ./dual-function-keys.yaml;

  virtualisation.docker.enable = true;

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  };

  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
      hinting.style = "slight";
    };
  };
}
