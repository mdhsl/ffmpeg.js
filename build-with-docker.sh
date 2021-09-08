#!/bin/bash
#
# This script is specific for building tesseract.js
#
# Before running this script, you need to install docker first.
#

#LAST: 2.0.29
EMSCRIPTEN_VERSION=latest
TARGET=${1:-build}

check_command() {
  CMD=$1
  command -v $CMD >/dev/null 2>&1 || { echo >&2 "$CMD is not installed  Aborting."; exit 1; }
}

build() {
  docker pull emscripten/emsdk:${EMSCRIPTEN_VERSION} && \
  docker run -it --rm \
    -v ${PWD}:/src \
    emscripten/emsdk:${EMSCRIPTEN_VERSION} \
    sh -c "bash ./${TARGET}-js.sh"
}

main() {
  check_command docker
  build
}

main "$@"
