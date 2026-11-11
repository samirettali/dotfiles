# The live MEV bots (~/dev/mevbot; its AGENTS.md has the runbook): mainnet's
# (mevbot) and Arc's (mevbot-arc, #67), each from its own script in the same
# checkout. The scripts read their keys at start, and stop with a status the
# unit does not restart when they cannot. The alerts in servers notice.
# mevbot-settings holds no key: it serves the settings' site,
# mevbot.samirettali.com, over the live bot's control socket, and a change to
# it does not touch the bot.
# servers scrapes it at orion:9467 and alerts after 5 minutes without an answer.
{
  config,
  lib,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
  # systemd's own lines on a unit (an OOM kill, a timeout, a crash with no
  # panic) stay in the journal, which Vector does not read and which drops
  # its oldest files by size. ExecStopPost runs this, its stdout is the unit's log
  # file, so that Loki keeps how each run ended, as mevbot-index's
  # --stopped does in servers. A clean stop is SERVICE_RESULT=success;
  # anything else is an error.
  stopped = pkgs.writeShellScript "mevbot-stopped" ''
    level=ERROR
    if [ "$SERVICE_RESULT" = success ]; then level=INFO; fi
    printf '{"time":"%s","level":"%s","msg":"stopped: result=%s code=%s status=%s","result":"%s","code":"%s","status":"%s"}\n' \
      "$(${pkgs.coreutils}/bin/date -u +%Y-%m-%dT%H:%M:%S.%NZ)" "$level" \
      "''${SERVICE_RESULT:-?}" "''${EXIT_CODE:-?}" "''${EXIT_STATUS:-?}" \
      "''${SERVICE_RESULT:-?}" "''${EXIT_CODE:-?}" "''${EXIT_STATUS:-?}"
  '';
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
      # How the run ended, into the log file (stopped above); "-" so that
      # its failure never fails the unit.
      ExecStopPost = "-${stopped}";
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
  # The site's reads must never slow the bot down (mevbot#637): under
  # contention mevbot-settings gets a fifth of mevbot's CPU share. The user
  # manager has the cpu controller delegated; it lacks io, and orion's NVMe
  # disks have no I/O scheduler, so IOWeight would do nothing.
  systemd.user.services.mevbot-settings = lib.recursiveUpdate (bot "mevbot settings bridge" "settings-http" "mevbot-settings.jsonl") {
    Service = {
      CPUWeight = 20;
      Nice = 10;
    };
  };

  # systemd creates the log file but not its directory, which a new host
  # (orion) lacks: the unit would fail with 209/STDOUT.
  home.activation.mevbotLogs = lib.hm.dag.entryBetween ["reloadSystemd"] ["writeBoundary"] ''
    run mkdir -p ${home}/.local/state/logs
  '';
}
