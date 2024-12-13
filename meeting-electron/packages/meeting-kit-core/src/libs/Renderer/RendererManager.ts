import { IRenderer } from './IRenderer'
import RendererCache, {
  generateRendererCacheKey,
  RendererCacheContext,
  RTCFrame,
} from './RendererCache'
import { isSupportRendererType } from './Utils'
import { Logger } from '../../utils/Logger'
import { NERoomRtcController } from 'neroom-types'

type RendererContext = {
  userUuid: string
  sourceType: string
  view: HTMLElement
}

export type RendererType = 'webgpu' | 'webgl' | 'software'

const logger = new Logger('RendererManager', true)

const _detectLagFrameSize = 3
const _lagCountToReduceFps = 3
const _unlagCountToRiseFps = 40
const _lagDelta = 0.8
const _availableFpsValues: number[] = [15, 20, 25, 30]

export default class RendererManager {
  private static _instance: RendererManager

  private _rendererType: RendererType
  private _rendererCaches: RendererCache[] = []
  private _renderersPool: IRenderer[] = []
  private _renderersPoolMaxLength: number = 10

  private _roomKit
  private _rtcController?: NERoomRtcController

  private _currentFrameCountOfWindow: number = 0
  private _firstFrameTimeOfWindow: number = 0
  private _renderingTimer?: NodeJS.Timeout
  private _renderingFps: number = 30
  // 渲染卡顿计数
  private _lagCount: number = 0
  private _unlagCount: number = 0
  private _firstFrameTimeOfLagWindow: number = 0
  private _frameCountOfLagWindow = 0
  // 上一帧率渲染结束时间
  private _previousFrameEndTime: number = 0
  // 下一帧率渲染延迟时间
  private _nextFrameDeltaTime: number = 0

  constructor() {
    this._rendererType = isSupportRendererType()
    console.warn(`RendererManager rendererType: ${this._rendererType}`)
  }

  static get instance(): RendererManager {
    if (!RendererManager._instance) {
      RendererManager._instance = new RendererManager()
    }

    return RendererManager._instance
  }

  public set roomKit(roomKit) {
    this._roomKit = roomKit
  }

  public set rtcController(controller) {
    this._rtcController = controller
  }

  public createRenderer(
    context: RendererContext,
    rendererType?: RendererType
  ): IRenderer {

    if (rendererType === undefined) {
      rendererType = this._rendererType
    }

    // 是否是主窗口添加
    const isMainRenderer = document.contains(context.view)
    const rendererCacheKey = generateRendererCacheKey(context)

    let rendererCache = this._rendererCaches.find(
      (item) => generateRendererCacheKey(item.context) === rendererCacheKey
    )

    let renderer = this._renderersPool.find(
      (item) => item.active === false && item.cacheKey === rendererCacheKey
    )

    if (!renderer) {
      renderer = this._renderersPool.find((item) => item.active === false)
    }

    if (!rendererCache) {
      rendererCache = new RendererCache(context)
      this._rendererCaches.push(rendererCache)
    }

    if (renderer && isMainRenderer) {
      renderer.reuse(context.view, rendererCacheKey)
    } else {
      renderer = new IRenderer(
        context.view,
        rendererCacheKey,
        this._rendererType
      )
      if (
        this._renderersPool.length < this._renderersPoolMaxLength &&
        isMainRenderer
      ) {
        renderer.inPool = true
        this._renderersPool.push(renderer)
      }
    }

    rendererCache.addRenderer(renderer)

    this.startRendering()
    return renderer
  }

  public removeRenderer(context: RendererCacheContext, renderer?: IRenderer) {
    const rendererCache = this._rendererCaches.find(
      (item) =>
        generateRendererCacheKey(item.context) ===
        generateRendererCacheKey(context)
    )

    if (rendererCache) {
      rendererCache.removeRenderer(renderer)
      if (rendererCache.renderers.length === 0) {
        this._rendererCaches.splice(
          this._rendererCaches.indexOf(rendererCache),
          1
        )
        if (this._rendererCaches.length === 0) {
          this.stopRendering()
          return
        }
      }
    }
  }

