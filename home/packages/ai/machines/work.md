You are on my work Mac. Company policy forbids Nix here, so nothing in this
repo is applied by home-manager on this machine.

- Homebrew installs the tools; chezmoi copies the configuration from
  `~/dev/dotfiles/chezmoi`. Every file is a plain writable copy, not a symlink.
- A file you edit here is lost at the next `chezmoi apply`. Run `chezmoi diff`
  before applying, and `chezmoi add <file>` to keep an edit.
- Work code is not mine: never push, never open a pull request, and keep
  anything company-specific out of `~/dev/dotfiles`.
