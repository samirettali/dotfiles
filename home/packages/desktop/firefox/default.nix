{
  pkgs,
  inputs,
  ...
}: let
  addons = inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons;

  extensions = with addons; [
    adaptive-tab-bar-colour
    bitwarden
    consent-o-matic
    darkreader
    linkding-extension
    sponsorblock
    violentmonkey
    ublock-origin
    vimium-c
    web-clipper-obsidian
  ];

  # Installed through policy rather than symlinked into the profile: `install_url`
  # is a store path, so it changes on every bump and Firefox reinstalls, instead
  # of deciding from an mtime that is 1000ms on every store file and therefore
  # never differs. `normal_installed` only blocks uninstalling, not disabling.
  # `private_browsing` and `updates_disabled` are otherwise profile state: the
  # first is lost whenever extensions.json is rebuilt, the second would let AMO
  # replace the pinned XPI.
  extensionSettings = builtins.listToAttrs (map (e: {
      name = e.addonId;
      value = {
        installation_mode = "normal_installed";
        install_url = "file://${e}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${e.addonId}.xpi";
        private_browsing = true;
        updates_disabled = true;
      };
    })
    extensions);

  # The theme reads these at load: an about:config edit silently breaks the
  # sidebar layout. gwfox.* cannot be locked — the Preferences policy only
  # accepts an allowlist of prefixes, and custom ones are not on it.
  lockedPrefs =
    builtins.mapAttrs (_: v: {
      Value = v;
      Status = "locked";
    }) {
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "hide-sidebar";
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "svg.context-properties.content.enabled" = true;
    };

  # Appended rather than patched: gwfox is one nested tree, so a patch hunk's
  # context lands wherever it happens to sit after an update.
  gwfoxUserChrome = pkgs.runCommand "gwfox-userChrome.css" {} ''
    cat ${inputs.gwfox}/userChrome.css ${./gwfox-overrides.css} > $out
  '';

  gwfoxUserContent = pkgs.runCommand "gwfox-userContent.css" {} ''
    ln -s ${inputs.gwfox}/userContent.css $out
  '';
