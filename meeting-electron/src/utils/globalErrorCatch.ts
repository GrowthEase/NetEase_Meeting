import { IPCEvent } from '../../app/src/types'

function globalErrorCatch() {
  let contextmenuCount = 0
  let contextmenuTimer: NodeJS.Timeout | null = null

  window.addEventListener(
    'contextmenu',
    () => {
      contextmenuCount++

      if (contextmenuCount > 30) {
        window.ipcRenderer?.send(IPCEvent.openDevTools)
        contextmenuCount = 0
      }

      if (contextmenuTimer) {
        clearTimeout(contextmenuTimer)
        contextmenuTimer = null
      }

      contextmenuTimer = setTimeout(() => {
        contextmenuCount = 0
      }, 3000)
    },
    true
  )

  window.onerror = function (message, source, lineno, colno, error) {
    window.electronLog?.('window.onerror：', {
      message,
      source,
      lineno,
      colno,
      error,
    })
    return true
  }

  window.addEventListener(
    'error',
    (error) => {
      window.electronLog?.('addEventListener error：', {
        error,
      })
    },
    true
  )

  window.addEventListener('unhandledrejection', function (e) {
    e.preventDefault()
    window.electronLog?.('unhandledrejection error：', {
      e,
    })
    return true
  })
}

export default globalErrorCatch
