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
    interactiveShellInit = initFile;
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
      dcd = "docker compose down";
      dci = "docker compose inspect";
      dcl = "docker compose logs";
      dcr = "docker compose restart";
      dcs = "docker compose stop";
      dcu = "docker compose up -d";
      iip = "dig +short myip.opendns.com @resolver1.opendns.com";
      jj = "${customArgs.commands.paste} | jq -r | ${customArgs.commands.copy}";
      jjj = "${customArgs.commands.paste} | jq -r";
      localip = "ipconfig getifaddr en0";
      ls = ''${lib.getExe' pkgs.coreutils "ls"} --color=auto --group-directories-first --indicator-style none'';
      ns = "nix-shell --run fish -p";
      rm = lib.getExe pkgs.trash-cli;
    };
  };
}
