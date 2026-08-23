{
  config,
  lib,
  pkgs,
  nurPkgs,
  ...
}: let
  inherit (nurPkgs) helium widevine-cdm chrome-extensions;

  # The CDM and the external extensions are wired for macOS only: nothing here
  # has been tried against the Linux build's profile layout.
  enable = pkgs.stdenv.hostPlatform.isDarwin;
  profile = "Library/Application Support/net.imput.helium";

  # Helium has no Web Store and no component updater, so both of these arrive
  # from the store instead: the CDM in the directory the component updater would
  # have filled, the extensions as CRX files an external-extension file points at.
  # See docs/helium.md.
  widevine = {
    "${profile}/WidevineCdm/${widevine-cdm.version}".source = widevine-cdm;
  };

  externalExtensions = lib.mapAttrs' (id: entry:
    lib.nameValuePair "${profile}/External Extensions/${id}.json" {
      text = builtins.toJSON {
        external_crx = "${chrome-extensions}/${id}.crx";
        external_version = entry.version;
      };
    })
  chrome-extensions.entries;
in {
  home.packages = [helium];

  home.file = lib.mkIf enable (widevine // externalExtensions);

  # Ad-hoc signed, so macOS identifies it by path: the copied application is the
  # only stable one across rebuilds. docs/macos-tcc.md explains the rest.
  home.sessionVariables = lib.mkIf enable {
    BROWSER_BIN = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Helium.app/Contents/MacOS/Helium";
  };
}
