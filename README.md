# ffmpeg.js

This is a fork of the original ffmpeg.js project that provides builds to use FFMPEG as a library for decoding live video streams.

The original ffmpeg.js project provides FFmpeg builds ported to JavaScript using [Emscripten project](https://github.com/kripken/emscripten). Builds are optimized for in-browser use: minimal size for faster loading, asm.js, performance tunings, etc. Though they work in Node as well.

## FFMPEG
Version: 2.8
Need 2 patch to work with emscripten


# --pre-js javascript/prepend.js \
# --closure 1 \
# -s USE_SDL=2 \
# -s WASM={0,1} -s SINGLE_FILE=1 merges JavaScript and WebAssembly code in the single output file
