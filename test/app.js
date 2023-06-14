const button = document.getElementById("add");
button.onclick = () => addNewVideo();

function addNewVideo() {
    const container = document.getElementById("container");
    const canvas = document.createElement('canvas');
    canvas.setAttribute("width","1920");
    canvas.setAttribute("height","780");
    canvas.setAttribute("style","width:50%;height:auto");

    document.body.appendChild(container);
    container.appendChild(canvas);

    // get info divs
    const timeStampDiv = document.getElementById("timeStamp");
    const pktSizeDiv = document.getElementById("pktSize");
    // const canvas = document.getElementById("canvas");
    //const canvas_ctx = canvas.getContext('2d');
    const yuvCanvas = new YUVCanvas({canvas: canvas, width: canvas.width, height: canvas.height});

    let worker = new Worker('./worker.js', {
      type: 'module'
    });
    // connect to WS H264 stream
    const url = document.getElementById('url').value;
    let ws = new WebSocket(url);
    ws.binaryType = 'arraybuffer';

    // on receiving data. The buffer has to be a COMPLETE NAL UNIT, otherwise the buffer could not be decoded
    ws.onmessage = function (event) {
        const timeStamp = new DataView(event.data).getFloat64(0, false); // read double time stamp as big endian
        const dataSize = new DataView(event.data).getInt32(8, false);

        // update div content to display frame info
        timeStampDiv.innerHTML = "TimeStamp: " + new Date(timeStamp * 1000).toISOString();
        pktSizeDiv.innerHTML = "NAL Unit Size: " + dataSize;

        // get actual NAL unit data
        const len = event.data.byteLength;
        const buffer = new Uint8Array(event.data, 12, len - 12) // H264 NAL unit starts at offset 12 after 8-bytes time stamp and 4-bytes frame length

        const pktData = buffer ;
        const pktSize = pktData.length;

        const transferableData = {
            pktSize: pktSize,
            pktData: pktData,
            byteOffset: pktData.byteOffset
        };

        worker.postMessage(transferableData);
        worker.onmessage = function (e) {
            const decodedFrame = e.data;

            yuvCanvas.canvasElement.drawing = true;
            yuvCanvas.drawNextOuptutPictureGL({
                yData: decodedFrame.frameYData,
                yDataPerRow: decodedFrame.frame_width,
                yRowCnt: decodedFrame.frame_height,
                uData: decodedFrame.frameUData,
                uDataPerRow: decodedFrame.frame_width / 2,
                uRowCnt: decodedFrame.frame_height / 2,
                vData: decodedFrame.frameVData,
                vDataPerRow: decodedFrame.frame_width / 2,
                vRowCnt: decodedFrame.frame_height / 2
            });
            yuvCanvas.canvasElement.drawing = false;
        }
    }
}
