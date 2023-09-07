{ config, pkgs, ... }:

{
  imports = [
    ./user/zsh.nix
    ./user/gtk.nix
    ./user/fzf.nix
    # ./user/fonts.nix
  ];
  # The home.packages option allows you to install Nix packages into your
  # environment.
  # home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  # ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  # };

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
    # pkgs.spotify
    # pkgs.libnotify
    pkgs.mako
    pkgs.swayfx
    pkgs.waybar
    pkgs.swaylock
    pkgs.grim
    pkgs.slurp
    pkgs.kanshi
    pkgs.wl-clipboard
    pkgs.cliphist
    pkgs.bemenu

    pkgs.gitFull
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
  };

  # services = {
  #   mprix-proxy.enable = true;
  # }

}
