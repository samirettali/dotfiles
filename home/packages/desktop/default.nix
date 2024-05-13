{ pkgs
, ...
}: {
  imports = [
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
    discord
  ];

  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
         return {
           window_padding = {
             left = 0,
             right = 0,
             top = 0,
             bottom = 0,
           },
           font = wezterm.font("JetBrains Mono"),
           font_size = 16.5,
           enable_tab_bar = false;
           color_scheme = "Builtin Dark";
        }
      '';
    };
  };
}
