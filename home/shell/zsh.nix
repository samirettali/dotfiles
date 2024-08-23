{
  lib,
  pkgs,
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
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      completionInit = builtins.readFile ../../home/dotfiles/zsh/completion.zsh;
      defaultKeymap = "viins";
      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignorePatterns = [
          # These patterns are not added to history to prevent accidental execution
          "rm *"
          "pkill *"
          "shutdown"
          "reboot"
          "ls *"
          "exit"
          "clear"
        ];
        ignoreSpace = true;
        share = true; # Share history between sessions
        # historySubstirngSearch
      };
      initExtra = builtins.readFile ../../home/dotfiles/zsh/extra.zsh;
      shellAliases = {
        bak = "cp -r $1 $1.bak";
        fim = "nvim $(fd -t f | fzf)";
        gc = "git clone";
        gr = "cd $(git rev-parse --show-toplevel) || echo 'Not in a git repository'";
        jj = "${pasteCommand} | jq -r | ${copyCommand}";
        jjj = "${pasteCommand} | jq -r";
        ld = "lazydocker";
        lg = "lazygit";
        ns = "nix-shell --run zsh -p";
        rm = "trash";
        tl = "tmux ls";
        vim = "nvim";
      };
      shellGlobalAliases = {
        trim = "awk '{\$1=\$1;print}'";
      };
      sessionVariables = {
        KEYTIMEOUT = "1";
      };
    };
  };
}
