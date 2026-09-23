{
  pkgs,
  nurPkgs,
}: let
  pi = nurPkgs.pi-coding-agent;
  runtime = "${pi}/lib/node_modules/pi-monorepo";
  modules = "${runtime}/node_modules";
  extensionModules = pkgs.linkFarm "pi-extension-node-modules" [
    {
      name = "@earendil-works/pi-coding-agent";
      path = runtime;
    }
    {
      name = "@earendil-works/pi-ai";
      path = "${modules}/@earendil-works/pi-ai";
    }
    {
      name = "@earendil-works/pi-tui";
      path = "${modules}/@earendil-works/pi-tui";
    }
    {
      name = "typebox";
      path = "${modules}/typebox";
    }
    {
      name = "@types/node";
      path = "${modules}/@types/node";
    }
  ];
in
  pkgs.mkShellNoCC {
    # Match the tsserver version used by typescript-language-server.
    packages = with pkgs; [git nodejs typescript_5 typescript-language-server];
    PI_TEST_PACKAGE = pi;

    shellHook = ''
      repo_root="$(git rev-parse --show-toplevel)" || exit 1
      modules="$repo_root/home/packages/ai/pi-coding-agent/node_modules"
      if [ -e "$modules" ] && [ ! -L "$modules" ]; then
        echo "Refusing to replace existing directory: $modules" >&2
        exit 1
      fi
      if [ -L "$modules" ]; then
        case "$(readlink "$modules")" in
          /nix/store/*-pi-extension-node-modules) ;;
          *) echo "Refusing to replace unrelated symlink: $modules" >&2; exit 1 ;;
        esac
      fi
      ln -sfn ${extensionModules} "$modules" || exit 1
      unset repo_root modules
    '';
  }
