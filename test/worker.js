import Decoder from './Decoder2.js';

const decoder = new Decoder();
self.onmessage = async function (e) {
    const data = e.data;
    const decodedFrame = await decoder.decode(data);
    if(decodedFrame) {
        self.postMessage(decodedFrame, [
            decodedFrame.frameYData.buffer,
            decodedFrame.frameUData.buffer,
            decodedFrame.frameVData.buffer
        ]);
    }
}
