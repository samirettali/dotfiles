{
  pkgs,
  samirettali-nur,
  config,
  ...
}: let
in {
  programs.opencode = {
    enable = true;
    package = samirettali-nur.packages.${pkgs.system}.opencode;
    enableMcpIntegration = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      autoshare = false;
      autoupdate = false;
      theme = "opencode";
      model = "github-copilot/claude-sonnet-4.5";
      small_model = "github-copilot/claude-haiku-4.5";
      provider = {
        openrouter = {
          npm = "@openrouter/ai-sdk-provider";
          name = "OpenRouter";
          options = {
            apiKey = "{file:${config.sops.secrets.openrouter_api_key.path}}";
          };
        };
      };
      agent = {
        code-reviewer = {
          description = "Reviews code for best practices and potential issues";
          model = "github-copilot/claude-sonnet-4.5";
          prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
          tools = {
            write = false;
            edit = false;
          };
        };
      };
    };
  };
}
