{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    claude-code
  ];

  # TODO: https://docs.anthropic.com/en/docs/claude-code/settings
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      statusLine = {
        type = "command";
        command = "bunx ccusage statusline";
      };
      includeCoAuthoredBy = false;
      mcpServers = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
        playwright = {
          type = "stdio";
          command = "npx";
          args = [
            "@playwright/mcp@latest"
          ];
          env = {
          };
        };
        ast-grep = {
          type = "stdio";
          command = "uvx";
          args = [
            "--from"
            "git+https://github.com/ast-grep/ast-grep-mcp"
            "ast-grep-server"
          ];
          env = {
          };
        };
      };
      env = {
        CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = "1";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_AUTOUPDATER = "1";
      };

      hooks = {
        Notification = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "afplay /System/Library/Sounds/Blow.aiff";
              }
            ];
          }
        ];
        Stop = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "afplay /System/Library/Sounds/Hero.aiff";
              }
            ];
          }
        ];
      };
    };
  };
}
