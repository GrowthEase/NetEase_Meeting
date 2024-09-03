const {
  app,
  ipcMain,
  dialog,
  BrowserWindow,
  nativeTheme,
  shell,
  systemPreferences,
} = require('electron')
const { promisify } = require('util')
const fs = require('fs')
const path = require('path')
const { exec } = require('child_process')
const os = require('os')
const si = require('systeminformation')
const sizeOf = require('image-size')
const { isWin32 } = require('../constant')

const EventType = {
  Beauty: 'nemeeting-beauty',
  AddVirtualBackgroundReply: 'addVirtualBackground-reply',
  Relaunch: 'relaunch',
  MaximizeWindow: 'maximize-window',
  MinimizeWindow: 'minimize-window',
  GetImageBase64: 'nemeeting-get-image-base64',
  ExitApp: 'exit-app',
  GetLogPath: 'getLogPath',
  SaveAvatarToPath: 'saveAvatarToPath',
  NoPermission: 'no-permission',
  getSystemManufacturer: 'get-system-manufacturer',
  getThemeColor: 'get-theme-color',
  downloadFileByUrl: 'download-file-by-url',
  DownloadPath: 'nemeeting-download-path',
  DownloadPathReply: 'nemeeting-download-path-reply',
  FileSaveAs: 'nemeeting-file-save-as',
  FileSaveAsReply: 'nemeeting-file-save-as-reply',
  openFile: 'nemeeting-open-file',
  openFileReply: 'nemeeting-open-file-reply',
  chooseFile: 'nemeeting-choose-file',
  chooseFileDone: 'nemeeting-choose-file-done',
  openBrowserWindow: 'open-browser-window',
  FlushStorageData: 'flushStorageData',
  QuiteFullscreen: 'quiteFullscreen',
  IsMainFullScreen: 'isMainFullScreen',
  IsMainFullScreenReply: 'isMainFullscreen-reply',
  GetDeviceAccessStatus: 'getDeviceAccessStatus',
  GetVirtualBackground: 'getVirtualBackground',

  OpenDevTools: 'openDevTools',
}

const readFileAsync = promisify(fs.readFile)
const readDirAsync = promisify(fs.readdir)

let virtualBackgroundList = []

async function getVirtualBackground(forceUpdate = false, event) {
  const userDataPath = app.getPath('userData')

  if (
    virtualBackgroundList &&
    virtualBackgroundList.length > 0 &&
    !forceUpdate
  ) {
    return virtualBackgroundList
  }

  virtualBackgroundList = []
  const virtualBackgroundDirPath = path.join(userDataPath, 'virtualBackground')

  if (!fs.existsSync(virtualBackgroundDirPath)) {
    fs.mkdirSync(virtualBackgroundDirPath)
  }

  fs.readdirSync(virtualBackgroundDirPath).map((item) => {
    const filePath = path.join(virtualBackgroundDirPath, item)
    const isDefault = path.basename(filePath).includes('default')

    if (isDefault) {
      fs.unlinkSync(filePath)
    }
  })
  //  拷贝默认资源到用户目录
  const defaultVirtualBackgroundPath = path.join(
    __dirname,
    '../assets/virtual/'
  )

  fs.readdirSync(defaultVirtualBackgroundPath).forEach((item) => {
    const filePath = path.join(defaultVirtualBackgroundPath, item)

    fs.copyFileSync(filePath, path.join(virtualBackgroundDirPath, item))
  })
  // const virtualBackgroundList = []
  let virtualBackgroundFileList = await readDirAsync(virtualBackgroundDirPath)

  virtualBackgroundFileList = virtualBackgroundFileList.filter((item) => {
    return ['.png', '.jpg', '.jpeg'].includes(path.extname(item))
  })
  for (const item of virtualBackgroundFileList) {
    const filePath = path.join(virtualBackgroundDirPath, item)
    const isDefault = path.basename(filePath).includes('default')
    const base64Prefix = `data:image/${path
      .extname(filePath)
      .substring(1)};base64,`
    const data = await readFileAsync(filePath, 'base64')
    const base64Image = base64Prefix + data

    virtualBackgroundList.push({
      src: base64Image,
      path: filePath,
      isDefault,
    })
  }

  event?.sender.send(
    'nemeeting-beauty-virtual-background',
    virtualBackgroundList
  )
  return virtualBackgroundList
}

