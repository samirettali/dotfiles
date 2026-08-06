{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.google-chrome;
in {
  programs.google-chrome = {
    enable = lib.elem pkgs.stdenv.hostPlatform.system ["aarch64-darwin" "x86_64-linux"];
    package = pkgs.google-chrome;
    extensions = [
      {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # ublock origin lite
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # vimium
      {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # json viewer
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # sponsorship block
      {id = "acmacodkjbdgmoleebolmdjonilkdbch";} # rabby
      {id = "bfnaelmomeimhlpmgjnjophhpkkoljpa";} # phantom
      {id = "dmkamcknogkgcdfhhbddcghachkejeap";} # keplr
      {id = "nngceckbapebfimnlniiiahkandclblb";} # bitwarden
      {id = "jinjaccalgkegednnccohejagnlnfdag";} # violentmonkey
    ];
  };

  home.sessionVariables = lib.mkIf cfg.enable {
    BROWSER_BIN = "${cfg.finalPackage}/bin/google-chrome";
  };
}
