{ lib, pkgs, ... }: {
  programs = {
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-audit
        exts.pass-genphrase
        exts.pass-otp
        exts.pass-update
      ]);
      settings = {
        # TODO check for new settings
        PASSWORD_STORE_CLIP_TIME = "10";
      };
    };
  };
}
