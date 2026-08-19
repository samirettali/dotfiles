You are on my work Mac. Company policy forbids Nix here, so nothing in this
repo is applied by home-manager on this machine.

- Homebrew installs the tools; chezmoi copies the configuration from
  `~/dev/dotfiles/chezmoi`. Every file is a plain writable copy, not a symlink.
- A file you edit here is lost at the next `chezmoi apply`. Run `chezmoi diff`
  before applying, and `chezmoi add <file>` to keep an edit.
- Keep anything company-specific out of `~/dev/dotfiles`.
- Work repositories are the job here: commit, push and open the pull request
  when I ask for it. Never on your own initiative.
