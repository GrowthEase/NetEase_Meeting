import { VideoFrame } from './IRenderer'

export function isSupportWebWorker(): boolean {
  return !!window.Worker
}

export function isSupportRendererType(): 'webgpu' | 'webgl' | 'software' {
  if (navigator.gpu) {
    return 'webgpu'
  }

  let flag = false
  const canvas: HTMLCanvasElement = document.createElement('canvas')

  try {
    const getContext = (
      contextNames = ['webgl2', 'webgl', 'experimental-webgl']
    ): WebGLRenderingContext | WebGLRenderingContext | null => {
      for (const contextName of contextNames) {
        const context = canvas?.getContext(contextName)

        if (context) {
          return context as WebGLRenderingContext | WebGLRenderingContext
        }
      }

      return null
    }

    let gl = getContext()

    flag = !!gl
    gl?.getExtension('WEBGL_lose_context')?.loseContext()
    gl = null
    console.log('Your browser support webGL')
  } catch (e) {
    console.warn('Your browser may not support webGL')
    flag = false
  }

  return flag ? 'webgl' : 'software'
}

type YUVBuffer = {
  yStride: number
  uStride: number
  vStride: number
  yOffset: number
  uOffset: number
  vOffset: number
  bytes: Uint8Array
}

export type YUVData = {
  width: number
  height: number
  data: YUVBuffer
}

export function getVideoFrame(yuv: YUVData): VideoFrame {
  const { width, height, data } = yuv

  return {
    width,
    height,
    yStride: data.yStride,
    uStride: data.uStride,
    vStride: data.vStride,
    yBuffer: data.bytes.subarray(0, data.yOffset),
    uBuffer: data.bytes.subarray(data.yOffset, data.uOffset),
    vBuffer: data.bytes.subarray(data.uOffset, data.vOffset),
    rotation: 0,
  }
}

// 生成uuid
export function getUUID(): string {
  let date = new Date().getTime()
  const uuid = 'xxxxxxxx-xxxx-xxxx-xxxx'.replace(/[xy]/g, function (c) {
    const r = (date + Math.random() * 16) % 16 | 0

    date = Math.floor(date / 16)
    return (c == 'x' ? r : (r & 0x3) | 0x8).toString(16)
  })

  return uuid
}

export class RafInterval {
  private timer: NodeJS.Timeout | null = null

  start(callback: () => void, interval: number) {
    this.timer = setInterval(callback, interval)
  }

  stop() {
    if (this.timer !== null) {
      clearInterval(this.timer)
      this.timer = null
    }
  }
}
