{
  pkgs,
  toolchain,
  manifest,
  resolver,
}:
{
  src,
  registry,
  localSources ? [ ],
  registryDownloadUrl ? "https://download.mooncakes.io",
}:
let
  inherit (pkgs) lib;
  readModule = manifest.read;
  project = readModule src;
  pname = builtins.baseNameOf project.name;
  members = lib.imap0 (i: source: {
    inherit source;
    directory = "member-${toString i}";
    module = readModule source;
  }) localSources;
  localModules = lib.listToAttrs (
    map (member: {
      name = member.module.name;
      value = member.module;
    }) members
  );
  resolution = resolver.resolve {
    root = project;
    inherit registry localModules;
  };
  stageArchive =
    module:
    let
      archive = pkgs.fetchurl {
        url = "${lib.removeSuffix "/" registryDownloadUrl}/user/${module.name}/${
          lib.replaceStrings [ "+" ] [ "%2B" ] module.version
        }.zip";
        sha256 = module.entry.checksum;
      };
    in
    ''install -Dm644 ${archive} "$MOON_HOME/registry/cache/"${lib.escapeShellArg "${module.name}/${module.version}.zip"}'';
in
assert lib.assertMsg (
  builtins.length members == builtins.length (builtins.attrNames localModules)
  && !(localModules ? ${project.name})
) "buildProject: duplicate workspace module name";
pkgs.stdenv.mkDerivation {
  inherit pname;
  inherit (project) version;
  dontUnpack = true;
  nativeBuildInputs = [ toolchain ];
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    export MOON_HOME="$HOME/.moon"
    mkdir -p "$MOON_HOME/registry" workspace
    cp -r "${registry}" "$MOON_HOME/registry/index"
    ${lib.concatMapStringsSep "\n" stageArchive resolution}
    cp -r "${src}" workspace/cli
    ${lib.concatMapStringsSep "\n" (m: ''cp -r "${m.source}" workspace/${m.directory}'') members}
    chmod -R u+w workspace
    (
      cd workspace
      printf '%s\n' ${lib.escapeShellArg "members = ${builtins.toJSON ([ "cli" ] ++ map (m: m.directory) members)}"} > moon.work
      moon build --target native --release ./cli
    )
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 ${lib.escapeShellArg "workspace/_build/native/release/build/${project.name}/${pname}.exe"} "$out/bin/"${lib.escapeShellArg pname}
    runHook postInstall
  '';
  meta = {
    mainProgram = pname;
  }
  // lib.optionalAttrs (project ? description) { inherit (project) description; }
  // lib.optionalAttrs (project ? repository) { homepage = project.repository; }
  // lib.optionalAttrs (project ? license) {
    license = lib.meta.getLicenseFromSpdxId project.license;
  };
}
