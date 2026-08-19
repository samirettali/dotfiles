{
  config,
  inputs,
  lib,
  nurPkgs,
  pkgs,
  vars,
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

  # The keymap as it settled, taken back from the file it was tried out in.
  keymap = {
    capsEscape = true;
    entries = [
      {
        browse = "~";
        key = "f";
        name = "files";
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
          cache = "vault";
          list = ["/bin/sh" "-c" "${rbw} list --raw | ${jq} -r '.[] | [.id, .name, (.user // \"\"), ((.uris // [] | map(select(startswith(\"http\"))) | first // \"\") as $u | if $u == \"\" then \"\" else \"https://\" + ($u | split(\"://\") | last | split(\"/\") | first) + \"/favicon.ico\" end)] | @tsv'"];
          run = ["/usr/bin/open" "{}"];
        };
      }
      {
        key = "m";
        name = "music";
        pick = {
          cache = "playlists";
          list = ["/bin/sh" "-c" "${spotctl} playlist list --full | ${jq} -r '.items[] | [.id, .name, (.owner.display_name // \"\"), (.images[-1].url // \"\")] | @tsv'"];
          run = ["/bin/sh" "-c" "${spotctl} play playlist \"$1\"" "sh" "{}"];
        };
      }
      {
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
            name = "guid";
            typeOutput = ["/usr/bin/uuidgen"];
          }
        ];
        key = "i";
        name = "insert";
      }
      {
        entries = [
          {
            key = "c";
            name = "code";
            search = "https://github.com/search?q={}&type=code";
          }
          {
            key = "c";
            search = "https://github.com/search?q={}&type=code";
            shift = true;
          }
          {
            key = "g";
            name = "google";
            search = "https://google.com/search?q={}";
          }
          {
            key = "g";
            search = "https://google.com/search?q={}";
            shift = true;
          }
          {
            key = "m";
            name = "maps";
            search = "https://www.google.com/maps/search/{}";
          }
          {
            key = "m";
            search = "https://www.google.com/maps/search/{}";
            shift = true;
          }
          {
            key = "n";
            name = "nixos";
            search = "https://mynixos.com/search?q={}";
          }
          {
            key = "n";
            search = "https://mynixos.com/search?q={}";
            shift = true;
          }
          {
            key = "p";
            name = "perplexity";
            search = "https://perplexity.ai/search?q={}";
          }
          {
            key = "p";
            search = "https://perplexity.ai/search?q={}";
            shift = true;
          }
          {
            key = "r";
            name = "repos";
            search = "https://github.com/search?q={}&type=repositories";
          }
          {
            key = "r";
            search = "https://github.com/search?q={}&type=repositories";
            shift = true;
          }
          {
            key = "t";
            name = "twitter";
            search = "https://x.com/search?q={}&src=typed_query";
          }
          {
            key = "t";
            search = "https://x.com/search?q={}&src=typed_query";
            shift = true;
          }
          {
            key = "y";
            name = "youtube";
            search = "https://www.youtube.com/results?search_query={}";
          }
          {
            key = "y";
            search = "https://www.youtube.com/results?search_query={}";
            shift = true;
          }
        ];
        key = "q";
        name = "query";
      }
      {
        entries = [
          {
            display = "docked";
            key = "d";
            name = "docked";
          }
          {
            display = "side-by-side";
            key = "s";
            name = "side by side";
          }
          {
            display = "external";
            key = "e";
            name = "external";
          }
        ];
        key = "d";
        name = "display";
      }
      {
        key = "o";
        name = "open";
        pick = {
          run = ["/usr/bin/open" "-a" "{}"];
          source = "applications";
        };
      }
      {
        key = "b";
        name = "browser";
        launch = "Firefox";
      }
      {
        key = "s";
        name = "spotify";
        launch = "Spotify";
      }
      {
        key = "t";
        name = "terminal";
        launch = "Ghostty";
      }
      {
        key = "p";
        name = "color";
        color = "hex";
      }
      {
        key = "k";
        name = "keyboard";
        layout = "next";
      }
      {
        key = "v";
        name = "vault";
        entries = [
          {
            key = "o";
            name = "otp";
            pick = {
              list = ["/bin/sh" "-c" "${rbw} list --raw | ${jq} -r '.[] | [.id, .name, (.user // \"\"), ((.uris // [] | map(select(startswith(\"http\"))) | first // \"\") as $u | if $u == \"\" then \"\" else \"https://\" + ($u | split(\"://\") | last | split(\"/\") | first) + \"/favicon.ico\" end)] | @tsv'"];
              run = ["/bin/sh" "-c" "${rbw} code \"$1\" | /usr/bin/pbcopy" "sh" "{}"];
              typeOutput = ["/bin/sh" "-c" "${rbw} code \"$1\"" "sh" "{}"];
              cache = "vault";
            };
          }
          {
            key = "p";
            name = "password";
            pick = {
              list = ["/bin/sh" "-c" "${rbw} list --raw | ${jq} -r '.[] | [.id, .name, (.user // \"\"), ((.uris // [] | map(select(startswith(\"http\"))) | first // \"\") as $u | if $u == \"\" then \"\" else \"https://\" + ($u | split(\"://\") | last | split(\"/\") | first) + \"/favicon.ico\" end)] | @tsv'"];
              run = ["/bin/sh" "-c" "${rbw} get \"$1\" | /usr/bin/pbcopy" "sh" "{}"];
              typeOutput = ["/bin/sh" "-c" "${rbw} get \"$1\"" "sh" "{}"];
              cache = "vault";
            };
          }
          {
            key = "u";
            name = "username";
            pick = {
              list = ["/bin/sh" "-c" "${rbw} list --raw | ${jq} -r '.[] | [.id, .name, (.user // \"\"), ((.uris // [] | map(select(startswith(\"http\"))) | first // \"\") as $u | if $u == \"\" then \"\" else \"https://\" + ($u | split(\"://\") | last | split(\"/\") | first) + \"/favicon.ico\" end)] | @tsv'"];
              run = ["/bin/sh" "-c" "${rbw} get --field username \"$1\" | /usr/bin/pbcopy" "sh" "{}"];
              typeOutput = ["/bin/sh" "-c" "${rbw} get --field username \"$1\"" "sh" "{}"];
              cache = "vault";
            };
          }
        ];
      }
    ];
    hooks = {
      inputSourceChanged = ["${sketchybar}" "--trigger" "keyboard_layout_change" "SOURCE_ID={}"];
    };
    hotkey = {
      key = "space";
      modifiers = ["command"];
    };
    hotkeys = [
      {
        entry = {
          key = "delete";
          shell = ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to playpause"];
        };
        key = "delete";
        modifiers = ["option"];
      }
      {
        entry = {
          key = "[";
          shell = ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to previous track"];
        };
        key = "[";
        modifiers = ["option"];
      }
      {
        entry = {
          key = "]";
          shell = ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to next track"];
        };
        key = "]";
        modifiers = ["option"];
      }
    ];
    theme = {
      font = vars.font.name;
      # font = "Avenir Next";
      shape = "list";
      flow = "columns";
      key = "column";
      arrow = true;
      title = false;
      group = true;
      size = 18;
      padding = 24;
      radius = 14;
      borderWidth = 0;
      animation = 0;
      background = "#000000";
      border = "#ffffff4d";
      text = "#ffffff";
      muted = "#ffffffae";
      rule = "#ffffff24";
      selection = "#ffffff1f";
      top = 0.25;
      iconSize = 38;
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