function addGlobalIpcMainListeners() {
  const userDataPath = app.getPath('userData')

  ipcMain.on(EventType.Beauty, async (event, data) => {
    if (data.event === 'addVirtualBackground') {
      dialog
        .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
          properties: ['openFile'],
          filters: [{ name: 'image', extensions: ['jpg', 'png', 'jpeg'] }],
        })
        .then(function (response) {
          if (!response.canceled) {
            // handle fully qualified file name
            const filePath = response.filePaths[0]
            const userVirtualBackgroundPath = path.join(
              userDataPath,
              'virtualBackground'
            )
            const toPath = path.join(
              userVirtualBackgroundPath,
              `user-${Date.now()}${path.extname(filePath)}`
            )

            fs.copyFileSync(filePath, toPath)
            getVirtualBackground(true, event)
            event.sender.send(EventType.AddVirtualBackgroundReply, toPath)
          } else {
            event.sender.send(EventType.AddVirtualBackgroundReply, '')
            console.log('no file selected')
          }
        })
    } else if (data.event === 'removeVirtualBackground') {
      const { path } = data.value

      try {
        fs.unlinkSync(path)
        getVirtualBackground(true, event)
      } catch (e) {
        console.log('removeVirtualBackground error', e)
      }
    }
  })

  ipcMain.on(EventType.Relaunch, () => {
    app.relaunch()
    app.exit(0)
  })

  ipcMain.handle(EventType.GetVirtualBackground, () => {
    return getVirtualBackground()
  })

  ipcMain.on(EventType.MaximizeWindow, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize()
  })

  ipcMain.handle(EventType.GetDeviceAccessStatus, () => {
    return {
      camera: systemPreferences.getMediaAccessStatus('camera'),
      microphone: systemPreferences.getMediaAccessStatus('microphone'),
    }
  })

  ipcMain.on(EventType.MinimizeWindow, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    mainWindow?.minimize()
  })

  ipcMain.handle(EventType.GetImageBase64, (_, { filePath, isDelete }) => {
    const base64Prefix = `data:image/${path
      .extname(filePath)
      .substring(1)};base64,`
    const base64 = base64Prefix + fs.readFileSync(filePath, 'base64')

    if (isDelete) {
      fs.unlinkSync(filePath)
    }

    return base64
  })

  ipcMain.handle(EventType.GetLogPath, () => {
    const cacheDirectoryName = 'logs'

    const logPath = path.join(userDataPath, cacheDirectoryName)

    return logPath
  })

  ipcMain.handle(EventType.SaveAvatarToPath, async (event, base64String) => {
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '')
    const imageCacheDirPath = path.join(userDataPath, 'imageCache')

    if (!fs.existsSync(imageCacheDirPath)) {
      fs.mkdirSync(imageCacheDirPath)
    }

    const filePath = path.join(imageCacheDirPath, 'avatar.png')

    try {
      await fs.promises.writeFile(filePath, base64Data, 'base64')
      return { status: 'success', filePath }
    } catch (error) {
      console.error('Error saving image:', error)
      return { status: 'error', message: error.message }
    }
  })

  ipcMain.on(EventType.NoPermission, (_, type) => {
    if (isWin32) {
      if (type === 'audio') {
        shell.openExternal('ms-settings:privacy-microphone')
      } else {
        shell.openExternal('ms-settings:privacy-webcam')
      }
    } else {
      const command = 'open "x-apple.systempreferences:"'

      exec(command, (error) => {
        if (error) {
          console.error(`打开系统偏好设置时出错： ${error}`)
        }
      })
    }
  })

  ipcMain.handle(EventType.getSystemManufacturer, () => {
    return si
      .system()
      .then((data) => {
        const manufacturer = data.manufacturer
        const model = data.model

        return { manufacturer, model, os_ver: os.release() }
      })
      .catch((error) => {
        console.error(error)
      })
  })

  ipcMain.handle(EventType.getThemeColor, () => {
    return nativeTheme.shouldUseDarkColors ?? true()
  })

  ipcMain.handle(EventType.downloadFileByUrl, (_, url) => {
    shell.openExternal(url)
    return true
  })

  ipcMain.on(EventType.DownloadPath, (event, value) => {
    if (value === 'get') {
      event.returnValue = app.getPath('downloads')
    }

    if (value === 'set') {
      dialog
        .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
          properties: ['openDirectory'],
        })
        .then(function (response) {
          if (!response.canceled) {
            // handle fully qualified file name
            const filePath = response.filePaths[0]

            event.sender.send(EventType.DownloadPathReply, filePath)
          } else {
            console.log('no file selected')
          }
        })
    }
  })

  ipcMain.on(EventType.FileSaveAs, (event, value) => {
    const { defaultPath, filePath } = value

    dialog
      .showSaveDialog(BrowserWindow.fromWebContents(event.sender), {
        defaultPath: defaultPath,
        filters: [{ name: '', extensions: '*' }],
      })
      .then(function (response) {
        let resFilePath = ''

        if (!response.canceled) {
          // handle fully qualified file name
          if (filePath && fs.existsSync(filePath)) {
            fs.copyFileSync(filePath, response.filePath)
          } else {
            resFilePath = response.filePath
          }
        }

        event.sender.send(EventType.FileSaveAsReply, resFilePath)
      })
      .catch(() => {
        event.sender.send(EventType.FileSaveAsReply, '')
      })
  })

  ipcMain.on(EventType.openFile, (event, value) => {
    const { isDir, filePath } = value

    fs.exists(filePath, (exists) => {
      if (exists) {
        if (isDir) {
          shell.showItemInFolder(filePath)
        } else {
          shell.openPath(filePath)
        }
      }

      event.sender.send(EventType.openFileReply, exists)
    })
  })

  ipcMain.on(EventType.chooseFile, (event, value) => {
    const { type, extensions, extendedData } = value

    dialog
      .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
        properties: ['openFile'],
        filters: [{ name: type, extensions: extensions }],
      })
      .then(function (response) {
        if (!response.canceled) {
          // handle fully qualified file name
          const filePath = response.filePaths[0]

          fs.stat(filePath, (err, stats) => {
            if (err) {
              console.error(err)
            } else {
              let base64Image = ''
              let width = 0
              let height = 0

              if (type === 'image') {
                const base64Prefix = `data:image/${path
                  .extname(filePath)
                  .substring(1)};base64,`

                base64Image = base64Prefix + fs.readFileSync(filePath, 'base64')

                try {
                  const dimensions = sizeOf(filePath)

                  width = dimensions.width
                  height = dimensions.height
                } catch (e) {
                  console.error(e)
                }
              }

              event.sender.send(EventType.chooseFileDone, {
                type,
                file: {
                  url: filePath,
                  name: path.basename(filePath),
                  size: stats.size,
                  base64: base64Image,
                  width,
                  height,
                },
                extendedData,
              })
            }
          })
        } else {
          console.log('no file selected')
        }
      })
      .catch((err) => {
        console.log('no file selected', err)
      })
  })

  ipcMain.on(EventType.openBrowserWindow, (event, url) => {
    shell.openExternal(url)
  })

  ipcMain.on(EventType.QuiteFullscreen, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    mainWindow.isFullScreen() && mainWindow.setFullScreen(false)
  })

  ipcMain.on(EventType.FlushStorageData, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)
    // 强制缓存

    try {
      mainWindow.webContents.session.flushStorageData()
    } catch {
      console.log('flushStorageData error')
    }
  })

  // 主窗口是否为全屏状态
  ipcMain.on(EventType.IsMainFullScreen, async (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)
    const isFullscreen = mainWindow?.isFullScreen() || mainWindow?.isMaximized()

    event.sender.send(EventType.IsMainFullScreenReply, isFullscreen)
  })

  ipcMain.on(EventType.OpenDevTools, async (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    mainWindow.webContents.openDevTools()
  })
}

function removeGlobalIpcMainListeners() {
  Object.keys(EventType).forEach((key) => {
    ipcMain.removeAllListeners(EventType[key])
    ipcMain.removeHandler(EventType[key])
  })
}

module.exports = {
  addGlobalIpcMainListeners,
  removeGlobalIpcMainListeners,
}
