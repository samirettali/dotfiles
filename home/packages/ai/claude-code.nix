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
in {
  # Herdr identifies agents by the pane's foreground process, which breaks as
  # soon as Claude spawns MCP servers. The hook reports the agent explicitly.
  home.file.".claude/hooks/herdr-agent-state.sh" = lib.mkIf herdrEnabled {
    source = ./claude-code-herdr-agent-state.sh;
  };

  programs.claude-code = {
    enable = lib.mkDefault true;
    package = pkgs.callPackage "${inputs.samirettali-nur}/pkgs/claude-code" {}; # TODO: fix
    enableMcpIntegration = true;
    skills = import ./coding-agent-skills.nix {inherit inputs pkgs;};
    outputStyles.lean = ./output-styles/lean.md;
    settings = {
      model = "claude-opus-5";
      includeCoAuthoredBy = false;
      # Remote Control sessions otherwise append a Claude-Session trailer to
      # every commit and a session link to every pull request body.
      attribution.sessionUrl = false;
      feedbackSurveyRate = 0;
      theme = "auto";
      effortLevel = "medium";
      skipDangerousModePermissionPrompt = true;
      tui = "fullscreen";
      permissions.defaultMode = "bypassPermissions";
      autoMemoryEnabled = false;
      disableClaudeAiConnectors = true;
      toolSearchEnabled = true;
      disableWorkflows = true;
      promptSuggestionEnabled = false;
      spinnerVerbs = {
        mode = "replace";
        verbs = ["Thinking" "Processing" "Working"];
      };
      spinnerTipsEnabled = false;
      outputStyle = "Lean";
      hooks =
        {
          PreToolUse = [
            {
              matcher = "Read|Bash";
              hooks = [
                {
                  type = "command";
                  command = "python3 '${guardHook}'";
                  timeout = 10;
                }
              ];
            }
          ];
        }
        // lib.optionalAttrs herdrEnabled {
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
