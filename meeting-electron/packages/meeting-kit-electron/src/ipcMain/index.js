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
  DeleteDirectory: 'nemeeting-delete-directory',
  chooseFile: 'nemeeting-choose-file',
  chooseFileDone: 'nemeeting-choose-file-done',
  openBrowserWindow: 'open-browser-window',
  FlushStorageData: 'flushStorageData',
  QuiteFullscreen: 'leave-full-screen',
  EnterFullscreen: 'enter-full-screen',
  IsMainFullScreen: 'isMainFullScreen',
  IsMaximized: 'isMaximized',
  GetDeviceAccessStatus: 'getDeviceAccessStatus',
  GetVirtualBackground: 'getVirtualBackground',
  GetCoverImage: 'getCoverImage',
  OpenDevTools: 'openDevTools',
  CheckDiskSpace: 'check-disk-space',
  GetMeetingRecordPath: 'local-record-meetingid-path'
}

const tagNEBackgroundSourceType = {
  kNEBackgroundColor: 1, /**< 背景图像为纯色（默认） */
  kNEBackgroundImage: 2, /**< 背景图像只支持 PNG 或 JPG 格式的文件 */
  kNEBackgroundVideo: 4, /**< 背景图像只支持 mov 或  mp4 格式的文件 */
}

const readFileAsync = promisify(fs.readFile)
const readDirAsync = promisify(fs.readdir)
const isLinux = process.platform === 'linux'

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
    const ext = path.extname(filePath);
    const isImage = ext === '.png' || ext === '.jpg' || ext === '.jpeg'
    //win系统下，对视频文件存在引用，不能直接删除
    if (isDefault && isImage) {
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
    return ['.png', '.jpg', '.jpeg', '.mov', '.mp4', '.MOV', '.MP4'].includes(path.extname(item))
  })
  for (const item of virtualBackgroundFileList) {
    const filePath = path.join(virtualBackgroundDirPath, item)
    const isDefault = path.basename(filePath).includes('default')
    const ext = path.extname(filePath);
    if (ext === '.mov' || ext === '.mp4' || ext === '.MOV' || ext === '.MP4') {
      virtualBackgroundList.push({
        src: filePath,
        path: filePath,
        isDefault,
        type: 'video',
      })
    } else {
      const base64Prefix = `data:image/${path
        .extname(filePath)
        .substring(1)};base64,`
      const data = await readFileAsync(filePath, 'base64')
      const base64Image = base64Prefix + data

      virtualBackgroundList.push({
        src: base64Image,
        path: filePath,
        isDefault,
        type: 'image',
      })
    }

  }

  event?.sender.send(
    'nemeeting-beauty-virtual-background',
    virtualBackgroundList
  )
  return virtualBackgroundList
}
async function getCoverImage(dirNmae, filePath) {
  try {
    console.log('getCoverImage() dirNmae: ', dirNmae, ', filePath: ', filePath)
    const userDataPath = app.getPath('userData')
    console.log('getCoverImage() userDataPath: ', userDataPath)
    const coverImageList = []
    const coverImageDirPath = path.join(userDataPath, 'localRecordCoverImage')
    console.log('getCoverImage() coverImageDirPath: ', coverImageDirPath)
    if (!filePath) {
      filePath = app.getPath('downloads')
    } else if (!fs.existsSync(filePath)) {
      console.warn('设置的录制文件文件不存在,使用默认下载路径')
      filePath = app.getPath('downloads')
    }
    console.log('getCoverImage() filePath: ', filePath)
    const localRecordDirPath = path.join(filePath, dirNmae)
    console.log('getCoverImage() localRecordDirPath: ', localRecordDirPath)
    if (!fs.existsSync(localRecordDirPath)) {
      fs.mkdirSync(localRecordDirPath)
    }
    if (!fs.existsSync(coverImageDirPath)) {
      fs.mkdirSync(coverImageDirPath)
    }
    console.log('getCoverImage() coverImageDirPath: ', coverImageDirPath)
    //删除原目标目录的所有文件资源
    fs.readdirSync(coverImageDirPath).map((item) => {
      const tempPath = path.join(coverImageDirPath, item)
      const isCover = path.basename(tempPath).includes('Cover')
      if (isCover) {
        fs.unlinkSync(tempPath)
      }
    })
    //  拷贝默认资源到用户目录
    const defaultCoverImagePath = path.join(
      __dirname,
      '../assets/localRecord/'
    )
    console.log('getCoverImage() defaultCoverImagePath: ', defaultCoverImagePath)
    fs.readdirSync(defaultCoverImagePath).forEach((item) => {
      const tempFilePath = path.join(defaultCoverImagePath, item)
      fs.copyFileSync(tempFilePath, path.join(coverImageDirPath, item))
    })
    let coverImageFileList = await readDirAsync(coverImageDirPath)
    console.log('getCoverImage() coverImageFileList: ', coverImageFileList)
    coverImageFileList = coverImageFileList.filter((item) => {
      return ['.png', '.jpg', '.jpeg', '.mov', '.mp4', '.MOV', '.MP4'].includes(path.extname(item))
    })
    for (const item of coverImageFileList) {
      const tempFilePath = path.join(coverImageDirPath, item)
      const isDefaultConver = path.basename(tempFilePath).includes('defaultCover')
      coverImageList.push({
        dirPath: localRecordDirPath,
        path: tempFilePath,
        isDefaultConver,
        filePath
      })
    }
    return coverImageList
  } catch (e) {
    console.error('getCoverImage() error: ', e.message)
    //返回错误仍然返回
    return [{ errorMessage: e.message }]
  }
}

