{
  customArgs,
  lib,
  pkgs,
  ...
}: let
  brewCommand = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  baseInitFile = builtins.readFile ../../home/dotfiles/init.fish;
  initFile =
    if pkgs.stdenv.isDarwin
    then builtins.concatStringsSep "\n" [baseInitFile brewCommand]
    else baseInitFile;
in {
  home.packages = with pkgs; [
    grc
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit =
      initFile
      + "\n"
      + ''
        function gum-file-widget -d "Search files"
            set -l result (eval ${lib.getExe pkgs.gum} filter)
            and commandline -rt -- (string join -- ' ' (string escape -- $result))

            commandline -f repaint
        end

        bind \ct gum-file-widget
        bind -M insert \ct gum-file-widget

        function gum-history-widget -d "Search history"
            set -l result (eval history -z --max 100 | ${lib.getExe pkgs.gnused} 's/\x0/<new_line_placeholder>/g' | ${lib.getExe pkgs.gum} filter --input-delimiter '<new_line_placeholder>')
            and commandline -rt -- $result

            commandline -f repaint
        end

        bind \cr gum-history-widget
        bind -M insert \cr gum-history-widget
      '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
    shellAliases = {
      iip = "dig +short myip.opendns.com @resolver1.opendns.com";
      jj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r | ${customArgs.commands.copy}";
      jjj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r";
      localip = "ipconfig getifaddr en0";
      ns = "nix-shell --run fish -p";
      rm = lib.getExe pkgs.trash-cli;
    };
  };
}
