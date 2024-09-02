const { ipcRenderer, webFrame } = require('electron')
const NERoom = require('neroom-node-sdk')
const log = require('electron-log/renderer')

// import NERoom from 'neroom-node-sdk'

log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}'

window.addEventListener('DOMContentLoaded', () => {
  //TODO
})

// contextBridge.exposeInMainWorld(
//   'NERoomNode',
//   require('neroom-node-sdk').default,
// );
try {
  window.isElectronNative = true // electron
  window.NERoom = NERoom
} catch (e) {
  console.warn('neroom-node-sdk not found')
}

window.electronLog = log.info
// console.error = log.info;
// console.info = log.info;
// console.debug = log.info;
window.isWins32 = process.platform === 'win32'
window.platform = process.platform
window.systemPlatform = process.platform
window.ipcRenderer = ipcRenderer
window.eleProcess = process
window.webFrame = webFrame
