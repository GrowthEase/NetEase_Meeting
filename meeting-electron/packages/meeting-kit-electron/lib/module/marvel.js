"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerMarvel = registerMarvel;
var electron_1 = require("electron");
var marvel_node_1 = require("marvel-node");
function registerMarvel() {
    // 仅在 Windows 上注册
    if (process.platform === 'win32') {
        electron_1.ipcMain.on('startMarvel', function (event, config) {
            (0, marvel_node_1.startWinMarvel)(config);
        });
    }
}