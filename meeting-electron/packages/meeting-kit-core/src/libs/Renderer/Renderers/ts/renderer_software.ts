import { VideoFrame } from '../../IRenderer'

// eslint-disable-next-line @typescript-eslint/no-var-requires
const YUVBuffer = require('yuv-buffer')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const YUVCanvas = require('yuv-canvas')

export default class SoftwareRenderer {
  public isInit: boolean = false
  private frameSink?

  constructor(canvas: HTMLCanvasElement) {
    this.frameSink = YUVCanvas.attach(canvas, {
      webGL: false,
    })
    this.isInit = true
  }

  drawFrame(videoFrame: VideoFrame) {
    if (!this.frameSink) return

    const {
      width,
      height,
      yStride,
      uStride,
      vStride,
      yBuffer,
      uBuffer,
      vBuffer,
    } = videoFrame

    this.frameSink.drawFrame(
      YUVBuffer.frame(
        YUVBuffer.format({
          width,
          height,
          chromaWidth: width / 2,
          chromaHeight: height / 2,
          cropLeft: yStride - width,
        }),
        {
          bytes: yBuffer,
          stride: yStride,
        },
        {
          bytes: uBuffer,
          stride: uStride,
        },
        {
          bytes: vBuffer,
          stride: vStride,
        }
      )
    )
  }

  public clear() {
    this.frameSink?.clear()
  }

  public destroy() {
    this.frameSink = undefined
    this.isInit = false
  }
}
