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
    package = pkgs.claude-code.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mkdir -p $out/libexec
          mv $out/bin/.claude-wrapped $out/libexec/claude
          ln -s ../libexec/claude $out/bin/.claude-wrapped
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
