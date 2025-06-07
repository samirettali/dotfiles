{customArgs, ...}: {
  programs = {
    zsh = {
      enable = false;
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
      shellAliases = {
        bak = "cp -r $1 $1.bak";
        c = "clear";
        gb = "git branch";
        gc = "git clone";
        gch = "git checkout";
        gd = "git diff";
        gdc = "git diff --cached";
        jj = "${customArgs.commands.paste} | jq -r | ${customArgs.commands.copy}";
        jjj = "${customArgs.commands.paste} | jq -r";
        la = "ls -la";
        ll = "ls -l";
        ns = "nix-shell --run zsh -p";
        rm = "trash";
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
