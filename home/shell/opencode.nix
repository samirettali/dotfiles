{
  pkgs,
  samirettali-nur,
  inputs,
  ...
}: let
  opencode = pkgs.callPackage ../../derivations/opencode.nix {
    source = inputs.opencode-src;
  };
in {
  programs.opencode = {
    enable = true;
    package = opencode;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      theme = "opencode";
      disabled_providers = ["google"];
      provider = {
        openrouter = {
          npm = "@openrouter/ai-sdk-provider";
          name = "OpenRouter";
          options = {};
          models = {
            "anthropic/claude-sonnet-4".name = "Claude Sonnet 4";
            "deepseek/deepseek-r1-0528".name = "Deepseek R1";
            "deepseek/deepseek-r1-distill-qwen-7b".name = "Deepseek R1 Qwen 7b";
            "google/gemini-2.5-flash".name = "Gemini 2.5 Flash";
            "google/gemini-2.5-flash-lite-preview-06-17".name = "Gemini 2.5 Flash Lite";
            "google/gemini-2.5-pro".name = "Gemini 2.5 Pro";
            "minimax/minimax-m1".name = "Minimax M1";
            "mistralai/devstral-small".name = "Mistral Devstral Small";
            "moonshotai/kimi-dev-72b:free".name = "Kimi Dev 72b";
            "openai/gpt-4.1".name = "OpenAI GPT 4.1";
            "openai/gpt-4.1-mini".name = "OpenAI GPT 4.1 Mini";
            "openai/o3".name = "OpenAI O3";
            "openai/o4-mini-high".name = "OpenAI O4 Mini High";
          };
        };
      };
      autoshare = false;
      autoupdate = false;
      # TODO: setting MPCs break opencode somehow
      # mcp = {
      #   context7 = {
      #     type = "remote";
      #     url = "https://mcp.context7.com/mcp";
      #   };
      #   stagehand = {
      #     type = "local";
      #     command = [
      #       "bun"
      #       "/Users/s.ettali/proj/mcp-server-browserbase/stagehand/dist/index.js"
      #     ];
      #   };
      # };
    };
  };
}
