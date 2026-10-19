# orion: mevbot's Ethereum node and, from the cutover, the live bot
# (~/dev/mevbot, AGENTS.md "Live"). What the bot's unit needs and the basics
# of a shell over SSH. No agents: they would be most of the profile, and
# nothing run on orion needs them.
{pkgs, ...}: {
  imports = [
    ./dotfiles.nix
    ./linux-shell.nix
    ./options.nix
    ./packages/dev/go.nix
    ./packages/shell/btop.nix
    ./packages/shell/direnv.nix
    ./packages/shell/fd.nix
    ./packages/shell/jq.nix
    ./packages/shell/neovim.nix
    ./packages/shell/ripgrep.nix
  ];

  # make for the unit's build (scripts/live runs `make build`), sqlite3 for
  # the cache. git is Ubuntu's.
  home.packages = with pkgs; [
    gnumake
    sqlite
  ];

  # orion has no C compiler, and the bot needs none: its SQLite is pure Go,
  # and go-ethereum signs with its pure-Go secp256k1 without cgo.
  home.sessionVariables.CGO_ENABLED = "0";

  # scripts/live reads the node on this host instead of Alchemy. Arc's bot
  # has no node of its own (scripts/live-arc).
  systemd.user.services.mevbot.Service.Environment = [
    "MEVBOT_NODE=127.0.0.1"
    "CGO_ENABLED=0"
  ];
  systemd.user.services.mevbot-arc.Service.Environment = ["CGO_ENABLED=0"];
}
