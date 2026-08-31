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
in {
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
