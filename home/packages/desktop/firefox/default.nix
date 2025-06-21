{pkgs, ...}: {
  programs = {
    firefox = {
      enable = true;
      package = with pkgs; (firefox.override {
        # nativeMessagingHosts = [passff-host];
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
      profiles.samir = {
        # path = "profiles/samir"; # TODO: backup the profile first
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          adaptive-tab-bar-colour
          clearurls
          copy-selection-as-markdown
          darkreader
          keepassxc-browser
          linkding-extension
          sponsorblock
          switchyomega
          tampermonkey
          ublock-origin
          vimium-c
        ];
        search = {
          force = true;
          default = "google";
          engines = {
            "NixOS" = {
              urls = [
                {
                  template = "https://mynixos.com/search?q={searchTerms}";
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@n"];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "AI";
              toolbar = false;
              bookmarks = [
                {
                  name = "Chat";
                  toolbar = false; # Assuming these are not toolbar bookmarks
                  bookmarks = [
                    {
                      name = "Diffusion models";
                      bookmarks = [
                        {
                          name = "Gemini diffusion";
                          url = "https://deepmind.google.com/frontiers/gemini-diffusion";
                        }
                        {
                          name = "Inception Labs (diffusion chatbot)";
                          url = "https://chat.inceptionlabs.ai";
                        }
                      ];
                    }
                    {
                      name = "t3.chat";
                      url = "https://t3.chat";
                    }
                    {
                      name = "Deepseek";
                      url = "https://chat.deepseek.com";
                    }
                    {
                      name = "Gemini";
                      url = "https://gemini.google.com";
                    }
                    {
                      name = "Claude";
                      url = "https://claude.ai";
                    }
                    {
                      name = "Perplexity";
                      url = "https://www.perplexity.ai";
                    }
                    {
                      name = "ChatGPT";
                      url = "https://chat.openai.com";
                    }
                    {
                      name = "Qwen";
                      url = "https://chat.qwen.ai";
                    }
                    {
                      name = "Mistral";
                      url = "https://chat.mistral.ai";
                    }
                    {
                      name = "Venice AI";
                      url = "https://venice.ai";
                    }
                    {
                      name = "Together AI";
                      url = "https://api.together.xyz/playground";
                    }
                    {
                      name = "Groq";
                      url = "https://console.groq.com/playground";
                    }
                    {
                      name = "Cohere";
                      url = "https://coral.cohere.com";
                    }
                    {
                      name = "Sambanova";
                      url = "https://cloud.sambanova.ai";
                    }
                    {
                      name = "Compute";
                      url = "https://compute.hyper.space";
                    }
                    {
                      name = "devv";
                      url = "https://devv.ai";
                    }
                    {
                      name = "Julius";
                      url = "https://julius.ai/chat";
                    }
                    {
                      name = "delve";
                      url = "https://delve.a9.io";
                    }
                    {
                      name = "Phind";
                      url = "https://www.phind.com";
                    }
                    {
                      name = "llmchat";
                      url = "https://llmchat.co";
                    }
                    {
                      name = "Replicate";
                      url = "https://replicate.com";
                    }
                    {
                      name = "Cerebras";
                      url = "https://inference.cerebras.ai";
                    }
                    {
                      name = "Liquid Labs";
                      url = "https://playground.liquid.ai";
                    }
                    {
                      name = "Manus";
                      url = "https://manus.im";
                    }
                    {
                      name = "Abacus";
                      url = "https://deepagent.abacus.ai";
                    }
                    {
                      name = "NotebookLM";
                      url = "https://notebooklm.google.com";
                    }
                    {
                      name = "Flux";
                      url = "https://playground.bfl.ai/image/generate";
                    }
                    {
                      name = "Bagel";
                      url = "https://demo.bagel-ai.org";
                    }
                    {
                      name = "Github Copilot";
                      url = "https://github.com/copilot";
                    }
                    {
                      name = "Minimax";
                      url = "https://chat.minimax.io";
                    }
                  ];
                }
                {
                  name = "Media generation";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Fal";
                      url = "https://fal.ai";
                    }
                    {
                      name = "Kling AI";
                      url = "https://app.klingai.com/";
                    }
                    {
                      name = "Hailuoai";
                      url = "https://hailuoai.video";
                    }
                    {
                      name = "Luma labs";
                      url = "https://lumalabs.ai/blog/news/introducing-modify-video";
                    }
                    {
                      name = "Reve";
                      url = "https://preview.reve.art/app";
                    }
                    {
                      name = "Midjourney";
                      url = "https://www.midjourney.com";
                    }
                    {
                      name = "Topaz labs";
                      url = "https://www.topazlabs.com/bloom";
                    }
                    {
                      name = "Light tricks";
                      url = "https://www.lightricks.com";
                    }
                    {
                      name = "Riffusion";
                      url = "https://www.riffusion.com";
                    }
                    {
                      name = "Magi";
                      url = "https://sand.ai";
                    }
                    {
                      name = "Krea";
                      url = "https://www.krea.ai/krea-1";
                    }
                    {
                      name = "Seedream";
                      url = "https://seedream.pro";
                    }
                    {
                      name = "Higgsfield";
                      url = "https://higgsfield.ai";
                    }
                    {
                      name = "AiClipGen";
                      url = "https://www.aiclipgen.com/";
                    }
                  ];
                }
                {
                  name = "Text to speech";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Eleven labs";
                      url = "https://elevenlabs.io/v3";
                    }
                    {
                      name = "Fish audio";
                      url = "https://fish.audio";
                    }
                  ];
                }
                {
                  name = "Speech to text";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Wisprflow";
                      url = "https://wisprflow.ai";
                    }
                  ];
                }
                {
                  name = "AI coding";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Jules";
                      url = "https://jules.google.com";
                    }
                    {
                      name = "Replit";
                      url = "https://replit.com";
                    }
                    {
                      name = "All Hands";
                      url = "https://app.all-hands.dev";
                    }
                    {
                      name = "Llama Coder";
                      url = "https://llamacoder.together.ai";
                    }
                    {
                      name = "Rork";
                      url = "https://rork.app";
                    }
                    {
                      name = "bolt.new";
                      url = "https://bolt.new";
                    }
                    {
                      name = "same";
                      url = "https://same.new";
                    }
                    {
                      name = "nut";
                      url = "https://www.nut.new";
                    }
                    {
                      name = "a0";
                      url = "https://a0.dev";
                    }
                    {
                      name = "Chef";
                      url = "https://chef.convex.dev";
                    }
                    {
                      name = "Rocket";
                      url = "https://www.rocket.new";
                    }
                    {
                      name = "Sleek";
                      url = "https://sleek.design";
                    }
                    {
                      name = "Lovable";
                      url = "https://lovable.dev";
                    }
                    {
                      name = "Val Town";
                      url = "https://www.val.town/townie";
                    }
                    {
                      name = "10Web";
                      url = "https://my.10web.io";
                    }
                    {
                      name = "Lazy";
                      url = "https://getlazy.ai";
                    }
                    {
                      name = "Another wrapper";
                      url = "https://anotherwrapper.com/tools/ai-app-generator";
                    }
                    {
                      name = "Genie";
                      url = "https://cosine.sh";
                    }
                  ];
                }
                {
                  name = "Frontend coding";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "v0";
                      url = "https://v0.dev";
                    }
                    {
                      name = "Wonderish";
                      url = "https://wonderish.ai";
                    }
                  ];
                }
                {
                  name = "AI apps";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Google Stitch";
                      url = "https://stitch.withgoogle.com";
                    }
                    {
                      name = "Gamma (presentations)";
                      url = "https://gamma.app";
                    }
                    {
                      name = "Beautiful (presentations)";
                      url = "https://www.beautiful.ai";
                    }
                    {
                      name = "BetterDictation (speech to text)";
                      url = "https://betterdictation.com";
                    }
                    {
                      name = "Jenni (research)";
                      url = "https://app.jenni.ai";
                    }
                    {
                      name = "Andi (assistant)";
                      url = "https://andisearch.com";
                    }
                    {
                      name = "Frase (writing)";
                      url = "https://www.frase.io";
                    }
                    {
                      name = "Rytr (writing)";
                      url = "https://app.rytr.me";
                    }
                    {
                      name = "Anyword (writing)";
                      url = "https://go.anyword.com/dashboard";
                    }
                    {
                      name = "Frank (writing)";
                      url = "https://franks.ai";
                    }
                    {
                      name = "Globe (search)";
                      url = "https://explorer.globe.engineer";
                    }
                    {
                      name = "CostGPT";
                      url = "https://costgpt.ai";
                    }
                    {
                      name = "CopyOwl";
                      url = "https://copyowl.ai/";
                    }
                    {
                      name = "Decktopus (presentations)";
                      url = "https://www.decktopus.com/";
                    }
                    {
                      name = "Framedrop";
                      url = "https://www.framedrop.ai";
                    }
                    {
                      name = "Vivid Hubs (video generation)";
                      url = "https://vividhubs.ai/image-to-video";
                    }
                    {
                      name = "Magicpath (web design)";
                      url = "https://www.magicpath.ai";
                    }
                    {
                      name = "Emergent";
                      url = "https://app.emergent.sh/";
                    }
                    {
                      name = "Storm Genie";
                      url = "https://storm.genie.stanford.edu/";
                    }
                  ];
                }
                {
                  name = "Benchmarks";
                  toolbar = false;
                  bookmarks = [
                    {
                      name = "Artificial Analysis";
                      url = "https://artificialanalysis.ai";
                    }
                    {
                      name = "Scale";
                      url = "https://scale.com/leaderboard";
                    }
                    {
                      name = "LM Arena";
                      url = "https://beta.lmarena.ai/leaderboard";
                    }
                    {
                      name = "SWE Bench";
                      url = "https://www.swebench.com";
                    }
                    {
                      name = "Arc Prize";
                      url = "https://arcprize.org/leaderboard";
                    }
                    {
                      name = "IQ test";
                      url = "https://www.trackingai.org/home";
                    }
                    {
                      name = "Openrouter rankings";
                      url = "https://openrouter.ai/rankings";
                    }
                    {
                      name = "LiveCodeBench";
                      url = "https://livecodebench.github.io/leaderboard.html";
                    }
                    {
                      name = "Berkeley Function Calling Leaderboard";
                      url = "https://gorilla.cs.berkeley.edu/leaderboard.html";
                    }
                  ];
                }
                {
                  name = "Misc";
                  bookmarks = [
                    {
                      name = "models.dev";
                      url = "https://models.dev";
                    }
                    {
                      name = "Pageready";
                      url = "https://aipageready.com";
                    }
                  ];
                }
              ];
            }
            {
              name = "Development";
              bookmarks = [
                {
                  name = "APIs";
                  bookmarks = [
                    {
                      name = "Serper";
                      url = "https://serper.dev";
                    }
                  ];
                }
                {
                  name = "Javascript libraries";
                  bookmarks = [
                    {
                      name = "React bits";
                      url = "https://reactbits.dev";
                    }
                    {
                      name = "tweakcn";
                      url = "https://tweakcn.com/editor/theme";
                    }
                    {
                      name = "Aceternity";
                      url = "https://ui.aceternity.com";
                    }
                    {
                      name = "21st";
                      url = "https://21st.dev";
                    }
                    {
                      name = "MagicUI";
                      url = "https://pro.magicui.design";
                    }
                    {
                      name = "AlignUI";
                      url = "https://pro.alignui.com";
                    }
                    {
                      name = "BentoGrids";
                      url = "https://bentogrids.com";
                    }
                    {
                      name = "Grainient";
                      url = "https://grainient.supply/freebies";
                    }
                    {
                      name = "use-mcp";
                      url = "https://github.com/modelcontextprotocol/use-mcp";
                    }
                  ];
                }
                {
                  name = "Python libraries";
                  bookmarks = [
                    {
                      name = "Marimo";
                      url = "https://docs.marimo.io/";
                    }
                  ];
                }
              ];
            }
            {
              name = "Self-hosted";
              toolbar = false;
              bookmarks = [
                {
                  name = "Miniflux";
                  url = "http://localhost:3001";
                }
                {
                  name = "Airdrops";
                  url = "http://localhost:3003";
                }
                {
                  name = "Open WebUI";
                  url = "http://localhost:3002";
                }
                {
                  name = "Linkding";
                  url = "http://localhost:3004";
                }
                {
                  name = "qBittorrent";
                  url = "http://localhost:3005";
                }
              ];
            }
            {
              name = "Nix";
              toolbar = false;
              bookmarks = [
                {
                  name = "Nix pills";
                  url = "https://nixos.org/guides/nix-pills/";
                }
                {
                  name = "Nixos and flakes";
                  url = "https://nixos-and-flakes.thiscute.world/";
                }
                {
                  name = "Nix dev";
                  url = "https://nix.dev/";
                }
                {
                  name = "NixOS wiki";
                  url = "https://wiki.nixos.org/wiki/NixOS_Wiki";
                }
                {
                  name = "Noogle";
                  url = "https://noogle.dev/";
                }
                {
                  name = "Zero to nix";
                  url = "https://zero-to-nix.com/";
                }
                {
                  name = "Nix package versions";
                  url = "https://lazamar.co.uk/nix-versions";
                }
                {
                  name = "JSON to nix";
                  url = "https://json-to-nix.pages.dev";
                }
              ];
            }
            {
              name = "Misc";
              toolbar = false;
              bookmarks = [
                {
                  name = "GitMatcher";
                  url = "https://gitmatcher.com";
                }
                {
                  name = "About ideas now";
                  url = "https://aboutideasnow.com";
                }
                {
                  name = "AI tool hub";
                  url = "https://www.aitoolhub.net";
                }
                {
                  name = "Icones";
                  url = "https://icones.js.org";
                }
                {
                  name = "svgl";
                  url = "https://svgl.app";
                }
                {
                  name = "Framer";
                  url = "https://www.framer.com";
                }
                {
                  name = "Excalidraw";
                  url = "https://excalidraw.com";
                }
                {
                  name = "Hyvector";
                  url = "https://www.hyvector.com";
                }
                {
                  name = "Photopea";
                  url = "https://www.photopea.com";
                }
                {
                  name = "Josepha (price comparison)";
                  url = "https://josepha.de";
                }
                {
                  name = "Cyberchef";
                  url = "https://gchq.github.io/CyberChef";
                }
              ];
            }
            {
              name = "Cool stuff";
              toolbar = false;
              bookmarks = [
                {
                  name = "Tixy landd";
                  url = "https://tixy.land";
                }
                {
                  name = "Word games collection";
                  url = "https://dles.gg";
                }
                {
                  name = "Glitch gallery";
                  url = "https://glitchgallery.org";
                }
                {
                  name = "Particle life";
                  url = "https://lisyarus.github.io/webgpu/particle-life.html";
                }
                {
                  name = "Visualize data structures";
                  url = "https://staying.fun";
                }
                {
                  name = "Embeddings calculator";
                  url = "https://calc.datova.ai";
                }
                {
                  name = "AI take off speed";
                  url = "https://takeoffspeeds.com";
                }
                {
                  name = "LifeWiki";
                  url = "https://conwaylife.com/wiki";
                }
                {
                  name = "Dwitter";
                  url = "https://www.dwitter.net";
                }
              ];
            }
            {
              name = "Blogs";
              toolbar = false;
              bookmarks = [
                {
                  name = "Eoin Murray";
                  url = "https://eoinmurray.info";
                }
              ];
            }
            {
              name = "Jobs";
              toolbar = false;
              bookmarks = [
                {
                  name = "Tech compenso";
                  url = "https://techcompenso.com/offerte-di-lavoro";
                }
                {
                  name = "Prospect";
                  url = "https://www.joinprospect.com/";
                }
                {
                  name = "Breakout list";
                  url = "https://www.breakoutlist.com/";
                }
                {
                  name = "levels.fyi";
                  url = "https://www.levels.fyi/jobs";
                }
              ];
            }
            {
              name = "Crypto";
              toolbar = false;
              bookmarks = [
                {
                  name = "Trading view";
                  url = "https://www.tradingview.com/chart/VIP09u4q/?symbol=BINANCE%3ABTCUSDT";
                }
                {
                  name = "DeBank";
                  url = "https://debank.com/profile";
                }
                {
                  name = "Layer3";
                  url = "https://app.layer3.xyz";
                }
                {
                  name = "Whales market";
                  url = "https://app.whales.market/points-markets";
                }
                {
                  name = "Phoenix news";
                  url = "https://phoenixnews.io";
                }
                {
                  name = "Polymarket";
                  url = "https://polymarket.com";
                }
                {
                  name = "AAVE governance";
                  url = "https://governance.aave.com/c/governance/4";
                }
                {
                  name = "Stakan";
                  url = "https://stakan.io/terminal";
                }
              ];
            }
            {
              name = "Yield";
              toolbar = false;
              bookmarks = [
                {
                  name = "Contango";
                  url = "https://app.contango.xyz/strategies/leveraged-staking/eth";
                }
                {
                  name = "Pendle";
                  url = "https://app.pendle.finance/trade/markets";
                }
                {
                  name = "vfat.io";
                  url = "https://vfat.io/yield";
                }
                {
                  name = "Merkl";
                  url = "https://app.merkl.xyz";
                }
                {
                  name = "Pool together";
                  url = "https://app.cabana.fi/account";
                }
              ];
            }
            {
              name = "Products";
              toolbar = false;
              bookmarks = [
                {
                  name = "Midday";
                  url = "https://midday.ai";
                }
                {
                  name = "Languine";
                  url = "https://languine.ai";
                }
              ];
            }
          ];
        };

        settings = {
          "browser.startup.homepage" = "http://localhost:3000";

          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          # Keep the reader button enabled at all times
          "reader.parse-on-load.force-enabled" = true;

          # Hide the sharing indicator
          "privacy.webrtc.legacyGlobalIndicator" = false;
          "privacy.webrtc.hideGlobalIndicator" = true;

          # Enable custom theming
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "layers.acceleration.force-enabled" = true;
          "svg.context-properties.content.enabled" = true;

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
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
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
          "browser.urlbar.shortcuts.bookmarks" = true;
          "browser.urlbar.shortcuts.history" = true;
          "browser.urlbar.shortcuts.tabs" = true;
          "browser.urlbar.showSearchSuggestionsFirst" = true;
          "browser.urlbar.speculativeConnect.enabled" = true;

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
          "extensions.pocket.enabled" = false;
          "extensions.shield-recipe-client.enabled" = false;
          "reader.parse-on-load.enabled" = false; # "reader view"

          "browser.sessionstore.interval" = "15000";
          "dom.battery.enabled" = false;
          "dom.gamepad.enabled" = false;
          "beacon.enabled" = true; # Used for analitycs, disabling it breaks some websites
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

          permissions = {
            "default.desktop-notification" = false;
          };
        };
      };
    };
  };
}
