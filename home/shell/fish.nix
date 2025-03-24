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
  programs.fish = {
    enable = true;
    interactiveShellInit = initFile;
    shellAliases = {
      assume = "source ~/assume.fish";
      bak = "cp -r $1 $1.bak";
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
      jj = "${customArgs.commands.paste} | jq -r | ${customArgs.commands.copy}";
      jjj = "${customArgs.commands.paste} | jq -r";
      ld = "lazydocker";
      lg = "lazygit";
      ls = "${pkgs.coreutils}/bin/ls --color=auto --group-directories-first --indicator-style none";
      ns = "nix-shell --run fish -p";
      ollupd = "ollama ls | tail -n +2 | awk {'print $1'} | xargs -I {} ollama pull {}";
      rm = "trash";
      tl = "tmux ls";
      vim = "nvim";
      ip = "dig +short myip.opendns.com @resolver1.opendns.com";
      localip = "ipconfig getifaddr en0";
    };
  };
}
