{ pkgs, ...} : {
  git = {
    enable = true;
    userName = "Samir Ettali";
    userEmail = "ettali.samir@gmail.com";
    package = pkgs.gitFull;
    # config.credential.helper = "libsecret";
    extraConfig = {
      # core.editor = nvim;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}