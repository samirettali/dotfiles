{
  pkgs,
  nurPkgs,
  config,
  lib,
  inputs,
  ...
}: let
  piCodingAgent = nurPkgs.pi-coding-agent;
  piPackageDir = piCodingAgent + "/share/pi-coding-agent";
  piRuntimeRoot = piCodingAgent + "/lib/node_modules/pi-monorepo";
  piNodeModules = piRuntimeRoot + "/node_modules";

  skills = import ../coding-agent-skills.nix {inherit inputs;};
  skillFiles =
    lib.mapAttrs'
    (name: src: lib.nameValuePair ".pi/agent/skills/${name}" {source = src;})
    skills;
in {
  home.packages = [
    piCodingAgent
  ];

  home.sessionVariables = {
    PI_PACKAGE_DIR = "${config.home.homeDirectory}/.pi/pi-source";
  };

  home.file = lib.mkIf (builtins.elem piCodingAgent config.home.packages) (skillFiles
    // {
      ".pi/pi-source".source = piPackageDir;

      ".pi/agent/extensions/package.json".text = builtins.toJSON {
        name = "pi-agent-extensions";
        private = true;
        type = "module";
      };

      ".pi/agent/extensions/tsconfig.json".text = builtins.toJSON {
        compilerOptions = {
          target = "ES2022";
          module = "NodeNext";
          moduleResolution = "NodeNext";
          strict = true;
          noEmit = true;
          skipLibCheck = true;
          types = ["node"];
        };
        include = ["./**/*.ts"];
        exclude = ["./node_modules"];
      };

      ".pi/agent/extensions/ask-user-question.ts".source = ./extensions/ask-user-question.ts;
      ".pi/agent/extensions/memory.ts".source = ./extensions/memory.ts;
      ".pi/agent/extensions/permission-gate.ts".source = ./extensions/permission-gate.ts;
      ".pi/agent/extensions/protected-paths.ts".source = ./extensions/protected-paths.ts;
      ".pi/agent/extensions/system-prompt.ts".source = ./extensions/system-prompt.ts;

      ".pi/agent/extensions/node_modules/@mariozechner/pi-coding-agent".source = piRuntimeRoot;
      ".pi/agent/extensions/node_modules/@mariozechner/pi-ai".source = piNodeModules + "/@mariozechner/pi-ai";
      ".pi/agent/extensions/node_modules/@mariozechner/pi-tui".source = piNodeModules + "/@mariozechner/pi-tui";
      ".pi/agent/extensions/node_modules/@sinclair/typebox".source = piNodeModules + "/@sinclair/typebox";
      ".pi/agent/extensions/node_modules/@types/node".source = piNodeModules + "/@types/node";
    });
}
