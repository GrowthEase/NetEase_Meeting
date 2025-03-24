const { wrapSudo, spawnSyncLog } = require('./utils')
const { app, autoUpdater } = require('electron')
function doInstall(options) {
  const sudo = wrapSudo()
  console.log('doInstall sudo', sudo)
  // pkexec doesn't want the command to be wrapped in " quotes
  const wrapper = /pkexec/i.test(sudo) ? "" : `"`
  console.log('doInstall wrapper', wrapper)
  const cmd = ["dpkg", "-i", options.installerPath, "||", "apt-get", "install", "-f", "-y"]
  console.log('doInstall cmd', cmd)
  spawnSyncLog(sudo, [`${wrapper}/bin/bash`, "-c", `'${cmd.join(" ")}'${wrapper}`])
  if (options.isForceRunAfter) {
    app.relaunch()
  }
  return true
}

function quitAndInstall(filePath) {
    console.log(`Install on explicit quitAndInstall`, filePath)
    // If NOT in silent mode use `autoRunAppAfterInstall` to determine whether to force run the app
    const isInstalled = install(filePath)
    console.log(`isInstalled`, isInstalled)
    if (isInstalled) {
      setImmediate(() => {
        // this event is normally emitted when calling quitAndInstall, this emulates that
        autoUpdater.emit("before-quit-for-update")
        app.quit()
      })
    } else {
      console.error(`Install failed`, filePath)
    }
}

function install(filePath) {
  try {
    console.log(`start doInstall: ${filePath}`)
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