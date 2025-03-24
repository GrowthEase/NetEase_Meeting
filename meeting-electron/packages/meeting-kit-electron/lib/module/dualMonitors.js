"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __read = (this && this.__read) || function (o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o), r, ar = [], e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    }
    catch (error) { e = { error: error }; }
    finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        }
        finally { if (e) throw e.error; }
    }
    return ar;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerDualMonitors = registerDualMonitors;
exports.unregisterDualMonitors = unregisterDualMonitors;
exports.handleDualMonitorsWin = handleDualMonitorsWin;
var electron_1 = require("electron");
var constant_1 = require("../constant");
var IPC_EVENT = {
    DUAL_MONITORS_DISPLAY_ADDED: 'DUAL_MONITORS_DISPLAY_ADDED',
    DUAL_MONITORS_DISPLAY_REMOVED: 'DUAL_MONITORS_DISPLAY_REMOVED',
    DUAL_MONITORS_GET_DISPLAY_COUNT: 'DUAL_MONITORS_GET_DISPLAY_COUNT',
    DUAL_MONITORS_WIN_CLOSE: 'DUAL_MONITORS_WIN_CLOSE',
    DUAL_MONITORS_WIN_HIDE: 'DUAL_MONITORS_WIN_HIDE',
    DUAL_MONITORS_WIN_SHOW: 'DUAL_MONITORS_WIN_SHOW',
    DUAL_MONITORS_WIN_SWAP: 'DUAL_MONITORS_WIN_SWAP',
    DUAL_MONITORS_WIN_END: 'DUAL_MONITORS_WIN_END',
};
var mainWin;
var dualMonitorsWin;
var swapWindowsPosition = function (win1, win2) { return __awaiter(void 0, void 0, void 0, function () {
    var isWin1FullScreen, isWin2FullScreen, _a, width1, height1, _b, width2, height2, _c, x1, y1, _d, x2, y2, centerX1, centerY1, centerX2, centerY2, newX1, newY1, newX2, newY2;
    return __generator(this, function (_e) {
        switch (_e.label) {
            case 0:
                isWin1FullScreen = win1.isFullScreenPrivate;
                isWin2FullScreen = win2.isFullScreenPrivate;
                // 如果窗口全屏，先退出全屏模式
                if (isWin1FullScreen)
                    win1.setFullScreen(false);
                if (isWin2FullScreen)
                    win2.setFullScreen(false);
                if (!(isWin1FullScreen || isWin2FullScreen)) return [3 /*break*/, 2];
                return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, 1000); })];
            case 1:
                _e.sent();
                _e.label = 2;
            case 2:
                _a = __read(win1.getSize(), 2), width1 = _a[0], height1 = _a[1];
                _b = __read(win2.getSize(), 2), width2 = _b[0], height2 = _b[1];
                _c = __read(win1.getPosition(), 2), x1 = _c[0], y1 = _c[1];
                _d = __read(win2.getPosition(), 2), x2 = _d[0], y2 = _d[1];
                centerX1 = x1 + width1 / 2;
                centerY1 = y1 + height1 / 2;
                centerX2 = x2 + width2 / 2;
                centerY2 = y2 + height2 / 2;
                newX1 = Math.round(centerX2 - width1 / 2);
                newY1 = Math.round(centerY2 - height1 / 2);
                newX2 = Math.round(centerX1 - width2 / 2);
                newY2 = Math.round(centerY1 - height2 / 2);
                // 设置新位置
                win1.setPosition(newX1, newY1);
                win2.setPosition(newX2, newY2);
                // 重新设置全屏模式
                if (isWin1FullScreen)
                    win1.setFullScreen(true);
                if (isWin2FullScreen)
                    win2.setFullScreen(true);
                return [2 /*return*/];
        }
    });
}); };
function registerDualMonitors(win) {
    mainWin = win;
    // 监听屏幕变化
    electron_1.screen.on('display-added', function () {
        var length = electron_1.screen.getAllDisplays().length;
        mainWin === null || mainWin === void 0 ? void 0 : mainWin.webContents.send(IPC_EVENT.DUAL_MONITORS_DISPLAY_ADDED, length);
    });
    electron_1.screen.on('display-removed', function () {
        var length = electron_1.screen.getAllDisplays().length;
        if (length === 1) {
            if (dualMonitorsWin && !dualMonitorsWin.isDestroyed()) {
                dualMonitorsWin.hide();
            }
        }
        mainWin === null || mainWin === void 0 ? void 0 : mainWin.webContents.send(IPC_EVENT.DUAL_MONITORS_DISPLAY_REMOVED, length);
    });
    electron_1.ipcMain.handle(IPC_EVENT.DUAL_MONITORS_GET_DISPLAY_COUNT, function () {
        return electron_1.screen.getAllDisplays().length;
    });
    electron_1.ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_SWAP, function () {
        if (mainWin && dualMonitorsWin) {
            mainWin.show();
            swapWindowsPosition(mainWin, dualMonitorsWin);
        }
    });
}
function handleDualMonitorsWin(win) {
    // 窗口关闭标记位
    var isClosed = false;
    dualMonitorsWin = win;
    // 打开开发者工具
    // dualMonitorsWin.webContents.openDevTools()
    function setWindowPosition() {
        var displays = electron_1.screen.getAllDisplays();
        if (displays.length > 1 && mainWin) {
            var mainWinDisplay = electron_1.screen.getDisplayMatching(mainWin.getBounds());
            //确定副屏的显示窗口
            var dualMonitorsWinDisplay = mainWinDisplay.id === displays[0].id ? displays[1] : displays[0];
            if (dualMonitorsWin) {
                var _a = dualMonitorsWin.getBounds(), winWidth = _a.width, winHeight = _a.height;
                var _b = dualMonitorsWinDisplay.workArea, x = _b.x, y = _b.y, width = _b.width, height = _b.height;
                dualMonitorsWin.show();
                dualMonitorsWin.setBounds({
                    x: Math.round(x + width / 2 - winWidth / 2),
                    y: Math.round(y + height / 2 - winHeight / 2),
                });
            }
        }
    }
    setWindowPosition();
    function handleWinHide() {
        dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.hide();
    }
    function handleWinShow() {
        dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.show();
    }
    function handleWinClose() {
        isClosed = true;
        electron_1.ipcMain.off(IPC_EVENT.DUAL_MONITORS_WIN_SHOW, handleWinShow);
        electron_1.ipcMain.off(IPC_EVENT.DUAL_MONITORS_WIN_HIDE, handleWinHide);
        if (dualMonitorsWin && !dualMonitorsWin.isDestroyed()) {
            dualMonitorsWin.close();
        }
    }
    dualMonitorsWin.removeAllListeners('close');
    dualMonitorsWin.removeAllListeners('closed');
    dualMonitorsWin.removeAllListeners('enter-full-screen');
    dualMonitorsWin.removeAllListeners('leave-full-screen');
    dualMonitorsWin.removeAllListeners('maximize');
    dualMonitorsWin.removeAllListeners('unmaximize');
    dualMonitorsWin.on('close', function (event) {
        event.preventDefault();
        if (isClosed) {
            if (dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.isFullScreenPrivate) {
                dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.removeAllListeners('leave-full-screen');
                dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.on('leave-full-screen', function () {
                    if (dualMonitorsWin) {
                        dualMonitorsWin.isFullScreenPrivate = false;
                        dualMonitorsWin.hide();
                    }
                });
                dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.setFullScreen(false);
                constant_1.isWin32 && dualMonitorsWin.hide();
            }
            else {
                dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.hide();
            }
            return;
        }
        dualMonitorsWin === null || dualMonitorsWin === void 0 ? void 0 : dualMonitorsWin.webContents.send(IPC_EVENT.DUAL_MONITORS_WIN_END);
    });
    dualMonitorsWin.on('leave-full-screen', function () {
        if (dualMonitorsWin) {
            dualMonitorsWin.webContents.send('leave-full-screen');
            dualMonitorsWin.isFullScreenPrivate = false;
        }
    });
    dualMonitorsWin.on('enter-full-screen', function () {
        if (dualMonitorsWin) {
            dualMonitorsWin.webContents.send('enter-full-screen');
            dualMonitorsWin.isFullScreenPrivate = true;
        }
    });
    // 最大化
    dualMonitorsWin.on('maximize', function () {
        if (dualMonitorsWin) {
            dualMonitorsWin.webContents.send('maximize-window', true);
            dualMonitorsWin.isMaximizedPrivate = true;
        }
    });
    // 取消最大化
    dualMonitorsWin.on('unmaximize', function () {
        if (dualMonitorsWin) {
            dualMonitorsWin.webContents.send('maximize-window', false);
            dualMonitorsWin.isMaximizedPrivate = false;
        }
    });
    // 窗口关闭
    electron_1.ipcMain.once(IPC_EVENT.DUAL_MONITORS_WIN_CLOSE, handleWinClose);
    electron_1.ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_SHOW, handleWinShow);
    electron_1.ipcMain.on(IPC_EVENT.DUAL_MONITORS_WIN_HIDE, handleWinHide);
}
function unregisterDualMonitors() {
    electron_1.ipcMain.removeHandler(IPC_EVENT.DUAL_MONITORS_GET_DISPLAY_COUNT);
}