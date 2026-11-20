{ pkgs, toolchain }:
let
  api = import ../default.nix { inherit pkgs toolchain; };
  args = {
    src = ./fixtures/native-cli;
    localSources = [ ./fixtures/shared ];
    registry = ./fixtures/registry;
    registryDownloadUrl = "file://${./fixtures/registry-download}";
  };
  project = api.buildProject args;
  duplicate = builtins.tryEval (
    (api.buildProject (args // { localSources = args.localSources ++ args.localSources; })).drvPath
  );
in
assert !duplicate.success;
assert project.version == "0.1.0";
assert project.meta.mainProgram == "cli";
assert project.meta.description == "Moon-backed builder fixture";
pkgs.runCommand "moon-nix-build-project-test" { } ''
  ${project}/bin/cli > "$out"
  test "$(cat "$out")" = 41
''
