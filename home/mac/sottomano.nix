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
  sketchybar = lib.getExe config.programs.sketchybar.package;

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

    # control tapped on its own is escape, control held is control — macOS
    # already maps caps lock to control, so this is what gives caps both roles.
    # It replaces ControlEscape.spoon and, like it, needs Accessibility and
    # stops while macOS holds Secure Input.
    capsEscape = true;

    hooks = {
      # sketchybar has no event of its own for a layout change, so it is pushed
      # one. Both when the launcher switches and when anything else does.
      inputSourceChanged = [sketchybar "--trigger" "keyboard_layout_change" "SOURCE_ID={}"];
    };

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
      {
        key = "l";
        modifiers = ["command" "control"];
        entry = {
          key = "l";
          layout = "next";
        };
      }
      {
        key = "l";
        modifiers = ["command" "shift"];
        entry = {
          key = "l";
          shell = ["/usr/bin/open" "-a" "ScreenSaverEngine"];
        };
      }
      # Registering a hotkey consumes the key, so an entry that does nothing is
      # how cmd+m and cmd+h stop minimising and hiding windows.
      {
        key = "m";
        modifiers = ["command"];
        entry = {key = "m";};
      }
      {
        key = "h";
        modifiers = ["command"];
        entry = {key = "h";};
      }
      {
        key = "h";
        modifiers = ["command" "option"];
        entry = {key = "h";};
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
            # kept on disk under this name: linkding answers over the tailnet in
            # about half a second, and the panel should not wait for it
            cache = "links";
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
            cache = "playlists";
            list = [
              sh
              "-c"
              "${spotctl} playlist list --full | ${jq} -r '.items[] | [.id, .name, (.owner.display_name // \"\")] | @tsv'"
            ];
            run = [sh "-c" "${spotctl} play playlist \"$1\"" "sh" "{}"];
          };
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
        {
          key = "n";
          name = "notes";
          launch = "Obsidian";
        }
        {
          key = "a";
          name = "activity monitor";
          launch = "Activity Monitor";
        }
        {
          key = ",";
          name = "preferences";
          launch = "System Settings";
        }
        # insert rather than paste: it types text, and it is the letter vim uses
        # for exactly that. paste wanted the p that password already has.
        {
          key = "i";
          name = "insert";
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
          key = "q";
          name = "query";
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
      ]
      ++ lib.optionals config.programs.rbw.enable [
        (vaultEntry "password" {run = [sh "-c" "${rbw} get \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
          // {key = "p";})
        (vaultEntry "username" {run = [sh "-c" "${rbw} get --field username \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
          // {key = "u";})
        (vaultEntry "otp" {run = [sh "-c" "${rbw} code \"$1\" | /usr/bin/pbcopy" "sh" "{}"];}
          // {key = "o";})
      ];
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
