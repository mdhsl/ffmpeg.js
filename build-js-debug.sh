#!/bin/bash -x

ROOT_DIR=$PWD

##
configure_ffmpeg() {
  cd build/FFmpeg
  echo "Make clean"
  make clean
  echo "Preparing configure"
  emconfigure ./configure \
      --cc=emcc \
    --nm="llvm-nm -g" \
    --ar=emar \
    --cxx=em++ \
    --dep-cc=emcc \
    --enable-cross-compile \
    --target-os=none \
    --arch=x86 \
    --disable-runtime-cpudetect \
    --disable-asm \
    --disable-fast-unaligned \
    --disable-pthreads \
    --disable-w32threads \
    --disable-os2threads \
    --disable-debug \
    --disable-stripping \
    \
    --disable-all \
    --enable-ffmpeg \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-swscale \
    --enable-avfilter \
    --disable-network \
    --disable-d3d11va \
    --disable-dxva2 \
    --disable-vaapi \
    --disable-vdpau \
    --enable-decoder=h264 \
    --enable-decoder=hevc \
    --enable-protocol=file \
    --disable-bzlib \
    --disable-iconv \
    --disable-libxcb \
    --disable-lzma \
    --disable-securetransport \
    --disable-xlib \
    --disable-zlib
}

make_ffmpeg() {
  NPROC=$(grep -c ^processor /proc/cpuinfo)
  echo "Making ffmpeg.bc"
  emmake make -j${NPROC} && cp ffmpeg ffmpeg.bc
}

build_ffmpegjs() {
  cd $ROOT_DIR
  echo "Emscriting ffmpeg into js"
  emcc build/FFmpeg/ffmpeg.bc \
    -o dist/ffmpeg-h264.js \
    -s MODULARIZE=1 \
    --memory-init-file 0 \
    -s WASM=1 \
    -g4 \
    --js-opts 0 \
    -s ASSERTIONS=2 \
    -s SAFE_HEAP=1 \
    -s SINGLE_FILE=1 \
    -s NO_EXIT_RUNTIME=1 \
    -s EXPORTED_FUNCTIONS='["_avcodec_register_all","_avcodec_find_decoder_by_name","_avcodec_alloc_context3","_avcodec_open2", "_av_init_packet", "_av_frame_alloc", "_av_packet_from_data", "_avcodec_decode_video2", "_avcodec_flush_buffers"]' \
    -s EXTRA_EXPORTED_RUNTIME_METHODS='["FS", "ccall", "getValue", "setValue", "writeArrayToMemory"]' \
    -s TOTAL_MEMORY=134217728
}

main() {
  configure_ffmpeg
  make_ffmpeg
  build_ffmpegjs
}

main "$@"


