{
  lib,
  stdenv,
  bun,
  nodejs,
  makeWrapper,
  source,
  pkgs,
  pkg-config,
  python3,
  vips,
  cacert,
  patchelf,
}:
stdenv.mkDerivation {
  pname = "opencode";
  version = "latest";

  src = source;

  nativeBuildInputs = [
    bun
    nodejs
    makeWrapper
    python3
    pkg-config
    vips
    cacert
    patchelf
  ];

  configurePhase = ''
    runHook preConfigure

    export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
    export HOME="$TMPDIR"
    export npm_config_cache="$TMPDIR/.npm"
    export npm_config_userconfig="$TMPDIR/.npmrc"
    export SHARP_IGNORE_GLOBAL_LIBVIPS=1

    mkdir -p "$TMPDIR/.npm"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Install dependencies
    bun install --frozen-lockfile

    # Build SDK package - compile TypeScript to JavaScript
    cd packages/sdk/js
    ${pkgs.bun}/bin/bun build src/index.ts --outdir dist --target node --format esm
    cd ../../..

    # Build plugin package if it has a build step
    cd packages/plugin
    if [ -f "src/index.ts" ]; then
      ${pkgs.bun}/bin/bun build src/index.ts --outdir dist --target node --format esm
    fi
    cd ../..

    # Run typecheck to ensure build is valid
    bun run typecheck

    runHook postBuild
  '';

  installPhase = ''
                runHook preInstall

                mkdir -p $out/bin $out/lib/opencode

                # Copy the entire workspace structure to preserve symlinks
                cp -r . $out/lib/opencode/

                # Create wrapper script that preserves user's working directory
                cat > $out/bin/opencode << EOF
    #!/usr/bin/env bash
    USER_CWD="\$(pwd)"
    cd "$out/lib/opencode"
    export NODE_PATH="$out/lib/opencode/node_modules"
    export PATH="${pkgs.lib.makeBinPath [pkgs.git pkgs.curl]}:\$PATH"
    cd "\$USER_CWD"
    exec ${pkgs.bun}/bin/bun run "$out/lib/opencode/packages/opencode/src/index.ts" "\$@"
    EOF
                chmod +x $out/bin/opencode

                runHook postInstall
  '';

  meta = with lib; {
    description = "AI-powered code editor";
    homepage = "https://github.com/sst/opencode";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
  };
}
