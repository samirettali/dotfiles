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
    })
  ];

  home.activation.setupLLM = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${lib.getExe pkgs.llm} keys set openrouter --value "$(cat ${config.sops.secrets."openrouter_api_key".path})"
    # TODO: it seems like the openrouter plugins is not available in writeBoundary phase
    ${lib.getExe pkgs.llm} models default openrouter/google/gemini-2.5-flash-preview-05-20 || true
  '';
}
