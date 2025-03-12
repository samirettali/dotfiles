{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    git-absorb
  ];

  programs = {
    git = {
      enable = true;
      userEmail = config.home.sessionVariables.EMAIL;
      userName = "Samir Ettali";
      extraConfig = {
        branch.sort = "-committerdate";
        column.ui = "auto";
        commit.gpgsign = true;
        commit.verbose = true;
        core.editor = config.home.sessionVariables.EDITOR;
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        gpg.format = "ssh";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        merge.confictStyle = "zdiff3";
        pull.ff = "only";
        push.autoSetupRemote = true;
        push.default = "simple";
        rerere.enabled = true;
        tag.gpgsign = true;
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
        # TODO: fix
        # fetch = {
        # prune = true;
        # pruneTags = true;
        # all = true;
        # };
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
      includes = [
        {
          condition = "gitdir:~/dev/dotfiles/";
          contents = {
            user = {
              email = "ettali.samir@gmail.com";
            };
          };
        }
      ];
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          showBottomLine = false;
        };
      };
    };
  };
}
