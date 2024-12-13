import { IRenderer, VideoFrame } from './IRenderer'
import { getVideoFrame } from './Utils'

export type RTCFrame = {
  // -1: initial; 0: success; 1: small size; 2: empty
  code: number
  // 总帧数
  total: number
  // 丢弃帧数
  drop: number
  /// rtc 回调的时间戳
  delay: number
  frame: {
    buffer: {
      bytes: Uint8Array
      yStride: number
      uStride: number
      vStride: number
      yOffset: number
      uOffset: number
      vOffset: number
    }
    userUuid: string
    bSubVideo: boolean
    type: number
    width: number
    height: number
  }
}

export type RendererCacheContext = {
  userUuid: string
  sourceType: string
}

export function generateRendererCacheKey({
  userUuid,
  sourceType,
}: RendererCacheContext): string {
  return `${userUuid}_${sourceType}`
}

export default class RendererCache {
  public onRenderDone?: () => void
  private _renderers: IRenderer[] = []
  private _rtcRTCFrame: RTCFrame
  private _context: RendererCacheContext

  constructor(context: RendererCacheContext) {
    this._context = context
    this._rtcRTCFrame = {
      code: -1,
      total: 0,
      drop: 0,
      delay: 0,
      frame: {
        buffer: {
          bytes: new Uint8Array(new SharedArrayBuffer(0)),
          yStride: 0,
          uStride: 0,
          vStride: 0,
          yOffset: 0,
          uOffset: 0,
          vOffset: 0,
        },
        userUuid: context.userUuid,
        bSubVideo: context.sourceType === 'video' ? false : true,
        type: 0,
        width: 0,
        height: 0,
      },
    }
  }

  public get rtcFrame(): RTCFrame {
    return this._rtcRTCFrame
  }

  public get context(): RendererCacheContext {
    return this._context
  }

  public get renderers(): IRenderer[] {
    return this._renderers
  }

  public addRenderer(renderer: IRenderer): void {
    this._renderers.push(renderer)
  }

  /**
   * Remove the specified renderer if it is specified, otherwise remove all renderers
   */
  public removeRenderer(renderer?: IRenderer): void {
    let start = 0
    let deleteCount = this._renderers.length

    if (renderer) {
      start = this._renderers.indexOf(renderer)
      if (start < 0) return
      deleteCount = 1
    }

    this._renderers.splice(start, deleteCount).forEach((it) => it.destroy())
  }

  public draw() {
    if (
      this._rtcRTCFrame.code !== 0 ||
      this._rtcRTCFrame.frame.buffer.bytes.byteLength === 0
    ) {
      // 不处理数据，直接返回
      this.onRenderDone?.()
      return
    }

    const videoFrame: VideoFrame = getVideoFrame({
      data: this._rtcRTCFrame.frame.buffer,
      width: this._rtcRTCFrame.frame.width,
      height: this._rtcRTCFrame.frame.height,
    })

    let rendererCount = this._renderers.length

    this._renderers.forEach((renderer) => {
      renderer.onRenderDone = () => {
        rendererCount--
        if (rendererCount <= 0) {
          this.onRenderDone?.()
        }
      }

      renderer.drawFrame(videoFrame)
    })
  }
}
