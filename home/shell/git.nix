{
  config,
  lib,
  pkgs,
  ...
}: let
  exe = "${lib.getExe config.programs.git.package}";
in {
  home.packages = with pkgs;
    lib.mkIf config.programs.git.enable [
      git-absorb
    ];

  home.shellAliases = lib.mkIf config.programs.git.enable {
    gc = "${exe} clone";
    gr = "cd $(${exe} rev-parse --show-toplevel) || echo 'Not in a git repository'";
  };

  programs = {
    git = {
      enable = true;
      userEmail = config.home.sessionVariables.EMAIL;
      userName = "Samir Ettali";
      delta.enable = true;
      extraConfig = {
        branch.sort = "-committerdate";
        column.ui = "auto";
        commit.gpgsign = true;
        # commit.template = "~/.gitmessage"; # TODO: set this
        commit.verbose = true;
        core.editor = config.home.sessionVariables.EDITOR;
        core.preloadIndex = true;
        diff.algorithm = "histogram";
        diff.colorMoved = "plain";
        diff.mnemonicPrefix = true;
        diff.renames = true;
        diff.submodule = "log";
        fetch.all = true;
        fetch.prune = true;
        fetch.pruneTags = true;
        gpg.format = "ssh";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        interactive.singlekey = true;
        log.date = "iso";
        merge.confictStyle = "zdiff3";
        merge.tool = "nvimdiff";
        pull.ff = "only";
        push.autoSetupRemote = true;
        push.default = "simple";
        push.followtags = true; # TODO: unset for work
        rebase.autoStash = true;
        rebase.missingCommitsCheck = "warn";
        rerere.enabled = true;
        status.showUntrackedFiles = "all";
        status.submoduleSummary = true;
        tag.gpgsign = true;
        tag.sort = "version:refname";
        url."git@github.com:".insteadOf = "gh:";
        url."git@github.com:YoungAgency".insteadOf = "https://github.com/YoungAgency";
        url."git@github.com:samirettali".insteadOf = "https://github.com/samirettali";
        url."git@github.com:samirettali/".insteadOf = "se:";
        user.signingkey = "${config.home.homeDirectory}/.ssh/github.pub";
      };
      ignores = [
        "*.env"
        ".DS_Store"
        ".env*"
        ".idea"
        ".opencode"
        "/target"
        "Session.vim"
        "__debug_bin*"
        "node_modules"
        "__pycache__"
        ".crush"
        ".claude"
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
        {
          condition = "gitdir:~/proj";
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