  public startRendering(): void {
    if (this._renderingTimer) return
    logger.warn('startRendering')
    this._roomKit?.startListenVideoFrame?.()

    const renderingLooper = () => {
      const now = performance.now()

      this.detectFrameLag()
      if (this._firstFrameTimeOfLagWindow === 0) {
        this._firstFrameTimeOfLagWindow = now
        this._frameCountOfLagWindow = 0
      }

      ++this._frameCountOfLagWindow

      if (this._firstFrameTimeOfWindow === 0) {
        this._firstFrameTimeOfWindow = now
        this._currentFrameCountOfWindow = 0
      }

      ++this._currentFrameCountOfWindow

      this.getRenderFrame()
      this.getRenderFrame(true)

      let needRenderCount = this._rendererCaches.length

      this._rendererCaches.forEach((rendererCache) => {
        rendererCache.onRenderDone = () => {
          needRenderCount--
          if (needRenderCount === 0) {
            const deltaTime = performance.now() - this._firstFrameTimeOfWindow
            const expectedTime =
              (this._currentFrameCountOfWindow * 1000) / this._renderingFps

            if (this._currentFrameCountOfWindow >= this._renderingFps) {
              this._firstFrameTimeOfWindow = 0
            }

            if (deltaTime < expectedTime) {
              this._nextFrameDeltaTime = expectedTime - deltaTime
              this._renderingTimer = setTimeout(
                renderingLooper,
                this._nextFrameDeltaTime
              )
            } else {
              this._nextFrameDeltaTime = 0
              renderingLooper()
            }
          }
        }

        this.doRendering(rendererCache)
      })
    }

    renderingLooper()
  }

  public stopRendering(): void {
    this._roomKit?.stopListenVideoFrame?.()

    if (this._renderingTimer) {
      clearTimeout(this._renderingTimer)
      this._renderingTimer = undefined
    }

    this._previousFrameEndTime = 0
    this._firstFrameTimeOfWindow = 0
    this._firstFrameTimeOfLagWindow = 0
    this._lagCount = 0
    this._unlagCount = 0
    logger.warn('stopRendering')
  }

  public getRenderFrame(secondTime: boolean = false) {
    const rtcFrames: RTCFrame[] = []

    this._rendererCaches.forEach((rendererCache) => {
      if (secondTime && rendererCache.rtcFrame.code !== 1) {
        return
      }

      if (rendererCache.rtcFrame.code === 1) {
        rendererCache.rtcFrame.frame.buffer.bytes = new Uint8Array(
          new SharedArrayBuffer(rendererCache.rtcFrame.frame.buffer.vOffset)
        )
      }

      rtcFrames.push(rendererCache.rtcFrame)
    })

    if (rtcFrames.length !== 0) {
      this._roomKit?.getVideoFrame?.(rtcFrames)
    }
  }

  public doRendering(rendererCache: RendererCache) {
    if (rendererCache) {
      rendererCache.draw()
    }
  }

  private detectFrameLag() {
    if (!window.isWins32) return
    if (this._frameCountOfLagWindow >= _detectLagFrameSize) {
      const deltaTime = performance.now() - this._firstFrameTimeOfLagWindow
      const expectedTime =
        (this._frameCountOfLagWindow * 1000) / this._renderingFps
      const isLag = deltaTime - _lagDelta > expectedTime

      this.markFrameLag(isLag)
      this._firstFrameTimeOfLagWindow = 0
      // console.warn(
      //   new Date().toLocaleTimeString(),
      //   'RendererManager',
      //   'detectFrameLag',
      //   'frameCount',
      //   this._frameCountOfLagWindow,
      //   'expectedTime',
      //   expectedTime,
      //   'deltaTime',
      //   deltaTime,
      //   'isLag',
      //   isLag,
      //   'lagCount',
      //   this._lagCount,
      //   'unlagCount',
      //   this._unlagCount,
      // )
    }
  }

  private markFrameLag(isLag: boolean) {
    const nowFps = this._renderingFps

    if (isLag) {
      this._unlagCount = Math.max(0, this._unlagCount - 3)
      this._lagCount++
      if (this._lagCount === _lagCountToReduceFps) {
        this._renderingFps = 15
        this._lagCount = 0
        this._unlagCount = 0
        this._firstFrameTimeOfLagWindow = 0
        this._firstFrameTimeOfWindow = 0
      }
    } else {
      this._lagCount = 0
      this._unlagCount++
      if (this._unlagCount === _unlagCountToRiseFps) {
        let fps = this._renderingFps

        for (let index = 0; index < _availableFpsValues.length; index++) {
          const value = _availableFpsValues[index]

          if (value > fps || index == _availableFpsValues.length - 1) {
            fps = value
            break
          }
        }

        this._renderingFps = fps
        this._lagCount = 0
        this._unlagCount = 0
        this._firstFrameTimeOfLagWindow = 0
        this._firstFrameTimeOfWindow = 0
      }
    }

    if (nowFps !== this._renderingFps) {
      this._rtcController?.setLocalVideoFramerate?.(this._renderingFps)

      console.warn(
        new Date().toLocaleString(),
        'RendererManager',
        `rendering fps changed ${nowFps} -> ${this._renderingFps}`
      )
    }
  }
}
