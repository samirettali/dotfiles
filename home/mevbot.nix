# The live MEV bot (~/dev/mevbot; its AGENTS.md has the runbook). The script
# reads its keys at start, and stops with a status the unit does not restart
# when it cannot. The alerts in servers notice.
{config, ...}: {
  systemd.user.services.mevbot = {
    Unit.Description = "mevbot live";
    Service = {
      WorkingDirectory = "${config.home.homeDirectory}/dev/mevbot";
      ExecStart = "${config.home.homeDirectory}/dev/mevbot/scripts/live";
      Environment = [
        # "MEVBOT_SEND=1"
        "PATH=${config.home.profileDirectory}/bin:/usr/bin:/bin"
      ];
      Restart = "on-failure";
      RestartSec = 30;
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
}
