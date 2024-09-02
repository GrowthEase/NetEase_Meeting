const {
  BrowserWindow,
  screen,
  shell,
  ipcMain,
  globalShortcut,
} = require('electron')
const path = require('path')
const NEMeetingKit = require('./kit/impl/meeting_kit')

const isLocal = process.env.MODE === 'local'

const newWins = {}

function createBeforeMeetingWindow() {
  // 获取当前，鼠标所在的屏幕中心
  const mousePosition = screen.getCursorScreenPoint()
  const nowDisplay = screen.getDisplayNearestPoint(mousePosition)
  const { x, y, width, height } = nowDisplay.workArea
  const beforeMeetingWindow = new BrowserWindow({
    titleBarStyle: 'hidden',
    width: 720,
    height: 480,
    x: Math.round(x + (width - 720) / 2),
    y: Math.round(y + (height - 480) / 2),
    trafficLightPosition: {
      x: 6,
      y: 6,
    },
    resizable: false,
    maximizable: false,
    backgroundColor: '#fff',
    show: false,
    fullscreenable: false,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      preload: path.join(__dirname, './preload.js'),
    },
  })

  const homeWindowHeight = 480
  const homeWindowWidth = 720

  if (isLocal) {
    beforeMeetingWindow.loadURL('http://localhost:8000/')
    beforeMeetingWindow.webContents.openDevTools()
  } else {
    beforeMeetingWindow.loadFile(path.join(__dirname, '../build/index.html'))
  }

  beforeMeetingWindow.webContents.on(
    'did-create-window',
    (newWin, { url: originalUrl }) => {
      const url = originalUrl.replace(/.*?(?=#)/, '')

      newWins[url] = newWin
      // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
      newWin.on('close', (event) => {
        event.preventDefault()
        if (url.includes('scheduleMeeting')) {
          newWin.webContents.send('scheduleMeetingWindow:close')
          return
        } else if (url.includes('interpreterSetting')) {
          newWin.webContents.send('interpreterSettingWindow:close')
          return
        }

        beforeMeetingWindow.webContents.send(`windowClosed:${url}`)

        newWin.hide()
      })
      if (url.includes('notification/card')) {
        newWin.setWindowButtonVisibility?.(false)
      }

      newWin.webContents.session.removeAllListeners('will-download')
      newWin.webContents.session.on('will-download', (event, item) => {
        item.on('done', (event, state) => {
          if (state === 'completed') {
            const path = event.sender.getSavePath()

            shell.showItemInFolder(path)
          }
        })
      })
      if (isLocal) {
        newWin.webContents.openDevTools()
      }
    }
  )

  beforeMeetingWindow.webContents.setWindowOpenHandler(
    ({ url: originalUrl }) => {
      const url = originalUrl.replace(/.*?(?=#)/, '')
      const { x, y } = beforeMeetingWindow.getBounds()
      const commonOptions = {
        width: 375,
        height: 670,
        titleBarStyle: 'hidden',
        maximizable: false,
        minimizable: false,
        resizable: false,
        fullscreenable: false,
        trafficLightPosition: {
          x: 10,
          y: 13,
        },
        webPreferences: {
          contextIsolation: false,
          nodeIntegration: true,
          preload: path.join(__dirname, './ipc.js'),
        },
      }

      if (url.includes('#/notification/list')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            x: x + 375,
            y: y,
          },
        }
      } else if (url.includes('#/history')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            trafficLightPosition: {
              x: 19,
              y: 19,
            },
            width: 375,
            height: 664,
            x: Math.round(x + (homeWindowWidth - 375) / 2),
            y: Math.round(y + (homeWindowHeight - 664) / 2),
          },
        }
      } else if (url.includes('#/transcriptionWindow')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            trafficLightPosition: {
              x: 19,
              y: 19,
            },
            width: 375,
            height: 664,
            x: Math.round(x + (homeWindowWidth - 375) / 2),
            y: Math.round(y + (homeWindowHeight - 664) / 2),
          },
        }
      } else if (url.includes('#/imageCrop')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 600,
            height: 380,
          },
        }
      } else if (url.includes('#/about')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            trafficLightPosition: {
              x: 19,
              y: 19,
            },
            width: 375,
            height: 731,
          },
        }
      } else if (url.includes('#/nps')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 601,
            height: 395,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
          },
        }
      } else if (url.includes('#/plugin')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        }
      } else if (url.includes('#/chat')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        }
      } else if (url.includes('#/setting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 800,
            height: 600,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
          },
        }
      } else if (url.includes('#/addressBook')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 498,
            height: 449,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
          },
        }
      } else if (url.includes('#/notification/card')) {
        const nowDisplay = screen.getPrimaryDisplay()
        const { width, height } = nowDisplay.workArea
        const notifyWidth = 360
        const notifyHeight = 260

        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            maximizable: false,
            titleBarStyle: 'hidden',
            minimizable: false,
            fullscreenable: false,
            alwaysOnTop: 'screen-saver',
            resizable: false,
            skipTaskbar: true,
            width: 360,
            height: 260,
            x: Math.round(width - notifyWidth - 60),
            y: Math.round(height - notifyHeight - 20),
          },
        }
      } else if (url.includes('#/scheduleMeeting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            trafficLightPosition: {
              x: 19,
              y: 19,
            },
            width: 375,
            height: 664,
            x: Math.round(x + (homeWindowWidth - 375) / 2),
            y: Math.round(y + (homeWindowHeight - 664) / 2),
          },
        }
      } else if (url.includes('#/joinMeeting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 375,
            height: 400,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
            x: Math.round(x + (homeWindowWidth - 375) / 2),
            y: Math.round(y + (homeWindowHeight - 402) / 2),
          },
        }
      } else if (url.includes('#/immediateMeeting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 375,
            height: 450,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
            x: Math.round(x + (homeWindowWidth - 375) / 2),
            y: Math.round(y + (homeWindowHeight - 594) / 2),
          },
        }
      } else if (url.includes('#/interpreterSetting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 520,
            height: 533,
            trafficLightPosition: {
              x: 10,
              y: 13,
            },
          },
        }
      } else if (url.includes('#/feedback')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 375,
            height: 731,
            trafficLightPosition: {
              x: 16,
              y: 19,
            },
          },
        }
      }

      return { action: 'deny' }
    }
  )

  function getKeyByValue(obj, value) {
    return Object.keys(obj).find((key) => obj[key] === value)
  }

  ipcMain.on('focusWindow', (event, url) => {
    const win = BrowserWindow.fromWebContents(event.sender)

    if (win === beforeMeetingWindow) {
      if (newWins[url] && !newWins[url].isDestroyed()) {
        newWins[url].show()
      }
    }
  })

  ipcMain.on('changeSetting', (event, setting) => {
    if (beforeMeetingWindow && !beforeMeetingWindow.isDestroyed()) {
      beforeMeetingWindow.webContents.send('changeSetting', setting)
    }

    Object.values(newWins).forEach((win) => {
      if (win && !win.isDestroyed()) {
        win.webContents.send('changeSetting', setting)
      }
    })
  })

  beforeMeetingWindow.on('focus', () => {
    globalShortcut.register('f5', function () {
      console.log('f5 is pressed')
      //mainWindow.reload()
    })
    globalShortcut.register('CommandOrControl+R', function () {
      console.log('CommandOrControl+R is pressed')
      //mainWindow.reload()
    })
  })

  beforeMeetingWindow.on('blur', () => {
    globalShortcut.unregister('f5', function () {
      console.log('f5 is pressed')
      //mainWindow.reload()
    })
    globalShortcut.unregister('CommandOrControl+R', function () {
      console.log('CommandOrControl+R is pressed')
      //mainWindow.reload()
    })
  })

  ipcMain.on('childWindow:closed', (event) => {
    const win = BrowserWindow.fromWebContents(event.sender)
    const url = getKeyByValue(newWins, win)

    url && beforeMeetingWindow.webContents.send(`windowClosed:${url}`)
    win?.hide()
  })

  ipcMain.on('NEMeetingKitElectron', (event, data) => {
    const neMeetingKit = NEMeetingKit.default.getInstance()
    const module = data.event
    const { replyKey, fnKey, args } = data.payload
    const modules = {
      neMeetingKit: neMeetingKit,
      getMeetingService: neMeetingKit.getMeetingService(),
      getAccountService: neMeetingKit.getAccountService(),
      getSettingsService: neMeetingKit.getSettingsService(),
      getMeetingInviteService: neMeetingKit.getMeetingInviteService(),
      getPreMeetingService: neMeetingKit.getPreMeetingService(),
      getMeetingMessageChannelService:
        neMeetingKit.getMeetingMessageChannelService(),
      getContactsService: neMeetingKit.getContactsService(),
      getFeedbackService: neMeetingKit.getFeedbackService(),
    }

    modules[module]?.[fnKey](...args)
      .then((res) => {
        event.sender.send(replyKey, {
          result: res,
        })
        if (fnKey === 'initialize') {
          neMeetingKit.setExceptionHandler({
            onError: () => {
              // 会中进程崩溃
              beforeMeetingWindow.webContents.send('NEMeetingKitCrash')
            },
          })
          neMeetingKit.getMeetingService().addMeetingStatusListener({
            onMeetingStatusChanged: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'meetingStatusListeners',
                  fnKey: 'onMeetingStatusChanged',
                  args,
                }
              )
            },
          })
          neMeetingKit.getMeetingService().setOnInjectedMenuItemClickListener({
            onInjectedMenuItemClick: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'meetingOnInjectedMenuItemClickListeners',
                  fnKey: 'onInjectedMenuItemClick',
                  args,
                }
              )
            },
          })
          neMeetingKit.getAccountService().addListener({
            onKickOut: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'accountServiceListeners',
                  fnKey: 'onKickOut',
                  args,
                }
              )
            },
            onAuthInfoExpired: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'accountServiceListeners',
                  fnKey: 'onAuthInfoExpired',
                  args,
                }
              )
            },
            onReconnected: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'accountServiceListeners',
                  fnKey: 'onReconnected',
                  args,
                }
              )
            },
            onAccountInfoUpdated: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'accountServiceListeners',
                  fnKey: 'onAccountInfoUpdated',
                  args,
                }
              )
            },
          })
          neMeetingKit.getPreMeetingService().addListener({
            onMeetingItemInfoChanged: (...args) => {
              beforeMeetingWindow.webContents.send(
                'NEMeetingKitElectron-Listener',
                {
                  module: 'preMeetingListeners',
                  fnKey: 'onMeetingItemInfoChanged',
                  args,
                }
              )
            },
          })
          neMeetingKit
            .getMeetingInviteService()
            .addMeetingInviteStatusListener({
              onMeetingInviteStatusChanged: (...args) => {
                beforeMeetingWindow.webContents.send(
                  'NEMeetingKitElectron-Listener',
                  {
                    module: 'meetingInviteStatusListeners',
                    fnKey: 'onMeetingInviteStatusChanged',
                    args,
                  }
                )
              },
            })

          neMeetingKit
            .getMeetingMessageChannelService()
            .addMeetingMessageChannelListener({
              onSessionMessageReceived: (...args) => {
                beforeMeetingWindow.webContents.send(
                  'NEMeetingKitElectron-Listener',
                  {
                    module: 'meetingMessageChannelListeners',
                    fnKey: 'onSessionMessageReceived',
                    args,
                  }
                )
              },
              onSessionMessageRecentChanged: (...args) => {
                beforeMeetingWindow.webContents.send(
                  'NEMeetingKitElectron-Listener',
                  {
                    module: 'meetingMessageChannelListeners',
                    fnKey: 'onSessionMessageRecentChanged',
                    args,
                  }
                )
              },
              onSessionMessageDeleted: (...args) => {
                beforeMeetingWindow.webContents.send(
                  'NEMeetingKitElectron-Listener',
                  {
                    module: 'meetingMessageChannelListeners',
                    fnKey: 'onSessionMessageDeleted',
                    args,
                  }
                )
              },
              onSessionMessageAllDeleted: (...args) => {
                beforeMeetingWindow.webContents.send(
                  'NEMeetingKitElectron-Listener',
                  {
                    module: 'meetingMessageChannelListeners',
                    fnKey: 'onSessionMessageAllDeleted',
                    args,
                  }
                )
              },
            })
        }
      })
      .catch((error) => {
        event.sender.send(replyKey, {
          error,
        })
      })
  })

  return beforeMeetingWindow
}

module.exports = {
  createBeforeMeetingWindow,
  beforeNewWins: newWins,
}
