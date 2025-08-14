{
  pkgs,
  lib,
  ...
}: let
  notification = pkgs.writeShellScriptBin "claude-code-notification" ''
    INPUT=$(cat)
    SESSION_DIR=$(basename "$(pwd)")
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
    if [ -f "$TRANSCRIPT_PATH" ]; then
        MSG=$(tail -10 "$TRANSCRIPT_PATH" | \
              jq -r 'select(.message.role == "assistant") | .message.content[0].text' | \
              tail -1 | \
              tr '\n' ' ' | \
              cut -c1-60)

        MSG=''${MSG:- "Task completed"}
    else
        MSG="Task completed"
    fi

    osascript -e "display notification \"$MSG\" with title \"ClaudeCode ($SESSION_DIR) Task Done\" sound name \"Funk\""
  '';
in {
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
      };

      hooks = {
        Notification = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "bash ${lib.getExe notification}";
              }
            ];
          }
        ];
      };
    };
  };
}
