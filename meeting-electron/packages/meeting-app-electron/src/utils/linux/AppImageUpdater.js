const { execFileSync } = require("child_process")
const { chmod } = require("fs-extra")
const { unlinkSync } = require("fs")
const path = require("path")


const { wrapSudo, spawnSyncLog } = require('./utils')
const { app, autoUpdater } = require('electron')
function doInstall(options) {
  const appImageFile = process.env["APPIMAGE"]!
  if (appImageFile == null) {
    throw newError("APPIMAGE env is not defined", "ERR_UPDATER_OLD_FILE_NOT_FOUND")
  }

  // https://stackoverflow.com/a/1712051/1910191
  unlinkSync(appImageFile)

  let destination
  const existingBaseName = path.basename(appImageFile)
  // if no version in existing file name, it means that user wants to preserve current custom name
  if (path.basename(options.installerPath) === existingBaseName || !/\d+\.\d+\.\d+/.test(existingBaseName)) {
    // no version in the file name, overwrite existing
    destination = appImageFile
  } else {
    destination = path.join(path.dirname(appImageFile), path.basename(options.installerPath))
  }

  execFileSync("mv", ["-f", options.installerPath, destination])
  if (destination !== appImageFile) {
    console.log("appimage-filename-updated", destination)
  }

  const env = {
    ...process.env,
    APPIMAGE_SILENT_INSTALL: "true",
  }

  spawnLog(destination, [], env)
  return true
}

async function quitAndInstall(filePath) {
    await chmod(filePath, 0o755)
    console.info(`Install on explicit quitAndInstall`)
    // If NOT in silent mode use `autoRunAppAfterInstall` to determine whether to force run the app
    const isInstalled = install(filePath)
    if (isInstalled) {
      setImmediate(() => {
        // this event is normally emitted when calling quitAndInstall, this emulates that
        autoUpdater.emit("before-quit-for-update")
        app.quit()
      })
    } else {
      this.quitAndInstallCalled = false
    }
}

function install(filePath) {
  try {
    console.info(`Install: ${filePath}`)
    return doInstall({
      installerPath: filePath,
      isSilent: true,
      isForceRunAfter: true,
    })
  } catch (e) {
    return false
  }
}



module.exports = {
  doInstall,
  quitAndInstall
}