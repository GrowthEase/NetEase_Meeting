const { ipcRenderer, webFrame } = require('electron')
const NERoom = require('neroom-node-sdk')
const log = require('electron-log/renderer')
const os = require('os')
const { startMarvel } = require('marvel-node')
const { isLocal } = require('./constant')

log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}'

window.addEventListener('DOMContentLoaded', () => {
  //TODO
})

if (process.platform === 'darwin') {
  window.startMarvel = startMarvel
}

try {
  window.isElectronNative = true // electron
  window.NERoom = NERoom
} catch (e) {
  console.warn('neroom-node-sdk not found')
}

window.isLocal = isLocal

window.electronLog = log.info
// console.error = log.info;
console.info = log.info
// console.debug = log.info;
window.isWins32 = process.platform === 'win32'
window.platform = process.platform
window.systemPlatform = process.platform
window.ipcRenderer = ipcRenderer
window.eleProcess = process
window.webFrame = webFrame
window.isArm64 = os.arch() === 'arm64'
window.electronPopover = {
  show: (items) => {
    ipcRenderer.send('showPopover', items)
  },
  hide: () => {
    ipcRenderer.send('hidePopover')
  },
  update: (items) => {
    ipcRenderer.send('updatePopover', items)
  },
}