async function getMeetingRecordPath(meetingNum, meetingStartTime, directory, needGetMeetingRecordPath) {
  console.log('getMeetingRecordPath() meetingNum: ', meetingNum, 'meetingStartTime: ', meetingStartTime, ', directory: ', directory, ', needGetMeetingRecordPath: ', needGetMeetingRecordPath)
  let meetingRecordPath = ''
  let meetingRecordFirstMp4FilePath = ''
  let meetingRecordFirstAacFilePath = ''
  console.log(`getMeetingRecordPath() directory: ${directory}`)
  if (!fs.existsSync(`${directory}`)) {
    console.log(`getMeetingRecordPath() ${directory} 不存在`)
    return {
      meetingRecordPath,
      meetingRecordFirstMp4FilePath,
      meetingRecordFirstAacFilePath
    }
  }
  let meetingRecordPathMatchMeetingNumOnly = ''
  if (needGetMeetingRecordPath) {
    //遍历目标目录的所有文件资源
    fs.readdirSync(directory).map((item) => {
      //console.log('录制文件下的item: ', item)
      if (item.includes(meetingNum)) {
        meetingRecordPathMatchMeetingNumOnly = item
        if (item.includes(meetingStartTime)) {
          //console.warn('找到了目标目录: ', item)
          meetingRecordPath = item
          return
        }
      }
    })
    meetingRecordPath == '' ? meetingRecordPath = meetingRecordPathMatchMeetingNumOnly : null
  } else {
    meetingRecordPath = directory
  }
  console.log(`getMeetingRecordPath() meetingRecordPath: ${meetingRecordPath}`)
  if (meetingRecordPath !== '') {
    needGetMeetingRecordPath ? meetingRecordPath = path.join(directory, meetingRecordPath) : null
    console.log(`getMeetingRecordPath() meetingRecordPath 11: ${meetingRecordPath}`)
    fs.readdirSync(meetingRecordPath).map((file) => {
      if(!meetingRecordFirstMp4FilePath && file.includes('mp4')) {
        meetingRecordFirstMp4FilePath = file
      }
      if(!meetingRecordFirstAacFilePath && file.includes('aac')) {
        meetingRecordFirstAacFilePath = file
      }
    })
    console.log('找到了目标mp4文件: ', meetingRecordFirstMp4FilePath)
    console.log('找到了目标aac文件: ', meetingRecordFirstMp4FilePath)
    if (meetingRecordFirstMp4FilePath != '') {
      meetingRecordFirstMp4FilePath = path.join(meetingRecordPath, meetingRecordFirstMp4FilePath)
    }
    if (meetingRecordFirstAacFilePath != '') {
      meetingRecordFirstAacFilePath = path.join(meetingRecordPath, meetingRecordFirstAacFilePath)
    }
  }
  console.log(`getMeetingRecordPath() 返回结果 meetingRecordPath: ${meetingRecordPath}, meetingRecordFirstMp4FilePath: ${meetingRecordFirstMp4FilePath}`)
  return {
    meetingRecordPath,
    meetingRecordFirstMp4FilePath,
    meetingRecordFirstAacFilePath
  }
}
function deleteFolder(folderPath) {
  if (fs.existsSync(folderPath)) {
    fs.readdirSync(folderPath).forEach(function (file, index) {
      var curPath = path.join(folderPath, file);
      if (fs.lstatSync(curPath).isDirectory()) { // recurse
        deleteFolder(curPath);
      } else { // delete file
        fs.unlinkSync(curPath);
      }
    });
    fs.rmdirSync(folderPath);
  }
}

