{
  pkgs,
  inputs,
  ...
}: {
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.nur.repos.DimitarNestorov.ghostty
      else inputs.ghostty.packages."${pkgs.system}".default;
    settings = {
      bold-is-bright = true;
      confirm-close-surface = false;
      cursor-style = "block";
      cursor-style-blink = false;
      font-feature = [
        "-calt"
        "-dlig"
        "-liga"
      ];
      font-size = 16;
      font-thicken = true;
      font-thicken-strength = 64;
      gtk-titlebar = false;
      macos-titlebar-proxy-icon = "hidden";
      macos-titlebar-style = "tabs";
      theme = "Builtin Dark";
      title = " ";
    };
  };
}
