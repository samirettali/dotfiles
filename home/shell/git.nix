{ config
, pkgs
, ...
}: {
  # TODO: use config for name and email
  programs.git = {
    enable = true;
    userName = "Samir Ettali";
    userEmail = "ettali.samir@gmail.com";
    extraConfig = {
      core.editor = config.home.sessionVariables.EDITOR;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      url."git@github.com:".insteadOf = "https://github.com/";
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
  };
}
