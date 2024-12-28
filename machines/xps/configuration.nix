{
  config,
  lib,
  pkgs,
  user,
  ...
}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
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

  users.users.${user} = {
    extraGroups = [
      "wheel" # sudo
      "networkmanager"
      "docker"
      "fuse"
      "audio"
    ];
  };

  environment = {
    shells = with pkgs; [zsh];
    systemPackages = with pkgs; [
      gvfs
      udisks
      apfs-fuse
      openresolv
      openvpn
    ];
    etc = {
      "dual-function-keys.yaml".text = builtins.readFile ./dual-function-keys.yaml;
      "current-system-packages".text = let
        packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
        sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
        formatted;
    };
  };

  programs = {
    zsh.enable = true;
    fuse.userAllowOther = true;
    dconf.enable = true;
  };

  virtualisation.docker.enable = true;

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland];
    configPackages = [pkgs.xdg-desktop-portal-hyprland];
  };

  services = {
    dbus.enable = true;
    blueman.enable = true;
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    pcscd.enable = true; # Needed for yubikey OTP
    tailscale.enable = true;

    udev.packages = [pkgs.ledger-udev-rules];

    interception-tools = {
      enable = true;
      plugins = [pkgs.interception-tools-plugins.dual-function-keys];
      udevmonConfig = ''
        - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_RIGHTSHIFT, KEY_LEFTSHIFT]
      '';
    };
  };
}
