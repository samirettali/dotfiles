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
  better-colors = "${inputs.jakubkrehel-skills}/skills/better-colors";
  better-typography = "${inputs.jakubkrehel-skills}/skills/better-typography";
  better-ui = "${inputs.jakubkrehel-skills}/skills/better-ui";
  commit = "${inputs.agent-stuff}/skills/commit";
  frontend-design = "${inputs.agent-stuff}/skills/frontend-design";
  generate-speech = ./skills/generate-speech;
  github = "${inputs.agent-stuff}/skills/github";
  hallmark = "${inputs.hallmark}/skills/hallmark";
  native-web-search = "${inputs.agent-stuff}/skills/native-web-search";
  uv = "${inputs.agent-stuff}/skills/uv";
  web-browser = "${webBrowserSkill}";
}
