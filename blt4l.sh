#!/usr/bin/env bash
## BLT4L Launcher Script
## Copyright (C) Zach Mertes 2017. GPL3
## Basic description of current implementation:
## 1. Check if we're in the Steam runtime and set the correct binary
## 2. Check if mods/ exists, if it doesn't copy in the default mods folder.
## 3. Check if mods/base exists, if not copy in the default one.
## 4. LD_PRELOAD
## 5. Launch game

# Folder for the two binaries and for the base lua folder (eventually)
BLT4L_LIB_PATH="/usr/lib/blt4l"
DISTDIR_MODS="$BLT4L_LIB_PATH/mods"
DISTDIR_MODS_BASE="$BLT4L_LIB_PATH/mods/base"

# Game directory, which Steam automatically launches us in
GAMEDIR="$PWD"
GAMEDIR_MODS="$PWD/mods"
GAMEDIR_MODS_BASE="$GAMEDIR_MODS/base"

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

popup_err() {
    if hash zenity 2>/dev/null; then
        zenity --error --ellipsize --text="$*"
    else
        log "zenity not found, the error that would've popped up would've been:"
        log "$*"
    fi
}

is_number() {
    re='^[0-9]+$'
    [[ $1 =~ $re ]]
}

## Detect if we're in the Steam runtime
## and set the binary accordingly
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
    popup_err "The BLT4L binary doesn't appear to exist, so your game is probably going to load without BLT."
fi

## Detect if the mods folder exists
if [[ -d "$GAMEDIR_MODS" ]]; then
    log "Mods directory exists"
else
    ## Load the mods folder in from the distributed version
    log "Mods directory not found, copying in distributed copy"
    if ! [[ -e "$DISTDIR_MODS" ]]; then
        # Mods directory doesn't exist and we don't have one to install, display err to user and exit
        log "WARNING: distribution mods folder '$DISTDIR_MODS' not found."
        popup_err "WARNING: no mods folder found and distribution mods folder '$DISTDIR_MODS' not found.
You'll need to manually install the mods directory.
See https://github.com/blt4linux/blt4l for more information.
If you installed blt4l from a distributed package, please complain at whoever provided it to you.
If you're trying to uninstall blt4l, clear PAYDAY 2's launch options in Steam."
        exit 1
    else
        mkdir -p "$GAMEDIR_MODS"
        cp -r -t "$GAMEDIR_MODS" "$DISTDIR_MODS/"*
        log "Mods directory copied from '$DISTDIR_MODS'"
    fi
fi

## Detect if the mods/base folder exists
if [[ -d "$GAMEDIR_MODS_BASE" ]]; then
    log "Base mod directory exists"
else
    ## Load the mods folder in from the distributed version
    log "Base mod directory not found, copying in distributed copy"
    if ! [[ -e "$DISTDIR_MODS_BASE" ]]; then
        # Mods directory doesn't exist and we don't have one to install, display err to user and exit
        log "WARNING: distribution mods folder '$DISTDIR_MODS_BASE' not found."
        popup_err "WARNING: no mods/base folder found and distribution mods/base folder '$DISTDIR_MODS_BASE' not found.
You'll need to manually install the mods directory.
See https://github.com/blt4linux/blt4l for more information.
If you installed blt4l from a distributed package, please complain at whoever provided it to you.
If you're trying to uninstall blt4l, clear PAYDAY 2's launch options in Steam."
        exit 1
    else
        mkdir -p "$GAMEDIR_MODS_BASE"
        cp -r -t "$GAMEDIR_MODS_BASE" "$DISTDIR_MODS_BASE/"*
        log "Mods directory copied from '$DISTDIR_MODS_BASE'"
    fi
fi


## Launch the game

log "Starting game with provided command '$*'"
export LD_PRELOAD="$LD_PRELOAD:$BLT4L_BINARY_PATH"
exec "$@"
