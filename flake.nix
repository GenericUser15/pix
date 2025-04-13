# cspell:ignore nixfmt nixpkgs pkgs numtide nixos toplevel minimise
{
  description = "Custom RPI Linux distribution";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    rpiFirmware = {
      url = "github:raspberrypi/firmware";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, rpiFirmware, ... }@input:
    let
      # The host system that we will be compiling on.
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
      hostPkgs = pkgs.pkgsBuildBuild;
      flattenTree = input.flake-utils.lib.flattenTree;

      nixosModules = {
        system =
          pkgs.callPackage ./nixos/system.nix { inherit system nixpkgs; };
        minimise_size =
          pkgs.callPackage ./nixos/minimiseSize.nix { inherit nixpkgs; };
        sdImage = pkgs.callPackage ./nixos/sdImage.nix { inherit nixpkgs; };
        kernel = pkgs.callPackage ./nixos/kernel.nix { };
        users = ./nixos/users.nix;
      };

      # Create any specific modules for the zero2w such as the bootloader.
      zero2wModules = {
        bootloader = pkgs.callPackage ./nixos/bootloader/zero2w/bootloader.nix {
          inherit rpiFirmware;
        };
        zero2w = pkgs.callPackage ./nixos/zero2w.nix { inherit rpiFirmware; };
      };

      nixosConfigurations = {
        zero2w = nixpkgs.lib.nixosSystem {
          modules = builtins.attrValues (nixosModules // zero2wModules);
        };
      };
    in {
      inherit nixosConfigurations;
      packages.${system} = { };

      # Combine the two sets.
      nixosModules = nixosModules // zero2wModules;

      checks.${system} = flattenTree {
        zero2w = self.nixosConfigurations.zero2w.config.system.build.toplevel;
        sdImage = self.nixosConfigurations.zero2w.config.system.build.sdImage;
      };

      # This defines the shell environment.
      # This defines the shell environment for development
      devShells.${system}.default = pkgs.mkShell {
        packages = (builtins.attrValues {
          inherit (hostPkgs)
            bashInteractive nix nixfmt-classic editorconfig-checker nil
            deploy-rs clang-tools;
        });
        shellHook = ''
          # export KERNEL_SRC=/nix/store/a7svyifzl4yyr28f2ccca1pi45d134gb-linux-aarch64-unknown-linux-gnu-6.12.21-dev
          # export ARCH=arm64
          # export CROSS_COMPILEs=aarch64-linux-gnu
        '';
        # KERNEL_SRC = let
        # kernel = nixosConfigurations.zero2w.config.boot.kernelPackages.kernel;
        # in "${kernel.dev}/lib/modules/${kernel.version}/";
      };
    };
}

# goto https://github.com/raspberrypi/linux/blob/rpi-6.12.y/arch/arm64/configs/bcm2711_defconfig
# make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bmc2711_defconfig
