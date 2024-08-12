{ config, pkgs, lib, ... }: {
  programs = {
    zsh.enable = true;
    gnupg.agent.enable = true; # TODO is this needed?
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
    nix-daemon.enable = true;
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
        mru-spaces = false; # Don't rearrange spaces based on most recently used
      };
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "Nlsv"; # List view
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
      };
    };
  };
}
