{
  config,
  pkgs,
  ...
}: {
  # TODO: use config for name and email
  programs.git = {
    enable = true;
    userName = "Samir Ettali";
    userEmail = config.home.sessionVariables.EMAIL;
    extraConfig = {
      core.editor = config.home.sessionVariables.EDITOR;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      url."git@github.com:samirettali".insteadOf = "https://github.com/samirettali";
      url."git@github.com:YoungAgency".insteadOf = "https://github.com/YoungAgency";
    };
    ignores = [
      "*.env"
      ".env*"
      ".DS_Store"
      "node_modules"
      "/target"
      ".idea"
      "Session.vim"
    ];

    # TODO: this is broken in nixpkgs
    delta = {
      enable = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging never";
        };
      };
    };
  };
  home.packages = with pkgs; [
    git-absorb
  ];
}
