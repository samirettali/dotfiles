{
  lib,
  config,
  pkgs,
  ...
}: let
  llm-openrouter = pkgs.callPackage ./openrouter.nix {};
  llmWithPlugins = pkgs.python313.withPackages (p: [
    p.llm
    p.llm-cmd
    llm-openrouter
  ]);
in {
  home.packages = [llmWithPlugins];

  home.activation.setupLlm = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${llmWithPlugins}/bin/llm keys set openrouter --value "$(cat ${config.sops.secrets."openrouter_api_key".path})"
    ${llmWithPlugins}/bin//llm models default openrouter/google/gemini-2.5-flash-preview-05-20
  '';
}
