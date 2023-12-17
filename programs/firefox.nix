{ pkgs
}: {
  programs = {
    firefox = {
      enable = true;
      package = with pkgs; (firefox.override {
        nativeMessagingHosts = [ passff-host pkgs.tridactyl-native ];
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
      });
      profiles."samir" = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          # bypass-paywalls-clean
          clearurls
          copy-selection-as-markdown
          darkreader
          passff
          sponsorblock
          tridactyl
          ublock-origin
        ];
        settings = {
          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          # Re-bind ctrl to super (would interfere with tridactyl otherwise)
          # "ui.key.accelKey" = 91; # TODO

          # Keep the reader button enabled at all times; really don't
          # care if it doesn't work 20% of the time, most websites are
          # crap and unreadable without this
          "reader.parse-on-load.force-enabled" = true;

          # Hide the "sharing indicator", it's especially annoying
          # with tiling WMs on wayland
          "privacy.webrtc.legacyGlobalIndicator" = false;

          # Actual settings
          "app.update.auto" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "browser.laterrun.enabled" = false;

          # Disable Activity Stream
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "extensions.htmlaboutaddons.discover.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;

          # Disable new tab tile ads & preload
          # http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
          # http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
          # https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-source
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-ping
          "browser.newtabpage.pinned" = false;
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.url" = "about:black";
          "browser.newtabpage.enhanced" = false;
          "browser.newtabpage.introShown" = true;
          "browser.newtab.preload" = false;
          "browser.newtabpage.directory.ping" = "";
          "browser.newtabpage.directory.source" = "data:text/plain,{}";

          "browser.protections_panel.infoMessage.seen" = true;
          "browser.quitShortcut.disabled" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.ssb.enabled" = true;
          "browser.toolbars.bookmarks.visibility" = "never";
          # "browser.urlbar.placeholderName" = "DuckDuckGo";
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
          "dom.security.https_only_mode_ever_enabled" = true;
          "dom.security.https_only_mode" = true;
          "extensions.getAddons.showPane" = false;
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "privacy.firstparty.isolate" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
          "privacy.purge_trackers.enabled" = true;
          "signon.rememberSignons" = false;

          # Reduce search engine noise in the urlbar's completion window. The
          # shortcuts and suggestions will still work, but Librewolf won't clutter
          # its UI with reminders that they exist.
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.tabs" = false;
          "browser.urlbar.showSearchSuggestionsFirst" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          # https://bugzilla.mozilla.org/1642623
          "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
          # https://blog.mozilla.org/data/2021/09/15/data-and-firefox-suggest/
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          # Show whole URL in address bar
          "browser.urlbar.trimURLs" = false;
          # Disable some not so useful functionality.
          "browser.disableResetPrompt" = true; # "Looks like you haven't started Librewolf in a while."
          "browser.onboarding.enabled" = false; # "New to Librewolf? Let's get started!" tour
          "browser.aboutConfig.showWarning" = false; # Warning when opening about:config
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "extensions.pocket.enabled" = false;
          "extensions.shield-recipe-client.enabled" = false;
          "reader.parse-on-load.enabled" = false; # "reader view"

          "browser.sessionstore.interval" = "15000";
          "dom.battery.enabled" = false;
          "dom.gamepad.enabled" = false;
          "beacon.enabled" = false; # Used for analitycs
          "browser.send_pings" = false; # Disable pinging URIs specified in <a> ping= attributes
          "browser.fixup.alternate.enabled" = false; # Don't try to guess domain names when entering an invalid domain name in URL bar

          # Disable telemetry
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "experiments.supported" = false;
          "experiments.enabled" = false;
          "experiments.manifest.uri" = "";
          "browser.ping-centre.telemetry" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "app.shield.optoutstudies.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;

          # Disable proxy
          "network.proxy.type" = 0;

          # Disable smooth scrolling (hate this feature on web browsers)
          "general.smoothScroll" = false;

          # Disable search suggestions
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.bookmark" = true;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;

          permissions = {
            "default.desktop-notification" = false;
          };
        };
      };
    };
  };
}
