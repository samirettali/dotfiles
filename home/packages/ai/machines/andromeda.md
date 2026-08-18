You are on `andromeda`, my Linux server (Ubuntu ARM). There is no interactive
desktop session or physical display. Headless browsers and browser automation
still work; use the relevant skill when the task requires inspecting or testing
a website.

- Nix does **not** own this machine: this repo owns only my user profile
  (`homeConfigurations.andromeda`), so `machines/` and everything under
  `home/mac` and `home/linux/desktop` do not apply here.
- The system and the services belong to `~/dev/servers` — Ansible for anything
  needing root, Docker Compose for the containers. If a change needs root, it
  goes there, not here.
- `make build` is not the darwin rebuild: activation goes through
  `nix build .#homeConfigurations.andromeda.activationPackage`.
