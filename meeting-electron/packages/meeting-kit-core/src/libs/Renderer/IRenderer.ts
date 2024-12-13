import { RendererType } from './RendererManager'
import { getUUID } from './Utils'

export type VideoFrame = {
  width: number
  height: number
  yStride: number
  uStride: number
  vStride: number
  yBuffer: Uint8Array
  uBuffer: Uint8Array
  vBuffer: Uint8Array
  rotation: number
}

export class IRenderer {
  public onRenderDone?: () => void
  worker: Worker
  active: boolean = true
  inPool: boolean = false
  cacheKey: string = ''
  uuid: string = getUUID()
  container?: HTMLElement
  canvas?: HTMLCanvasElement
  private _width: number = 0
  private _height: number = 0
  private _observer?: ResizeObserver
  private _firstFrame = true

  constructor(
    element: HTMLElement,
    cacheKey: string,
    rendererType: RendererType
  ) {
    this.bind(element)
    this.cacheKey = cacheKey
    this.worker = new Worker(new URL('./worker.js', import.meta.url), {
      name: `renderer-worker-${this.uuid}`,
    })

    if (this.worker) {
      const offscreenCanvas = this.canvas?.transferControlToOffscreen()

      if (offscreenCanvas) {
        this.worker.postMessage(
          {
            event: 'create',
            payload: {
              rendererType,
              canvas: offscreenCanvas,
            },
          },
          [offscreenCanvas]
        )
      }

      this.worker.onmessage = (e) => {
        const { event } = e.data

        if (event === 'renderDone') {
          this.onRenderDone?.()
        }
      }
    }
  }

  public reuse(element: HTMLElement, cacheKey: string) {
    this.container = element
    this.active = true
    this.cacheKey = cacheKey
    this.bind(element)
  }

  public destroy() {
    this.active = false
    this.unbind()
    this.onRenderDone?.()
    if (!this.inPool) {
      this.worker?.terminate()
    } else {
      // 下个时间循环，进行 clear，否则 display:none 会晚于 clear
      setTimeout(() => {
        this.worker?.postMessage({
          event: 'clear',
        })
      })
    }
  }

  private bind(element: HTMLElement) {
    this.container = element
    if (!this.canvas) {
      this.canvas = document.createElement('canvas')
      Object.assign(this.canvas.style, {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
      })
    }

    this.canvas.style.display = 'none'

    if (this.container.firstChild) {
      this.container.insertBefore(this.canvas, this.container.firstChild)
    } else {
      this.container.appendChild(this.canvas)
    }

    this._observer = new ResizeObserver(() => {
      this.resizeCanvas()
    })

    this._observer.observe(this.container)
    this._firstFrame = true
  }

  private unbind() {
    if (this.canvas) {
      this.canvas.style.display = 'none'
    }

    this.container && this._observer?.unobserve(this.container)
    this._observer?.disconnect()

    if (this.container && this.canvas?.parentNode === this.container) {
      this.container.removeChild(this.canvas)
    }

    this.container = undefined
  }

  public drawFrame(videoFrame: VideoFrame): void {
    if (!this.canvas) return
    const { width, height } = videoFrame
    if (this._firstFrame) {
      this._firstFrame = false
      console.warn(
        new Date().toLocaleString(),
        this.cacheKey,
        'first frame available',
        'width',
        width,
        'height',
        height,
      )
    }

    if (this.canvas.style.display != '') {
      this.canvas.style.display = ''
    }

    if (this._width != width || this._height != height) {
      this._width = width
      this._height = height

      this.resizeCanvas()
    }

    this.worker?.postMessage({
      event: 'drawFrame',
      payload: {
        videoFrame,
      },
    })
  }

  protected rotateCanvas(videoFrame: VideoFrame): void {
    if (!this.canvas) return
    const { width, height, rotation } = videoFrame

    if (rotation === 0 || rotation === 180) {
      this.canvas.width = width!
      this.canvas.height = height!
    } else if (rotation === 90 || rotation === 270) {
      this.canvas.height = width!
      this.canvas.width = height!
    } else {
      throw new Error(
        `Invalid rotation: ${rotation}, only 0, 90, 180, 270 are supported`
      )
    }
  }

  private resizeCanvas() {
    if (!this.canvas) return
    const width = this._width
    const height = this._height

    // 性能优化
    const canvas = this.canvas
    const view = this.container

    if (canvas && view) {
      const viewWidth = view.clientWidth
      const viewHeight = view.clientHeight

      if (viewWidth / (width / height) > viewHeight) {
        canvas.style.height = `${viewHeight}px`
        canvas.style.width = `auto`
      } else {
        canvas.style.width = `${viewWidth}px`
        canvas.style.height = `auto`
      }
    }
  }
}
