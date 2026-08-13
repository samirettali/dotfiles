{
  nurPkgs,
  lib,
  ...
}: {
  programs.opencode = {
    enable = lib.mkDefault false;
    package = nurPkgs.opencode;
    enableMcpIntegration = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      autoshare = false;
      autoupdate = false;
      theme = "opencode";
      model = "github-copilot/claude-sonnet-4.6";
      small_model = "github-copilot/claude-haiku-4.5";
    };
  };
}
