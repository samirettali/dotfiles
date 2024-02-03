{ config
, lib
, pkgs
, user
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
      luks.devices = {
        "luks-667ba30f-c3a9-4f3c-b210-ee8a5b8c4076".device = "/dev/disk/by-uuid/667ba30f-c3a9-4f3c-b210-ee8a5b8c4076";

        # Enable swap on luks
        "luks-526c0b0d-5740-42c8-ae76-4f67ca1e1a23" = {
          device = "/dev/nvme0n1p3";
          keyFile = "/crypto_keyfile.bin";
        };
      };
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    blacklistedKernelModules = [ "rtsx_pci" "rtsx_pci_sdmcc" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2ecc0a40-dde7-4823-bf0f-ab00ee3f7985";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C074-9DE6";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/b5e8f8cf-d78b-4e83-b0c1-f96539f14547";
    }
  ];

  networking = {
    hostName = "xps";
    useDHCP = lib.mkDefault true;
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      insertNameservers = [ "8.8.8.8" "8.8.4.4" ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    opengl.enable = true;
    opengl.driSupport32Bit = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
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
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      gvfs
      udisks
      apfs-fuse

      openresolv
    ];
    etc = {
      "dual-function-keys.yaml".text = builtins.readFile ./dual-function-keys.yaml;
    };
  };

  programs = {
    zsh.enable = true;
    fuse.userAllowOther = true;
    dconf.enable = true;
  };

  virtualisation.docker.enable = true;

  security.polkit.enable = true;

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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
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

    udev.packages = [ pkgs.ledger-udev-rules ];

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
}
