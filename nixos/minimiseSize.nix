# cSpell:ignore pkgs nixpkgs nixos perlless polkit udisks ramfs
{ nixpkgs }:
{ config, pkgs, lib, ... }:
with lib;

# See https://github.com/illegalprime/nixos-on-arm/tree/master/images/mini
#
# This set of configuration options disables unused features in an effort to reduce image size.

{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/perlless.nix"
    "${nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  config = {
    environment.defaultPackages = mkForce [ ];

    # disable firewall (needs iptables)
    networking.firewall.enable = mkDefault false;

    # disable polkit
    security.polkit.enable = mkDefault false;

    # disable audit
    security.audit.enable = mkDefault false;

    # disable udisks
    services.udisks2.enable = mkDefault false;

    # build less locales
    # This isn't perfect, but let's expect the user specifies an UTF-8 defaultLocale
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

    # only add strictly necessary modules
    boot.initrd.includeDefaultModules = mkDefault false;
    boot.initrd.kernelModules = mkDefault [ "ext4" ];

    xdg.menus.enable = mkDefault false;

    systemd.shutdownRamfs.enable = mkDefault false;
  };
}
