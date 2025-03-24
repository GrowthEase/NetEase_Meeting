"use strict";
var ipcRenderer = require('electron').ipcRenderer;
var log = require('electron-log/renderer');
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
window.electronLog = log.info;
window.isElectronNative = true;
window.ipcRenderer = ipcRenderer;
window.platform = process.platform;
window.systemPlatform = process.platform;
window.isWins32 = process.platform === 'win32';
window.isChildWindow = true;
window.electronPopover = {
    show: function (items) {
        ipcRenderer.send('showPopover', items);
    },
    hide: function () {
        ipcRenderer.send('hidePopover');
    },
    update: function (items) {
        ipcRenderer.send('updatePopover', items);
    },
};