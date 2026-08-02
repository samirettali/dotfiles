{
  lib,
  pkgs,
  ...
}: let
  src = pkgs.runCommand "agent-bus-src" {} ''
    mkdir -p $out
    cp ${./bus.ts} $out/bus.ts
    cp ${./cli.ts} $out/cli.ts
  '';

  agent-bus = pkgs.writeShellScriptBin "agent-bus" ''
    exec ${lib.getExe pkgs.bun} run ${src}/cli.ts "$@"
  '';

  hook = command: [
    {
      hooks = [
        {
          type = "command";
          command = "${lib.getExe agent-bus} ${command}";
        }
      ];
    }
  ];
in {
  home.packages = [agent-bus];

  programs.claude-code.settings.hooks = {
    SessionStart = hook "hook-session-start";
    Stop = hook "hook-stop";
    SessionEnd = hook "hook-session-end";
  };
}
