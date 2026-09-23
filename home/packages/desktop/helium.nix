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
  # The store copy is signed ad hoc; the activation below re-signs the copied app
  # with the Developer ID, because nix builds as `_nixbld`, which cannot reach
  # the login Keychain.
  helium = nurPkgs.helium.override {enableWidevine = true;};

  # One Team ID across version bumps keeps the TCC grants and the `Helium Safe
  # Storage` Keychain item, which an ad-hoc signature loses on every bump.
  signingIdentity = "Developer ID Application: Samir Ettali (22K9H4B864)";
  teamId = "22K9H4B864";
  app = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Helium.app";

  # The NUR package's set, which Chromium needs under the hardened runtime, plus
  # the camera and microphone entitlements upstream's own signature carries.
  entitlements = pkgs.writeText "helium-entitlements.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.cs.allow-jit</key>
      <true/>
      <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
      <true/>
      <key>com.apple.security.cs.disable-executable-page-protection</key>
      <true/>
      <key>com.apple.security.cs.disable-library-validation</key>
      <true/>
      <key>com.apple.security.cs.allow-dyld-environment-variables</key>
      <true/>
      <key>com.apple.security.device.audio-input</key>
      <true/>
      <key>com.apple.security.device.camera</key>
      <true/>
    </dict>
    </plist>
  '';

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

  # copyApps restores the store's ad-hoc bytes on every activation, so this signs
  # again each time; it takes about two seconds. Inside-out, like the NUR package:
  # signing a helper after its framework would break the framework's seal.
  home.activation.signHelium = lib.mkIf enable (lib.hm.dag.entryAfter ["copyApps"] ''
    signHelium() {
      local app=${lib.escapeShellArg app}
      sign() {
        run /usr/bin/codesign --force --sign ${lib.escapeShellArg signingIdentity} \
          --options runtime --entitlements ${entitlements} --timestamp=none "$1"
      }
      local versionDir helper
      for versionDir in "$app/Contents/Frameworks/Helium Framework.framework/Versions/"*; do
        [[ -L "$versionDir" ]] && continue
        for helper in "$versionDir/Helpers/"*; do
          sign "$helper" || return 1
        done
        sign "$versionDir" || return 1
      done
      sign "$app"
    }

    if [[ -d ${lib.escapeShellArg app} ]] \
      && ! /usr/bin/codesign -dv ${lib.escapeShellArg app} 2>&1 | grep -x 'TeamIdentifier=${teamId}' > /dev/null; then
      signHelium > /dev/null 2>&1 \
        || warnEcho "Helium could not be signed with the Developer ID; it keeps the ad-hoc signature. See docs/helium.md."
    fi
  '');

  # The copied application is the stable path across rebuilds. docs/macos-tcc.md
  # explains the rest.
  home.sessionVariables = lib.mkIf enable {
    BROWSER_BIN = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Helium.app/Contents/MacOS/Helium";
  };
}
