{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.bun.enable = config.features.js == "minimal" || config.features.js == "full";

  home.packages = with pkgs;
    lib.optionals (config.features.js == "minimal" || config.features.js == "full") [
      nodejs
      pnpm
      typescript-language-server
    ]
    ++ lib.optionals (config.features.js == "full") [
      eslint_d
      eslint
      js-beautify
      prettierd
      vscode-langservers-extracted
    ];

  home.sessionVariables = lib.optionalAttrs (config.features.js == "full") {
    NEXT_TELEMETRY_DISABLED = "1";
  };
}