in {
  programs = {
    firefox = {
      enable = true;
      package = with pkgs; (firefox-bin.override {
        extraPolicies = {
          DisableFirefoxScreenshots = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };
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
          SearchBar = "unified";
          ExtensionSettings = extensionSettings;
          Preferences = lockedPrefs;
        };
      });
      profiles.samir = {
        userChrome = gwfoxUserChrome;
        userContent = gwfoxUserContent;
        extensions = {
          force = true;
          # Inert while ExtensionStorageIDB is on — kept as a record of what was
          # applied by hand. See issue #11.
          settings = with addons; {
            "${adaptive-tab-bar-colour.addonId}" = {
              settings = {
                tabbar = 10;
                tabbarBorder = 0;
                tabSelected = 0;
                tabSelectedBorder = 0;
                toolbar = 0;
                toolbarBorder = 0;
                toolbarField = 5;
                toolbarFieldBorder = 5;
                toolbarFieldOnFocus = 5;
                sidebar = 10;
                sidebarBorder = 10;
                popup = 5;
                popupBorder = 5;
                minContrast_light = 90;
                minContrast_dark = 45;
                allowDarkLight = true;
                dynamic = true;
                noThemeColour = true;
                compatibilityMode = false;
                homeBackground_light = "#ffffff";
                homeBackground_dark = "#2b2a33";
                fallbackColour_light = "#ffffff";
                fallbackColour_dark = "#2b2a33";
                siteList = {
                };
                version = [
                  3
                  1
                ];
              };
            };
            "${ublock-origin.addonId}" = {
              settings = {
                userSettings = {
                  userFiltersTrusted = true;
                };
                whitelist = [
                  "chrome-extension-scheme"
                  "moz-extension-scheme"
                ];
                selectedFilterLists = [
                  "user-filters"
                  "ublock-filters"
                  "ublock-badware"
                  "ublock-privacy"
                  "ublock-quick-fixes"
                  "ublock-unbreak"
                  "easylist"
                  "adguard-generic"
                  "adguard-spyware"
                  "adguard-spyware-url"
                  "adguard-cookies"
                  "adguard-mobile"
                  "easyprivacy"
                  "block-lan"
                  "urlhaus-1"
                  "plowe-0"
                  "adguard-social"
                  "adguard-mobile-app-banners"
                  "adguard-other-annoyances"
                  "adguard-popup-overlays"
                  "adguard-widgets"
                  "ublock-cookies-adguard"
                  "ublock-annoyances"
                ];
                user-filters = ''
                  $3p,to=facebook.*,from=~facebook.*|~instagram.com|~messenger.com|~meta.*|~threads.*
                  ||accounts.google.com/gsi/*$xhr,script,3p
                  ||googlevideo.com/videoplayback$xhr,3p,method=get,domain=www.youtube.com
                '';
              };
            };
            "${vimium-c.addonId}" = {
              settings = {
                exclusionRules = [
                  {
                    passKeys = "f ";
                    pattern = ":https://mail.google.com/";
                  }
                  {
                    passKeys = "";
                    pattern = ":https://monkeytype.com/";
                  }
                  {
                    passKeys = "/";
                    pattern = ":https://github.com/";
                  }
                  {
                    passKeys = "";
                    pattern = ":https://vim-adventures.com/";
                  }
                  {
                    passKeys = "";
                    pattern = ":https://app.godelterminal.com/";
                  }
                ];
                # keyMappings = [];
              };
            };
          };
        };
        search = {
          force = true;
          default = "google";
          engines = {
            "NixOS" = {
              urls = [{template = "https://mynixos.com/search?q={searchTerms}";}];
              definedAliases = ["@n"];
              updateInterval = 24 * 60 * 60 * 1000; # every day
              icon = "https://mynixos.com/static/icons/mnos-logo.svg";
            };
            "NixOS Wiki" = {
              urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
              definedAliases = ["@nw"];
              updateInterval = 24 * 60 * 60 * 1000; # every day
              icon = "https://nixos.wiki/favicon.png";
            };
            bing.metaData.hidden = true; # TODO: is this needed?
            ddg.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
            google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        settings = {
          "browser.startup.homepage" = "https://home.samirettali.com";

          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          # Hide the sharing indicator
          # "privacy.webrtc.legacyGlobalIndicator" = false;
          # "privacy.webrtc.hideGlobalIndicator" = true;

          # Enable custom theming — the two prefs the theme cannot survive without
          # are locked in `lockedPrefs` instead.
          "layers.acceleration.force-enabled" = true;
          "ui.useOverlayScrollbars" = 1;
          "browser.newtabpage.activity-stream.nova.enabled" = false;

          # Actual settings
          "app.update.auto" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "browser.laterrun.enabled" = false;

          # Vertical tabs — revamp, verticalTabs and visibility are in `lockedPrefs`.
          "sidebar.revamp.round-content-area" = false;
          # Which tools the bottom of the sidebar lists. Firefox appends any
          # extension declaring a sidebar_action, so leaving this unset lets a
          # rebuild drop Bitwarden's panel.
          "sidebar.main.tools" = addons.bitwarden.addonId;
          "sidebar.animation.enabled" = false;

          "widget.macos.native-context-menus" = false;
          "gwfox.toolbar" = true;
          "gwfox.urlbar" = true;
          "gwfox.blur" = false;
          "gwfox.ac" = false;
          "gwfox.atbc" = true;
          "gwfox.newtab" = false;
          "gwfox.noborder" = true;
          "gwfox.icons" = true;
          "gwfox.msc" = true;
          "gwfox.sidebar" = 3;

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
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enabled" = false;
          # Extensions here are symlinked into the profile by home-manager, which
          # Firefox counts as a foreign install and disables by default.
          "extensions.autoDisableScopes" = 0;
          # home-manager turns this off for any non-empty extensions.settings,
          # since browser-extension-data is only read by the legacy JSON backend.
          # It is global, so every extension loses Firefox's default storage —
          # Bitwarden kept its whole vault in one 2MB file. Keeping the default
          # is what makes extensions.settings inert (see issue #11).
          "extensions.webextensions.ExtensionStorageIDB.enabled" = true;
          "browser.tabs.insertAfterCurrent" = true;
          "browser.tabs.insertAfterCurrentExceptPinned" = true;

          # Disable new tab tile ads & preload
          # http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
          # http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
          # https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-source
          # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-ping
          "browser.newtabpage.pinned" = false;
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.url" = "https://home.samirettali.com";
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
          "dom.security.https_only_mode_ever_enabled" = true;
          "dom.security.https_only_mode" = true;
          "extensions.getAddons.showPane" = false;
          "identity.fxaccounts.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.firstparty.isolate" = false; # TODO: disabling this breaks some websites
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
          "privacy.purge_trackers.enabled" = true;
          "signon.rememberSignons" = false;

          # Reopen previous tabs
          "browser.startup.page" = 3;

          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.history" = true;
          "browser.urlbar.suggest.bookmark" = true;
          "browser.urlbar.suggest.openpage" = true;
          "browser.urlbar.suggest.topsites" = true;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = true;
          "browser.urlbar.shortcuts.tabs" = true;
          "browser.urlbar.showSearchSuggestionsFirst" = true;
          "browser.urlbar.speculativeConnect.enabled" = true;

          "browser.formfill.enable" = false;

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
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
          "extensions.shield-recipe-client.enabled" = false;
          "reader.parse-on-load.enabled" = false; # "reader view"

          "browser.sessionstore.interval" = "15000";
          "dom.battery.enabled" = false;
          "dom.gamepad.enabled" = false;
          "beacon.enabled" = true; # Used for analytics, disabling it breaks some websites
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

          "dom.storage.default_quota" = 25600;

          # 0 ask, 1 allow, 2 block
          "permissions.default.desktop-notification" = 2;
        };
      };
    };
  };
}
