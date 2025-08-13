{
  customArgs,
  pkgs,
  ...
}: {
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;
    settings = {
      bold-is-bright = true;
      confirm-close-surface = false;
      cursor-style = "block";
      cursor-style-blink = false;
      font-family = customArgs.font.name;
      font-feature = ["-calt" "-dlig" "-liga"];
      font-size = 16;
      font-thicken = true;
      adjust-cell-height = "25%";
      font-thicken-strength = 16;
      gtk-titlebar = false;
      macos-titlebar-proxy-icon = "hidden";
      macos-titlebar-style = "hidden";
      theme = "Builtin Dark";
      title = ''" "'';
      shell-integration-features = "no-cursor";
      copy-on-select = "clipboard";
      auto-update = "off";
    };
  };
}
