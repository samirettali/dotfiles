{...}: {
  programs.direnv = {
    enable = true;
    config = {
      # https://www.mankier.com/1/direnv.toml
      load_dotenv = true;
      strict_env = true;
      whitelist = {
        # TODO
        prefix = [];
        exact = [];
      };
    };
  };
}
