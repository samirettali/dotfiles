{
  pkgs,
  lib,
  ...
}: {
  programs.claude-code = {
    enable = true;
    settings = {
      includeCoAuthoredBy = false;
      env = {
        CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = "1";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
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
