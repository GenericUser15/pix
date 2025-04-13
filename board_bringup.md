<!-- cspell:ignore nixos minimise defconfig UART uboot -->
# What's Covered

This branch covers the process of bringing up the RPI Zero 2 W using a custom Linux Kernel and U-boot.

The flake.nix file defines our environment, any external repos and packages which will make up the system.

The directory `nixos` is where all of the nix specific modules are created.

### kernel.nix

This builds the custom kernel by defining the Linux version, any drivers (builtin and our own drivers), device tree, kernel arguments etc.

### minimiseSize.nix

Disables some modules to reduce the size of the system.

### sdImage.nix

Defines the SD image which can then be burned to an SD card to boot.

This file sets some of the default commands that the sd-image package generates and defines some options.

### system.nix

Defines the system. Enables SSH and defines the packages to use. Example packages are dtc, ethtool etc.

### users.nix

Defines the users for the system. Just creates a root user and password. This can be extended to create multiple users with passwords.

### zero2w.nix

Configuration specific to the Zero 2 W. This sets the kernel driver specific for the Zero 2 W and appends to the default kernel boot params.

# Bootloader

The bootloader is defined in `bootloader/zero2w.`

### bootloader.nix

This file does the majority of the board bring up work. This will use the build in uboot package to create a u boot.bin file.

We need a config.txt file for the 3rd stage bootloader. There is a default config provided by RPI so we use this file with some changes. This enables UART and uboot.

The PI has a complicated boot process and the boot files are proprietary so we have to get them from the RPI github.

From the firmware repo, we get the device tree and the startup binaries required.

Finally, copy the correct files to the proper partition.

# Linux

The Linux kernel and custom drivers are in the `linux` directory.

The kernel config file is obtained from the defconfig, we use this as a starting point and change the kernel as required.
