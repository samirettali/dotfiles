{pkgs, ...}: {
  imports = [
    ./wm
  ];

  services = {
    mpris-proxy.enable = true;
  };

  home.packages = with pkgs; [
    ledger-live-desktop
    lmstudio
    redisinsight
    neohtop
  ];

  # TODO:
  # - use ungoogled-chromium
  # - disable smooth scroll
  # - add custom search engines
  #     - @nix https://mynixos.com/search?q=%s
  #     - @gh https://github.com/search?q=%s
  #     - @cl https://claude.ai/new?q=%s
  #     - @pl https://perplexity.ai/?q=%s
  programs.chromium = {
    enable = true;
    # package = pkgs.ungoogled-chromium;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # vimium
      {id = "oboonakemofpalcgghocfoadofidjkkk";} # keepassxc
      {id = "niloccemoadcdkdjlinkgdfekeahmflj";} # pocket
      {id = "gbmdgpbipfallnflgajpaliibnhdgobh";} # json viewer
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # sponsorship block
      {id = "acmacodkjbdgmoleebolmdjonilkdbch";} # rabby
      {id = "bfnaelmomeimhlpmgjnjophhpkkoljpa";} # phantom
      {id = "hnfanknocfeofbddgcijnmhnfnkdnaad";} # coinbase
      {id = "bfnaelmomeimhlpmgjnjophhpkkoljpa";} # phantom
      {id = "dmkamcknogkgcdfhhbddcghachkejeap";} # keplr
    ];
    # TODO: fix
    # extraOpts = {
    #   ShowHomeButton = false;
    #   RestoreOnStartup = 1;
    #   PasswordManagerEnabled = false;
    #   SpellcheckEnabled = true;
    #   SpellcheckLanguages = [
    #     "en-US"
    #     "it"
    #   ];
    #   SiteSearchSettings = [
    #     {
    #       featured = true;
    #       name = "nix";
    #       shortcut = "nix";
    #       url = "https://mynixos.com/search?q=%s";
    #     }
    #   ];
    # };
  };
}
