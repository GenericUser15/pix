# cspell:ignore pkgs uboot defconfig extlinux DISTRO bootcmd pxefile
# cspell:ignore BOOTCOMMAND sysboot dont stdenv bootcode dtbs
# cspell:ignore uarts rootwait
{ ... }:

{ lib, pkgs, config, ... }:
{
  config = {
    system.platform = "zero2w";

    boot.kernelParams =
      [ "coherent_pool=1M" "8250.nr_uarts=1" "vc_mem.mem_base=0x1ec00000" "vc_mem.mem_size=0x20000000" "console=ttyS0,115200" "console=tty1" "fsck.repair=yes" "rootwait"];

    boot.initrd.availableKernelModules = lib.mkForce [ "mmc_block" ]; 

    boot.kernel.config = "config_zero2w";
  };
}
