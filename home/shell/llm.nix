{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (llm.withPlugins {
      cmd = true;
      llm-openrouter = true;
      llm-cmd = true;
    })
  ];

  home.activation.setupLLM = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${lib.getExe pkgs.llm} keys set openrouter --value "$(cat ${config.sops.secrets."openrouter_api_key".path})"
    # TODO: it seems like the openrouter plugins is not available in writeBoundary phase
    ${lib.getExe pkgs.llm} models default openrouter/google/gemini-2.5-flash || true
    ${lib.getExe pkgs.llm} aliases set g3 "openrouter/google/gemma-3-27b-it"
    ${lib.getExe pkgs.llm} aliases set gl "openrouter/google/gemini-2.5-flash-lite-preview-06-17"
    ${lib.getExe pkgs.llm} aliases set gf "openrouter/google/gemini-2.5-flash"
    ${lib.getExe pkgs.llm} aliases set gp "openrouter/google/gemini-2.5-pro"
    ${lib.getExe pkgs.llm} models options set g3 unlimited 1
    ${lib.getExe pkgs.llm} models options set gl unlimited 1
    ${lib.getExe pkgs.llm} models options set gf unlimited 1
  '';
}
