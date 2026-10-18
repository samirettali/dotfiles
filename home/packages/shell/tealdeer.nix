{...}: {
  programs.tealdeer = {
    enable = false;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      updates = {
        auto_update = true;
      };
    };
  };
}
