{
  pkgs,
  lib,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals (features.js == "minimal" || features.js == "full") [
      nodejs
      bun
    ]
    ++ lib.optionals (features.js == "full") [
      eslint_d
      nodePackages.eslint
      nodePackages.js-beautify
      nodePackages.typescript-language-server
      prettierd
      vscode-langservers-extracted
    ];

  home.sessionVariables = lib.optionalAttrs (features.js == "full") {
    NEXT_TELEMETRY_DISABLED = "1";
  };
}
