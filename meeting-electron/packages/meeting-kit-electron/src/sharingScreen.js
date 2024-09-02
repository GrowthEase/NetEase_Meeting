const { BrowserWindow, ipcMain, screen } = require('electron')
const path = require('path')

const isLocal = process.env.MODE === 'local'
const isWin32 = process.platform === 'win32'

const MEETING_HEADER_HEIGHT = 28
const NOTIFY_WINDOW_WIDTH = 408
const NOTIFY_WINDOW_HEIGHT = 200
const WINDOW_WIDTH = 1200
const COLLAPSE_WINDOW_WIDTH = 350

let mY = 0

let memberNotifyTimer = null
let mainWindowAlwaysOnTopTimer

const sharingScreen = {
  isSharing: false,
  memberNotifyWindow: null,
  shareScreen: null,
}

const closeScreenSharingWindow = function () {
  ipcMain.removeAllListeners('nemeeting-sharing-screen')
  closeMemberNotifyWindow()
}

function createNotifyWindow(mainWindow) {
  if (
    sharingScreen.memberNotifyWindow &&
    !sharingScreen.memberNotifyWindow.isDestroyed()
  ) {
    return
  }

  const nowDisplay = screen.getPrimaryDisplay()
  const { x, y, width, height } = nowDisplay.workArea

  sharingScreen.memberNotifyWindow = new BrowserWindow({
    width: NOTIFY_WINDOW_WIDTH,
    height: NOTIFY_WINDOW_HEIGHT,
    x: Math.round(width + NOTIFY_WINDOW_WIDTH),
    y: Math.round(height + NOTIFY_WINDOW_HEIGHT),
    titleBarStyle: 'hidden',
    maximizable: false,
    minimizable: false,
    fullscreenable: false,
    closable: false,
    resizable: false,
    skipTaskbar: true,
    transparent: true,
    show: false,
    hasShadow: false,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      preload: path.join(__dirname, './ipc.js'),
    },
  })
  const notifyWindow = sharingScreen.memberNotifyWindow

  // 先强制保护窗口内容，避免共享被捕获
  notifyWindow.setContentProtection(true)

  if (isLocal) {
    notifyWindow.loadURL('http://localhost:8000/#/memberNotify')
  } else {
    notifyWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'memberNotify',
    })
  }

  notifyWindow.setAlwaysOnTop(true, 'screen-saver')
  notifyWindow.show()
  setTimeout(() => {
    setNotifyWindowPosition(width, height)
  })
  if (isWin32) {
    ipcMain.on('member-notify-mousemove', () => {
      if (memberNotifyTimer) {
        clearNotifyWIndowTimeout()
      }
    })
  }

  ipcMain.on('notify-show', (event, arg) => {
    sharingScreen.memberNotifyWindow?.webContents.send('notify-show', arg)
    sharingScreen.memberNotifyWindow?.setPosition(
      Math.round(width - NOTIFY_WINDOW_WIDTH),
      Math.round(height - NOTIFY_WINDOW_HEIGHT)
    )
    if (isWin32) {
      clearNotifyWIndowTimeout()
      memberNotifyTimer = setTimeout(() => {
        setNotifyWindowPosition(width, height)
      }, 5000)
    }
  })

  ipcMain.on('notify-hide', (event, arg) => {
    sharingScreen.memberNotifyWindow?.webContents.send('notify-hide', arg)
    setNotifyWindowPosition(width, height)
  })
  ipcMain.on('member-notify-view-member-msg', (event, arg) => {
    mainWindow?.webContents.send('member-notify-view-member-msg')
  })
  ipcMain.on('member-notify-close', (event, arg) => {
    // mainWindow?.webContents.send('member-notify-close')
    setNotifyWindowPosition(width, height)
  })
  ipcMain.on('member-notify-not-notify', (event, arg) => {
    mainWindow?.webContents.send('member-notify-not-notify')
    setNotifyWindowPosition(width, height)
  })
  sharingScreen.memberNotifyWindow.on('destroyed', function (event) {
    removeMemberNotifyListener()
    sharingScreen.memberNotifyWindow = null
  })
}

