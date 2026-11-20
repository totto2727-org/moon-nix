{
  description = "Build MoonBit projects with Nix and the official Moon CLI";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    moonbit-overlay = {
      url = "github:moonbit-community/moonbit-overlay/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      moonbit-overlay,
    }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      lib = {
        mkMoonNix = import ./default.nix;
      };
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
      checks = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          build-project = import ./tests {
            inherit pkgs;
            toolchain = moonbit-overlay.packages.${system}.latest;
          };
          formatting = pkgs.runCommand "moon-nix-formatting" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
            find ${self} -name '*.nix' -print0 | xargs -0 nixfmt --check
            touch $out
          '';
        }
      );
    };
}
