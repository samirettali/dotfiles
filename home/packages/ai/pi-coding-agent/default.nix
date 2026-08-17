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

  # Matched by pname: herdr ships patched, so it is not the nurPkgs derivation.
  herdrEnabled = lib.any (p: (p.pname or "") == "herdr") config.home.packages;

  modelsConfig = builtins.fromJSON (builtins.readFile ./models.json);

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
      # Disabled while trying pi-automode.
      # PI_PERMS_MODE = "auto";
      # PI_PERMS_PROVIDER = "openai-codex";
      # PI_PERMS_MODEL = "gpt-5.6-luna";
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
        theme = "light/dark";
        quietStartup = true;
        hideThinkingBlock = false;
        defaultProvider = "openai-codex";
        defaultModel = "gpt-5.6-sol";
        defaultThinkingLevel = "medium";
        enabledModels = modelsConfig.enabledModels;
        tuiMode = "fullscreen";
        autoMode = {
          enabled = false;
        };
      };

      ".pi/agent/models.json".text = builtins.toJSON {
        inherit (modelsConfig) providers;
      };

      ".pi/agent/keybindings.json".text = builtins.toJSON {
        "tui.altScreen.halfPageUp" = "ctrl+u";
        "tui.altScreen.halfPageDown" = "ctrl+d";
      };

      ".pi/agent/automode.json".text = builtins.toJSON {
        autoMode = {
          enabled = true;
          classifierModel = "openai-codex/gpt-5.6-luna";
          classifierReasoningLevel = "low";
          # In-tree file work skips the classifier; out-of-tree access is classified.
          allowInsideWorkingDirectory = true;
          # Hard-denied for the file tools, reads included.
          deniedPaths = [
            "~/.ssh/*"
            "~/Library/Application Support/rbw/*"
            "~/.pi/agent/auth.json"
            "**/.env"
            "**/.env.*"
          ];
          environment = ["$defaults"];
          allow = ["$defaults"];
          protectedPaths = ["$defaults"];
          soft_deny = ["$defaults"];
          hard_deny = ["$defaults"];
        };
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
      # Superseded by pi-automode while it is on trial.
      # ".pi/agent/extensions/permission-gate.ts".source = ./extensions/permission-gate.ts;
      # ".pi/agent/extensions/protected-paths.ts".source = ./extensions/protected-paths.ts;
      ".pi/agent/extensions/auto-mode.ts".source = "${inputs.pi-automode}/extensions/auto-mode.ts";
      ".pi/agent/extensions/auto-mode".source = "${inputs.pi-automode}/extensions/auto-mode";
      ".pi/agent/extensions/speak.ts".source = ./extensions/speak.ts;
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
