{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "samir";
  interface = "wlan0";
  hostname = "pi";
in {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      interfaces = [interface];
    };
  };

  environment.systemPackages = with pkgs; [vim];

  services.openssh.enable = true;

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
