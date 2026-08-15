{pkgs, ...}: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "samir@ettali.com";
      base_url = "https://vw.samirettali.com";
      lock_timeout = 3600;
      pinentry = pkgs.pinentry-curses;
    };
  };
}
