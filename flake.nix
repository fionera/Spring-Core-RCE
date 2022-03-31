{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages = flake-utils.lib.flattenTree {
          build-and-run =
            pkgs.writeShellScriptBin "build-and-run" ''
              ${pkgs.maven}/bin/mvn package
              ${pkgs.docker-compose}/bin/docker-compose up
            '';
        };
        apps.build-and-run = flake-utils.lib.mkApp { drv = packages.build-and-run; };
        defaultPackage = packages.build-and-run;
        defaultApp = apps.build-and-run;
        devShell = pkgs.mkShell { buildInputs = [ pkgs.maven packages.build-and-run ]; };
      }
    );
}
