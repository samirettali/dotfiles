{ ... }: {
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Nerd Font";
      size = 10.5;
    };
    extraConfig = ''
      text_composition_strategy legacy
      cursor_shape block
    '';
  };
}
