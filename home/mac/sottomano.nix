{
  config,
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
  linkding = "https://links.samirettali.com";
  sketchybar = lib.getExe config.programs.sketchybar.package;

  # A leader entry for the engine and a shifted twin that runs the same search.
  search = key: name: url: [
    {
      inherit key name;
      search = url;
    }
    {
      inherit key;
      search = url;
      shift = true;
    }
  ];

  # The vault picker lists every rbw entry with its site's favicon; the command
  # decides what is typed or copied.
  vaultPick = command: {
    list = ["/bin/sh" "-c" "${rbw} list --raw | ${jq} -r '.[] | [.id, .name, (.user // \"\"), ((.uris // [] | map(select(startswith(\"http\"))) | first // \"\") as $u | if $u == \"\" then \"\" else \"https://\" + ($u | split(\"://\") | last | split(\"/\") | first) + \"/favicon.ico\" end)] | @tsv'"];
    typeOutput = ["/bin/sh" "-c" "${rbw} ${command} \"$1\"" "sh" "{}"];
    copyOutput = ["/bin/sh" "-c" "${rbw} ${command} \"$1\"" "sh" "{}"];
    secret = true;
    cache = "vault";
  };

  # The keymap as it settled, taken back from the file it was tried out in.
  keymap = {
    capsEscape = false;
    controlBracketEscape = true;
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
          cache = "links";
          list = ["/bin/sh" "-c" "${curl} -sS -H \"Authorization: Token $(${rbw} get linkding-api-key)\" '${linkding}/api/bookmarks/archived/?limit=1000' | ${jq} -r '.results[] | [.url, ([.title, .website_title, .url] | map(select(. != null and . != \"\")) | first), (.tag_names // [] | join(\" \")), (.favicon_url // \"\")] | @tsv'"];
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
        entries =
          search "c" "code" "https://github.com/search?q={}&type=code"
          ++ search "g" "google" "https://google.com/search?q={}"
          ++ search "m" "maps" "https://www.google.com/maps/search/{}"
          ++ search "n" "nixos" "https://mynixos.com/search?q={}"
          ++ search "p" "perplexity" "https://perplexity.ai/search?q={}"
          ++ search "r" "repos" "https://github.com/search?q={}&type=repositories"
          ++ search "t" "twitter" "https://x.com/search?q={}&src=typed_query"
          ++ search "y" "youtube" "https://www.youtube.com/results?search_query={}";
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
        launch = "Helium";
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
        key = ",";
        name = "settings";
        launch = "System Settings";
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
            pick = vaultPick "code";
          }
          {
            key = "p";
            name = "password";
            pick = vaultPick "get";
          }
          {
            key = "u";
            name = "username";
            pick = vaultPick "get --field username";
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
        modifiers = ["control" "option"];
      }
      {
        entry = {
          key = "[";
          shell = ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to previous track"];
        };
        key = "[";
        modifiers = ["control" "option"];
      }
      {
        entry = {
          key = "]";
          shell = ["/usr/bin/osascript" "-e" "tell application \"Spotify\" to next track"];
        };
        key = "]";
        modifiers = ["control" "option"];
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
    # The emoji picker has no data until sottomano ships its own:
    # samirettali/sottomano#3.
    "sottomano/keymap.json".source = (pkgs.formats.json {}).generate "keymap.json" keymap;
  };
}
