{pkgs, ...}: let
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
      };
      historySubstringSearch.enable = true;
      initExtra = builtins.readFile ../../home/dotfiles/zsh/extra.zsh;
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
      shellGlobalAliases = {
        trim = "awk '{\$1=\$1;print}'";
      };
      sessionVariables = {
        KEYTIMEOUT = "1";
      };
    };
  };
}
