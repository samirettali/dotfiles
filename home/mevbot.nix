# The live MEV bots (~/dev/mevbot; its AGENTS.md has the runbook): mainnet's
# (mevbot) and Arc's (mevbot-arc, #67), each from its own script in the same
# checkout. The scripts read their keys at start, and stop with a status the
# unit does not restart when they cannot. The alerts in servers notice.
{
  config,
  lib,
  ...
}: let
  home = config.home.homeDirectory;
  bot = description: script: log: {
    Unit = {
      Description = description;
      # Ten starts in five minutes is a crash loop: the unit stops, and
      # Grafana's mevbot down pages. RestartSteps would back off, but its
      # count never resets while the unit runs, so a crash days later would
      # wait the longest delay too (systemd 255, measured 2026-10-15).
      StartLimitIntervalSec = 300;
      StartLimitBurst = 10;
    };
    Service = {
      WorkingDirectory = "${home}/dev/mevbot";
      ExecStart = "${home}/dev/mevbot/scripts/${script}";
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
      StandardOutput = "append:${home}/.local/state/logs/${log}";
      StandardError = "append:${home}/.local/state/logs/${log}";
    };
    Install.WantedBy = ["default.target"];
  };
in {
  systemd.user.services.mevbot = bot "mevbot live" "live" "mevbot.jsonl";
  systemd.user.services.mevbot-arc = bot "mevbot live on Arc" "live-arc" "mevbot-arc.jsonl";
  systemd.user.services.mevbot-gov = bot "mevbot governance watcher" "governance" "mevbot-gov.jsonl";

  # systemd creates the log file but not its directory, which a new host
  # (orion) lacks: the unit would fail with 209/STDOUT.
  home.activation.mevbotLogs = lib.hm.dag.entryBetween ["reloadSystemd"] ["writeBoundary"] ''
    run mkdir -p ${home}/.local/state/logs
  '';
}
