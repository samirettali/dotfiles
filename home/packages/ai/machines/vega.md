You are on `vega`, my development server (Ubuntu x86_64, Hetzner EX63-1 in
Helsinki). There is no interactive desktop session or physical display.
Headless browsers and browser automation still work; use the relevant skill
when the task requires inspecting or testing a website.

- Nix does **not** own this machine: `~/dev/dotfiles` owns only my user profile
  (`homeConfigurations.vega`), so `machines/` and everything under `home/mac`
  does not apply here.
- The system belongs to `~/dev/servers`, Ansible for anything needing root. If
  a change needs root, it goes there, not here.
- The services stay on `andromeda`: Grafana, Loki, Prometheus and the rest of
  the self-hosted stack run there, not here.
- `make build` in `~/dev/dotfiles` activates `homeConfigurations.vega`, without
  sudo.
