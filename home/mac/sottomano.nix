{
  config,
  inputs,
  lib,
  nurPkgs,
  pkgs,
  ...
}: let
  # An app launched by `open` inherits launchd's PATH, not the shell's, so every
  # command a binding runs is named by its store path.
  rbw = lib.getExe config.programs.rbw.package;
  spotctl = lib.getExe nurPkgs.spotctl;
  jq = lib.getExe pkgs.jq;
  curl = lib.getExe pkgs.curl;
  sh = "/bin/sh";

  # AppleScript rather than spotctl for transport: it talks to the running app
  # instead of the Web API, which is what bindings.lua did and what keeps a
  # skip instant. spotctl still owns anything that needs the library.
  spotify = command: ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to ${command}"];

  engines = [
    {
      key = "c";
      name = "code";
      url = "https://github.com/search?q={}&type=code";
    }
    {
      key = "g";
      name = "google";
      url = "https://google.com/search?q={}";
    }
    {
      key = "m";
      name = "maps";
      url = "https://www.google.com/maps/search/{}";
    }
    {
      key = "n";
      name = "nixos";
      url = "https://mynixos.com/search?q={}";
    }
    {
      key = "p";
      name = "perplexity";
      url = "https://perplexity.ai/search?q={}";
    }
    {
      key = "r";
      name = "repos";
      url = "https://github.com/search?q={}&type=repositories";
    }
    {
      key = "t";
      name = "twitter";
      url = "https://x.com/search?q={}&src=typed_query";
    }
    {
      key = "y";
      name = "youtube";
      url = "https://www.youtube.com/results?search_query={}";
    }
  ];

  # shift searches whatever is selected instead of asking for it. It carries no
  # name, so it binds without listing every engine in the panel a second time.
  searchLayer =
    lib.concatMap (engine: [
      {
        inherit (engine) key name;
        search = engine.url;
      }
      {
        inherit (engine) key;
        shift = true;
        search = engine.url;
      }
    ])
    engines;

  # rbw takes the entry name as an argument rather than in the command line, so
  # a name with a space or a quote in it cannot break out of the shell.
  vaultEntry = name: command: {
    inherit name;
    pick =
      {
        list = [sh "-c" "${rbw} list"];
      }
      // command;
  };

  keymap = {
    # classic, keyboard, depth or columns
    theme = "classic";

    hotkey = {
      key = "space";
      modifiers = ["command"];
    };

    # The applications picker keeps the binding it had under Hammerspoon, so it
    # opens straight onto the list rather than through the panel.
    hotkeys = [
      {
        key = "space";
        modifiers = ["option"];
        entry = {
          key = "space";
          pick = {
            source = "applications";
            run = ["/usr/bin/open" "-a" "{}"];
          };
        };
      }
      # the media keys bindings.lua had, so Hammerspoon is not needed for them
      {
        key = "delete";
        modifiers = ["option"];
        entry = {
          key = "delete";
          shell = spotify "playpause";
        };
      }
      {
        key = "[";
        modifiers = ["option"];
        entry = {
          key = "[";
          shell = spotify "previous track";
        };
      }
      {
        key = "]";
        modifiers = ["option"];
        entry = {
          key = "]";
          shell = spotify "next track";
        };
      }
    ];

    entries =
      [
        {
          key = "b";
          name = "browser";
          launch = "Firefox";
        }
        {
          key = "t";
          name = "terminal";
          launch = "Ghostty";
        }
        {
          key = "f";
          name = "files";
          browse = "~";
        }
        {
          key = "c";
          name = "clipboard";
          pick = {
            source = "clipboard";
            type = true;
          };
        }
        {
          key = "e";
          name = "emoji";
          pick = {
            source = "emoji";
            type = true;
          };
        }
        {
          key = "l";
          name = "links";
          pick = {
            list = [
              sh
              "-c"
              "${curl} -sf -H \"Authorization: Token $(${rbw} get linkding-api-key)\" 'https://links.samirettali.com/api/bookmarks/?limit=500' | ${jq} -r '.results[] | [.url, (.title // .website_title // .url), .url] | @tsv'"
            ];
            run = ["/usr/bin/open" "{}"];
          };
        }
        {
          key = "m";
          name = "music";
          pick = {
            list = [
              sh
              "-c"
              "${spotctl} playlist list --full | ${jq} -r '.items[] | [.id, .name, (.owner.display_name // \"\")] | @tsv'"
            ];
            run = [sh "-c" "${spotctl} play playlist \"$1\"" "sh" "{}"];
          };
        }
        {
          key = "o";
          name = "open";
          entries = [
            {
              key = "c";
              name = "code";
              launch = "Visual Studio Code";
            }
            {
              key = "d";
              name = "discord";
              launch = "Discord";
            }
            {
              key = "e";
              name = "eqMac";
              launch = "eqMac";
            }
            {
              key = "f";
              name = "finder";
              launch = "Finder";
            }
            {
              key = "m";
              name = "monitor";
              launch = "Activity Monitor";
            }
            {
              key = "o";
              name = "obsidian";
              launch = "Obsidian";
            }
            {
              key = "p";
              name = "preferences";
              launch = "System Settings";
            }
            {
              key = "s";
              name = "spotify";
              launch = "Spotify";
            }
            {
              key = "z";
              name = "zed";
              launch = "Zed";
            }
          ];
        }
        {
          key = "w";
          name = "work";
          entries = [
            {
              key = "c";
              name = "compass";
              launch = "MongoDB Compass";
            }
            {
              key = "d";
              name = "datagrip";
              launch = "DataGrip";
            }
            {
              key = "p";
              name = "postman";
              launch = "Postman";
            }
            {
              key = "r";
              name = "redis";
              launch = "Redis Insight";
            }
            {
              key = "s";
              name = "slack";
              launch = "Slack";
            }
          ];
        }
        {
          key = "p";
          name = "paste";
          entries = [
            {
              key = "e";
              name = "email";
              type = "samir@ettali.com";
            }
            {
              key = "u";
              name = "username";
              type = "samirettali";
            }
            {
              key = "t";
              name = "timestamp";
              typeOutput = ["/bin/date" "+%s"];
            }
            {
              key = "d";
              name = "date";
              typeOutput = ["/bin/date" "-u" "+%Y-%m-%d %H:%M:%S"];
            }
            {
              key = "g";
              name = "uuid";
              typeOutput = ["/usr/bin/uuidgen"];
            }
          ];
        }
        {
          key = "s";
          name = "search";
          entries = searchLayer;
        }
        {
          key = "d";
          name = "display";
          entries = [
            {
              key = "d";
              name = "docked";
              display = "docked";
            }
            {
              key = "s";
              name = "side by side";
              display = "side-by-side";
            }
            {
              key = "e";
              name = "external";
              display = "external";
            }
          ];
        }
        {
          key = "x";
          name = "transform";
          entries = [
            {
              key = "d";
              name = "base64 decode";
              transform = "base64-decode";
            }
            {
              key = "e";
              name = "base64 encode";
              transform = "base64-encode";
            }
            {
              key = "h";
              name = "hex decode";
              transform = "hex-decode";
            }
            {
              key = "x";
              name = "hex encode";
              transform = "hex-encode";
            }
            {
              key = "u";
              name = "url decode";
              transform = "url-decode";
            }
            {
              key = "p";
              name = "url encode";
              transform = "url-encode";
            }
            {
              key = "j";
              name = "jwt";
              transform = "jwt";
            }
            {
              key = "f";
              name = "format json";
              transform = "json";
            }
            {
              key = "t";
              name = "timestamp";
              transform = "timestamp";
            }
          ];
        }
      ]
      ++ lib.optional config.programs.rbw.enable {
        key = "v";
        name = "vault";
        entries = [
          (vaultEntry "password" {run = [sh "-c" "${rbw} get \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
            // {key = "p";})
          (vaultEntry "type" {typeOutput = [sh "-c" "${rbw} get \"$1\"" "sh" "{}"];}
            // {key = "t";})
          (vaultEntry "username" {run = [sh "-c" "${rbw} get --field username \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
            // {key = "u";})
          (vaultEntry "otp" {run = [sh "-c" "${rbw} code \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
            // {key = "o";})
        ];
      };
  };
in {
  # The launcher reads its bindings from here and nothing else, so the keymap is
  # declared like the rest of the configuration rather than edited in place.
  xdg.configFile = {
    "sottomano/keymap.json".source = (pkgs.formats.json {}).generate "keymap.json" keymap;

    # The emojione data ships inside Emojis.spoon, which is already pinned for
    # Hammerspoon. Reduce it here rather than at every open: display drops the
    # duplicate encodings, and an entry with a diversity is one skin tone of
    # another already in the list.
    "sottomano/emoji.json".source = pkgs.runCommandLocal "sottomano-emoji" {} ''
      ${pkgs.python3}/bin/python3 - <<'PY'
      import json, os

      source = "${inputs.spoons}/Source/Emojis.spoon/emojis/emojis.json"
      out = []

      for entry in json.load(open(source)).values():
          if entry.get("display") != 1 or entry.get("diversity"):
              continue

          points = entry["code_points"]["fully_qualified"]

          out.append({
              "glyph": "".join(chr(int(p, 16)) for p in points.split("-")),
              "name": entry["name"],
              "keywords": " ".join(
                  [entry.get("shortname", "").strip(":")] + (entry.get("keywords") or [])
              ).strip(),
              "order": entry.get("order", 0),
          })

      out.sort(key=lambda item: item["order"])

      with open(os.environ["out"], "w") as handle:
          json.dump(out, handle, ensure_ascii=False)
      PY
    '';
  };
}
