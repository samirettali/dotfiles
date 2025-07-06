{...}: {
  programs = {
    keepassxc = {
      enable = true;
      settings = {
        Browser = {
          Enabled = true;
          UpdateBinaryPath = false;
        };
        GUI = {
          TrayIconAppearance = "monochrome";
        };
        PasswordGenerator = {
          Length = 64;
          SpecialChars = true;
        };
      };
    };
  };
}
