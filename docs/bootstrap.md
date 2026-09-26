# Setting up a new Mac

The install steps link to upstream, which keeps its commands current.

1. Install Nix, following the macOS instructions at
   [nixos.org/download](https://nixos.org/download/).
2. Clone this repository to `~/dev/dotfiles`.
3. Install nix-darwin with this flake as its configuration, as in
   [Installing nix-darwin](https://github.com/nix-darwin/nix-darwin#step-2-installing-nix-darwin),
   passing `--flake ~/dev/dotfiles#mbp`.
4. From then on, `make build` rebuilds the machine.

## Set by hand

nix-darwin has no option for these, and macOS offers no stable command:

- Display resolution: the scaled "More Space" setting.
- Automatically adjust brightness: off.
- True Tone: off.
