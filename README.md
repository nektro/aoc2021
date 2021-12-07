# Advent Of Code Zig 2021

This repo provides my implementation for Advent of Code using Zig for 2021.  It contains a main file for each day, a build.zig file set up with targets for each day, and Visual Studio Code files for debugging.

This repo tracks the master branch of Zig, *not* 0.8.1.  It may not work with older versions.

This repo is built with Zig `0.9.0-dev.1815+20e19e75f`.

## How to use this:

The src/ directory contains a main file for each day.  Put your code there.  The build command `zig build dayXX [target and mode options] -- [program args]` will build and run the specified day.  You can also use `zig build install_dayXX [target and mode options]` to build the executable for a day and put it into `zig-out/bin` without executing it.
