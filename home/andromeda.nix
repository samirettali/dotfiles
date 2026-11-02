# What andromeda alone does on top of server.nix: it hosts Grafana.
{
  lib,
  pkgs,
  ...
}: {
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
