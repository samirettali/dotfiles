{
  nurPkgs,
  pkgs,
  ...
}: let
  monid = pkgs.stdenvNoCC.mkDerivation {
    pname = "monid";
    version = "0.1.6";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@monid-ai/cli/-/cli-0.1.6.tgz";
      hash = "sha256-Lcp241chP5Q1gtBdxX+JY1Snxjgs6BEbmdItmVC5wKA=";
    };

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/monid
      cp package.json $out/lib/monid/
      cp -R dist $out/lib/monid/
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/monid \
        --add-flags $out/lib/monid/dist/index.js

      runHook postInstall
    '';
  };
in {
  imports = [
    ./agents.nix
    ./antigravity-cli.nix
    ./claude-code.nix
    ./codex.nix
    ./fabric.nix
    ./mcp.nix
    ./mtplx.nix
    ./opencode.nix
    ./pi-coding-agent
    ./skill-scripts.nix
  ];

  home.packages = [
    monid
    nurPkgs.grok-cli
  ];
}
