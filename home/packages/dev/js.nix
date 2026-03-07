{
  pkgs,
  lib,
  features,
  ...
}: {
  home.packages = with pkgs;
    [
      nodejs # TODO: define "minimal" | "full" flag
    ]
    ++ lib.optionals features.js [
      bun
      eslint_d
      nodePackages.eslint
      nodePackages.js-beautify
      nodePackages.typescript-language-server
      prettierd
    ];

  home.sessionVariables = lib.optionalAttrs features.js {
    NEXT_TELEMETRY_DISABLED = "1";
  };
}
