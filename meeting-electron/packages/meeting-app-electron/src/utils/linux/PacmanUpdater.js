const { wrapSudo, spawnSyncLog } = require('./utils')
const { app, autoUpdater } = require('electron')
function doInstall(options) {
  const sudo = wrapSudo()
  // pkexec doesn't want the command to be wrapped in " quotes
  const wrapper = /pkexec/i.test(sudo) ? "" : `"`
  const cmd = ["pacman", "-U", "--noconfirm", options.installerPath]
  spawnSyncLog(sudo, [`${wrapper}/bin/bash`, "-c", `'${cmd.join(" ")}'${wrapper}`])
  this.app.relaunch()
  return true
}

function quitAndInstall(filePath) {
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
      isForceRunAfter: false,
    })
  } catch (e) {
    return false
  }
}



module.exports = {
  doInstall,
  quitAndInstall
}