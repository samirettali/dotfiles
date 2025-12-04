{...}: {
  programs.gemini-cli = {
    enable = true;
    settings = {
      preferredEditor = "vim";
      vimMode = true;
      previewFeatures = true;
      checkpointing = {
        enabled = true;
      };
      hideTips = false;
      hideBanner = false;
      usageStatisticsEnabled = false;
      telemetry = {
        enabled = false;
      };
      # contextFileName = "AGENTS.md";
      selectedAuthType = "oauth-personal";
    };
  };
}
