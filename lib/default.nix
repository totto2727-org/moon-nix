{ pkgs, toolchain }:
let
  inherit (pkgs) lib;
  manifest = import ./pure/manifest.nix { inherit lib; };
  resolver = import ./pure/resolve.nix { inherit lib manifest; };
in
{
  buildProject = import ./buildProject.nix {
    inherit
      pkgs
      toolchain
      manifest
      resolver
      ;
  };
}
