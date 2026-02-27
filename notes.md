## Disable tests for a package

```nix
nixpkgsConfig = {
  overlays = with inputs; [
    (final: prev: {
      fish = prev.fish.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];
```

## Find out why a package is being built

```sh
nix why-depends .#darwinConfigurations."settali".system nixpkgs#jeepney
```
