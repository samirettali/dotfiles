{pkgs, ...}: {
  programs.gemini-cli = {
    enable = true;
    settings = {
      preferredEditor = "vim";
      vimMode = true;
      checkpointing = {
        enabled = true;
      };
      hideTips = true;
      hideBanner = true;
      usageStatisticsEnabled = false;
      telemetry = {
        enabled = false;
      };
      # contextFileName = "AGENTS.md";
      selectedAuthType = "oauth-personal";
      # mcpServers = {
      # context7 = {
      #   httpUrl = "https://mcp.context7.com/mcp";
      # };
      # };
    };
  };
}