function addGlobalIpcMainListeners() {
  const userDataPath = app.getPath('userData')

  ipcMain.on(EventType.Beauty, async (event, data) => {
    if (data.event === 'addVirtualBackground') {
      dialog
        .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
          properties: ['openFile'],
          filters: [{ name: 'image', extensions: ['jpg', 'png', 'jpeg', 'mov', 'mp4'] }],
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
            const ext = path.extname(filePath);
            let sourceType = 0
            if (ext === '.mov' || ext === '.mp4' || ext === '.MOV' || ext === '.MP4') {
              sourceType = tagNEBackgroundSourceType.kNEBackgroundVideo
            } else if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
              sourceType = tagNEBackgroundSourceType.kNEBackgroundImage
            }
            const fileSize = fs.statSync(filePath).size
            let error = null
            //限制文件大小为500M
            if (fileSize > 500 * 1024 * 1024) {
              error = '文件过大'
              event.sender.send(EventType.AddVirtualBackgroundReply, '', sourceType, error)
              return
            }
            fs.copyFileSync(filePath, toPath)
            getVirtualBackground(true, event)
            event.sender.send(EventType.AddVirtualBackgroundReply, toPath, sourceType)
          } else {
            event.sender.send(EventType.AddVirtualBackgroundReply, '', sourceType)
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

  ipcMain.handle(EventType.GetCoverImage, (_, { dirNmae, filePath }) => {
    return getCoverImage(dirNmae, filePath)
  })
  ipcMain.handle(EventType.CheckDiskSpace, (_, { directory }) => {
    try {
      console.log(`查看剩余空间，当前要查找的路径为： ${directory}`);
      function bytesToSize(bytes) {
        const sizes = ['Bytes', 'K', 'M', 'G'];
        if (bytes == 0) return '0 Byte';
        const i = Math.floor(Math.log(bytes) / Math.log(1024));
        if (i == 0) return bytes + ' ' + sizes[i];
        if (i == 1) return Math.floor(bytes / Math.pow(1024, i)) + ' ' + sizes[i];
        return Math.floor(bytes / Math.pow(1024, i)) + '' + sizes[i];
      }

      return new Promise((resolve, reject) => {
        const rootPath = directory.charAt(0); // 指定目录路径
        if (os.type() == 'Windows_NT') {
          //windows平台
          console.log('查看剩余空间 windows平台')
          exec(`wmic logicaldisk where "DeviceID='${rootPath}:'" get FreeSpace`, (err, stdout, stderr) => {
            if (err) {
              console.error('查看剩余空间 error: ', err);
              resolve('')
            }
            if (stderr) {
              console.error('查看剩余空间 stderr: ', stderr);
              resolve('')
            }
            console.log('查看剩余空间 shell命令: ', stdout);
            const lines = stdout.split('\n');
            // 第二行包含可用空间的信息
            if (lines && lines.length && lines[1]) {
              const availableSpaceBytes = lines[1].trim();
              const availableSpaceGB = bytesToSize(availableSpaceBytes)
              console.log(`指定目录的可用空间大小：${availableSpaceBytes} bytes, ${availableSpaceGB}`)
              resolve(availableSpaceGB)
            } else {
              resolve('')
            }
          });
        } else if (os.type() == 'Darwin') {
          console.log('查看剩余空间 mac平台')
          exec(`df -h ${rootPath}`, (err, stdout, stderr) => {
            if (err) {
              console.error('查看剩余空间 error: ', err);
              resolve('')
            }
            console.log('查看剩余空间 shell命令: ', stdout);
            const regex = /\b(\d+\.?\d*)([KMG]?iB?)\b/g;
            const list = stdout.match(regex)
            if (list && list.length && list.length > 1 && list[2]) {
              resolve(list[2].slice(0, -1))
            } else {
              resolve('')
            }
          });
        } else if (os.type() == 'Linux') {
          //Linux平台
          console.log('Linux平台')
        }
      })
    } catch (error) {
      console.error('Error getting disk space:', error);
      throw error;
    }

  })
  ipcMain.handle(EventType.GetMeetingRecordPath, (_, { meetingNum, meetingStartTime, directory, needGetMeetingRecordPath }) => {
    return getMeetingRecordPath(meetingNum, meetingStartTime, directory, needGetMeetingRecordPath)
  })
  ipcMain.on(EventType.MaximizeWindow, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    if (mainWindow.isMaximized()) {
      mainWindow.unmaximize()
    // linux 不设置，否则最大化窗口再全屏会有问题
      if (mainWindow.isMainWindow && !isLinux) {
        mainWindow.setResizable(true)
        mainWindow.setMovable(true)
      }
    } else {
      mainWindow.maximize()
      if (mainWindow.isMainWindow && !isLinux) {
        mainWindow.setResizable(false)
        mainWindow.setMovable(false)
      }
    }
  })

  ipcMain.handle(EventType.GetDeviceAccessStatus, () => {
    if(process.platform === 'linux') {
      return {
        camera: 'unknown',
        microphone: 'unknown'
      }
    }
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

  ipcMain.handle(EventType.SaveAvatarToPath, async (event, base64String, defaultPath = null, fileName) => {
    console.log('保存图片到本地 defaultPath: ', defaultPath, 'fileName: ', fileName)
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '')
    const imageCacheDirPath = path.join(userDataPath, 'imageCache')

    if (!fs.existsSync(imageCacheDirPath)) {
      fs.mkdirSync(imageCacheDirPath)
    }

    const filePath = path.join(defaultPath || imageCacheDirPath, fileName || 'avatar.png')

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

    if (value === 'open') {

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

  ipcMain.handle(EventType.DeleteDirectory, (event, value) => {
    console.log('删除路径: ', value)
    const { directory } = value
    deleteFolder(directory)
    return true
  })

  ipcMain.on(EventType.openBrowserWindow, (event, url) => {
    shell.openExternal(url)
  })



  let _isMaximized = false

  ipcMain.on(EventType.QuiteFullscreen, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    !isLinux && mainWindow.setFullScreenable(true)

    mainWindow.isFullScreenPrivate && mainWindow.setFullScreen(false)
    !isLinux &&_isMaximized && mainWindow.maximize()
  })

  ipcMain.on(EventType.EnterFullscreen, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    // linux 不设置，否则最大化窗口再全屏会有问题
    if(!isLinux) {
      mainWindow.setFullScreenable(true)

      _isMaximized = mainWindow.isMaximized()
      _isMaximized && mainWindow.unmaximize()
    }
    !mainWindow.isFullScreenPrivate && mainWindow.setFullScreen(true)
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
  ipcMain.handle(EventType.IsMainFullScreen, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)
    const isFullscreen = mainWindow?.isFullScreen()

    return isFullscreen
  })

  ipcMain.handle(EventType.IsMaximized, (event) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)
    const isMaximized = mainWindow?.isMaximized()

    return isMaximized
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
