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
    cp -R ${../../../.agents/skills/spotify}/. $out/
    chmod -R u+w $out
    cat >> $out/SKILL.md <<'EOF'

    ## Samir's listening profile

    Treat this as a durable starting point, not a substitute for current top-item
    and recent-history data:

    - The stable core is dark, high-energy, emotionally melodic electronic music:
      hard techno, rave, trance, acid, breakbeat, and cinematic club tracks. Strong
      reference points include Funk Tribu, Indecorum, Montee, DJ HEARTSTRING,
      The Prodigy, Underworld, and the Blade, Matrix, and videogame-soundtrack
      aesthetic.
    - Rap taste favors technical writing, distinctive flows, and underground scenes.
      French rap is a long-term anchor (Alpha Wann, Freeze Corleone, Hugo TSR, IAM,
      Nekfeu, Dinos, Sinik, and Fonky Family), while recent listening has shifted
      toward Italian rap and songwriting (Caparezza, Shiva, Guè, Rhove, Luchè, and
      Baby Gang).
    - Melancholy cuts across genres: trip-hop, emo rap, alternative rock, piano,
      modern classical, and film scores all recur. Portishead, Massive Attack, Moby,
      Linkin Park, System Of A Down, Einaudi, Satie, and Apparat are useful anchors.
    - Listening is multilingual and exploratory, spanning Italian, French, Arabic
      and Moroccan, Spanish, German, Russian, and Romani-adjacent music. Language is
      not a reason to filter a recommendation out.
    - Samir alternates between playlist-driven electronic discovery and focused
      album or artist deep dives. The catalog has high churn, so recent history
      should outweigh this profile when it shows a clear new phase.
    - Recommendations should favor specific, slightly niche adjacency over generic
      mainstream similarity. Preserve the dark, propulsive, lyrical, cinematic, or
      nostalgic quality that links the otherwise broad genres.
    EOF
  '';
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
  remotion-best-practices = "${inputs.remotion-skills}/skills/remotion-best-practices";
  spotify = "${spotifySkill}";
  uv = "${inputs.agent-stuff}/skills/uv";
  web-browser = "${webBrowserSkill}";
}
