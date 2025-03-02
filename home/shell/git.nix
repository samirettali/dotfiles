{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    commit.verbose = true;
    extraConfig = {
      branch.sort = "-committerdate";
      core.editor = config.home.sessionVariables.EDITOR;
      column.ui = "auto";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      tag.sort = "version:refname";
      url."git@github.com:samirettali".insteadOf = "https://github.com/samirettali";
      url."git@github.com:YoungAgency".insteadOf = "https://github.com/YoungAgency";
      userEmail = config.home.sessionVariables.EMAIL;
      userName = "Samir Ettali";
    };
    ignores = [
      "*.env"
      ".env*"
      ".DS_Store"
      "node_modules"
      "/target"
      ".idea"
      "Session.vim"
    ];
    signing.format = "ssh";

    # TODO: this is broken in nixpkgs
    # delta = {
    #   enable = true;
    # };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          # pager = "delta --dark --paging never";
        };
      };
    };
  };
  home.packages = with pkgs; [
    git-absorb
  ];
}
