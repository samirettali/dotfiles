{
  lib,
  pkgs,
  config,
  ...
}: let
  models = [
    "deepcoder"
    "deepseek-r1"
    "gemma3"
    "gemma3:4b-it-qat"
    "hf.co/bartowski/Qwen2.5.1-Coder-7B-Instruct-GGUF"
    "hf.co/bartowski/Zyphra_ZR1-1.5B-GGUF"
  ];

  downloadModels = ''
    total=${toString (builtins.length models)}
    failed=0

    for model in ${lib.escapeShellArgs models}; do
      '${lib.getExe pkgs.ollama}' pull "$model" &
    done

    for job in $(jobs -p); do
      set +e
      wait $job
      exit_code=$?
      set -e

      if [ $exit_code != 0 ]; then
        failed=$((failed + 1))
      fi
    done

    if [ $failed != 0 ]; then
      echo "error: $failed out of $total attempted model downloads failed" >&2
      exit 1
    fi
  '';
in {
  services.ollama = {
    enable = false;
  };

  home.activation =
    {}
    // lib.optionalAttrs config.services.ollama.enable {
      downloadOllamaModels = lib.hm.dag.entryAfter ["writeBoundary"] downloadModels;
    };
}
