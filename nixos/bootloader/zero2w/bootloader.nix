# cspell:ignore BOOTCOMMAND DISTRO bootcmd bootcode defconfig dont dtbs extlinux pkgs pxefile
# cspell:ignore raspberrypi stdenv sysboot uboot
{ rpiFirmware }:

{ lib, pkgs, config, ... }:
let
  uboot = pkgs.buildUBoot {
    name = "zero2w_uboot";
    filesToInstall = [ "u-boot.bin" "./board/raspberrypi/rpi/rpi.env" ];
    defconfig = "rpi_arm64_defconfig";
    # In order to boot from an extlinux.conf, we need to enable CONFIG_DISTRO_DEFAULTS and modify the bootcmd variable.
    # This will look in mmc (sd card) partition 2 (the main linux partition of the card).
    # pxefile_addr_r is defined by u-boot by enabling distro defaults.
    extraConfig = ''
      CONFIG_DISTRO_DEFAULTS=y
      CONFIG_BOOTCOMMAND="sysboot mmc 0:2 any $pxefile_addr_r /boot/extlinux/extlinux.conf"
    '';
  };

  bootConfigFile = pkgs.stdenv.mkDerivation {
    name = "boot_config_file";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      mv ./config.txt $out
    '';
  };

  dtb = pkgs.stdenv.mkDerivation {
    name = "zero2w_dtb";
    src = rpiFirmware;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/dtbs
      mv ./boot/bcm2710-rpi-zero-2-w.dtb $out/dtbs
    '';
  };

  firmware = pkgs.stdenv.mkDerivation {
    name = "zero2w_firmware";
    src = rpiFirmware;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      mv -t $out ./boot/start*.elf ./boot/fixup*.dat ./boot/bootcode.bin
    '';
  };
in {
  boot.initrd.systemd.enable = true;

  # The DTB needs to be present for the bootloader.
  # TODO can this be removed from extlinux then?
  sdImage.populateFirmwareCommands = ''
    cp ${uboot}/rpi.env $NIX_BUILD_TOP/firmware/uboot.env
    cp ${uboot}/u-boot.bin $NIX_BUILD_TOP/firmware/
    cp ${dtb}/dtbs/* $NIX_BUILD_TOP/firmware/
    cp ${firmware}/* $NIX_BUILD_TOP/firmware/
    cp ${bootConfigFile}/* $NIX_BUILD_TOP/firmware/
  '';

  hardware.deviceTree = {
    name = "bcm2710-rpi-zero-2-w.dtb";
    kernelPackage = dtb;
  };
}
