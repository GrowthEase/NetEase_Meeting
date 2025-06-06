import { ipcMain, screen, BrowserWindow } from 'electron'
import { isWin32 } from '../constant'

const IPC_EVENT = {
  DUAL_MONITORS_DISPLAY_ADDED: 'DUAL_MONITORS_DISPLAY_ADDED',
  DUAL_MONITORS_DISPLAY_REMOVED: 'DUAL_MONITORS_DISPLAY_REMOVED',
  DUAL_MONITORS_GET_DISPLAY_COUNT: 'DUAL_MONITORS_GET_DISPLAY_COUNT',
  DUAL_MONITORS_WIN_CLOSE: 'DUAL_MONITORS_WIN_CLOSE',
  DUAL_MONITORS_WIN_HIDE: 'DUAL_MONITORS_WIN_HIDE',
  DUAL_MONITORS_WIN_SHOW: 'DUAL_MONITORS_WIN_SHOW',
  DUAL_MONITORS_WIN_SWAP: 'DUAL_MONITORS_WIN_SWAP',
  DUAL_MONITORS_WIN_END: 'DUAL_MONITORS_WIN_END',
}

type BrowserWindowEx = BrowserWindow & {
  isFullScreenPrivate: boolean
  isMaximizedPrivate: boolean
}

let mainWin: BrowserWindow | undefined
let dualMonitorsWin: BrowserWindowEx | undefined

const swapWindowsPosition = async (win1, win2) => {
  // 检查窗口是否全屏
  const isWin1FullScreen = win1.isFullScreenPrivate
  const isWin2FullScreen = win2.isFullScreenPrivate

  // 如果窗口全屏，先退出全屏模式
  if (isWin1FullScreen) win1.setFullScreen(false)
  if (isWin2FullScreen) win2.setFullScreen(false)

  // 等待窗口退出全屏状态
  if (isWin1FullScreen || isWin2FullScreen) {
    await new Promise((resolve) => setTimeout(resolve, 1000))
  }

  // 获取窗口尺寸
  const [width1, height1] = win1.getSize()
  const [width2, height2] = win2.getSize()

  // 获取窗口位置
  const [x1, y1] = win1.getPosition()
  const [x2, y2] = win2.getPosition()

  // 计算窗口中心点
  const centerX1 = x1 + width1 / 2
  const centerY1 = y1 + height1 / 2
  const centerX2 = x2 + width2 / 2
  const centerY2 = y2 + height2 / 2

  // 计算新位置，使每个窗口的中心点对调
  const newX1 = Math.round(centerX2 - width1 / 2)
  const newY1 = Math.round(centerY2 - height1 / 2)
  const newX2 = Math.round(centerX1 - width2 / 2)
  const newY2 = Math.round(centerY1 - height2 / 2)

  // 设置新位置
  win1.setPosition(newX1, newY1)
  win2.setPosition(newX2, newY2)
  // 重新设置全屏模式
  if (isWin1FullScreen) win1.setFullScreen(true)
  if (isWin2FullScreen) win2.setFullScreen(true)
}

function registerDualMonitors(win: BrowserWindow) {
  mainWin = win
  // 监听屏幕变化
  screen.on('display-added', () => {
    const length = screen.getAllDisplays().length

    mainWin?.webContents.send(IPC_EVENT.DUAL_MONITORS_DISPLAY_ADDED, length)
  })

  screen.on('display-removed', () => {
    const length = screen.getAllDisplays().length

    if (length === 1) {
      if (dualMonitorsWin && !dualMonitorsWin.isDestroyed()) {
        dualMonitorsWin.hide()
      }
    }

    mainWin?.webContents.send(IPC_EVENT.DUAL_MONITORS_DISPLAY_REMOVED, length)
  })

  ipcMain.handle(IPC_EVENT.DUAL_MONITORS_GET_DISPLAY_COUNT, () => {
    return screen.getAllDisplays().length
  })

  ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_SWAP, () => {
    if (mainWin && dualMonitorsWin) {
      mainWin.show()
      swapWindowsPosition(mainWin, dualMonitorsWin)
    }
  })
}

