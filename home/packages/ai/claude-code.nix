{
  lib,
  inputs,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = lib.mkDefault true;
    # tmux names panes after the resolved executable, which would be the
    # `.claude-wrapped` binary makeBinaryWrapper leaves behind.
    #
    # The extra wrapper adds `--allow-dangerously-skip-permissions`, which only
    # makes `bypassPermissions` reachable in the shift+tab cycle without
    # enabling it by default. There is no settings.json equivalent: the cycle
    # checks a session flag that only these CLI flags set.
    package = pkgs.claude-code.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mkdir -p $out/libexec
          mv $out/bin/.claude-wrapped $out/libexec/claude
          ln -s ../libexec/claude $out/bin/.claude-wrapped
          mv $out/bin/claude $out/libexec/claude-env
          makeBinaryWrapper $out/libexec/claude-env $out/bin/claude \
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
      tui = "fullscreen";
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
