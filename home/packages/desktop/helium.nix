{
  config,
  lib,
  pkgs,
  nurPkgs,
  ...
}: let
  inherit (nurPkgs) widevine-cdm chrome-extensions;

  # NUR ships the bundle imput signed. Widevine needs the library-validation flag
  # gone, which only re-signing clears, so the CDM costs a signature of our own.
  #
  # `signingIdentity` stays unset even though a Developer ID would keep one
  # stable Team ID across version bumps: nix builds as `_nixbld`, which cannot
  # reach the login Keychain, and codesign fails with `no identity found`.
  helium = nurPkgs.helium.override {enableWidevine = true;};

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

  # The copied application is the stable path across rebuilds. docs/macos-tcc.md
  # explains the rest.
  home.sessionVariables = lib.mkIf enable {
    BROWSER_BIN = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Helium.app/Contents/MacOS/Helium";
  };
}
