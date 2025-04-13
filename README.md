<!-- cspell:ignore direnv -->
# What is pix?

Pix stands for Raspberry PI Nix. A custom Linux kernel, running NixOs on a Pi Zero 2 W.

Leveraging the Nix package manager and Nix flakes, it's possible to build the same Linux distribution for any board, with a bit of work of course!

The inspiration for this came from a lack of resources on how to write Linux kernel drivers. There are many many ways to write a driver and the unfortunately, a lot of the drivers have no comments so it's hard to reverse engineer a driver as a way of learning.

This repo will have multiple branches, which will target specific aspects of Linux drivers and some board bring up work.

Nix has a fairly steep learning curve and some of it can be quite cryptic but it is very good for deploying the same system on anything. The build system is also quite nice.

Each branch has it's own readme which explains what the work entails and which files are of particular interest.

# Board Support

Currently, only the RPI Zero 2 W is supported because it's cheap and quite simple with minimal peripherals.

It's fairly easy to add new boards, hopefully the board bring up is enough for you to go off and bring up your own boards.

# Pre-requisites

This project uses direnv and a Nix flake to manage the environment. You need to have these installed to make this work.

You can run the script `setup_env.sh` but it's recommended you install Nix and direnv yourself so you can debug it if the install fails.
