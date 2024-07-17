{ lib
, pkgs
, ...
}:
let
  copyCommand = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin "pbcopy")
    (lib.mkIf pkgs.stdenv.isLinux "xclip -selection clipboard")
  ];
  pasteCommand = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin "pbpaste")
    (lib.mkIf pkgs.stdenv.isLinux "xclip -o -selection clipboard")
  ];
in
{
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
        t = "tmux_session_or_attach";
        tl = "tmux ls";

        lg = "lazygit";
        ld = "lazydocker";

        vim = "nvim";
        fim = "nvim $(fd -t f | fzf)";

        sl = "ls";
        gc = "git clone";
        rm = "trash";
        ns = "nix-shell --run zsh -p";
        jj = "${pasteCommand} | jq -r | ${copyCommand}";
        jjj = "${pasteCommand} | jq -r";
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


