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
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      autoshare = false;
      autoupdate = false;
      theme = "opencode";
      model = "anthropic/claude-sonnet-4-5";
      small_model = "anthropic/claude-haiku-4-5";
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
          model = "anthropic/claude-sonnet-4-5-20250929";
          prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
          tools = {
            write = false;
            edit = false;
          };
        };
      };
      mcp = {
        # context7 = {
        #   enabled = true;
        #   type = "remote";
        #   url = "https://mcp.context7.com/mcp";
        # };
        # playwright = {
        #   enabled = true;
        #   type = "local";
        #   command = [
        #     "npx"
        #     "@playwright/mcp@latest"
        #   ];
        # };
        # ast-grep = {
        #   enabled = true;
        #   type = "local";
        #   command = [
        #     "uvx"
        #     "--from"
        #     "git+https://github.com/ast-grep/ast-grep-mcp"
        #     "ast-grep-server"
        #   ];
        # };
      };
    };
  };
}
