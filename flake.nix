{
  description = "A simple TAP (Test Anything Protocol) test runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Not using writeShellApplication because it injects `set -euo pipefail`,
          # which conflicts with tapf's intentional handling of non-zero exit codes
          # from test commands.
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "tapf";
            version = self.shortRev or self.dirtyShortRev or "dev";
            src = self;
            dontBuild = true;
            installPhase = ''
              install -Dm755 tapf $out/bin/tapf
            '';
          };
        }
      );
    };
}
