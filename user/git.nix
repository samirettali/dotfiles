{ pkgs, ...} : {
  programs = {
    git = {
      enable = true;
      userName = "Samir Ettali";
      userEmail = "ettali.samir@gmail.com";
      package = pkgs.gitFull;
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = false;
         "url \"git@github.com:samirettali\"".insteadOf = "https://github.com/samirettali/";
      };
      ignores = [
          "*.env"
          ".env.*"
          ".DS_Store"
          "node_modules"
          "/target"
          ".idea"
          "Session.vim"
      ];
    };
  };
}
