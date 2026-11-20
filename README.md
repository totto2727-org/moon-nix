# moon-nix

Build a native MoonBit executable with Nix and the official `moon build` command.
Nix reads module manifests, resolves dependencies against a locked Mooncakes index, and stages checksum-verified archives and local modules in a workspace.
Moon reads `moon.pkg` files and handles compilation and linking.

See [Upstream differences](docs/upstream-differences.md) for how this fork differs from `moonbit-community/moon-nix`.

## Build a project

Add the fork and the Mooncakes index to your flake inputs, and commit `flake.lock`:

```nix
inputs.moon-nix.url = "github:totto2727-org/moon-nix";
inputs.mooncake-index = {
  url = "git+https://mooncakes.io/git/index";
  flake = false;
};
```

Provide `pkgs` and a toolchain containing the official Moon CLI, such as one from [moonbit-overlay](https://github.com/moonbit-community/moonbit-overlay):

```nix
let
  moon = inputs.moon-nix.lib.mkMoonNix { inherit pkgs toolchain; };
in
moon.buildProject {
  src = ./.;
  registry = inputs.mooncake-index.outPath;
  # localSources = [ inputs.shared.outPath ];
}
```

`src` is the executable module root (the directory containing `moon.mod` or `moon.mod.json`).
Its root package must be executable and use the module's default binary name.
The result installs that executable in `bin/` and takes its version and optional metadata from the module manifest.
Use `localSources` to add workspace members as module roots.
Use `registryDownloadUrl` only if the ZIP archives are hosted on a mirror with the same layout as `https://download.mooncakes.io`.
The registry archives are staged without import from derivation (IFD).

Run `nix flake check` to verify formatting and build and run the example with a local module and a checksum-locked registry dependency.

[MIT license](LICENSE)
