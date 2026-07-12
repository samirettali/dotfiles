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
    ]
    ++ lib.optionals (config.features.js == "full") [
      eslint_d
      eslint
      js-beautify
      typescript-language-server
      prettierd
      vscode-langservers-extracted
    ];

  home.sessionVariables = lib.optionalAttrs (config.features.js == "full") {
    NEXT_TELEMETRY_DISABLED = "1";
  };
}