function handleDualMonitorsWin(win: BrowserWindowEx) {
  // 窗口关闭标记位
  let isClosed = false

  dualMonitorsWin = win
  // 打开开发者工具
  // dualMonitorsWin.webContents.openDevTools()
  function setWindowPosition() {
    const displays = screen.getAllDisplays()

    if (displays.length > 1 && mainWin) {
      const mainWinDisplay = screen.getDisplayMatching(mainWin.getBounds())

      //确定副屏的显示窗口
      const dualMonitorsWinDisplay =
        mainWinDisplay.id === displays[0].id ? displays[1] : displays[0]

      if (dualMonitorsWin) {
        const { width: winWidth, height: winHeight } =
          dualMonitorsWin.getBounds()
        const { x, y, width, height } = dualMonitorsWinDisplay.workArea

        dualMonitorsWin.show()
        dualMonitorsWin.setBounds({
          x: Math.round(x + width / 2 - winWidth / 2),
          y: Math.round(y + height / 2 - winHeight / 2),
        })
      }
    }
  }

  setWindowPosition()

  function handleWinHide() {
    dualMonitorsWin?.hide()
  }

  function handleWinShow() {
    dualMonitorsWin?.show()
  }

  function handleWinClose() {
    isClosed = true
    ipcMain.off(IPC_EVENT.DUAL_MONITORS_WIN_SHOW, handleWinShow)
    ipcMain.off(IPC_EVENT.DUAL_MONITORS_WIN_HIDE, handleWinHide)
    if (dualMonitorsWin && !dualMonitorsWin.isDestroyed()) {
      dualMonitorsWin.close()
    }
  }

  dualMonitorsWin.removeAllListeners('close')
  dualMonitorsWin.removeAllListeners('closed')
  dualMonitorsWin.removeAllListeners('enter-full-screen')
  dualMonitorsWin.removeAllListeners('leave-full-screen')
  dualMonitorsWin.removeAllListeners('maximize')
  dualMonitorsWin.removeAllListeners('unmaximize')

  dualMonitorsWin.on('close', (event) => {
    event.preventDefault()
    if (isClosed) {
      if (dualMonitorsWin?.isFullScreenPrivate) {
        dualMonitorsWin?.removeAllListeners('leave-full-screen')
        dualMonitorsWin?.on('leave-full-screen', () => {
          if (dualMonitorsWin) {
            dualMonitorsWin.isFullScreenPrivate = false
            dualMonitorsWin.hide()
          }
        })
        dualMonitorsWin?.setFullScreen(false)
        isWin32 && dualMonitorsWin.hide()
      } else {
        dualMonitorsWin?.hide()
      }

      return
    }

    dualMonitorsWin?.webContents.send(IPC_EVENT.DUAL_MONITORS_WIN_END)
  })

  dualMonitorsWin.on('leave-full-screen', () => {
    if (dualMonitorsWin) {
      dualMonitorsWin.webContents.send('leave-full-screen')
      dualMonitorsWin.isFullScreenPrivate = false
    }
  })
  dualMonitorsWin.on('enter-full-screen', () => {
    if (dualMonitorsWin) {
      dualMonitorsWin.webContents.send('enter-full-screen')
      dualMonitorsWin.isFullScreenPrivate = true
    }
  })

  // 最大化
  dualMonitorsWin.on('maximize', () => {
    if (dualMonitorsWin) {
      dualMonitorsWin.webContents.send('maximize-window', true)
      dualMonitorsWin.isMaximizedPrivate = true
    }
  })

  // 取消最大化
  dualMonitorsWin.on('unmaximize', () => {
    if (dualMonitorsWin) {
      dualMonitorsWin.webContents.send('maximize-window', false)
      dualMonitorsWin.isMaximizedPrivate = false
    }
  })

  // 窗口关闭
  ipcMain.once(IPC_EVENT.DUAL_MONITORS_WIN_CLOSE, handleWinClose)

  ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_SHOW, handleWinShow)
  ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_HIDE, handleWinHide)
}

function unregisterDualMonitors() {
  ipcMain.removeHandler(IPC_EVENT.DUAL_MONITORS_GET_DISPLAY_COUNT)
}

export { registerDualMonitors, unregisterDualMonitors, handleDualMonitorsWin }
