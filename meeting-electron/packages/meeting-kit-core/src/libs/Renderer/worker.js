import SoftwareRenderer from './Renderers/js/renderer_software'
import WebGLRenderer from './Renderers/js/renderer_webgl'
import WebGPURender from './Renderers/js/renderer_webgpu'

const globalThis =
  typeof window !== 'undefined'
    ? window
    : typeof global !== 'undefined'
    ? global
    : typeof self !== 'undefined'
    ? self
    : {}

let renderer

function createRenderer(data) {
  if (!data.canvas) return
  const { rendererType, canvas } = data

  switch (rendererType) {
    case 'software':
      renderer = new SoftwareRenderer(canvas)
      break
    case 'webgl':
      renderer = new WebGLRenderer(canvas)
      break
    case 'webgpu':
      renderer = new WebGPURender(canvas)
      break
    default:
      break
  }
}

async function drawFrame(data) {
  if (!renderer) return

  const { videoFrame } = data

  if (!renderer.isInit) {
    await renderer.init?.()
  }

  renderer.drawFrame(videoFrame)

  self.postMessage({
    event: 'renderDone',
  })
}

function clear() {
  if (!renderer) return
  renderer.clear?.()
}

if (globalThis) {
  self.addEventListener(
    'message',
    async ({ data }) => {
      const { event, payload } = data

      switch (event) {
        case 'create':
          createRenderer(payload)
          break
        case 'drawFrame':
          await drawFrame(payload)
          break
        case 'clear':
          clear()
          break
        default:
          break
      }
    },
    false
  )
}
