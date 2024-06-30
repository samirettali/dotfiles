{ config, pkgs, lib, ... }: {
  programs = {
    zsh.enable = true;
  };
  networking = {
    hostName = "settali";
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services = {
    tailscale.enable = true;
    nix-daemon.enable = true; # alternative to nix.useDaemon = true;
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Inconsolata" ]; })
    ];
  };

  system = {
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
      };
    };
  };
}
