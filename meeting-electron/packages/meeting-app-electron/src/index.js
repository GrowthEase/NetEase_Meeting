const {
  app,
  BrowserWindow,
  ipcMain,
  shell,
  Menu,
  crashReporter,
  powerSaveBlocker,
  screen,
} = require('electron')
const log = require('electron-log/main')
const path = require('path')
const fs = require('fs')

const { getLogDate } = require('nemeeting-electron-sdk/lib/utils/log')
const {
  sharingScreen,
  closeScreenSharingWindow,
} = require('nemeeting-electron-sdk/lib/sharingScreen')
const {
  createBeforeMeetingWindow,
  beforeNewWins,
} = require('nemeeting-electron-sdk/lib/beforeMeetingWindow')

const { isLocal, isWin32 } = require('nemeeting-electron-sdk/lib/constant')

const { initUpdateListener } = require('./utils/update')
const { watchProtocol } = require('./utils/agreement')

const privateConfigFileName = 'xkit_server_private.json'

app.commandLine.appendSwitch('--max-active-webgl-contexts', 1000)

let userDataPath = app.getPath('userData')

// Windows直接用userPath还不行，要将路径改到local下
if (process.platform === 'win32') {
  userDataPath = path.join(userDataPath, '../../local/Netease/Meeting')
} else {
  userDataPath = path.join(userDataPath, '../Netease/Meeting')
}

app.setPath('userData', userDataPath)

if (!fs.existsSync(userDataPath)) {
  try {
    fs.mkdirSync(userDataPath, { recursive: true })
  } catch (err) {
    console.error(err)
  }
}

const privateConfigPath = path.join(userDataPath, privateConfigFileName)
// 定义日志目录名称
const cacheDirectoryName = 'logs'

// 构建日志目录路径
const logPath = path.join(userDataPath, cacheDirectoryName)

log.initialize({ preload: true })
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}'
log.transports.file.maxSize = 1024 * 1024 * 10
log.transports.file.fileName = `meeting_${getLogDate()}.log`
log.errorHandler.startCatching()
log.eventLogger.startLogging()
log.transports.file.resolvePathFn = (variables) =>
  path.join(logPath, 'app', variables.fileName)

console.log = log.log

app.setPath('crashDumps', path.join(logPath, 'app', 'crashDumps'))

crashReporter.start({
  uploadToServer: false,
})

// 处理 win SSO 登录，
if (isWin32) {
  const appLock = app.requestSingleInstanceLock()

  if (!appLock) {
    app.quit()
  }
}

let beforeMeetingWindow
let mainWindow
let inMeeting = false
let powerSaveBlockerId = null
let inviteUrl = ''

// 私有化配置文件内容
let privateConfig = null

//  创建日志文件夹
if (!fs.existsSync(logPath)) {
  fs.mkdirSync(logPath)
}

const innerPrivateConfigPath = path.join(__dirname, privateConfigFileName)

getPrivateConfig()

function getPrivateConfig() {
  try {
    // 如果存在配置文件
    if (fs.existsSync(innerPrivateConfigPath)) {
      console.log('存在私有化配置文件')
      fs.copyFileSync(innerPrivateConfigPath, privateConfigPath)
    }
  } catch (error) {
    console.log('copyPrivateConfig error', error)
  }
}

function dealLoginSuccess(url) {
  beforeMeetingWindow?.webContents.send('electron-login-success', url)
  mainWindow?.focus()
}

function handleUrl(url) {
  const isInviteUrl = url.includes('invitation')

  if (isInviteUrl) {
    if (inMeeting) {
      mainWindow?.show()
      mainWindow?.focus()
      mainWindow?.webContents.send('already-in-meeting')
    } else {
      // 从url启动应用，这个时候beforeMeetingWindow还没有创建需要缓存url
      if (!beforeMeetingWindow && !isWin32) {
        inviteUrl = url
      } else {
        beforeMeetingWindow?.show()
        beforeMeetingWindow?.focus()
        beforeMeetingWindow?.webContents.send('electron-join-meeting', url)
      }
    }
  } else {
    dealLoginSuccess(url)
  }
}

if (isLocal) {
  app.commandLine.appendSwitch('ignore-certificate-errors')
}

// 在ready事件回调之前监听自定义协议唤起
watchProtocol(handleUrl)

