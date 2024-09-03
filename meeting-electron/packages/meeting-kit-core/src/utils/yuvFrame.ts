export type YuvFrame = {
  format: {
    width: number
    height: number
    chromaWidth: number
    chromaHeight: number
    cropLeft: number
    cropTop: number
    cropHeight: number
    cropWidth: number
    displayWidth: number
    displayHeight: number
    pixelStorei: number
  }
  y: {
    bytes: Uint8Array
    stride: number
  }
  u: {
    bytes: Uint8Array
    stride: number
  }
  v: {
    bytes: Uint8Array
    stride: number
  }
}

type Data = {
  bytes: Uint8Array
  yOffset: number
  yStride: number
  uOffset: number
  uStride: number
  vOffset: number
  vStride: number
}

function getYuvFrame(data: Data, width: number, height: number): YuvFrame {
  const uvWidth = width / 2
  let pixelStorei = 1

  if (uvWidth % 8 === 0) {
    pixelStorei = 8
  } else if (uvWidth % 4 === 0) {
    pixelStorei = 4
  } else if (uvWidth % 2 === 0) {
    pixelStorei = 2
  }

  return {
    format: {
      width,
      height,
      chromaWidth: width / 2,
      chromaHeight: height / 2,
      cropLeft: 0, // default
      cropTop: 0, // default
      cropHeight: height,
      cropWidth: width,
      displayWidth: width, // derived from width via cropWidth
      displayHeight: height, // derived from cropHeight
      pixelStorei, // default
    },
    y: {
      bytes: data.bytes.subarray(0, data.yOffset),
      stride: data.yStride,
    },
    u: {
      bytes: data.bytes.subarray(data.yOffset, data.uOffset),
      stride: data.uStride,
    },
    v: {
      bytes: data.bytes.subarray(data.uOffset, data.vOffset),
      stride: data.vStride,
    },
  }
}

export { getYuvFrame }
