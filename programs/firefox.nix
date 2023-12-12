{ pkgs
}: {
  programs = {
    firefox = {
      enable = true;
      package = with pkgs; (firefox.override { nativeMessagingHosts = [ passff-host ]; });
      override =
        {
          cfg = {
            enableTridactylNative = true;
          };
        };
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
        OfferToSaveLoginsDefault = false;
      };
    };
  };
}
