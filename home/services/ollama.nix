{
  lib,
  pkgs,
  ...
}: let
  models = [
    "deepcoder"
    "deepseek-r1"
    "gemma3"
    "hf.co/bartowski/Qwen2.5.1-Coder-7B-Instruct-GGUF"
    "hf.co/bartowski/Zyphra_ZR1-1.5B-GGUF"
    "llama3.2"
  ];
in {
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
  };

  home.activation = {
    downloadOllamaModels = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
  };
}
