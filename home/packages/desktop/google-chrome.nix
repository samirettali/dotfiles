{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # vimium
      {id = "oboonakemofpalcgghocfoadofidjkkk";} # keepassxc
      {id = "niloccemoadcdkdjlinkgdfekeahmflj";} # pocket
      {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # json viewer
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # sponsorship block
      {id = "acmacodkjbdgmoleebolmdjonilkdbch";} # rabby
      {id = "bfnaelmomeimhlpmgjnjophhpkkoljpa";} # phantom
      {id = "hnfanknocfeofbddgcijnmhnfnkdnaad";} # coinbase
      {id = "dmkamcknogkgcdfhhbddcghachkejeap";} # keplr
    ];
  };

  home.sessionVariables = lib.mkIf config.programs.google-chrome.enable {
    BROWSER_BIN = "${config.programs.google-chrome.finalPackage}/bin/google-chrome";
  };
}
