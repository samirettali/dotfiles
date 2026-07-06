{
  lib,
  inputs,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = lib.mkDefault true;
    skills = import ./coding-agent-skills.nix {inherit inputs pkgs;};
    settings = {
      model = "claude-opus-4-8";
      includeCoAuthoredBy = false;
      feedbackSurveyRate = 0;
      theme = "auto";
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
