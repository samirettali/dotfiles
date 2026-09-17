{
  lib,
  pkgs,
  ...
}: let
  pinentry = pkgs.writeShellApplication {
    name = "rbw-pinentry";
    text = ''
      if [[ "''${PINENTRY_USER_DATA:-}" == "rbw-interactive" ]]; then
        exec ${lib.getExe pkgs.pinentry-curses} "$@"
      fi

      printf 'OK rbw pinentry guard\n'
      while IFS= read -r request; do
        case "$request" in
          GETPIN*)
            printf 'ERR 83886179 pinentry disabled for non-interactive rbw calls\n'
            exit 0
            ;;
          BYE*)
            printf 'OK closing connection\n'
            exit 0
            ;;
          *) printf 'OK\n' ;;
        esac
      done
    '';
  };

  # `rbw get x | pbcopy` puts a plain string on the pasteboard, and every
  # clipboard manager keeps it. This one adds the concealed marker that the
  # managers agree to skip, sottomano included, and drops the trailing newline
  # that would submit the form the password is pasted into. JXA rather than a
  # compiled tool: it starts in a third of a second and needs no toolchain.
  pbconceal = pkgs.writeTextFile {
    name = "pbconceal";
    destination = "/bin/pbconceal";
    executable = true;
    text = ''
      #!/usr/bin/osascript -l JavaScript
      ObjC.import("AppKit")
      const data = $.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile
      let text = ObjC.unwrap($.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding))
      if (text.endsWith("\n")) text = text.slice(0, -1)
      const board = $.NSPasteboard.generalPasteboard
      board.clearContents
      board.setStringForType(text, $.NSPasteboardTypeString)
      board.setStringForType("", "org.nspasteboard.ConcealedType")
    '';
  };
in {
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [pbconceal];

  programs.rbw = {
    enable = true;
    settings = {
      email = "samir@ettali.com";
      base_url = "https://vw.samirettali.com";
      lock_timeout = 43200;
      pinentry =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pinentry
        else pkgs.pinentry-curses;
    };
  };
}
