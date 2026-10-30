{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./dotfiles.nix
    ./linux-shell.nix
    ./options.nix
    ./packages/dev/c.nix
    ./packages/dev/go.nix
    ./packages/dev/headless-browser.nix
    ./packages/dev/js.nix
    ./packages/dev/python.nix
    ./packages/shell
  ];

  dotfiles.programs = {
    ansible.enable = false;
    git-sync.enable = false;
  };

  programs.fish.enable = false;

  home.sessionVariables.KIMI_MEMBERSHIP_LEVEL = "moderato";

  # The agents' worktrees add about 10 GB an hour to Go's build cache, on
  # the root; mevbot's script keeps it to 10 GiB (its docs/disk.md).
  systemd.user.services.go-cache-trim = {
    Unit.Description = "Trim Go's build cache";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils pkgs.findutils pkgs.go]}";
      ExecStart = "${pkgs.bash}/bin/bash %h/dev/mevbot/scripts/go-cache-trim.sh";
    };
  };
  systemd.user.timers.go-cache-trim = {
    Unit.Description = "Trim Go's build cache every 10 minutes";
    Timer.OnCalendar = "*:0/10";
    Install.WantedBy = ["timers.target"];
  };
}
