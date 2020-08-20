# ffmpeg.js

This is a fork of the original ffmpeg.js project that provides builds to use FFMPEG as a library for decoding live video streams.

The original ffmpeg.js project provides FFmpeg builds ported to JavaScript using [Emscripten project](https://github.com/kripken/emscripten). Builds are optimized for in-browser use: minimal size for faster loading, asm.js, performance tunings, etc. Though they work in Node as well.

## FFMPEG
Version: 2.8
Need 2 patch to work with emscripten


## Build

The compilation options are contained into build-js.sh file

You can build using docker image:

```bash
$ ./build-with-docker.sh
```

This will build dist files into dist directory

## Test

You can test using python simple server from the root directory:

```bash
$ python -m http.server 8000 
```
