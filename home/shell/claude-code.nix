{
  pkgs,
  lib,
  ...
}: let
  exe = lib.getExe pkgs.claude-code;
in {
  home.packages = with pkgs; [
    claude-code
  ];

  home.activation.setupClaudeCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${exe} mcp remove context7 > /dev/null
    ${exe} mcp add --transport http context7 https://mcp.context7.com/mcp > /dev/null
  '';

  # TODO: https://docs.anthropic.com/en/docs/claude-code/settings
  home.file = {
    ".claude/settings.json".text = builtins.toJSON {
      statusLine = {
        type = "command";
        command = "bunx ccusage statusline";
      };
      includeCoAuthoredBy = false;
      env = {
        CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = "1";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
      };
    };
  };
}
