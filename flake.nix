{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          gridcraft-cli = pkgs.rustPlatform.buildRustPackage {
            pname = "gridcraft-cli";
            version = "0.6.1";
            src = self;
            cargoLock = {
              lockFile = ./Cargo.lock;
              outputHashes."craft-print-0.1.0" = "sha256-u2AR5YZZSRzhWaevgR2S/jofD99J3YWKJA+CktUJbRY=";
            };
            cargoBuildFlags = [ "-p" "gridcraft-cli" ];
            doCheck = false;
            installPhase = ''
              runHook preInstall
              install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/gridcraft-cli $out/bin/gridcraft-cli
              runHook postInstall
            '';
          };
          default = self.packages.${system}.gridcraft-cli;
        });

    };
}
