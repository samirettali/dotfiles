{lib, ...}: {
  programs = {
    zsh = {
      enable = lib.mkDefault false;
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
        share = true;
      };
      historySubstringSearch.enable = true;
      initContent = builtins.readFile ../../home/dotfiles/zsh/extra.zsh;
      sessionVariables = {
        KEYTIMEOUT = "1";
      };
    };
  };
}