function setNotifyWindowPosition(width, height) {
  if (
    sharingScreen.memberNotifyWindow &&
    !sharingScreen.memberNotifyWindow.isDestroyed()
  ) {
    sharingScreen.memberNotifyWindow.setPosition(
      Math.round(width + NOTIFY_WINDOW_WIDTH),
      Math.round(height + NOTIFY_WINDOW_HEIGHT)
    )
  }

  clearNotifyWIndowTimeout()
}

function clearNotifyWIndowTimeout() {
  memberNotifyTimer && clearTimeout(memberNotifyTimer)
  memberNotifyTimer = null
}

function removeMemberNotifyListener() {
  ipcMain.removeAllListeners('notify-show')
  ipcMain.removeAllListeners('notify-hide')
  ipcMain.removeAllListeners('member-notify-view-member-msg')
  ipcMain.removeAllListeners('member-notify-close')
  ipcMain.removeAllListeners('member-notify-not-notify')
  if (isWin32) {
    ipcMain.removeAllListeners('member-notify-mousemove')
  }
}

function closeMemberNotifyWindow() {
  sharingScreen.memberNotifyWindow?.destroy()
  sharingScreen.memberNotifyWindow = null
  removeMemberNotifyListener()
  memberNotifyTimer && clearTimeout(memberNotifyTimer)
  memberNotifyTimer = null
}

