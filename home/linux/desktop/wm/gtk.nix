{pkgs, ...}: {
  home.packages = with pkgs; [
    google-fonts
    noto-fonts
    nerd-fonts.jetbrains-mono
  ];

  gtk = {
    enable = true;
    font.name = "sans";
    theme = {
      name = "Fluent-Dark";
      package = pkgs.fluent-gtk-theme;
    };
    iconTheme = {
      name = "Fluent-dark";
      package = pkgs.fluent-icon-theme;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}
