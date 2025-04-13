# cSpell:ignore pkgs configfile stdenv werror
{ }:
{ pkgs, config, lib, ... }:

let
  kernelPackages = let
    configfile = ../linux/${config.boot.kernel.config};

    extraMakeFlags = [ "-Werror" ];
    src = pkgs.linux_6_12.src;
    version = pkgs.linux_6_12.version;

    kernel = pkgs.linuxManualConfig {
      inherit (pkgs.linux) stdenv;
      inherit configfile;
      inherit extraMakeFlags;
      inherit lib;
      inherit src;
      inherit version;
      modDirVersion = "6.12.21-v8";
      allowImportFromDerivation = true;
    };
  in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor kernel);

  mkDefault = lib.mkDefault;

in {
  options = with lib; {
    boot.kernel.config = mkOption {
      type = with types; str;
      description = "Custom kernel config to use";
    };

    boot.extraKernelModules = lib.mkOption {
      description = "Extra drivers to be built";
      default = [ ];
    };
  };

  config = {
    # Reboot 10 seconds after a kernel panic
    boot.kernel.sysctl."kernel.panic" = mkDefault 10;

    # Panic on rcu stall + oops. (The system is normally inoperable)
    boot.kernel.sysctl."kernel.panic_on_rcu_stall" = mkDefault 1;
    boot.kernel.sysctl."kernel.panic_on_oops" = mkDefault 1;

    # Custom kernel configuration
    boot.kernelPackages = kernelPackages;

    # Custom kernel modules to be loaded in.
    # All files in this directory need:
    #   - default.nix
    #   - Makefile
    #   - Source code
    boot.extraModulePackages = builtins.map (n:
      config.boot.kernelPackages.callPackage
      (../linux/modules + "/${n}/default.nix") {
      }) config.boot.extraKernelModules;

    # Common drivers to build and load. Platforms may append more.
    boot.extraKernelModules = [ ];

    # List modules to load at the end of stage 2 boot.
    boot.kernelModules = config.boot.extraKernelModules;

    # How much stuff should be dumped to tty. 4 is the default, repeated here and is WARN and below.
    boot.consoleLogLevel = lib.mkDefault 4;

    # Parameters passed to the kernel.
    # Passed to all platforms. Platforms may append additional parameters.
    boot.kernelParams = [
      "clk_ignore_unused"
      "udev.log_level=4"
      "quiet"
      "pty.legacy_count=8"
    ];

    # Reduce logs from initrd
    boot.initrd.verbose = false;

    hardware.deviceTree = {
      enable = true;
      name = lib.mkDefault "";
      filter = mkDefault config.hardware.deviceTree.name;
    };
  };
}