function addScreenSharingIpc({ mainWindow, initMainWindowSize }) {
  let shareScreen = null
  // 用来改变工具栏视图的高度
  let mainHeight = [60]

  function mainWindowCenter(mainWindow) {
    const nowDisplay = shareScreen || screen.getPrimaryDisplay()
    const { x, width } = nowDisplay.workArea
    const mainWindowWidth = mainWindow.getBounds().width

    mainWindow.setBounds({
      x: Math.floor(x + width / 2 - mainWindowWidth / 2),
      y: mY,
    })
  }

  function removeMainHeight(height) {
    const index = mainHeight.findIndex((item) => item === height)

    if (index !== -1) {
      mainHeight.splice(index, 1)
    }
  }

  function setMainWindowHeight() {
    if (!mainWindow || mainWindow.isDestroyed()) {
      return
    }

    let height = Math.max.apply(null, mainHeight)

    // 如果高度没有超过 100 ， 说明是工具栏的高度，不需要改变主窗口的高度。 只有 40 ， 60  两种
    if (height < 100) {
      height = mainHeight[mainHeight.length - 1]
    }

    if (sharingScreen.isSharing) {
      mainWindow.setBounds({
        height,
      })
    }

    if (height === 60) {
      mainWindow.setBounds({
        width: WINDOW_WIDTH,
      })
    } else if (height === 40) {
      mainWindow.setBounds({
        width: COLLAPSE_WINDOW_WIDTH,
      })
    } else {
      mainWindow.setBounds({
        width: WINDOW_WIDTH,
      })
    }

    // mainWindow.center();
    mainWindowCenter(mainWindow)
  }

  ipcMain.on('nemeeting-sharing-screen', (event, value) => {
    const { method, data } = value

    switch (method) {
      case 'start': {
        const nowDisplay = shareScreen || screen.getPrimaryDisplay()
        const { x, y, width } = nowDisplay.workArea

        mainWindow.setBackgroundColor('rgba(255, 255, 255, 0)')
        mainWindow.setOpacity(0)
        setTimeout(() => {
          mainWindow.setOpacity(1)
          mainWindow.setBackgroundColor('rgba(255, 255, 255,0)')
        }, 300)

        createNotifyWindow(mainWindow)
        sharingScreen.isSharing = true

        mainWindow.setMinimizable(false)
        mainWindow.setMinimumSize(1, 1)
        mainWindow.setWindowButtonVisibility?.(false)
        mainWindow.setHasShadow(false)
        mainWindow.setResizable(false)

        const mainWidth = 760
        const mainX = x + width / 2 - mainWidth / 2

        // 记录主窗口的y坐标
        mY = y

        mainWindow.setBounds({
          x: Math.round(mainX),
          y,
          width: WINDOW_WIDTH,
        })

        mainWindow.setMovable(true)
        mainHeight = [60]
        setMainWindowHeight()

        mainWindow.setAlwaysOnTop(true, 'normal', 100)
        if (isWin32) {
          mainWindowAlwaysOnTopTimer = setInterval(() => {
            if (mainWindow && !mainWindow.isDestroyed()) {
              mainWindow.setAlwaysOnTop(true, 'normal', 100)
            } else {
              clearInterval(mainWindowAlwaysOnTopTimer)
              mainWindowAlwaysOnTopTimer = null
            }
          }, 1000)
        }

        // 先强制保护窗口内容，避免共享被捕获
        mainWindow.setContentProtection(true)

        break
      }

      case 'share-screen': {
        shareScreen = screen.getAllDisplays()[data]
        sharingScreen.shareScreen = shareScreen
        screen.on('display-removed', (_, data) => {
          const isSameDisplay = data.label === shareScreen?.label

          if (isSameDisplay) {
            // TODO: 退出共享
          }
        })

        break
      }

      case 'stop':
        closeMemberNotifyWindow()
        if (sharingScreen.isSharing && !mainWindow.isDestroyed()) {
          if (!data?.immediately) {
            mainWindow.setOpacity(0)
            setTimeout(() => {
              if (mainWindow.isDestroyed()) return
              mainWindow.setOpacity(1)
              !isWin32 && mainWindow.setBackgroundColor('#ffffff')
            }, 300)
          }

          shareScreen = null
          sharingScreen.isSharing = false

          mainWindow.setMinimizable(true)
          mainWindow.setWindowButtonVisibility?.(true)
          mainWindow.setHasShadow(true)
          mainWindow.setAlwaysOnTop(false)
          mainWindow.setResizable(true)

          initMainWindowSize()
          mainWindow.show()

          if (mainWindowAlwaysOnTopTimer) {
            clearInterval(mainWindowAlwaysOnTopTimer)
            mainWindowAlwaysOnTopTimer = null
          }
        }

        // 先强制结束内容保护
        mainWindow.setContentProtection(false)

        break
      case 'controlBarVisibleChangeByMouse':
        if (sharingScreen.isSharing) {
          if (data) {
            mainWindow.setBounds({
              width: WINDOW_WIDTH,
            })
            removeMainHeight(60)
            mainHeight.push(60)
            setMainWindowHeight(true)
          } else {
            mainWindow.setBounds({
              width: COLLAPSE_WINDOW_WIDTH,
            })
            removeMainHeight(40)
            mainHeight.push(40)
            setMainWindowHeight(true)
          }

          mainWindowCenter(mainWindow)
        }

        break
      case 'openDeviceList':
        mainHeight.push(800)
        setMainWindowHeight()
        break
      case 'closeDeviceList':
        removeMainHeight(800)
        setMainWindowHeight(true)
        break
      case 'openPopover':
        mainHeight.push(150)
        setMainWindowHeight(true)
        break
      case 'closePopover':
        removeMainHeight(150)
        setMainWindowHeight(true)
        break
      case 'openModal':
        if (sharingScreen.isSharing) {
          mainHeight.push(300)
          setMainWindowHeight()
        }

        break
      case 'closeModal':
        if (sharingScreen.isSharing) {
          removeMainHeight(300)
          setMainWindowHeight(true)
        }

        break
      case 'openToast':
        if (sharingScreen.isSharing) {
          mainHeight.push(120)
          setMainWindowHeight()
        }

        event.sender.send('nemeeting-sharing-screen', {
          method,
          data: sharingScreen.isSharing,
        })
        break
      case 'closeToast':
        if (sharingScreen.isSharing) {
          removeMainHeight(120)
          setMainWindowHeight(true)
        }

        break
      case 'videoWindowHeightChange': {
        const { height } = data
        const videoWindow = BrowserWindow.fromWebContents(event.sender)

        if (videoWindow) {
          videoWindow?.setBounds({
            height: Math.round(height + MEETING_HEADER_HEIGHT),
          })
        }

        break
      }

      default:
        break
    }
  })
}

module.exports = {
  sharingScreen,
  closeScreenSharingWindow,
  addScreenSharingIpc,
}
