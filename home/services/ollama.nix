{
  lib,
  pkgs,
  ...
}: let
  models = [
    "deepseek-r1:8b"
    "gemma3:12b"
    "hf.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M"
    "hf.co/bartowski/Zyphra_ZR1-1.5B-GGUF:Q8_0"
    "hf.co/smirki/UIGEN-T1-Qwen-7b"
    "llama3.2:3b-instruct-q8_0"
    "qwen2.5-coder"
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
