{
  inputs,
  pkgs,
  ...
}: {
  programs.television = {
    enable = true;
    package = inputs.television.packages.${pkgs.system}.default;
    settings = {
      tick_rate = 60;
      ui = {
        use_nerd_font_icons = true;
        features.status_bar.visible = false;
      };
    };
  };
}
