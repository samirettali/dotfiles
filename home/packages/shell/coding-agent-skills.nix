{
  inputs,
  pkgs,
}: let
  webBrowserSkill = pkgs.buildNpmPackage {
    pname = "agent-stuff-web-browser-skill";
    version = "unstable";
    src = inputs.agent-stuff + "/skills/web-browser/scripts";
    npmDepsHash = "sha256-vQxKChe57on93GAA180X/W36YNeumg7zPlcPhrT+yXQ=";
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R ${inputs.agent-stuff}/skills/web-browser/. $out/
      chmod -R u+w $out
      cp -R node_modules $out/scripts/

      runHook postInstall
    '';
  };
in {
  hallmark = "${inputs.hallmark}/skills/hallmark";
  native-web-search = "${inputs.agent-stuff}/skills/native-web-search";
  web-browser = "${webBrowserSkill}";
}
