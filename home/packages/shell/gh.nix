{config, ...}: {
  programs = {
    gh = {
      enable = true;
    };
    gh-dash = {
      enable = config.programs.gh.enable;
    };
  };
}
