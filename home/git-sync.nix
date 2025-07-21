{
  config,
  pkgs,
  ...
}: let
  toYAML = obj: let
    jsonStr = builtins.toJSON obj;
  in
    builtins.readFile (pkgs.runCommand "json-to-yaml" {
        buildInputs = [pkgs.yj];
      } ''
        echo '${jsonStr}' | yj -jy > $out
      '');
in {
  # TODO: install only if git is enabled
  home.packages = with pkgs; [
    (buildGoModule {
      pname = "git-sync";
      version = "0.19.0";
      src = fetchFromGitHub {
        owner = "AkashRajpurohit";
        repo = "git-sync";
        rev = "v0.19.0";
        sha256 = "sha256-MHr4X8bPrbm9YxBSWJ9bHCChlcMFTsUPDliPVzlUFZY=";
      };
      vendorHash = "sha256-VJLdAkONyJiyQTtrZ9xwVXTqpkbHsIbVgOAu2RA62ao=";
    })
  ];
  home.file.".config/git-sync/config.yaml".text = toYAML {
    backup_dir = "${config.home.homeDirectory}/git";
    clone_type = "full";
    include_wiki = true;
    concurrency = 5;
    retry = {
      count = 3;
      delay = 5;
    };
    raw_git_urls = [
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
    ];
  };
}
