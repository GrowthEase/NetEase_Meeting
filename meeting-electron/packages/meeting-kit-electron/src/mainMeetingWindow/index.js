const {
  BrowserWindow,
  screen,
  shell,
  nativeTheme,
  app,
  dialog,
} = require('electron')
const { download } = require('electron-dl')
const path = require('path')
const {
  addScreenSharingIpc,
  closeScreenSharingWindow,
} = require('../sharingScreen')
const { setWindowOpenHandler } = require('./childWindow')
const { addIpcMainListeners, removeIpcMainListeners } = require('./ipcMain')
const { MINI_WIDTH, MINI_HEIGHT, isLocal, isWin32 } = require('../constant')
const {
  addGlobalIpcMainListeners,
  removeGlobalIpcMainListeners,
} = require('../ipcMain')
const { initMonitoring } = require('../utils/monitoring')
const os = require('os')
const NEMeetingKit = require('../kit/impl/meeting_kit')

// 获取操作系统类型
const platform = os.platform()
const version = os.release()

const isMacOS15 = platform === 'darwin' && version.startsWith('24')

initMonitoring()

if (isLocal) {
  app.commandLine.appendSwitch('ignore-certificate-errors')
}

// 窗口数量
app.commandLine.appendSwitch('--max-active-webgl-contexts', 1000)
// 开启 SharedArrayBuffer
app.commandLine.appendSwitch('enable-features', 'SharedArrayBuffer')
// 开启 web gpu
/*
if (!isMacOS15) {
  app.commandLine.appendSwitch('--enable-unsafe-webgpu')
}
*/

if (process.platform === 'win32') {
  app.commandLine.appendSwitch('high-dpi-support', 'true')
  // app.commandLine.appendSwitch('force-device-scale-factor', '1')
}

let mainWindow = null

function displayChanged() {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow?.webContents.send('display-changed')
  }
}

function checkSystemVersion() {
  const systemLanguage = app.getPreferredSystemLanguages()?.[0]
  const defaultMessageTip = '当前系统版本过低，请升级系统版本'
  const defaultBtnTextTip = '确定'
  const messageLanguageMap = {
    'zh-Hans-CN': '当前系统版本过低，请升级系统版本',
    'en-CN':
      'The current system version is too low, please upgrade the system version',
    'ja-CN':
      '現在のシステムバージョンが低すぎます。システムバージョンをアップグレードしてください',
  }

  const btnTextLanguageMap = {
    'zh-Hans-CN': '确定',
    'en-CN': 'OK',
    'ja-CN': '確認',
  }
  const showDialog = (message, btnText) => {
    dialog
      .showMessageBox({
        message: message || defaultMessageTip,
        buttons: [btnText || defaultBtnTextTip],
        type: 'warning',
      })
      .then(() => {
        app.exit(0)
      })
  }

  // 如果是 Windows 系统
  if (platform === 'win32') {
    const version = os.release()
    const majorVersion = parseInt(version.split('.')[0])

    if (majorVersion < 10) {
      // 弹出提示对话框
      showDialog(
        messageLanguageMap[systemLanguage],
        btnTextLanguageMap[systemLanguage]
      )
      return false
    } else {
      return true
    }
  } else {
    const version = os.release()
    const macVersion = parseFloat(version)

    if (macVersion < 19.5) {
      showDialog(
        messageLanguageMap[systemLanguage],
        btnTextLanguageMap[systemLanguage]
      )
      return false
    } else {
      return true
    }
  }
}

