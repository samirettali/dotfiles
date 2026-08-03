{
  config,
  lib,
  pkgs,
  ...
}: {
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
    ];
  };

  home.sessionVariables = lib.mkIf config.programs.google-chrome.enable {
    BROWSER_BIN = "${config.programs.google-chrome.finalPackage}/bin/google-chrome";
  };
}
