{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./dotfiles.nix
    ./shell
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "chrome";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    aider-chat
    nix-prefetch-github
    ollama
    (buildGoModule {
      pname = "git-sync";
      version = "latest";
      src = fetchFromGitHub {
        owner = "AkashRajpurohit";
        repo = "git-sync";
        rev = "main";
        sha256 = "sha256-HrcvhIUwEzyULNAKiCA7zq0QQFf0Y1VSxcs8vfZR33A=";
      };
      vendorHash = "sha256-H191WtXDbAD9z5XCgpgcZBwFLFMnVaoWF93ZOLgyrSs=";
    })
  ];

  # TODO: this does not work
  # services.ollama = {
  #   enable = true;
  #   host = "0.0.0.0";
  # };

  home.activation = {
    downloadOllamaModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # check if ~/.ollama-models-latest-pull contains a date more than 1 day old
      if [ -f ~/.ollama-models-latest-pull ] && [ $(($(date +%s) - $(date -r ~/.ollama-models-latest-pull +%s))) -lt 86400 ]; then
          echo "Not downloading ollama models"
      else
          # TODO: early return (exit stops the flake from being built)
          echo "Downloading ollama models"

          models=(
              deepseek-r1:8b
              llama3.1
              qwen2.5-coder
              hf.co/smirki/UIGEN-T1-Qwen-7b
              hf.co/SentientAGI/Dobby-Mini-Unhinged-Llama-3.1-8B_GGUF
          )

          for model in "''${models[@]}"; do
              echo "Downloading $model"
              $DRY_RUN_CMD ${pkgs.ollama}/bin/ollama pull $model
          done

          date +%s > ~/.ollama-models-latest-pull
      fi
    '';
  };
}
