{
  lib,
  pkgs,
  ...
}: let
  # nixpkgs wraps chromium with CHROME_DEVEL_SANDBOX pointing at a setuid helper
  # that only a root-owned installation can provide. Nix owns nothing outside
  # the profile on this machine, so chromium finds the helper, refuses to run
  # unsandboxed and aborts. --no-sandbox is the way in, and it is what every
  # agent session was passing by hand anyway.
  chromium = pkgs.writeShellScriptBin "chromium" ''
    exec ${lib.getExe pkgs.ungoogled-chromium} --no-sandbox "$@"
  '';
in {
  home.packages = [
    chromium

    # Headless chromium renders text with whatever fontconfig can find, and this
    # machine had nothing: screenshots came out as empty boxes.
    pkgs.dejavu_fonts
    pkgs.liberation_ttf
    pkgs.noto-fonts-color-emoji
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    BROWSER_BIN = "${chromium}/bin/chromium";
  };
}
