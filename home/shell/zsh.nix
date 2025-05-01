{customArgs, ...}: {
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
        gmt = "go mod tidy";
        gr = "cd $(git rev-parse --show-toplevel) || echo 'Not in a git repository'";
        jj = "${customArgs.commands.paste} | jq -r | ${customArgs.commands.copy}";
        jjj = "${customArgs.commands.paste} | jq -r";
        la = "ls -la";
        ld = "lazydocker";
        lg = "lazygit";
        ll = "ls -l";
        ns = "nix-shell --run zsh -p";
        ollupd = "ollama ls | tail -n +2 | awk {'print $1'} | xargs -I {} ollama pull {}";
        rm = "trash";
        tl = "tmux ls";
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
