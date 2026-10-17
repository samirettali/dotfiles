# The live MEV bot (~/dev/mevbot; its AGENTS.md has the runbook). The script
# reads its keys at start, and stops with a status the unit does not restart
# when it cannot. The alerts in servers notice.
{
  config,
  lib,
  ...
}: {
  systemd.user.services.mevbot = {
    Unit = {
      Description = "mevbot live";
      # Ten starts in five minutes is a crash loop: the unit stops, and
      # Grafana's mevbot down pages. RestartSteps would back off, but its
      # count never resets while the unit runs, so a crash days later would
      # wait the longest delay too (systemd 255, measured 2026-10-15).
      StartLimitIntervalSec = 300;
      StartLimitBurst = 10;
    };
    Service = {
      WorkingDirectory = "${config.home.homeDirectory}/dev/mevbot";
      ExecStart = "${config.home.homeDirectory}/dev/mevbot/scripts/live";
      Environment = [
        "MEVBOT_SEND=1"
        "PATH=${config.home.profileDirectory}/bin:/usr/bin:/bin"
      ];
      Restart = "on-failure";
      RestartSec = 1;
      # Statuses a restart would meet again (the runbook lists them).
      RestartPreventExitStatus = "3 4 5";
      TimeoutStopSec = 30;
      # JSON lines, which Vector (servers) sends to Loki like every file in
      # that directory. Not rotated yet.
      StandardOutput = "append:${config.home.homeDirectory}/.local/state/logs/mevbot.jsonl";
      StandardError = "append:${config.home.homeDirectory}/.local/state/logs/mevbot.jsonl";
    };
    Install.WantedBy = ["default.target"];
  };

  # systemd creates the log file but not its directory, which a new host
  # (orion) lacks: the unit would fail with 209/STDOUT.
  home.activation.mevbotLogs = lib.hm.dag.entryBetween ["reloadSystemd"] ["writeBoundary"] ''
    run mkdir -p ${config.home.homeDirectory}/.local/state/logs
  '';
}