function openMeetingWindow(data) {
  if (!checkSystemVersion()) {
    return
  }

  addGlobalIpcMainListeners()

  const urlPath = data ? 'meeting' : 'meeting-component'

  // 设置进入会议页面窗口大小及其他属性
  function initMainWindowSize() {
    const mousePosition = screen.getCursorScreenPoint()
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition)
    const { x, y, width, height } = nowDisplay.workArea

    mainWindow.setFullScreen(false)

    mainWindow.setBounds({
      width: Math.round(MINI_WIDTH),
      height: Math.round(MINI_HEIGHT),
      x: Math.round(x + (width - MINI_WIDTH) / 2),
      y: Math.round(y + (height - MINI_HEIGHT) / 2),
    })
    mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT)
    mainWindow.isFullScreenPrivate = false
    mainWindow.isMaximizedPrivate = false
  }

  function setThemeColor() {
    if (!mainWindow.isDestroyed()) {
      mainWindow?.webContents.send(
        'set-theme-color',
        nativeTheme.shouldUseDarkColors ?? true
      )
      nativeTheme.on('updated', () => {
        if (!mainWindow?.isDestroyed()) {
          mainWindow?.webContents.send(
            'set-theme-color',
            nativeTheme.shouldUseDarkColors ?? true
          )
        }
      })
    }
  }

  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.destroy()
  }

  mainWindow = new BrowserWindow({
    titleBarStyle: 'hidden',
    title: '网易会议',
    trafficLightPosition: {
      x: 10,
      y: 7,
    },
    hasShadow: true,
    transparent: true,
    show: false,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      backgroundThrottling: false,
      preload: path.join(__dirname, '../preload.js'),
    },
  })

  if (isLocal) {
    mainWindow.loadURL(`http://localhost:8000/#/${urlPath}`)
    setTimeout(() => {
      mainWindow.webContents.openDevTools()
    }, 3000)
  } else {
    mainWindow.loadFile(path.join(__dirname, '../../build/index.html'), {
      hash: urlPath,
    })
  }

  // 最大化
  mainWindow.on('maximize', () => {
    mainWindow?.webContents.send('maximize-window', true)
    mainWindow.isMaximizedPrivate = true
  })

  // 取消最大化
  mainWindow.on('unmaximize', () => {
    mainWindow?.webContents.send('maximize-window', false)
    mainWindow.isMaximizedPrivate = false
  })

  mainWindow.webContents.session.removeAllListeners('will-download')
  mainWindow.webContents.session.on('will-download', async (event, item) => {
    // 获取文件名
    const fileName = item.getFilename()

    if (fileName.includes('auto_save!')) {
      event.preventDefault()

      const url = item.getURL()
      const paths = fileName.split('!')

      mainWindow.webContents
        .executeJavaScript(
          `localStorage.getItem("ne-meeting-setting-${paths[1]}")`,
          true
        )
        .then((res) => {
          try {
            const setting = JSON.parse(res)

            download(mainWindow, url, {
              directory:
                setting?.normalSetting?.downloadPath ||
                app.getPath('downloads'),
              filename: `${paths[2]}`,
              overwrite: true,
              openFolderWhenDone: false,
            })
          } catch {
            //
          }
        })
    } else {
      item.on('done', (event, state) => {
        const uuidCsvRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.csv$/i

        if (
          state === 'completed' &&
          fileName.endsWith('csv') &&
          !uuidCsvRegex.test(fileName)
        ) {
          // 文件下载完成，打开文件所在路径
          const path = event.sender.getSavePath()

          shell.showItemInFolder(path)
        }
      })
    }
  })

  // 用来区分关闭窗口的方式
  let beforeQuit = false

  app.on('before-quit', async () => {
    if (mainWindow.inMeeting) {
      beforeQuit = true
    } else {
      console.log('开始反初始化')
      const neMeetingKit = NEMeetingKit.default.getInstance()

      try {
        neMeetingKit.isInitialized && (await neMeetingKit.unInitialize())
      } catch (error) {
        console.log('unInitialize error', error)
      }
    }
  })

  mainWindow.on('close', function (event) {
    if (mainWindow.inMeeting) {
      event.preventDefault()
      mainWindow?.webContents.send('main-close-before', beforeQuit)
      mainWindow?.show()
      beforeQuit = false
    }
  })

  mainWindow.on('leave-full-screen', () => {
    mainWindow?.webContents.send('leave-full-screen')
    mainWindow.isFullScreenPrivate = false
  })
  mainWindow.on('enter-full-screen', () => {
    mainWindow?.webContents.send('enter-full-screen')
    mainWindow.isFullScreenPrivate = true
  })

  mainWindow.webContents.once('dom-ready', () => {
    if (data) {
      mainWindow?.webContents.send('nemeeting-open-meeting', data)
      mainWindow?.show()
    }

    mainWindow.isDomReady = true

    if (
      mainWindow.domReadyCallback &&
      typeof mainWindow.domReadyCallback === 'function'
    ) {
      mainWindow.domReadyCallback()
    }
  })

  mainWindow.setBackgroundColor('rgba(255, 255, 255,0)')

  mainWindow.webContents.send(
    'set-theme-color',
    nativeTheme.shouldUseDarkColors ?? true
  )

  screen.on('display-removed', displayChanged)

  screen.on('display-added', displayChanged)

  /*
  function debounce(func, wait) {
    let timeout

    return function (...args) {
      clearTimeout(timeout)
      timeout = setTimeout(() => {
        func.apply(this, args)
      }, wait)
    }
  }

  const neMeetingDisplayChanged = debounce(() => {
    const display = screen.getDisplayMatching(mainWindow.getBounds())

    mainWindow.webContents.send('neMeetingDisplayChanged', display.size)
  }, 1000)

  mainWindow.on('moved', neMeetingDisplayChanged)
  */

  setWindowOpenHandler(mainWindow)

  initMainWindowSize()

  addScreenSharingIpc({
    mainWindow,
    initMainWindowSize,
  })

  setThemeColor()
  addIpcMainListeners(mainWindow)

  mainWindow.initMainWindowSize = initMainWindowSize

  return mainWindow
}

function closeMeetingWindow() {
  mainWindow?.destroy()
  mainWindow = null
  closeScreenSharingWindow()
  removeIpcMainListeners()

  removeGlobalIpcMainListeners()

  screen.removeListener('display-removed', displayChanged)
  screen.removeListener('display-added', displayChanged)
}

module.exports = {
  openMeetingWindow,
  closeMeetingWindow,
}
