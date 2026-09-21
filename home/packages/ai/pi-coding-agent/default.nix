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
  piAutoresearch = pkgs.runCommand "pi-autoresearch-manual-skills" {nativeBuildInputs = [pkgs.yq-go];} ''
    mkdir -p $out
    cp -R ${inputs.pi-autoresearch}/. $out/
    chmod -R u+w $out
    for skill in autoresearch-create autoresearch-finalize autoresearch-hooks; do
      yq --front-matter=process -i '."disable-model-invocation" = true' "$out/skills/$skill/SKILL.md"
    done
  '';

  # Matched by pname: herdr ships patched, so it is not the nurPkgs derivation.
  herdrEnabled = lib.any (p: (p.pname or "") == "herdr") config.home.packages;

  modelsConfig = builtins.fromJSON (builtins.readFile ./models.json);

  skills = import ../coding-agent-skills.nix {inherit inputs pkgs;};
  skillFiles =
    lib.mapAttrs'
    (name: src: lib.nameValuePair ".pi/agent/skills/${name}" {source = src;})
    (builtins.removeAttrs skills ["x-search"]);
  enabled = config.programs.pi-coding-agent.enable;
in {
  programs.pi-coding-agent = {
    enable = true;
    package = piCodingAgent;

    settings = {
      packages = [
        "${piMcpAdapter}"
        "${piAutoresearch}"
      ];
      theme = "light/dark";
      quietStartup = true;
      hideThinkingBlock = false;
      defaultProvider = "openrouter";
      defaultModel = "deepseek/deepseek-v4.1-flash";
      defaultThinkingLevel = "medium";
      inherit (modelsConfig) enabledModels;
      tuiMode = "fullscreen";
    };

    models = {inherit (modelsConfig) providers;};

    keybindings = {
      "tui.altScreen.halfPageUp" = "ctrl+u";
      "tui.altScreen.halfPageDown" = "ctrl+d";
    };
  };

  home.sessionVariables = lib.mkIf enabled ({
      PI_PACKAGE_DIR = "${config.home.homeDirectory}/.pi/pi-source";
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
      PI_AI_MODULE_PATH = piNodeModules + "/@earendil-works/pi-ai/dist/index.js";
      PI_AI_OAUTH_MODULE_PATH = piNodeModules + "/@earendil-works/pi-ai/dist/oauth.js";
    }
    // lib.optionalAttrs herdrEnabled {
      HERDR_TITLE_PROVIDER = "openai-codex";
      HERDR_TITLE_MODEL = "gpt-5.6-luna";
    });

  home.file = lib.mkIf enabled (skillFiles
    // {
      ".pi/pi-source".source = piPackageDir;

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
      ".pi/agent/extensions/prompt-snippets".source = ./extensions/prompt-snippets;
      ".pi/agent/extensions/speak.ts".source = ./extensions/speak.ts;
      ".pi/agent/extensions/system-prompt.ts".source = ./extensions/system-prompt.ts;
      ".pi/agent/extensions/theme.ts".source = ./extensions/theme.ts;
      ".pi/agent/extensions/x-search.ts".source = ./extensions/x-search.ts;

      ".pi/agent/extensions/node_modules/@earendil-works/pi-coding-agent".source = piRuntimeRoot;
      ".pi/agent/extensions/node_modules/@earendil-works/pi-ai".source = piNodeModules + "/@earendil-works/pi-ai";
      ".pi/agent/extensions/node_modules/@earendil-works/pi-tui".source = piNodeModules + "/@earendil-works/pi-tui";
      ".pi/agent/extensions/node_modules/typebox".source = piNodeModules + "/typebox";
      ".pi/agent/extensions/node_modules/@types/node".source = piNodeModules + "/@types/node";
    }
    // lib.optionalAttrs herdrEnabled {
      ".pi/agent/extensions/herdr-agent-state.ts" = {
        source = "${inputs.herdr-fork}/src/integration/assets/pi/herdr-agent-state.ts";
        force = true;
      };
      ".pi/agent/extensions/herdr-session-title.ts".source = ./extensions/herdr-session-title.ts;
    });
}
