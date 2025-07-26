{...}: {
  programs.bat = {
    enable = true;
    config = {
      # theme = "fly16"; # TODO: fix this
    };
    themes = {
      # fly16 = {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "bluz71";
      #     repo = "fly16-bat";
      #     rev = "40c20cbb7ec5bf413b24b927952ffc8702b8389b";
      #     sha256 = "sha256-IcN5EENhbB82LDb8qpq6EU36eJlpbjKWS5Par0kFCUk=";
      #   };
      #   file = "fly16.tmTheme";
      # };
    };
  };
}
