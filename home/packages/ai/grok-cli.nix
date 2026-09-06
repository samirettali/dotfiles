{
  config,
  lib,
  nurPkgs,
  pkgs,
  ...
}: let
  # Matched by pname: herdr ships patched, so it is not the nurPkgs derivation.
  herdrEnabled = lib.any (p: (p.pname or "") == "herdr") config.home.packages;
  herdrHook = "${config.home.homeDirectory}/.grok/hooks/herdr-agent-state.sh";

  tomlFormat = pkgs.formats.toml {};

  # Grok's option names match `programs.mcp.servers`, but its TOML parser
  # rejects the nulls and empty collections the module leaves behind.
  pruned = lib.filterAttrs (
    _: value:
      value != null && value != [] && value != {}
  );

  mcpServers =
    lib.mapAttrs (_: pruned)
    (lib.optionalAttrs config.programs.mcp.enable config.programs.mcp.servers);

  # Layer 2 of Grok's config: fleet defaults that ~/.grok/config.toml still
  # overrides, and the one file in ~/.grok that Grok itself never writes.
  managedConfig =
    {
      # Skills, rules and MCP servers come from ~/.claude; the hooks there are
      # Claude's copy of the herdr integration, and Grok has its own below.
      compat.claude.hooks = !herdrEnabled;
    }
    // lib.optionalAttrs (mcpServers != {}) {mcp_servers = mcpServers;};
in {
  home.packages = [nurPkgs.grok-cli];

  home.file = {
    ".grok/managed_config.toml".source =
      tomlFormat.generate "grok-managed-config.toml" managedConfig;

    ".grok/hooks/herdr-agent-state.sh" = lib.mkIf herdrEnabled {
      source = ./grok-herdr-agent-state.sh;
    };

    ".grok/hooks/herdr.json" = lib.mkIf herdrEnabled {
      source = (pkgs.formats.json {}).generate "grok-herdr-hook.json" {
        hooks.SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "sh '${herdrHook}' session";
                timeout = 10;
              }
            ];
          }
        ];
      };
    };
  };
}
