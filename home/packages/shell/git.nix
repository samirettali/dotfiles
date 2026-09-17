{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  exe = "${lib.getExe config.programs.git.package}";
  # Every SSH key the account signs with, so a commit from any machine verifies
  # on all of them. Refresh with:
  #   gh api users/samirettali/ssh_signing_keys --jq '.[] | .key'
  signingKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUb2sSBUVrFo1qrBNJka1lVoT63PXsl0oOoBhIQiw36"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTS4qYl2b7qP/0LoWBIXv1Z4evTjKzGvcolWGoT2IZj"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK92kPwQJ+dmGtqwA6SEtoc5dLUnWxL69BxVt3ENZBs0"
  ];

  # Both identities: the work Mac signs as the company address.
  signingIdentities = [
    "samir@ettali.com"
    "s.ettali@young.business"
  ];

  allowedSigners =
    lib.concatMapStringsSep "\n"
    (identity:
      lib.concatMapStringsSep "\n"
      (key: "${identity} namespaces=\"git\" ${key}")
      signingKeys)
    signingIdentities;
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
      settings = {
        user = {
          inherit (vars) email;
          name = "Samir Ettali";
          signingkey = "${config.home.homeDirectory}/.ssh/github.pub";
        };
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
        diff.tool = "nvimdifftool";
        # Not the builtin nvimdiff: its -R marks the buffers readonly, which
        # warns on every launch and defeats the write-back of difftool -d.
        difftool.nvimdifftool.cmd = ''nvim -d "$LOCAL" "$REMOTE"'';
        difftool.prompt = false;
        fetch.all = true;
        fetch.prune = true;
        fetch.pruneTags = true;
        gpg.format = "ssh";
        # Signing needs no list; verifying a signature does. Without it, git has
        # nothing to check a commit against and refuses to report on it.
        gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        interactive.singlekey = true;
        log.date = "iso";
        merge.conflictStyle = "zdiff3";
        merge.tool = "nvimdiff";
        pull.rebase = true;
        push.autoSetupRemote = true;
        push.default = "simple";
        push.followtags = true;
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
      ];
      signing.format = "ssh";
    };
  };

  xdg.configFile."git/allowed_signers" = lib.mkIf config.programs.git.enable {
    text = allowedSigners + "\n";
  };
}
