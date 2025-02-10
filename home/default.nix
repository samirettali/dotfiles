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
    ollama
  ];

  home.activation = {
    downloadOllamaModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
      models=(
          deepseek-r1:8b
          llama3.1
      )

      for model in "''${models[@]}"; do
          echo "Downloading $model"
          $DRY_RUN_CMD ${pkgs.ollama}/bin/ollama pull $model
      done
    '';
  };
}
