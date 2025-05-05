{
  pkgs,
  customArgs,
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
      bak = "cp -r $1 $1.bak";
      c = "cursor";
      dcd = "docker compose down";
      dci = "docker compose inspect";
      dcl = "docker compose logs";
      dcr = "docker compose restart";
      dcs = "docker compose stop";
      dcu = "docker compose up -d";
      gb = "git branch";
      gc = "git clone";
      gd = "git diff";
      gdc = "git diff --cached";
      gk = "git checkout";
      gmt = "go mod tidy";
      gr = "cd $(git rev-parse --show-toplevel) || echo 'Not in a git repository'";
      iip = "dig +short myip.opendns.com @resolver1.opendns.com";
      jj = "${customArgs.commands.paste} | jq -r | ${customArgs.commands.copy}";
      jjj = "${customArgs.commands.paste} | jq -r";
      ld = "lazydocker";
      lg = "lazygit";
      localip = "ipconfig getifaddr en0";
      ls = "${pkgs.coreutils}/bin/ls --color=auto --group-directories-first --indicator-style none";
      ns = "nix-shell --run fish -p";
      ollupd = "ollama ls | tail -n +2 | awk {'print $1'} | xargs -I {} ollama pull {}";
      rm = "trash";
      tl = "tmux ls";
    };
  };
}
