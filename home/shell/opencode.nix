{ pkgs, ... }:
{
  home.packages = [
    (pkgs.stdenv.mkDerivation rec {
      pname = "opencode";
      version = "0.1.105";

      src = pkgs.fetchurl {
        url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-${
          if pkgs.stdenv.isDarwin then "darwin" else "linux"
        }-${
          if pkgs.stdenv.isAarch64 then "arm64" else "x64"
        }.zip";
        sha256 = "sha256-Ogqm+7kEHS6dA4eCzkPgBbLDebIwg/j9CufIs9F5bXA="; # TODO: this only works on darwin arm64
      };

      nativeBuildInputs = [ pkgs.unzip ];

      unpackPhase = ''
        unzip $src
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp opencode $out/bin/
        chmod +x $out/bin/opencode
      '';

      meta = with pkgs.lib; {
        description = "AI coding agent, built for the terminal";
        changelog = "https://github.com/sst/opencode/releases/tag/v${version}";
        homepage = "https://opencode.ai";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    })
  ];
}