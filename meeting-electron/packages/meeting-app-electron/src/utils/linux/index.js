const {existsSync, readFileSync} = require('fs-extra')
const path = require('path')
let _autoUpdater
function updateLinux(filePath) {
  try {
    let identity = path.join(process.resourcesPath, "package-type")
    console.log("identity", identity)
    // if (!existsSync(identity)) {
    //   identity = filePath
    // }
    console.log("Checking for beta autoupdate feature for deb/rpm distributions")
    // 获取文件类型
    const fileType = path.extname(filePath).trim().toLocaleLowerCase().replace(/\./g, '')
    // 去除获取到的文件类型中的点
    console.log("Found package-type:", fileType)
    switch (fileType) {
    case "deb":
        require("./DebUpdater").quitAndInstall(filePath)
        break
    case "rpm":
        require("./RpmUpdater").quitAndInstall(filePath)
        break
    case "pacman":
        require("./PacmanUpdater").quitAndInstall(filePath)
        break
    case "appimage":
        require("./AppImageUpdater").quitAndInstall(filePath)
        break
    default:
        break
    }
  } catch (error) {
    console.warn(
      "Unable to detect 'package-type' for autoUpdater (beta rpm/deb support). If you'd like to expand support, please consider contributing to electron-builder",
      error.message
    )
  }
}

module.exports = {
  updateLinux
}