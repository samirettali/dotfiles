{
  pkgs,
  inputs,
  ...
}: let
  dbee = pkgs.callPackage ../derivations/dbee.nix {
    source = "${inputs.dbee-src}/dbee";
  };
in {
  home.packages = [
    dbee
  ];
}
