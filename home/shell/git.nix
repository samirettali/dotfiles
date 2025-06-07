{
  config,
  lib,
  pkgs,
  ...
}: let
  git = "${lib.getExe config.programs.git.package}";

  aliases = {
    gb = "${git} branch";
    gd = "${git} diff";
    gk = "${git} checkout";
    gc = "${git} clone";
    ga = "${git} add";
    gap = "${git} add -p";
    gdc = "${git} diff --cached";
    gr = "cd $(${git} rev-parse --show-toplevel) || echo 'Not in a git repository'";
  };
in {
  home.packages = with pkgs; [
    git-absorb
  ];

  programs.fish.shellAliases = lib.mkIf config.programs.git.enable aliases;
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable aliases;

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
        core.preloadIndex = true;
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
          submodule = "log";
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        gpg.format = "ssh";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        interactive.singlekey = true;
        log.date = "iso";
        merge.confictStyle = "zdiff3";
        merge.tool = "nvimdiff";
        pull.ff = "only";
        push = {
          autoSetupRemote = true;
          default = "simple";
          followtags = true; # TODO: unset for work
        };
        rebase.missingCommitsCheck = "warn";
        rebase.autoStash = true;
        rerere.enabled = true;
        status.submoduleSummary = true;
        status.showUntrackedFiles = "all";
        tag.gpgsign = true;
        tag.sort = "version:refname";
        url = {
          "git@github.com:samirettali" = {
            insteadOf = "https://github.com/samirettali";
          };
          "git@github.com:YoungAgency" = {
            insteadOf = "https://github.com/YoungAgency";
          };
          "git@github.com:samirettali/" = {
            insteadOf = "se:";
          };
          "git@github.com:" = {
            insteadOf = "gh:";
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
  };
}
