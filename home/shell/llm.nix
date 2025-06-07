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

  home.activation.setupLlm = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.llm}/bin/llm keys set openrouter --value "$(cat ${config.sops.secrets."openrouter_api_key".path})"
    ${pkgs.llm}/bin/llm models default openrouter/google/gemini-2.5-flash-preview-05-20
  '';
}
