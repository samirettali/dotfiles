{pkgs, ...}: {
  home.packages = [
    (pkgs.stdenv.mkDerivation rec {
      pname = "opencode";
      version = "0.1.117";

      src = pkgs.fetchurl {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-${
          if pkgs.stdenv.isDarwin
          then "darwin"
          else "linux"
        }-${
          if pkgs.stdenv.isAarch64
          then "arm64"
          else "x64"
        }.zip";
        sha256 = "sha256-ofj8eCmqyPosXg3fwOg1Bxc1KDQuPpIy5H0kCgJpIk8="; # TODO: this works only on darwin arm64
      };

      nativeBuildInputs = [pkgs.unzip];

      unpackPhase = ''
        unzip $src
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp opencode $out/bin/
        chmod +x $out/bin/opencode
      '';

      meta = with pkgs.lib; {
        description = "AI coding agent, built for the terminal";
        changelog = "https://github.com/sst/opencode/releases/tag/v${version}";
        homepage = "https://opencode.ai";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    })
  ];

  home.file.".config/opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    theme = "opencode";
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
    # TODO: setting mpcs break opencode somehow
    # mcp = {
    #   context7 = {
    #     type = "remote";
    #     url = "https://mcp.context7.com/mcp";
    #   };
    # stagehand = {
    #   type = "local";
    #   command = [
    #     "bun"
    #     "/Users/s.ettali/proj/mcp-server-browserbase/stagehand/dist/index.js"
    #   ];
    # };
    # };
  };
}
