{nurPkgs, ...}: {
  imports = [
    ./agents-memory.nix
    ./antigravity-cli.nix
    ./claude-code.nix
    ./codex.nix
    ./fabric.nix
    ./mcp.nix
    ./opencode.nix
    ./pi-coding-agent
  ];

  home.packages = [
    nurPkgs.grok-cli
  ];
}
