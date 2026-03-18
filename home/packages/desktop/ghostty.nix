{
  vars,
  pkgs,
  samirettali-nur,
  ...
}: {
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.ghostty
      else pkgs.ghostty;
    settings = {
      bold-is-bright = true;
      confirm-close-surface = false;
      cursor-style = "block";
      cursor-style-blink = false;
      font-family = vars.font.name;
      font-feature = ["-calt" "-dlig" "-liga"];
      font-size = vars.font.size;
      font-thicken = true;
      adjust-cell-height = "25%";
      font-thicken-strength = 32;
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

  home.sessionVariables = {
    TERMINAL = "ghostty";
  };
}
