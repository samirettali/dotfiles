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
    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R ${inputs.agent-stuff}/skills/web-browser/. $out/
      chmod -R u+w $out
      cp -R node_modules $out/scripts/
      cp ${./skills/web-browser}/*.js $out/scripts/
      cat ${./skills/web-browser/additions.md} >> $out/SKILL.md

      substituteInPlace $out/scripts/watch.js \
        --replace-fail 'import { connect } from "./cdp.js";' 'import { connect } from "./cdp.js"; import { captureHeaders } from "./headers.js";' \
        --replace-fail 'hasPostData: !!request.hasPostData,' 'hasPostData: !!request.hasPostData, headers: captureHeaders(request.headers),' \
        --replace-fail 'mimeType: response.mimeType || null,' 'mimeType: response.mimeType || null, headers: captureHeaders(response.headers),'

      for command in nav eval screenshot emulate pick dismiss-cookies; do
        mv $out/scripts/$command.js $out/scripts/$command.unlocked.js
        makeWrapper ${pkgs.nodejs}/bin/node $out/scripts/$command.js \
          --add-flags "$out/scripts/serialized.js $out/scripts/$command.unlocked.js"
      done
      for command in click fill; do
        makeWrapper ${pkgs.nodejs}/bin/node $out/scripts/$command.js \
          --add-flags "$out/scripts/serialized.js $out/scripts/interact.js $command"
      done
      chmod +x $out/scripts/logs.js

      runHook postInstall
    '';
  };

  spotifySkill = pkgs.runCommand "spotify-skill" {} ''
    mkdir -p $out
    cp -R ${inputs.spotctl}/.agents/skills/spotify/. $out/
    chmod -R u+w $out
    printf '\n' >> $out/SKILL.md
    cat ${./skills/spotify/additions.md} >> $out/SKILL.md
    cp ${./skills/spotify/listening-profile.md} $out/listening-profile.md
  '';

  minifluxSkill = "${inputs.fluxctl}/.agents/skills/miniflux";

  linkdingSkill = "${inputs.linkctl}/.agents/skills/linkding";

  monidSkill = pkgs.runCommand "monid-skill" {} ''
    mkdir -p $out
    cp ${inputs."monid-skill"} $out/SKILL.md
  '';

  # Upstream saves the description under .humanlayer/tasks/, the working
  # directory of HumanLayer's own product. Without it the skill creates that
  # directory in whatever repository it runs in, to hold a copy of a body that
  # already lives on GitHub. The bundled references/show-me.md is a stale copy
  # of the show-me skill and points at the same place.
  visualPrSkill = pkgs.runCommand "visual-pr-skill" {} ''
    mkdir -p $out
    cp -R ${inputs.humanlayer-skills}/plugins/visual-pr/skills/visual-pr/. $out/
    chmod -R u+w $out

    substituteInPlace $out/SKILL.md \
      --replace-fail '`.humanlayer/tasks/{task-slug}/pr-description.md` when the task directory exists; otherwise use `.humanlayer/tasks/pr-{number}/description.md`' 'a temporary file outside the repository, such as `$(mktemp -t pr-description)`. Never create a directory in the working tree to hold it'

    substituteInPlace $out/references/show-me.md \
      --replace-fail 'then display it inline:' 'then open it for the user:' \
      --replace-fail '```task-artifact' '```' \
      --replace-fail '.humanlayer/tasks/{task-slug}/show-me-{description}.html' 'Bash(open path/to/show-me-{description}.html)'

    grep -q 'Description saved' $out/references/describe_pr_final_answer.md
    sed -i '/Description saved/d' $out/references/describe_pr_final_answer.md
  '';
in {
  agent-messaging = ./skills/agent-messaging;
  android = ./skills/android;
  code-review = ./skills/code-review;
  commit = ./skills/commit;
  design = ./skills/design;
  firecrawl-search = ./skills/firecrawl-search;
  firecrawl-scrape = ./skills/firecrawl-scrape;
  firecrawl-developer-index = ./skills/firecrawl-developer-index;
  firecrawl-research-index = ./skills/firecrawl-research-index;
  generate-image = ./skills/generate-image;
  generate-music = ./skills/generate-music;
  generate-speech = ./skills/generate-speech;
  herdr = ./skills/herdr;
  hunk = ./skills/hunk;
  ideas = ./skills/ideas;
  linkding = "${manualSkill "linkding" linkdingSkill}";
  live-ui-variants = ./skills/live-ui-variants;
  lyrics = ./skills/lyrics;
  miniflux = "${manualSkill "miniflux" minifluxSkill}";
  macos-app-release = ./skills/macos-app-release;
  monid = "${manualSkill "monid" monidSkill}";
  project-workflow = ./skills/project-workflow;
  remotion-best-practices = "${manualSkill "remotion-best-practices" "${inputs.remotion-skills}/skills/remotion-best-practices"}";
  show-me = "${manualSkill "show-me" "${inputs.humanlayer-skills}/plugins/show-me/skills/show-me"}";
  side-project = ./skills/side-project;
  spotify = "${manualSkill "spotify" spotifySkill}";
  subagents = ./skills/subagents;
  tavily = ./skills/tavily;
  uv = "${inputs.agent-stuff}/skills/uv";
  visual-pr = "${manualSkill "visual-pr" visualPrSkill}";
  web-browser = "${webBrowserSkill}";
  x-search = ./skills/x-search;
  x-post = "${manualSkill "x-post" "${inputs.skills}/x-post"}";
}
