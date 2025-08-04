{...}: {
  programs.firefox.profiles.samir.bookmarks = {
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
                name = "Morphic";
                url = "https://studio.morphic.com";
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
              {
                name = "Kyutai";
                url = "https://kyutai.org/next/tts";
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
              {
                name = "MySite";
                url = "https://app.mysite.ai/projects";
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
                name = "Director";
                url = "https://www.director.ai/";
              }
              {
                name = "Chronicle";
                url = "https://chroniclehq.com/";
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
                name = "DeepWiki";
                url = "https://deepwiki.com/";
              }
              {
                name = "GitDiagram";
                url = "https://gitdiagram.com/";
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
              {
                name = "Which LLM";
                url = "https://whichllm.together.ai/use-case";
              }
              {
                url = "https://www.llm-prices.com/";
              }
            ];
          }
        ];
      }
      {
        name = "Development";
        bookmarks = [
          {
            name = "Better Go Playground";
            url = "https://goplay.tools";
          }
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
          {
            name = "Flakehub";
            url = "https://flakehub.com/flakes";
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
          {
            name = "JSON space analyzer";
            url = "https://json-space-analyzer.com/";
          }
          {
            name = "Vanilla JS";
            url = "http://vanilla-js.com/";
          }
          {
            name = " Finance";
            bookmarks = [
              {
                url = "https://companiesmarketcap.com/";
              }

              {
                url = "https://stockanalysis.com/";
              }
            ];
          }
          {
            name = "Firefox settings";
            bookmarks = [
              {url = "https://kb.mozillazine.org/About:config_entries";}
              {url = "https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml";}
              {url = "https://searchfox.org/mozilla-release/source/browser/app/profile/firefox.js";}
              {url = "https://searchfox.org/mozilla-release/source/modules/libpref/init/all.js";}
            ];
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
          {
            name = "Langton's ant";
            url = "https://evolvecode.io/turmites/index.html";
          }
          {
            name = "Reaction diffusion playground";
            url = "https://jasonwebb.github.io/reaction-diffusion-playground";
          }
          {
            name = "Reaction diffusion system (Gray-Scott model)";
            url = "https://pmneila.github.io/jsexp/grayscott";
          }
          {
            name = "Glitch gallery";
            url = "glitchgallery.org";
          }
          {
            name = "Shadertoy";
            url = "https://www.shadertoy.com";
          }
          {
            name = "Mandel Set Explorer";
            url = "https://mandel.gart.nz";
          }
          {
            name = "Fractal explorer";
            url = "https://jsdw.me/js-fractal-explorer";
          }
          {
            name = "Fractal Lab";
            url = "https://hirnsohle.de/test/fractalLab";
          }
          {
            name = "Fractal Garden";
            url = "https://fractal-garden.netlify.app";
          }
          {
            name = "Golly";
            url = "https://golly.sourceforge.io/webapp/golly.html";
          }
          {
            name = "Particle Life 2D";
            url = "https://lisyarus.github.io/webgpu/particle-life.html";
          }
          {
            name = "Web particle";
            url = "https://webgl-particle-life.netlify.app/";
          }
          {
            url = "https://hunar4321.github.io/particle-life/particle_life.html";
          }
          {
            name = "Clusters";
            url = "https://www.ventrella.com/Clusters/";
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
          {
            name = "EigenPhi";
            url = "https://eigenphi.io/";
          }
          {
            name = "ChainID";
            url = "https://chainid.network/chains.json";
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
      {
        name = "Dotfiles";
        toolbar = false;
        bookmarks = [
          {
            name = "Dotfiles";
            url = "https://nvimluau.dev";
          }
          {
            name = "Github neovim";
            url = "https://github.com/topics/neovim";
          }
          {
            name = "Dotfyle";
            url = "https://dotfyle.com/";
          }
          {
            name = "Nvim store";
            url = "https://nvim.store/";
          }
          {
            name = "Reddit neovim";
            url = "https://www.reddit.com/r/neovim/";
          }
          {
            name = "Reddit unixporn";
            url = "https://www.reddit.com/r/unixporn/";
          }
        ];
      }
    ];
  };
}
