import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { resolve } from "node:path";
import { test } from "node:test";

const profiles = JSON.parse(execFileSync("nix", ["eval", "--impure", "--json", "--expr", `
  let
    lib = {
      optionals = enabled: values: if enabled then values else [];
      concatMapStringsSep = separator: f: values:
        builtins.concatStringsSep separator (map f values);
    };
    pkgs = builtins.listToAttrs (map (name: { inherit name; value = name; }) [
      "nodejs" "pnpm" "typescript-language-server" "eslint_d" "eslint"
      "js-beautify" "prettierd" "vscode-langservers-extracted"
    ]);
  in map (js: let
    config.features = { inherit js; web3 = false; dart = false; };
    tools = import ${JSON.stringify(resolve("home/packages/dev/js.nix"))} { inherit config lib pkgs; };
    editor = import ${JSON.stringify(resolve("home/packages/shell/neovim.nix"))} {
      inherit config lib pkgs;
      neovimPackage = null;
    };
  in {
    inherit js;
    packages = tools.home.packages;
    servers = editor.home.file.".config/nvim/lua/lsp-features.lua".text;
  }) [false "minimal" "full"]
`], { encoding: "utf8" }));

for (const profile of profiles) {
  test(`JavaScript ${profile.js}: TypeScript follows minimal, ESLint follows full`, () => {
    const enabled = profile.js !== false;
    const full = profile.js === "full";
    assert.equal(profile.packages.includes("typescript-language-server"), enabled);
    assert.equal(profile.servers.includes('"ts_ls"'), enabled);
    assert.equal(profile.packages.includes("eslint"), full);
    assert.equal(profile.servers.includes('"eslint"'), full);
  });
}
