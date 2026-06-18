{config, ...}: {
  programs = {
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
    gh-dash = {
      enable = config.programs.gh.enable;
    };
  };
}
