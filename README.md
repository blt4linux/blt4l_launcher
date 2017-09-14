# BLT4L launcher script
Work in progress. Script must always pass shellcheck.

Basic current plan:

* [x] Detect if we're in the Steam runtime or not (is STEAM_RUNTIME not a number?)
    * if true: set binary to libblt_loader.so
    * if false: set binary to libblt_loader_steamrt.so
* [x] Detect if `mods` directory is present
    * if true: skip to #3
    * if false: copy in base folder structure from stored copy
* [x] Detect if `mods/base` directory is present
    * if true: skip to #4
    * if false: copy in base lua from stored copy
* [x] Set LD_PRELOAD and exec the game
* [x] Detect if run without parameters (ex, just `$ blt4l`) and display an informative error
* [x] Support using blt4l binaries present in the game directory rather than the system ones

others:

* perhaps a flag or something to force the Steam runtime on?
* other flags perhaps?

## Current Usage
Steam launch options:

`blt4l %command% [PD2 options, like -skip_intro]`

Logs to `$PAYDAY2/blt4l_launcher.log`
