function getYuvFrame(data, width, height) {
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
