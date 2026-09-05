{
  inputs,
  pkgs,
}: let
  manualSkill = name: source:
    pkgs.runCommand "${name}-manual-skill" {nativeBuildInputs = [pkgs.yq-go];} ''
      mkdir -p $out
      cp -R ${source}/. $out/
      chmod -R u+w $out
      yq --front-matter=process -i '."disable-model-invocation" = true' $out/SKILL.md
      mkdir -p $out/agents
      touch $out/agents/openai.yaml
      yq -i '.policy.allow_implicit_invocation = false' $out/agents/openai.yaml
    '';

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

  # Shannon's own wrapper delegates to a tmux-only discovery script at a
  # hardcoded pack path. Swap in the herdr implementation; SKILL.md already
  # calls scripts/shannon-find-nvim.sh, so nothing else changes.
  shannonNeovimSkill = pkgs.runCommand "shannon-neovim-skill" {} ''
    mkdir -p $out
    cp -R ${inputs.wincent-agent-plugins}/pi/skills/neovim/. $out/
    chmod -R u+w $out
    install -m755 ${./skills/shannon-neovim/shannon-find-nvim.sh} $out/scripts/shannon-find-nvim.sh
    # Upstream ships this skill inside a plugin, where the name comes from the
    # directory. Installed as a personal skill it needs the frontmatter field.
    sed -i '1a name: neovim' $out/SKILL.md
  '';

  spotifySkill = pkgs.runCommand "spotify-skill" {} ''
    mkdir -p $out
    cp -R ${inputs.spotctl}/.agents/skills/spotify/. $out/
    chmod -R u+w $out
    printf '\n' >> $out/SKILL.md
    cat ${./skills/spotify/listening-profile.md} >> $out/SKILL.md
  '';

  monidSkill = pkgs.runCommand "monid-skill" {} ''
    mkdir -p $out
    cp ${inputs."monid-skill"} $out/SKILL.md
  '';
in {
  agent-messaging = ./skills/agent-messaging;
  android = ./skills/android;
  code-review = ./skills/code-review;
  commit = ./skills/commit;
  design = ../../../.agents/skills/design;
  generate-image = ./skills/generate-image;
  generate-music = ./skills/generate-music;
  generate-speech = ./skills/generate-speech;
  herdr = ./skills/herdr;
  linkding = ./skills/linkding;
  live-ui-variants = ./skills/live-ui-variants;
  lyrics = ./skills/lyrics;
  macos-app-release = ./skills/macos-app-release;
  monid = "${monidSkill}";
  native-web-search = "${inputs.agent-stuff}/skills/native-web-search";
  neovim = "${manualSkill "neovim" shannonNeovimSkill}";
  project-workflow = ./skills/project-workflow;
  remotion-best-practices = "${inputs.remotion-skills}/skills/remotion-best-practices";
  show-me = "${manualSkill "show-me" "${inputs.humanlayer-skills}/plugins/show-me/skills/show-me"}";
  side-project = ./skills/side-project;
  spotify = "${spotifySkill}";
  uv = "${inputs.agent-stuff}/skills/uv";
  web-browser = "${webBrowserSkill}";
  x-search = ./skills/x-search;
}
