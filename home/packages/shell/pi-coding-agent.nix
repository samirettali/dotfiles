{
  pkgs,
  samirettali-nur,
  config,
  lib,
  ...
}: let
  piCodingAgent = samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent;
  piRoot = piCodingAgent + "/lib/node_modules/pi-monorepo";
  piNodeModules = piRoot + "/node_modules";
in {
  home.packages = [
    piCodingAgent
  ];

  home.file = lib.mkIf (builtins.elem piCodingAgent config.home.packages) {
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

    ".pi/agent/extensions/node_modules/@mariozechner/pi-coding-agent".source = piRoot;
    ".pi/agent/extensions/node_modules/@mariozechner/pi-ai".source = piNodeModules + "/@mariozechner/pi-ai";
    ".pi/agent/extensions/node_modules/@mariozechner/pi-tui".source = piNodeModules + "/@mariozechner/pi-tui";
    ".pi/agent/extensions/node_modules/@sinclair/typebox".source = piNodeModules + "/@sinclair/typebox";
    ".pi/agent/extensions/node_modules/@types/node".source = piNodeModules + "/@types/node";
  };
}
