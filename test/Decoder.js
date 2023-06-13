import OSH from './lib/ffmpeg-h264.js';

class Decoder {
    constructor(props) {
        this.initialized = false;
    }

    async init() {
        if(!this.initialized) {
            this.Module = await OSH()

            // register all compiled codecs
            this.Module._avcodec_register_all();

            // find h264 decoder
            const codec = this.Module.ccall('avcodec_find_decoder_by_name', 'number', ['string'], ["h264"]);
            if (codec == 0) {
                console.error("Could not find H264 codec");
            }

            // init codec and conversion context
            this.av_ctx = this.Module._avcodec_alloc_context3(codec);

            // this.av_ctx.flags2 |= (1 << 15);
            // open codec
            const ret = this.Module._avcodec_open2(this.av_ctx, codec, 0);
            if (ret < 0) {
                console.error("Could not initialize codec");
            }


            // allocate packet
            this.av_pkt = this.Module._malloc(96);
            this.av_pktData = this.Module._malloc(1024 * 3000);
            this.Module._av_init_packet(this.av_pkt);
            this.Module.setValue(this.av_pkt + 24, this.av_pktData, '*');

            // allocate video frame
            this.av_frame = this.Module._av_frame_alloc();
            if (!this.av_frame)
                alert("Could not allocate video frame");

            // init decode frame function
            this.got_frame = this.Module._malloc(4);
            this.initialized = true;
        }
    }

    async decode(data) {
        if (!this.initialized) {
            await this.init();
        }
        return this.innerWorkerDecode(data.pktSize, new Uint8Array(data.pktData, data.byteOffset, data.pktSize));
    }

    innerWorkerDecode(pktSize, pktData) {
        // prepare packet
        this.Module.setValue(this.av_pkt + 28, pktSize, 'i32');
        this.Module.writeArrayToMemory(pktData, this.av_pktData);

        // decode next frame
        const len = this.Module._avcodec_decode_video2(this.av_ctx, this.av_frame, this.got_frame, this.av_pkt);
        if (len < 0) {
            console.log("Error while decoding frame");
            return;
        }

        let type = this.Module.getValue(this.got_frame, 'i8');
        if (type === 0) {
            // console.log("No frame");
            return;
        }

        const decoded_frame = this.av_frame;
        const frame_width = this.Module.getValue(decoded_frame + 68, 'i32');
        const frame_height = this.Module.getValue(decoded_frame + 72, 'i32');
        //console.log("Decoded Frame, W=" + frame_width + ", H=" + frame_height);

        // copy Y channel to canvas
        const frameYDataPtr = this.Module.getValue(decoded_frame, '*');
        const frameUDataPtr = this.Module.getValue(decoded_frame + 4, '*');
        const frameVDataPtr = this.Module.getValue(decoded_frame + 8, '*');

        return {
            frame_width: frame_width,
            frame_height: frame_height,
            frameYDataPtr: frameYDataPtr,
            frameUDataPtr: frameUDataPtr,
            frameVDataPtr: frameVDataPtr,
            frameYData: new Uint8Array(this.Module.HEAPU8.buffer.slice(frameYDataPtr, frameYDataPtr + frame_width * frame_height)),
            frameUData: new Uint8Array(this.Module.HEAPU8.buffer.slice(frameUDataPtr, frameUDataPtr + frame_width / 2 * frame_height / 2)),
            frameVData: new Uint8Array(this.Module.HEAPU8.buffer.slice(frameVDataPtr, frameVDataPtr + frame_width / 2 * frame_height / 2))
        };
    }
}

export default Decoder;
