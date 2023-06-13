#!/bin/bash -x

ROOT_DIR=$PWD
#HASH=9f8c81ef
HASH=n6.0
##
configure_ffmpeg() {
#  rm -fr build/FFmpeg
#  git clone --recursive https://github.com/FFmpeg/FFmpeg.git build/FFmpeg
  cd build/FFmpeg
  git checkout $HASH
  echo "Preparing configure for "$HASH
  emconfigure ./configure \
    --cc=emcc \
    --nm="llvm-nm -g" \
    --ar=emar \
    --ranlib="emranlib" \
    --cxx=em++ \
    --dep-cc=emcc \
    --enable-cross-compile \
    --target-os=none \
    --arch=x86 \
    --disable-runtime-cpudetect \
    --disable-asm \
    --disable-fast-unaligned \
    --disable-os2threads \
    --disable-debug \
    --disable-stripping \
    --disable-pthreads \
    --disable-w32threads \
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
    --enable-decoder=vp9 \
    --enable-decoder=vp8 \
    --enable-decoder=hevc \
    --enable-decoder=mp3 \
    --enable-decoder=mp3float  \
    --enable-decoder=pcm_s8 \
    --enable-decoder=pcm_s8_planar \
    --enable-decoder=pcm_u8 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=vorbis \
    --enable-decoder=aac \
    --enable-protocol=file \
    --disable-bzlib \
    --disable-iconv \
    --disable-libxcb \
    --disable-lzma \
    --disable-securetransport \
    --disable-xlib \
    --disable-zlib \
    --enable-hardcoded-tables
}

make_ffmpeg() {
  NPROC=$(grep -c ^processor /proc/cpuinfo)
  echo "Making ffmpeg.bc"
  emmake make -j${NPROC} && cp ffmpeg ffmpeg.bc
}

build_ffmpegjs() {
  cd $ROOT_DIR
  echo "Emscripting ffmpeg into js"
  echo `ls -lh build/FFmpeg/ffmpeg.bc`
  emcc --bind \
    build/FFmpeg/libavutil/libavutil.a \
    build/FFmpeg/libswscale/libswscale.a \
    build/FFmpeg/libavcodec/libavcodec.a \
    build/FFmpeg/libavfilter/libavfilter.a \
    build/FFmpeg/libavformat/libavformat.a \
    -o dist/ffmpeg-h264.js \
    -O3 \
    -s MODULARIZE=1 \
    --memory-init-file 0 \
    -s WASM=1 \
    --llvm-opts 3 \
    --llvm-lto 3 \
    -g0 \
    --closure 1 \
    -s SINGLE_FILE=0 \
    -s FILESYSTEM=0 \
    -s NO_EXIT_RUNTIME=1 \
    -s 'EXPORT_NAME="OSH"' \
    -s EXPORTED_FUNCTIONS='["_avcodec_send_packet","_avcodec_receive_frame","_av_get_default_channel_layout", "_av_init_packet", "_av_frame_alloc", "_av_packet_from_data","_avcodec_find_decoder_by_name","_avcodec_alloc_context3","_avcodec_open2", "_avcodec_flush_buffers", "_malloc"]' \
    -s EXPORTED_RUNTIME_METHODS='["ccall", "getValue", "setValue", "writeArrayToMemory"]' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s STACK_OVERFLOW_CHECK=2 \
    -s PTHREAD_POOL_SIZE_STRICT=2 \
    -s EXPORT_ES6=1 \
    -s USE_ES6_IMPORT_META=1
}

copy_ffmpegjs() {
   cd $ROOT_DIR
   cp dist/ffmpeg-h264.* test/lib
}
main() {
  configure_ffmpeg
  make_ffmpeg
  build_ffmpegjs
  copy_ffmpegjs
}

main "$@"

