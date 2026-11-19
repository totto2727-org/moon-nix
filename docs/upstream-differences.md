# Upstream differences

Upstream: [`moonbit-community/moon-nix` at `026f5a4e9fc7bf78699d69fdb70318c26ac8f07c`](https://github.com/moonbit-community/moon-nix/tree/026f5a4e9fc7bf78699d69fdb70318c26ac8f07c).

The package reader in [`lib/pure/manifest.nix`](../lib/pure/manifest.nix) accepts `pkgtype(kind: "executable")` as a main package declaration.
`buildProject` can build a package after `moon fmt` converts its old `is_main` declaration.
The change affects the Nix build only.
It does not change the MoonBit compiler or runtime.
The project build tests use the new declaration, and other fixtures still use the old declaration.

When upstream accepts the new declaration, consumers can update the `moon-nix` input to the upstream repository without changing their `buildProject` calls.

## Native CLI builder

The public `buildNativeCli` builder uses `moon build --target native --release` for package syntax that `buildProject` cannot parse, such as `#cfg` imports on toolchains that support them.
It stages checksum-pinned Mooncakes archives and the requested local module sources in an isolated workspace.
This lets consumers install a native executable without implementing the registry cache or build phases in their own `package.nix` files.
The builder is opt-in and does not change `buildProject`, the MoonBit compiler, or the runtime.

Pass the executable module root as `src`, the pinned Mooncakes index path as `registry`, and any additional module roots as `localSources`.
The executable must be the root package with the default binary name from the module manifest.
