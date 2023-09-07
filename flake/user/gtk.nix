{ pkgs, ... }: {
  gtk = {
      enable = true;
      font = {
        name = "sans";
      };
      theme = {
        name = "Fluent-Dark";
        package = pkgs.fluent-gtk-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      gtk3.extraConfig = {
          gtk-application-prefer-dark-theme=1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme=1;
      };
  };
}