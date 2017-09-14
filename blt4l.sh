#!/usr/bin/env bash
## BLT4L Launcher Script
## Copyright (C) Zach Mertes 2017. GPL3
## Basic description of current implementation:
## 1. Check if we're in the Steam runtime and set the correct binary
## 2. LD_PRELOAD
## 3. Launch game

# Folder for the two binaries and for the base lua folder (eventually)
BLT4L_LIB_PATH="/usr/lib/blt4l"

# Game directory, which Steam automatically launches us in
GAMEDIR="$PWD"

# Where we spit out debugging information
LOGFILE="$GAMEDIR/blt4l_launcher.log"

## Check if we're even being run by Steam
if [ $# -eq 0 ]; then
    echo -e "blt4l isn't meant to be run directly
You should go into Steam->\e[4mPAYDAY 2\e[0m->Right click->\e[4mProperies\e[0m->\e[4mSet Launch Options...\e[0m and set:
    \e[1mblt4l %command%\e[0m
(feel free to pass any options to Payday 2 after %command%, like -skip_intro)
Then run Payday 2 from Steam normally."
    exit 1
fi


## Utility Functions
log() {
    local msg
    msg="[$(date --iso=s)] $1"
    echo "$msg" >> "$LOGFILE"
    echo "$msg" >&2
}

is_number() {
    re='^[0-9]+$'
    [[ $1 =~ $re ]]
}

## Detect if we're in the Steam runtime
# and set the binary accordingly
BLT4L_BINARY_PATH=""
if is_number "$STEAM_RUNTIME"; then
    log "Steam runtime not detected"
    BLT4L_BINARY_PATH="$BLT4L_LIB_PATH/libblt_loader.so"
else
    log "Steam runtime detected"
    BLT4L_BINARY_PATH="$BLT4L_LIB_PATH/libblt_loader_steamrt.so"
fi
log "Planning to load BLT4L binary '$BLT4L_BINARY_PATH'"

if ! [[ -e "$BLT4L_BINARY_PATH" ]]; then
    log "WARNING: BLT4L binary doesn't appear to exist; BLT probably isn't going to work."
fi


## Launch the game

log "Starting game with provided command '$*'"
export LD_PRELOAD="$LD_PRELOAD:$BLT4L_BINARY_PATH"
exec "$@"
