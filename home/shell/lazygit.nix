{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.lazygit = {
    enable = config.programs.git.enable;
    settings = {
      gui = {
        showBottomLine = false;
        autoForwardBranches = "none";
      };
      git = {
        overrideGpg = true;
        paging = {
          colorArg = "always";
        };
      };
      promptToReturnFromSubprocess = false;
      customCommands = [
        # TODO
        # {
        #   key = "B";
        #   output = "popup"; # or "terminal"
        #   context = "files";
        #   command = "git absorb --and-rebase"; # TODO: use --force flag but it's "dangerous"
        #   # command: "for b in upstream/main upstream/master origin/main origin/master origin/dev; do if git rev-parse --verify $b; then git absorb --force --and-rebase --base $b; break; fi; done"
        # }
      ];
    };
  };

  home.shellAliases = lib.mkIf config.programs.lazygit.enable {
    lg = lib.getExe pkgs.lazygit;
  };
}
