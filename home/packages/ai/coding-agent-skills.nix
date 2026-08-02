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

  spotifySkill = pkgs.runCommand "spotify-skill" {} ''
    mkdir -p $out
    cp -R ${inputs.spotctl}/.agents/skills/spotify/. $out/
    chmod -R u+w $out
    printf '\n' >> $out/SKILL.md
    cat ${./skills/spotify/listening-profile.md} >> $out/SKILL.md
  '';
in {
  better-accessibility = "${inputs.jakubkrehel-skills}/skills/better-accessibility";
  better-colors = "${inputs.jakubkrehel-skills}/skills/better-colors";
  better-interface = "${inputs.jakubkrehel-skills}/skills/better-interface";
  better-layout = "${inputs.jakubkrehel-skills}/skills/better-layout";
  better-typography = "${inputs.jakubkrehel-skills}/skills/better-typography";
  better-ui = "${inputs.jakubkrehel-skills}/skills/better-ui";
  better-writing = "${inputs.jakubkrehel-skills}/skills/better-writing";
  commit = "${inputs.agent-stuff}/skills/commit";
  frontend-design = "${inputs.agent-stuff}/skills/frontend-design";
  generate-image = ./skills/generate-image;
  generate-speech = ./skills/generate-speech;
  github = "${inputs.agent-stuff}/skills/github";
  hallmark = "${inputs.hallmark}/skills/hallmark";
  i-have-adhd = ./skills/i-have-adhd;
  native-web-search = "${inputs.agent-stuff}/skills/native-web-search";
  project-workflow = ./skills/project-workflow;
  remotion-best-practices = "${inputs.remotion-skills}/skills/remotion-best-practices";
  spotify = "${spotifySkill}";
  uv = "${inputs.agent-stuff}/skills/uv";
  web-browser = "${webBrowserSkill}";
}
