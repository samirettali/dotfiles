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
    ollama
    # aider-chat
  ];

  home.activation = {
    downloadOllamaModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
      models=(
          "CognitiveComputations/dolphin-gemma2:2b-v2.9.4-Q8_0"
          "ajindal/llama3.1-storm:8b"
          "ajindal/llama3.1-storm:8b-Q8_0"
          "codegemma:latest"
          "hermes3:8b-llama3.1-fp16"
          "hermes3:8b"
          "llama3.1:8b"
          "llama3.1:8b-instruct-fp16"
          "mistral-nemo:latest"
          "mxbai-embed-large:latest"
          "phi3.5:3.8b"
          "phi3.5:3.8b-mini-instruct-fp16"
          "qwen2:7b"
          "smollm:135m-base-v0.2-fp16"
          "smollm:135m-instruct-v0.2-q8_0"
          "tinyllama"
          "tinyllama:1.1b-chat-v0.6-fp16"
          "tinyllama:latest"
          "yi-coder:9b"
      )

      for model in "''${models[@]}"; do
          echo "Downloading $model"
          $DRY_RUN_CMD ${pkgs.ollama}/bin/ollama pull $model
      done
    '';
  };
}
