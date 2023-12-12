{ pkgs
, nixpkgs
, browser
}: {
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
        # PASSWORD_STORE_KEY = "12345678";
        PASSWORD_STORE_CLIP_TIME = "10";
      };
    };
    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };
  };
}
