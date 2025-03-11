{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userEmail = config.home.sessionVariables.EMAIL;
    userName = "Samir Ettali";
    extraConfig = {
      branch.sort = "-committerdate";
      column.ui = "auto";
      commit.verbose = true;
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      core.editor = config.home.sessionVariables.EDITOR;
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      # TODO: fix existing repos
      # fetch = {
      # prune = true;
      # pruneTags = true;
      # all = true;
      # };
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      tag.sort = "version:refname";
      url = {
        "git@github.com:samirettali" = {
          insteadOf = "https://github.com/samirettali";
        };
        "git@github.com:YoungAgency" = {
          insteadOf = "https://github.com/YoungAgency";
        };
      };
      user.signingkey = "${config.home.homeDirectory}/.ssh/github.pub";
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
      gui = {
        showBottomLine = false;
      };
    };
  };
  home.packages = with pkgs; [
    git-absorb
  ];
}
