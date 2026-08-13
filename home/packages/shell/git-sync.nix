{
  config,
  pkgs,
  lib,
  ...
}: let
  repos = [
    "https://github.com/ThePrimeagen/init.lua.git"
    "https://github.com/adibhanna/nvim.git"
    "https://github.com/jackfranklin/dotfiles.git"
    "https://github.com/karpathy/micrograd.git"
    "https://github.com/kristijanhusak/neovim-config.git"
    "https://github.com/mrnugget/dotfiles.git"
    "https://github.com/rubilmax/executooor.git"
    "https://github.com/samyk/samytools.git"
    "https://github.com/tinygrad/tinygrad.git"
    "https://github.com/tjdevries/config.nvim.git"
    "https://github.com/willothy/nvim-config.git"
    "https://github.com/wincent/wincent.git"
    "https://github.com/wincent/wincent-agent-plugins"
    "https://github.com/adomokos/Vim-Katas.git"
    "https://github.com/eatonphil/linearizability-playground.git"
    "https://github.com/RajaSrinivasan/assignments.git"
    "https://github.com/prakhar1989/awesome-courses.git"
    "https://github.com/mikker/dotfiles.git"
    "https://github.com/ossu/computer-science.git"
    "https://github.com/yangshun/tech-interview-handbook.git"
    "https://github.com/SylvanFranklin/.config.git"
    "https://github.com/elder-plinius/CL4R1T4S.git"
    "https://gitlab.com/usmcamp0811/dotfiles.git"
    "https://github.com/bluz71/dotfiles.git"
    "https://github.com/folke/dot.git"
    "https://github.com/neovim/neovim.git"
    "https://github.com/trimstray/the-book-of-secret-knowledge.git"
    "https://codeberg.org/gpanders/dotfiles.git"
  ];

  reposFile = pkgs.writeText "git-sync-repos" (lib.concatLines repos);

  git-sync = pkgs.writeShellScriptBin "git-sync" ''
    set -euo pipefail

    export PATH=${lib.makeBinPath [config.programs.git.package]}:"$PATH"

    exec ${pkgs.python3}/bin/python3 ${./scripts/git-sync.py} \
      --repos ${reposFile} \
      --dir ${config.home.homeDirectory}/ref \
      "$@"
  '';
in {
  home.packages = lib.mkIf (config.dotfiles.programs.git-sync.enable && config.programs.git.enable) [
    git-sync
  ];
}
