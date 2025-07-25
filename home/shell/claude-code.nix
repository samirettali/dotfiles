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
}
