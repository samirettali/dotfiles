{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.claude-code = {
    enable = lib.mkDefault true;
    skills = {
      # https://github.com/nutlope/hallmark — anti-AI-slop design skill.
      # Pinned via the `hallmark` flake input; `nix flake update` bumps it.
      hallmark = "${inputs.hallmark}/skills/hallmark";
    };
    settings = {
      model = "claude-opus-4-8";
      includeCoAuthoredBy = false;
      feedbackSurveyRate = 0;
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
