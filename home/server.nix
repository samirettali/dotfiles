{
  imports = [
    ./dotfiles.nix
    ./options.nix
    ./packages/dev/c.nix
    ./packages/dev/go.nix
    ./packages/dev/js.nix
    ./packages/dev/python.nix
    ./packages/shell
    ./packages/desktop/google-chrome.nix
  ];

  dotfiles.programs = {
    ansible.enable = false;
    git-sync.enable = false;
  };

  # Andromeda-only projects, appended to the global agent memory. Details live in
  # each repo's own AGENTS.md; these are just breadcrumbs.
  dotfiles.agentsMemory.extra = ''
    - **sottocasa** — `~/dev/sottocasa`. Multi-tenant booking product (Go API +
      React owner panel). Dev runs on this host (air + pnpm dev), served
      tailnet-only at https://sottocasa-dev.samirettali.com via the side-projects
      proxy. ZITADEL identity managed by OpenTofu under infra/.
    - **side-projects** — `~/dev/side-projects`. Small personal projects plus the
      shared tailnet-only Caddy that fronts host-run dev servers at
      *.samirettali.com. Deployed by the selfhosted Ansible playbook.
  '';

  programs.fish.enable = false;
}
