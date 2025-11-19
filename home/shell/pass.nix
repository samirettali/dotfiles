{
  lib,
  pkgs,
  ...
}: {
  programs = {
    password-store = {
      enable = lib.mkDefault false;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-genphrase
        exts.pass-otp
        exts.pass-update
      ]);
      settings = {
        PASSWORD_STORE_CLIP_TIME = "10";
      };
    };
  };
}
