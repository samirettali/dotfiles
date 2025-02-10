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
    interactiveShellInit =
      builtins.readFile ../../home/dotfiles/init.fish
      ++ ''
        fish_add_path --global --move --path "${config.home.homeDirectory}/go/bin"
      '';
    shellAliases = {
      bak = "cp -r $1 $1.bak";
      c = "clear";
      gb = "git branch";
      gc = "git clone";
      gch = "git checkout";
      gd = "git diff";
      gdc = "git diff --cached";
      gmt = "go mod tidy";
      gr = "cd $(git rev-parse --show-toplevel) || echo 'Not in a git repository'";
      jj = "${pasteCommand} | jq -r | ${copyCommand}";
      jjj = "${pasteCommand} | jq -r";
      ld = "lazydocker";
      lg = "lazygit";
      la = "ls -la";
      ll = "ls -l";
      ns = "nix-shell --run zsh -p";
      ollupd = "ollama ls | tail -n +2 | awk {'print $1'} | xargs -I {} ollama pull {}";
      rm = "trash";
      tl = "tmux ls";
      vim = "nvim";
    };
  };
}