app.whenReady().then(() => {
  // addIpcMainListeners()

  beforeMeetingWindow = createBeforeMeetingWindow()

  beforeMeetingWindow?.on('close', (event) => {
    if (inMeeting) {
      event.preventDefault()
    }
  })

  beforeMeetingWindow?.on('closed', () => {
    app.exit(0)
  })

  initUpdateListener(beforeMeetingWindow, {}, `${app.name}/rooms`)

  app.on('render-process-gone', (event, webContents) => {
    if (
      beforeMeetingWindow &&
      !beforeMeetingWindow.isDestroyed() &&
      webContents.id === beforeMeetingWindow?.webContents.id
    ) {
      beforeMeetingWindow?.reload()
    }
  })

  // 通过 openWindow 打开的窗口，focusWindow 前置窗

  ipcMain.handle('getPrivateConfig', () => {
    if (privateConfig) {
      return privateConfig
    }

    if (fs.existsSync(privateConfigPath)) {
      privateConfig = require(privateConfigPath)
      console.log('privateConfig', privateConfig)
    } else {
      privateConfig = null
    }

    return privateConfig
  })

  ipcMain.on('isStartByUrl', () => {
    console.log('isStartByUrl', process.argv, inviteUrl)
    if (inviteUrl && !isWin32) {
      handleUrl(inviteUrl)
      inviteUrl = ''
    } else {
      // windows 启动参数超过1个才可能是通过url schema启动
      if (process.argv.length > 1) {
        app.emit('second-instance', null, process.argv)
      }
    }
  })

  ipcMain.handle('exit-app', () => {
    app.exit(0)
  })

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createBeforeMeetingWindow()
  })

  /*
  app.on('before-quit', () => {
    // mac 程序坞直接右键退出会先走这里。如果是在会中直接退出
    if (inMeeting && !isWin32) {
      app.exit(0)
    }
  })
  */

  function windowCenter(win) {
    const nowDisplay = screen.getDisplayNearestPoint(win.getBounds())
    const { x, y, width, height } = nowDisplay.workArea

    win.setBounds({
      x: Math.floor(x + width / 2 - win.getBounds().width / 2),
      y: Math.floor(y + height / 2 - win.getBounds().height / 2),
    })
  }

  ipcMain.on('open-sso', (_, url) => {
    shell.openExternal(url)
  })

  ipcMain.on('beforeLogin', () => {
    mainWindow?.destroy()
    mainWindow = null
    inMeeting = false
    // 退出登录，关闭会前的窗口
    Object.keys(beforeNewWins).forEach((key) => {
      beforeNewWins[key]?.close()
    })

    beforeMeetingWindow?.setBounds({
      width: 375,
      height: 670,
    })
    beforeMeetingWindow.show()
    windowCenter(beforeMeetingWindow)
  })

  ipcMain.on('inMeeting', () => {
    inMeeting = true
    beforeMeetingWindow?.webContents.send('beforeMeeting', false)
  })

  // 登录完成也会触发此事件
  ipcMain.on('beforeEnterRoom', () => {
    console.log('beforeEnterRoom')

    inMeeting = false
    beforeMeetingWindow?.show()
    beforeMeetingWindow?.webContents.send('beforeMeeting', true)
    powerSaveBlockerId && powerSaveBlocker.stop(powerSaveBlockerId)
    powerSaveBlockerId = null
    beforeMeetingWindow?.setBounds({
      width: 720,
      height: 480,
    })
    windowCenter(beforeMeetingWindow)
  })

  ipcMain.on('in-waiting-room', (event, isInWaitingRoom) => {
    // 等候室关闭，需要同步关闭设置页面
    if (!isInWaitingRoom) {
      // closeSettingWindowHandle();
    } else {
      // 需要关闭共享
      if (sharingScreen.isSharing) {
        closeScreenSharingWindow()
      }
    }
  })

  ipcMain.on('enterRoom', () => {
    inMeeting = true
    // 阻止屏幕休眠
    powerSaveBlockerId = powerSaveBlocker.start('prevent-display-sleep')

    Object.keys(beforeNewWins).forEach((key) => {
      if (key.includes('interpreterSetting')) {
        beforeNewWins[key]?.webContents.send('forceClose')
      } else {
        beforeNewWins[key]?.close()
      }
    })
    beforeMeetingWindow?.hide()
  })

  const template = [
    {
      role: 'appmenu',
      submenu: [
        {
          label: '关于网易会议',
          click: () => {
            beforeMeetingWindow.webContents.send('open-meeting-about')
          },
        },
        { type: 'separator' },
        { role: 'hide', label: '隐藏网易会议' },
        { role: 'hideothers', label: '隐藏其他' },
        { role: 'unhide', label: '显示全部' },
        { type: 'separator' },
        { role: 'quit', label: '退出网易会议' }, // 退出菜单项保持不变
      ],
    },
    {
      label: '编辑',
      submenu: [
        { role: 'cut', label: '剪切' },
        { role: 'copy', label: '复制' },
        { role: 'paste', label: '粘贴' },
        { role: 'delete', label: '删除' },
        { role: 'selectAll', label: '全选' },
      ],
    },
    {
      label: '窗口',
      submenu: [
        { role: 'minimize', label: '最小化' },
        { role: 'close', label: '关闭' },
        { role: 'zoom', label: '缩放' },
        { type: 'separator' },
        {
          label: '显示主窗口',
          click: () => {
            inMeeting
              ? mainWindow?.showInactive()
              : beforeMeetingWindow.showInactive()
          },
        },
        { type: 'separator' },
        { role: 'front', label: '前置所有窗口' },
      ],
    },
    {
      label: '帮助',
      submenu: [
        {
          label: '打开日志文件',
          click: () => {
            shell.openPath(logPath)
          },
        },
        {
          label: '意见反馈',
          click: () => {
            beforeMeetingWindow.webContents.send('open-meeting-feedback')
          },
        },
      ],
    },
  ]

  // 创建菜单
  const menu = Menu.buildFromTemplate(template)

  Menu.setApplicationMenu(menu)

  // checkUpdate();

  // 捕获主进程报错
  process.on('uncaughtException', (error) => {
    console.error('\n process caught exception: ', error)
  })
})
