{
  pkgs,
  lib,
  ...
}: {
  # TODO: feedbackSurveyRate: 0
  programs.claude-code = {
    enable = lib.mkDefault true;
    settings = {
      includeCoAuthoredBy = false;
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
    hooks = {
      # Notification = lib.optionals pkgs.stdenv.isDarwin [
      #   {
      #     matcher = "";
      #     hooks = [
      #       {
      #         type = "command";
      #         command = "afplay /System/Library/Sounds/Blow.aiff";
      #       }
      #     ];
      #   }
      # ];
      # Stop = lib.optionals pkgs.stdenv.isDarwin [
      #   {
      #     matcher = "";
      #     hooks = [
      #       {
      #         type = "command";
      #         command = "afplay /System/Library/Sounds/Hero.aiff";
      #       }
      #     ];
      #   }
      # ];

      Notification = lib.optionals pkgs.stdenv.isDarwin ''
        #!/usr/bin/env bash
        afplay /System/Library/Sounds/Blow.aiff
      '';
      Stop = lib.optionals pkgs.stdenv.isDarwin ''
        #!/usr/bin/env bash
        afplay /System/Library/Sounds/Hero.aiff
      '';
    };
  };
}
