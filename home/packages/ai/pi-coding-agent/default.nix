{
  nurPkgs,
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  piCodingAgent = nurPkgs.pi-coding-agent;
  piPackageDir = piCodingAgent + "/share/pi-coding-agent";
  piRuntimeRoot = piCodingAgent + "/lib/node_modules/pi-monorepo";
  piNodeModules = piRuntimeRoot + "/node_modules";

  piMcpAdapter = nurPkgs.pi-mcp-adapter;
  piProviderKimiCode = nurPkgs.pi-provider-kimi-code;

  herdrEnabled = builtins.elem nurPkgs.herdr config.home.packages;

  skills = import ../coding-agent-skills.nix {inherit inputs pkgs;};
  skillFiles =
    lib.mapAttrs'
    (name: src: lib.nameValuePair ".pi/agent/skills/${name}" {source = src;})
    skills;
in {
  home.packages = [
    piCodingAgent
  ];

  home.sessionVariables = lib.mkIf (builtins.elem piCodingAgent config.home.packages) ({
      PI_PACKAGE_DIR = "${config.home.homeDirectory}/.pi/pi-source";
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
      PI_PERMS_MODE = "auto";
      PI_PERMS_PROVIDER = "openai-codex";
      PI_PERMS_MODEL = "gpt-5.6-luna";
      PI_AI_MODULE_PATH = piNodeModules + "/@earendil-works/pi-ai/dist/index.js";
      PI_AI_OAUTH_MODULE_PATH = piNodeModules + "/@earendil-works/pi-ai/dist/oauth.js";
    }
    // lib.optionalAttrs herdrEnabled {
      HERDR_TITLE_PROVIDER = "openai-codex";
      HERDR_TITLE_MODEL = "gpt-5.6-luna";
    });

  home.file = lib.mkIf (builtins.elem piCodingAgent config.home.packages) (skillFiles
    // {
      ".pi/pi-source".source = piPackageDir;

      ".pi/agent/settings.json".text = builtins.toJSON {
        packages = [
          "${piMcpAdapter}"
          "${piProviderKimiCode}"
        ];
        theme = "dark";
        hideThinkingBlock = false;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-5.6-sol";
        defaultThinkingLevel = "medium";
        enabledModels = [
          "openai-codex/gpt-5.6-sol"
          "openai-codex/gpt-5.6-terra"
          "openai-codex/gpt-5.6-luna"
          "kimi-coding/k3"
          "kimi-coding/k3-256k"
          "xai/grok-4.5"
          "openrouter/minimax/minimax-m3"
          "openrouter/qwen/qwen3.8-max"
          "openrouter/qwen/qwen3.7-plus"
          "openrouter/qwen/qwen3.7-flash"
          "openrouter/qwen/qwen3.6-35b-a3b"
          "openrouter/qwen/qwen3.6-27b"
          "openrouter/deepseek/deepseek-v4-pro"
          "openrouter/deepseek/deepseek-v4-flash-0731"
          "openrouter/z-ai/glm-5.2"
          "openrouter/anthropic/claude-fable-5"
          "openrouter/anthropic/claude-opus-5"
          "openrouter/anthropic/claude-sonnet-5"
          "openrouter/google/gemini-3.1-pro-preview"
          "openrouter/google/gemini-3.6-flash"
          "openrouter/google/gemini-3.5-flash-lite"
          "openrouter/xiaomi/mimo-v2.5"
          "openrouter/tencent/hy3"
          "openrouter/stepfun/step-3.7-flash"
          "openrouter/thinkingmachines/inkling"
          "openrouter/thinkingmachines/inkling-small"
        ];
      };

      ".pi/agent/extensions/package.json".text = builtins.toJSON {
        name = "pi-agent-extensions";
        private = true;
        type = "module";
      };

      ".pi/agent/extensions/tsconfig.json".text = builtins.toJSON {
        compilerOptions = {
          target = "ES2022";
          module = "NodeNext";
          moduleResolution = "NodeNext";
          strict = true;
          noEmit = true;
          skipLibCheck = true;
          types = ["node"];
        };
        include = ["./**/*.ts"];
        exclude = ["./node_modules"];
      };

      ".pi/agent/extensions/ask-user-question.ts".source = ./extensions/ask-user-question.ts;
      ".pi/agent/extensions/permission-gate.ts".source = ./extensions/permission-gate.ts;
      ".pi/agent/extensions/protected-paths.ts".source = ./extensions/protected-paths.ts;
      ".pi/agent/extensions/system-prompt.ts".source = ./extensions/system-prompt.ts;
      ".pi/agent/extensions/x-search.ts".source = ./extensions/x-search.ts;

      ".pi/agent/extensions/node_modules/@earendil-works/pi-coding-agent".source = piRuntimeRoot;
      ".pi/agent/extensions/node_modules/@earendil-works/pi-ai".source = piNodeModules + "/@earendil-works/pi-ai";
      ".pi/agent/extensions/node_modules/@earendil-works/pi-tui".source = piNodeModules + "/@earendil-works/pi-tui";
      ".pi/agent/extensions/node_modules/typebox".source = piNodeModules + "/typebox";
      ".pi/agent/extensions/node_modules/@sinclair/typebox".source = piNodeModules + "/@sinclair/typebox";
      ".pi/agent/extensions/node_modules/@types/node".source = piNodeModules + "/@types/node";
    }
    // lib.optionalAttrs herdrEnabled {
      ".pi/agent/extensions/herdr-session-title.ts".source = ./extensions/herdr-session-title.ts;
    });
}
