const { ipcRenderer } = require('electron');

window.isElectronNative = true;
window.ipcRenderer = ipcRenderer;
window.platform = process.platform;
window.systemPlatform = process.platform;
