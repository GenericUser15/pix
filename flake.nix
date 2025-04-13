# cspell:ignore nixfmt nixpkgs pkgs numtide nixos toplevel minimise
{
  description = "Custom RPI Linux distribution";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, ... }@input:
    let
      # The host system that we will be compiling on.
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
      hostPkgs = pkgs.pkgsBuildBuild;
      flattenTree = input.flake-utils.lib.flattenTree;
    in {
      packages.${system} = { };

      checks.${system} = flattenTree { };

      # This defines the shell environment.
      # This defines the shell environment for development
      devShells.${system}.default = pkgs.mkShell {
        packages = (builtins.attrValues {
          inherit (hostPkgs)
            bashInteractive nix nixfmt-classic editorconfig-checker nil
            deploy-rs clang-tools;
        });
        shellHook = "";
      };
    };
}
