{vars, ...}: let
  hosts = {
    mbp = ''
      You are on `mbp`, my Mac (Apple silicon, nix-darwin). This is where I work.

      - The machine is mine and nix owns all of it: `make build` rebuilds it.
      - The GUI layer lives here — Hammerspoon, sketchybar, aerospace, Ghostty, Firefox.
      - `andromeda` is reachable over the tailnet: `ssh andromeda`.
    '';

    andromeda = ''
      You are on `andromeda`, my Linux server (Ubuntu ARM). There is no GUI, and no
      display to open anything on.

      - Nix does **not** own this machine: this repo owns only my user profile
        (`homeConfigurations.andromeda`), so `machines/` and everything under
        `home/mac` and `home/linux/desktop` do not apply here.
      - The system and the services belong to `~/dev/servers` — Ansible for anything
        needing root, Docker Compose for the containers. If a change needs root, it
        goes there, not here.
      - `make build` is not the darwin rebuild: activation goes through
        `nix build .#homeConfigurations.andromeda.activationPackage`.
    '';

    xps = ''
      You are on `xps`, my NixOS laptop. I barely use it, so assume nothing here is
      current. `make build` runs `nixos-rebuild switch`.
    '';
  };

  content =
    builtins.readFile ./agents.md
    + ''

      ## This machine

      ${hosts.${vars.hostname}}'';
in {
  home.file = {
    ".claude/CLAUDE.md".text = content;
    ".codex/AGENTS.md".text = content;
    ".pi/agent/AGENTS.md".text = content;
  };
}
