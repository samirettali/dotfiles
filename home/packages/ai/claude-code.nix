{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  herdrHook = "${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh";
  # Matched by pname: herdr ships patched, so it is not the nurPkgs derivation.
  herdrEnabled = lib.any (p: (p.pname or "") == "herdr") config.home.packages;
  # The status line prints nothing: its job is to hand Claude Code's own rate
  # limits to the Sketchybar usage widget, which must not call the usage
  # endpoint itself. See docs/sketchybar.md.
  sketchybarEnabled = lib.attrByPath ["programs" "sketchybar" "enable"] false config;
  usageStatusLine = pkgs.writeShellScriptBin "claude-usage-statusline" ''
    ${lib.optionalString sketchybarEnabled ''export SKETCHYBAR=${lib.getExe config.programs.sketchybar.package}''}
    exec ${pkgs.python3}/bin/python3 ${./claude-usage-statusline.py}
  '';
in {
  # Herdr identifies agents by the pane's foreground process, which breaks as
  # soon as Claude spawns MCP servers. The hook reports the agent explicitly.
  home.file.".claude/hooks/herdr-agent-state.sh" = lib.mkIf herdrEnabled {
    source = "${inputs.herdr-fork}/src/integration/assets/claude/herdr-agent-state.sh";
    executable = true;
  };

  programs.claude-code = {
    enable = lib.mkDefault true;
    package = pkgs.callPackage "${inputs.samirettali-nur}/pkgs/claude-code" {}; # TODO: fix
    enableMcpIntegration = true;
    # Only Claude Code can sign in to claude.ai, which Claude Design needs.
    mcpServers.claude-design.url = "https://api.anthropic.com/v1/design/mcp";
    skills = import ./coding-agent-skills.nix {inherit inputs pkgs;};
    settings = {
      model = "claude-opus-5-5";
      effortLevel = "high";
      attribution.commit = "";
      attribution.pr = "";
      # Remote Control sessions otherwise append a Claude-Session trailer to
      # every commit and a session link to every pull request body.
      attribution.sessionUrl = false;
      theme = "auto";
      skipDangerousModePermissionPrompt = true;
      tui = "fullscreen";
      permissions.defaultMode = "bypassPermissions";
      # a denied tool is dropped from the model's tool list, not only refused
      # pkill -f and killall match other sessions' processes, and the shell
      # running them; this is the rule from agents.md, enforced.
      permissions.deny = ["ReportFindings" "Bash(pkill:*)" "Bash(killall:*)"];
      # Artifact has its own switch (also drops the artifact-* skills)
      enableArtifact = false;
      autoMemoryEnabled = false;
      disableClaudeAiConnectors = true;
      disableWorkflows = true;
      cleanupPeriodDays = 3650;
      # bundled skills: "user-invocable-only" leaves the model's prompt but
      # keeps /name, "off" removes both; dataviz stays, it must self-trigger
      skillOverrides = {
        claude-api = "user-invocable-only";
        init = "user-invocable-only";
        loop = "user-invocable-only";
        run = "user-invocable-only";
        security-review = "user-invocable-only";
        simplify = "user-invocable-only";
        fewer-permission-prompts = "off";
        keybindings-help = "off";
        schedule = "off";
        update-config = "off";
      };
      promptSuggestionEnabled = false;
      spinnerVerbs = {
        mode = "replace";
        verbs = ["Thinking" "Processing" "Working"];
      };
      spinnerTipsEnabled = false;
      outputStyle = "Concise";
      statusLine = {
        type = "command";
        command = lib.getExe usageStatusLine;
      };
      hooks = lib.optionalAttrs herdrEnabled {
        SessionStart = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "bash '${herdrHook}' session";
                timeout = 10;
              }
            ];
          }
        ];
      };
      env = {
        CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = "1";
        # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"; # TODO
        # DISABLE_TELEMETRY = "1";
        DISABLE_ERROR_REPORTING = "1";
        DISABLE_FEEDBACK_COMMAND = "1";
        CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
        DISABLE_AUTOUPDATER = "1";
        ENABLE_TOOL_SEARCH = "true";
      };
    };
  };
}
