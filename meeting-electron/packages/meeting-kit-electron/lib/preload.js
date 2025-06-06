"use strict";
var _a = require('electron'), ipcRenderer = _a.ipcRenderer, webFrame = _a.webFrame;
var NERoom = require('neroom-node-sdk');
var log = require('electron-log/renderer');
var os = require('os');
var startMarvel = require('marvel-node').startMarvel;
var isLocal = require('./constant').isLocal;
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
window.addEventListener('DOMContentLoaded', function () {
    //TODO
});
if (process.platform === 'darwin') {
    window.startMarvel = startMarvel;
}
try {
    window.isElectronNative = true; // electron
    window.NERoom = NERoom;
}
catch (e) {
    console.warn('neroom-node-sdk not found');
}
window.isLocal = isLocal;
window.electronLog = log.info;
// console.error = log.info;
console.info = log.info;
// console.debug = log.info;
window.isWins32 = process.platform === 'win32';
window.platform = process.platform;
window.systemPlatform = process.platform;
window.ipcRenderer = ipcRenderer;
window.eleProcess = process;
window.webFrame = webFrame;
window.isArm64 = os.arch() === 'arm64';
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