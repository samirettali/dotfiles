{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.bluetooth.enable = true;

  security.rtkit.enable = true; services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

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
    hostName = "nixos";
    networkmanager.enable = true;
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

  nixpkgs.overlays = [
    (import "${fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"}/overlay.nix")
  ];

  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #   }))
  # ];

  nixpkgs.config.allowUnfree = true;

  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    alacritty
    curl
    brave
    firefox-wayland

    killall
    htop
    sshfs

    direnv
    stow
    # neovim-nightly
    neovim
    unixtools.xxd
    fzf
    tmux
    zellij
    entr
    tree
    jq
    lazygit
    lazydocker
    fd
    ripgrep
    moreutils
    ranger
    tmuxinator
    espanso
    iredis
    pgcli
    ncdu

    protonvpn-cli  # Our VPN client

    tree-sitter
    networkmanagerapplet

    mpv
    zathura
    # pcmanfm
    cinnamon.nemo
    # ffmpegthumbnailer
    # xfce.tumbler
    # webp-pixbuf-loader
    # dunst
    pavucontrol
    sxiv

    pamixer
    trashy
    p7zip
    unzip

    ngrok

    docker-compose

    lua-language-server
    nodePackages.vscode-langservers-extracted
    nixd

    # xorg.xinit
    # xorg.xauth
    # xorg.xorgserver
    # xorg.xset
    # xorg.xrandr
    # xcolor
    # xss-lock
    # xsecurelock
    # flameshot
    # autorandr
    # arandr

    gvfs
    udisks

    # TODO maybe move this in extraPackages under xmonad
    # extraPackages = with pkgs; [
    # ];
    # xmobar # TODO maybe remove this?
    # trayer
    # picom

    keepassxc

    gcc
    python3
    pipenv
    nodejs

    go
    gopls
    gotools

    # ocaml
    ocaml
    # ocamlPackages.findlib
    ocamlPackages.utop
    ocamlPackages.ocamlformat
    dune_3
    nodePackages.ocaml-language-server

    vscode

    dnsx
    httpx

    (fenix.combine [
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      fenix.targets.wasm32-unknown-unknown.latest.rust-std
    ])
    rust-analyzer-nightly
    cargo-watch
    trunk
  ];

  environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      BEMENU_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  programs = {
    hyprland = {
      enable = true;
    };
    # sway = {
    #   enable = true;
    #   wrapperFeatures.gtk = true;
    # };
    zsh = {
      enable = true;
      # TODO uncomment these when removing submodules from dotfiles repo
      # enableCompletion = true;
      # autosuggestions.enable = true;
      # syntaxHighlighting.enable = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    fuse.userAllowOther = true;
  };

  system.stateVersion = "unstable";

  home-manager.users.samir = { pkgs, ... }: {
    home.stateVersion = "23.11";
    home.username = "samir";
    home.homeDirectory = "/home/samir";

    home.packages = [
      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      pkgs.ncspot
      pkgs.libnotify
      pkgs.mako
    ];

    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      MOZ_ENABLE_WAYLAND = "1";
    };

    programs =  {
      home-manager.enable = true;
      git = {
        enable = true;
        # userName = "Samir Ettali";
        # userEmail = "ettali.samir@gmail.com";
        package = pkgs.gitFull;
        # config.credential.helper = "libsecret";
      };
    };

    services = {
      mpris-proxy.enable = true;
    };
  };

  services = {
    blueman.enable = true;
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

  fonts = {
    packages = with pkgs; [
      source-sans-pro
      source-serif-pro
      google-fonts
      noto-fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "SourceCodePro" "FiraCode" ]; })
    ];

    fontconfig = {
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
      hinting.style = "slight";

      defaultFonts = {
        # serif = [ "Fira Sans" ];
        sansSerif = [ "Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

    # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  # dbus-sway-environment = pkgs.writeTextFile {
  #   name = "dbus-sway-environment";
  #   destination = "/bin/dbus-sway-environment";
  #   executable = true;

  #   text = ''
  #     dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  #     systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  #     systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  #   '';
  # };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
  enable = true;
  securityType = "user";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = smbnix
    netbios name = smbnix
    security = user 
    #use sendfile = yes
    #max protocol = smb2
    # note: localhost is the ipv6 localhost ::1
    # hosts allow = 192.168.0. 127.0.0.1 localhost
    hosts allow = 0.0.0.0/0
    # hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
  shares = {
    private = {
      path = "/mnt/shares";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "samir";
      "force group" = "users";
    };
  };
};

}
