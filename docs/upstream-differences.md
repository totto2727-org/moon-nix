# Upstream differences

Upstream base: [`moonbit-community/moon-nix` at `026f5a4e9fc7bf78699d69fdb70318c26ac8f07c`](https://github.com/moonbit-community/moon-nix/tree/026f5a4e9fc7bf78699d69fdb70318c26ac8f07c).

The fork's [`buildProject`](../lib/buildProject.nix) stages a locked registry snapshot and checksum-verified archives in an isolated workspace, then invokes the official `moon build --target native --release`.
It delegates `moon.pkg` parsing, source discovery, compilation, and linking to Moon instead of recreating the compiler's package graph in Nix.
The MoonBit compiler, SDK, and runtime sources are unchanged.

This is a breaking API change: pass the executable module root as `src`, the locked Mooncakes index path as `registry`, and any additional module roots as `localSources`.
The builder installs one native executable with the module's default binary name.
The old compiler action APIs, graph introspection, and direct Wasm or JavaScript build targets are no longer provided by the fork.
