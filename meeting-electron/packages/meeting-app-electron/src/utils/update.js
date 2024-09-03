const { app, autoUpdater, ipcMain } = require('electron')
const path = require('path')
const { unlink, rename, emptyDir } = require('fs-extra')
const fs = require('fs')
const { spawn } = require('child_process')
const { downloadUpdateFile, cancelUpdate } = require('./downloadHelper')
const os = require('os')
// import fs from "fs";
const isWin32 = process.platform === 'win32'

function getCacheFileName(fileUrl) {
  if (fileUrl.endsWith(`.${isWin32 ? 'exe' : 'zip'}`)) {
    return path.basename(fileUrl)
  } else {
    return fileUrl
  }
}

async function removeCacheFile(cacheDir) {
  try {
    emptyDir(cacheDir)
  } catch (e) {
    console.log('removeCacheFile error', e)
    // ignore
  }
}

async function checkUpdate(
  window,
  fileUrl,
  md5,
  neroom,
  tmpCacheFileName,
  forceUpdate
) {
  // Set global tempdialog
  global.tempPath = path.join(app.getPath('temp'), tmpCacheFileName)
  const cacheFileName = getCacheFileName(fileUrl)
  const filePath = path.join(global.tempPath, cacheFileName)

  console.log('filePath>>>>>>', filePath)
  const tempUpdateFileName = await createTempUpdateFile(
    `temp-${cacheFileName}`,
    global.tempPath
  )
  const tempUpdateFile = path.join(global.tempPath, tempUpdateFileName)

  console.log('tempUpdateFile>>>>>', tempUpdateFile)
  downloadUpdateFile({
    window,
    fileUrl,
    filePath: global.tempPath,
    fileName: tempUpdateFileName,
    md5,
    forceUpdate,
    done: async (e) => {
      if (e) {
        if (!window.isDestroyed()) {
          window.send('update-progress', 0)
          window.send('update-error', e)
        }

        removeCacheFile(global.tempPath)
        return
      }

      try {
        await rename(tempUpdateFile, filePath)
      } catch (e) {
        removeCacheFile(global.tempPath)
      }

      window.send('update-progress', 100)
      if (isWin32) {
        spawnLog(path.join(process.resourcesPath, 'elevate.exe'), [
          filePath,
          '/S',
          '--updated',
          '--force-run',
        ])
      } else {
        const json = { url: `file://${filePath}` }

        fs.writeFileSync(global.tempPath + '/feed.json', JSON.stringify(json))
        const feedURL = `file://${global.tempPath}/feed.json`

        autoUpdater.setFeedURL(feedURL)
        autoUpdater.on('error', (err) => {
          removeCacheFile(global.tempPath)
          if (window.isDestroyed()) return
          window.send('update-error', err)
        })

        //监听'update-downloaded'事件，新版本下载完成时触发
        autoUpdater.on('update-downloaded', () => {
          if (neroom && neroom.isInitialized) {
            neroom.release()
          }

          autoUpdater.quitAndInstall()
          // app.exit(0);
          // removeCacheFile(global.tempPath);
          // app.exit(0);
        })

        autoUpdater.checkForUpdates()
      }
    },
    onprogress: (progress) => {
      if (window.isDestroyed()) return
      window.send('update-progress', progress)
    },
  })
}

async function createTempUpdateFile(name, cacheDir) {
  // https://github.com/electron-userland/electron-builder/pull/2474#issuecomment-366481912
  let nameCounter = 0
  let result = name
  let resultPath = path.join(cacheDir, result)

  for (let i = 0; i < 3; i++) {
    try {
      await unlink(resultPath)
      return result
    } catch (e) {
      if (e.code === 'ENOENT') {
        return result
      }

      result = `${nameCounter++}-${name}`
      resultPath = path.join(cacheDir, result)
    }
  }

  console.log('result>>>>>', result)
  return result
}

async function spawnLog(cmd, args) {
  return new Promise((resolve, reject) => {
    try {
      const params = { detached: true }
      const p = spawn(cmd, args, params)

      p.on('error', (error) => {
        reject(error)
      })
      p.unref()
      if (p.pid !== undefined) {
        console.log('resolve', resolve)
        resolve(true)
      }
    } catch (error) {
      reject(error)
    }
  })
}

function getVersionCode(version) {
  if (!version) {
    return 0
  }

  const verArr = version.split('.')
  let versionCode = 0

  if (verArr[0]) {
    versionCode += parseInt(verArr[0]) * 10000
  }

  if (verArr[1]) {
    versionCode += parseInt(verArr[1]) * 100
  }

  if (verArr[2]) {
    versionCode += parseInt(verArr[2])
  }

  return parseInt(versionCode)
}

function initUpdateListener(mainWindow, neroom, appName) {
  ipcMain.handle('get-local-update-info', () => {
    const currentVersion = app.getVersion()

    return {
      versionName: currentVersion,
      versionCode: getVersionCode(currentVersion),
      platform: process.platform,
    }
  })
  ipcMain.handle('get-check-update-info', () => {
    const currentVersion = app.getVersion()

    return {
      versionCode: getVersionCode(currentVersion),
      clientAppCode: 2,
      // accountId: '',
      framework: 'Electron-native',
      osVer: os.release(),
      buildVersion: '',
    }
  })
  ipcMain.handle('decode-base64', (event, valStr) => {
    return valStr ? Buffer.from(valStr, 'base64').toString() : ''
  })
  ipcMain.handle('check-update', (event, { url, md5, forceUpdate }) => {
    checkUpdate(mainWindow, url, md5, neroom, appName, forceUpdate)
    return true
  })
  ipcMain.handle('cancel-update', () => {
    return cancelUpdate()
  })
}

module.exports = {
  getVersionCode,
  checkUpdate,
  initUpdateListener,
}
