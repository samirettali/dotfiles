{
  config,
  lib,
  inputs,
  nurPkgs,
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
    # tmux and herdr name panes after the process, which would be the
    # `.claude-wrapped` binary makeBinaryWrapper leaves behind.
    #
    # `--inherit-argv0` is what keeps the process named `claude`: the upstream
    # wrapper (now `claude-env`) already inherits argv0, so without it here the
    # whole chain reports `claude-env` and herdr stops detecting the agent.
    package = pkgs.claude-code.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mkdir -p $out/libexec
          mv $out/bin/.claude-wrapped $out/libexec/claude
          ln -s ../libexec/claude $out/bin/.claude-wrapped
          mv $out/bin/claude $out/libexec/claude-env
          makeBinaryWrapper $out/libexec/claude-env $out/bin/claude \
            --inherit-argv0 \
            --add-flags "--allow-dangerously-skip-permissions"
        '';
    });
    enableMcpIntegration = true;
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
    settings = {
      model = "claude-opus-5";
      includeCoAuthoredBy = false;
      feedbackSurveyRate = 0;
      theme = "auto";
      effortLevel = "medium";
      skipDangerousModePermissionPrompt = true;
      tui = "fullscreen";
      permissions.defaultMode = "bypassPermissions";
      autoMemoryEnabled = false;
      spinnerVerbs = {
        mode = "replace";
        verbs = ["Thinking" "Processing" "Working"];
      };
      hooks = lib.mkIf herdrEnabled {
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
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_TELEMETRY = "1";
        DISABLE_ERROR_REPORTING = "1";
        DISABLE_FEEDBACK_COMMAND = "1";
        CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
        DISABLE_AUTOUPDATER = "1";
      };
    };
  };
}
