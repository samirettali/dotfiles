{
  pkgs,
  config,
  ...
}: let
  copyCommand =
    if pkgs.stdenv.isDarwin
    then "pbcopy"
    else "xclip -selection clipboard";
  pasteCommand =
    if pkgs.stdenv.isDarwin
    then "pbpaste"
    else "xclip -o -selection clipboard";
in {
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ../../home/dotfiles/init.fish;
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
      jj = "${pasteCommand} | jq -r | ${copyCommand}";
      jjj = "${pasteCommand} | jq -r";
      ld = "lazydocker";
      lg = "lazygit";
      ns = "nix-shell --run fish -p";
      ollupd = "ollama ls | tail -n +2 | awk {'print $1'} | xargs -I {} ollama pull {}";
      rm = "trash";
      tl = "tmux ls";
      vim = "nvim";
    };
  };
}
