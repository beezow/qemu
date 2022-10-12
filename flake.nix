{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      hostCpuTargets = [
        "aarch64-softmmu"
        "riscv32-softmmu"
        "riscv64-softmmu"
        "x86_64-softmmu"
      ];
      version = "0.1.0";

      qemu = pkgs.callPackage ./nix {
        inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
        inherit (pkgs.darwin.stubs) rez setfile;
        inherit (pkgs.darwin) sigtool;
        inherit hostCpuTargets version;
        src = self;
      };

    in {
      packages = {
        qemu = qemu;
        default = qemu;
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = [
          qemu
        ];
      };

      checks = {
        build = self.packages.${system}.qemu;
      };
    });
}
