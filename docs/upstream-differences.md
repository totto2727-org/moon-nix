# Upstream differences

Upstream: [`moonbit-community/moon-nix` at `026f5a4e9fc7bf78699d69fdb70318c26ac8f07c`](https://github.com/moonbit-community/moon-nix/tree/026f5a4e9fc7bf78699d69fdb70318c26ac8f07c).

The package reader in [`lib/pure/manifest.nix`](../lib/pure/manifest.nix) accepts `pkgtype(kind: "executable")` as a main package declaration.
`buildProject` can build a package after `moon fmt` converts its old `is_main` declaration.
The change affects the Nix build only.
It does not change the MoonBit compiler or runtime.
The project build tests use the new declaration, and other fixtures still use the old declaration.

When upstream accepts the new declaration, consumers can update the `moon-nix` input to the upstream repository without changing their `buildProject` calls.
