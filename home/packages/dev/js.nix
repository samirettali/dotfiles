{
  pkgs,
  lib,
  features,
  ...
}: {
  programs.bun.enable = features.js == "minimal" || features.js == "full";

  home.packages = with pkgs;
    lib.optionals (features.js == "minimal" || features.js == "full") [
      nodejs
    ]
    ++ lib.optionals (features.js == "full") [
      eslint_d
      eslint
      js-beautify
      typescript-language-server
      prettierd
      vscode-langservers-extracted
    ];

  home.sessionVariables = lib.optionalAttrs (features.js == "full") {
    NEXT_TELEMETRY_DISABLED = "1";
  };
}
