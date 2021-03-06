#!/bin/sh
set -e

BUILDER_PATH="/opt/arduino"
LIBRARIES_PATH="$BUILDER_PATH/libraries:$GITHUB_WORKSPACE/../"

SKETCH_PATH="$INPUT_SKETCH"
BOARD_NAME="$INPUT_BOARD"
SKETCH_DIRECTORY_PATH="$INPUT_SKETCHDIRECTORY"

if [ -d "$INPUT_LIBRARIES" ]; then
    LIBRARIES_PATH="$LIBRARIES_PATH:$INPUT_LIBRARIES"
fi

getLibraryOptions() {
    local IFS=":"
    for library in $1
    do
        echo -n " -libraries $library"
    done
}

mkdir -p $INPUT_BUILD

BUILDER_OPTIONS="-compile -warnings=all -build-path `realpath $INPUT_BUILD` -hardware $BUILDER_PATH/packages -hardware $BUILDER_PATH/hardware -tools $BUILDER_PATH/hardware/tools/avr -tools $BUILDER_PATH/tools-builder `getLibraryOptions $LIBRARIES_PATH` -fqbn $BOARD_NAME -prefs=runtime.tools.xtensa-lx106-elf-gcc.path=$BUILDER_PATH/packages/esp8266/tools/xtensa-lx106-elf-gcc/2.5.0-3-20ed2b9 -prefs=runtime.tools.python.path=/usr/bin/"

if [ -d "$INPUT_HARDWARE" ]; then
    BUILDER_OPTIONS="$BUILDER_OPTIONS -hardware $INPUT_HARDWARE"
fi


echo $BUILDER_OPTIONS

if [ -n "$SKETCH_PATH" ]; then
    if [ -z "$1" ]; then
        arduino-builder $BUILDER_OPTIONS "$SKETCH_PATH"
    else
        arduino-builder "$@" "$SKETCH_PATH"
    fi
else
    for sketch in `find "$SKETCH_DIRECTORY_PATH" -name '*.ino'`
    do
        if [ -z "$1" ]; then
            arduino-builder $BUILDER_OPTIONS "$sketch"
        else
            arduino-builder "$@" "$sketch"
        fi
    done
fi
