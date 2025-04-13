# cspell:ignore nixpkgs extlinux nixos toplevel
{ nixpkgs }:

{ lib, config, ... }:
# Defines the sd card format required for a specified platform.
#
# We currently only support the Zero 2 W.
#
# The boot partition contains our custom u-boot.bin file.
# It also contains all of the pre-compiled firmware from RPI as this is proprietary.
#
# All of the bootloader files are handled by the `zero2w.nix` module.
{
  imports = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix" ];

  options = {
    boot.loader = {
      description = ''
        The bootloader for the platform.
      '';
    };
  };

  config = {
    # Grub is not used in boot.
    boot.loader.grub.enable = false;

    # Use the extlinux loader on boot.
    boot.loader.generic-extlinux-compatible.enable = true;

    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;

    # Disable containers.
    boot.enableContainers = false;

    sdImage.imageBaseName = lib.mkDefault "pix-zero2w-nix-image";

    # Populate root partition.
    # -t flag sets the timeout.
    # -c sets the default config.
    # -d sets the boot dir.
    # -n sets the dtb name.
    sdImage.populateRootCommands = lib.mkDefault ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -t ${
        builtins.toString config.boot.loader.timeout
      } -c ${config.system.build.toplevel} -d ./files/boot -n ${config.hardware.deviceTree.name}
    '';
  };
}
