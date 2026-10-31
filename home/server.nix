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

  # The governance watcher's file (mevbot #328), for Grafana's Governance
  # dashboard (servers). The directory is Grafana's mount, read-only there;
  # rsync's rename swaps the file whole.
  systemd.user.services.governance-sync = {
    Unit.Description = "Copy mevbot's governance.sqlite from orion";
    Service = {
      Type = "oneshot";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.rsync}/bin/rsync --times --timeout=60"
        "--rsh='${pkgs.openssh}/bin/ssh -p 38719 -i %h/.ssh/mevbot-node -o IdentitiesOnly=yes -o UserKnownHostsFile=%h/.ssh/known_hosts.mevbot-node -o BatchMode=yes -o ConnectTimeout=10'"
        "samir@orion:dev/mevbot/data/governance/governance.sqlite"
        "%h/volumes/liquidations/governance.sqlite"
      ];
    };
  };
  systemd.user.timers.governance-sync = {
    Unit.Description = "Copy mevbot's governance.sqlite from orion every 5 minutes";
    Timer.OnCalendar = "*:0/5";
    Install.WantedBy = ["timers.target"];
  };
}
