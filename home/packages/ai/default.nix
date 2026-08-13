{nurPkgs, ...}: {
  imports = [
    ./agents.nix
    ./antigravity-cli.nix
    ./claude-code.nix
    ./codex.nix
    ./fabric.nix
    ./mcp.nix
    ./opencode.nix
    ./pi-coding-agent
    ./skill-scripts.nix
  ];

  home.packages = [
    nurPkgs.grok-cli
  ];
}
