# cspell:ignore pkgs nixpkgs autologin
{ system, nixpkgs }:

{ lib, pkgs, config, ... }:
let
  # Natively compiled a53 packages, from upstream cache
  # avoids having to cross-compile everything.
  pkgsA53 = import nixpkgs {
    config = { allowUnfree = true; };
    overlays = [ ];
    system = "aarch64-linux";
  };
in {
  options = {
    # Define a platform to build for.
    # Currently supported platforms:
    #  - rpi zero2w
    system.platform = lib.mkOption {
      description = "The platform to build for";
      type = lib.types.str;
      default = "none";
    };
  };

  config = {
    environment.systemPackages = (with pkgsA53; [ bash-completion dtc ]);
    # Enable SSH for all systems.
    services.sshd.enable = true;
    services.getty.autologinUser = lib.mkDefault "root";
    services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

    nixpkgs.buildPlatform = system;
    nixpkgs.hostPlatform = "aarch64-linux";
    # Use 24.11 system state configuration
    system.stateVersion = "24.11";

    # Set hardware watchdogs to reboot the system if it becomes unresponsive
    systemd.watchdog.runtimeTime = "60s";
    systemd.watchdog.rebootTime = "60s";
  };
}
