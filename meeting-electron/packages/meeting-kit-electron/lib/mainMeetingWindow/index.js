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
var _a = require('electron'), BrowserWindow = _a.BrowserWindow, screen = _a.screen, shell = _a.shell, nativeTheme = _a.nativeTheme, app = _a.app, dialog = _a.dialog, protocol = _a.protocol;
var download = require('electron-dl').download;
var path = require('path');
var _b = require('../sharingScreen'), addScreenSharingIpc = _b.addScreenSharingIpc, closeScreenSharingWindow = _b.closeScreenSharingWindow;
var setWindowOpenHandler = require('./childWindow').setWindowOpenHandler;
var _c = require('./ipcMain'), addIpcMainListeners = _c.addIpcMainListeners, removeIpcMainListeners = _c.removeIpcMainListeners;
var _d = require('../constant'), MINI_WIDTH = _d.MINI_WIDTH, MINI_HEIGHT = _d.MINI_HEIGHT, isLocal = _d.isLocal, isWin32 = _d.isWin32;
var _e = require('../ipcMain'), addGlobalIpcMainListeners = _e.addGlobalIpcMainListeners, removeGlobalIpcMainListeners = _e.removeGlobalIpcMainListeners;
var initMonitoring = require('../utils/monitoring').initMonitoring;
var os = require('os');
var NEMeetingKit = require('../kit/impl/meeting_kit');
var _f = require('../module/dualMonitors'), registerDualMonitors = _f.registerDualMonitors, unregisterDualMonitors = _f.unregisterDualMonitors;
var registerMarvel = require('../module/marvel').registerMarvel;
// 获取操作系统类型
var platform = os.platform();
var isLinux = platform === 'linux';
app.commandLine.appendSwitch('disable-site-isolation-trials');
initMonitoring();
if (isLocal) {
    app.commandLine.appendSwitch('ignore-certificate-errors');
}
// 窗口数量
app.commandLine.appendSwitch('--max-active-webgl-contexts', 1000);
// 开启 SharedArrayBuffer
app.commandLine.appendSwitch('enable-features', 'SharedArrayBuffer');
// 开启 web gpu
/*
if (!isMacOS15) {
  app.commandLine.appendSwitch('--enable-unsafe-webgpu')
}
*/
app.whenReady().then(function () {
    protocol.registerFileProtocol('media', function (request, callback) {
        var url = request.url.substr(8); // 去掉协议名
        var videoPath = path.normalize(url); // 将url转换为正常路径
        callback({ path: videoPath });
    });
});
if (process.platform === 'win32') {
    app.commandLine.appendSwitch('high-dpi-support', 'true');
    // app.commandLine.appendSwitch('force-device-scale-factor', '1')
}
var mainWindow = null;
function checkSystemVersion() {
    var _a;
    var systemLanguage = (_a = app.getPreferredSystemLanguages()) === null || _a === void 0 ? void 0 : _a[0];
    var defaultMessageTip = '当前系统版本过低，请升级系统版本';
    var defaultBtnTextTip = '确定';
    var messageLanguageMap = {
        'zh-Hans-CN': '当前系统版本过低，请升级系统版本',
        'en-CN': 'The current system version is too low, please upgrade the system version',
        'ja-CN': '現在のシステムバージョンが低すぎます。システムバージョンをアップグレードしてください',
    };
    var btnTextLanguageMap = {
        'zh-Hans-CN': '确定',
        'en-CN': 'OK',
        'ja-CN': '確認',
    };
    var showDialog = function (message, btnText) {
        dialog
            .showMessageBox({
            message: message || defaultMessageTip,
            buttons: [btnText || defaultBtnTextTip],
            type: 'warning',
        })
            .then(function () {
            app.exit(0);
        });
    };
    var version = os.release();
    console.log('system version>>>', platform, version);
    // 如果是 Windows 系统
    if (platform === 'win32') {
        // const majorVersion = parseInt(version.split('.')[0])
        // if (majorVersion < 10) {
        //   // 弹出提示对话框
        //   showDialog(
        //     messageLanguageMap[systemLanguage],
        //     btnTextLanguageMap[systemLanguage]
        //   )
        //   return false
        // } else {
        //   return true
        // }
        // 部分window系统win10也会返回6.x版本，所以先关闭
        return true;
    }
    else if (platform === 'darwin') {
        var macVersion = parseFloat(version);
        if (macVersion < 19.5) {
            showDialog(messageLanguageMap[systemLanguage], btnTextLanguageMap[systemLanguage]);
            return false;
        }
        else {
            return true;
        }
    }
    else {
        return true;
    }
}
function openMeetingWindow(data) {
    var _this = this;
    var _a;
    if (!checkSystemVersion()) {
        return;
    }
    addGlobalIpcMainListeners();
    var urlPath = data ? 'meeting' : 'meeting-component';
    // 设置进入会议页面窗口大小及其他属性
    function initMainWindowSize() {
        var nowDisplay = screen.getPrimaryDisplay();
        var _a = nowDisplay.workArea, x = _a.x, y = _a.y, width = _a.width, height = _a.height;
        mainWindow.setFullScreen(false);
        mainWindow.setBounds({
            width: Math.round(MINI_WIDTH),
            height: Math.round(MINI_HEIGHT),
            x: Math.round(x + (width - MINI_WIDTH) / 2),
            y: Math.round(y + (height - MINI_HEIGHT) / 2),
        });
        mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT);
        mainWindow.isFullScreenPrivate = false;
        mainWindow.isMaximizedPrivate = false;
    }
    function setThemeColor() {
        var _a;
        if (!mainWindow.isDestroyed()) {
            mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('set-theme-color', (_a = nativeTheme.shouldUseDarkColors) !== null && _a !== void 0 ? _a : true);
            nativeTheme.on('updated', function () {
                var _a;
                if (!(mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isDestroyed())) {
                    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('set-theme-color', (_a = nativeTheme.shouldUseDarkColors) !== null && _a !== void 0 ? _a : true);
                }
            });
        }
    }
    if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.destroy();
    }
    mainWindow = new BrowserWindow({
        titleBarStyle: 'hidden',
        frame: !isLinux,
        title: '网易会议',
        trafficLightPosition: {
            x: 10,
            y: 7,
        },
        hasShadow: true,
        transparent: true,
        show: false,
        webPreferences: {
            webSecurity: false,
            contextIsolation: false,
            nodeIntegration: true,
            enableRemoteModule: true,
            backgroundThrottling: false,
            preload: path.join(__dirname, '../preload.js'),
        },
    });
    if (isLocal) {
        mainWindow.loadURL("https://localhost:8000/#/".concat(urlPath));
        setTimeout(function () {
            mainWindow.webContents.openDevTools();
        }, 3000);
    }
    else {
        mainWindow.loadFile(path.join(__dirname, '../../build/index.html'), {
            hash: urlPath,
        });
    }
    mainWindow.isMainWindow = true;
    // 最大化
    mainWindow.on('maximize', function () {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('maximize-window', true);
        mainWindow.isMaximizedPrivate = true;
    });
    // 取消最大化
    mainWindow.on('unmaximize', function () {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('maximize-window', false);
        mainWindow.isMaximizedPrivate = false;
    });
    mainWindow.webContents.session.removeAllListeners('will-download');
    mainWindow.webContents.session.on('will-download', function (event, item) { return __awaiter(_this, void 0, void 0, function () {
        var fileName, url_1, paths_1;
        return __generator(this, function (_a) {
            fileName = item.getFilename();
            if (fileName.includes('auto_save!')) {
                event.preventDefault();
                url_1 = item.getURL();
                paths_1 = fileName.split('!');
                mainWindow.webContents
                    .executeJavaScript("localStorage.getItem(\"ne-meeting-setting-".concat(paths_1[1], "\")"), true)
                    .then(function (res) {
                    var _a;
                    try {
                        var setting = JSON.parse(res);
                        download(mainWindow, url_1, {
                            directory: ((_a = setting === null || setting === void 0 ? void 0 : setting.normalSetting) === null || _a === void 0 ? void 0 : _a.downloadPath) ||
                                app.getPath('downloads'),
                            filename: "".concat(paths_1[2]),
                            overwrite: true,
                            openFolderWhenDone: false,
                        });
                    }
                    catch (_b) {
                        //
                    }
                });
            }
            else {
                item.on('done', function (event, state) {
                    var uuidCsvRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.csv$/i;
                    if (state === 'completed' &&
                        fileName.endsWith('csv') &&
                        !uuidCsvRegex.test(fileName)) {
                        // 文件下载完成，打开文件所在路径
                        var path_1 = event.sender.getSavePath();
                        shell.showItemInFolder(path_1);
                    }
                });
            }
            return [2 /*return*/];
        });
    }); });
    // 用来区分关闭窗口的方式
    var beforeQuit = false;
    app.on('before-quit', function () { return __awaiter(_this, void 0, void 0, function () {
        var neMeetingKit, _a, error_1;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    if (!mainWindow.inMeeting) return [3 /*break*/, 1];
                    beforeQuit = true;
                    return [3 /*break*/, 6];
                case 1:
                    console.log('开始反初始化');
                    neMeetingKit = NEMeetingKit.default.getInstance();
                    _b.label = 2;
                case 2:
                    _b.trys.push([2, 5, , 6]);
                    _a = neMeetingKit.isInitialized;
                    if (!_a) return [3 /*break*/, 4];
                    return [4 /*yield*/, neMeetingKit.unInitialize()];
                case 3:
                    _a = (_b.sent());
                    _b.label = 4;
                case 4:
                    _a;
                    return [3 /*break*/, 6];
                case 5:
                    error_1 = _b.sent();
                    console.log('unInitialize error', error_1);
                    return [3 /*break*/, 6];
                case 6: return [2 /*return*/];
            }
        });
    }); });
    mainWindow.on('close', function (event) {
        if (mainWindow.inMeeting) {
            event.preventDefault();
            mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('main-close-before', beforeQuit);
            // linux会回到非全屏状态
            if (!isLinux) {
                mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.show();
            }
            beforeQuit = false;
        }
    });
    mainWindow.on('leave-full-screen', function () {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('leave-full-screen');
        mainWindow.isFullScreenPrivate = false;
    });
    mainWindow.on('enter-full-screen', function () {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('enter-full-screen');
        mainWindow.isFullScreenPrivate = true;
    });
    mainWindow.webContents.once('dom-ready', function () {
        if (data) {
            mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('nemeeting-open-meeting', data);
            mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.show();
        }
        mainWindow.isDomReady = true;
        if (mainWindow.domReadyCallback &&
            typeof mainWindow.domReadyCallback === 'function') {
            mainWindow.domReadyCallback();
        }
    });
    mainWindow.setBackgroundColor('rgba(255, 255, 255,0)');
    mainWindow.webContents.send('set-theme-color', (_a = nativeTheme.shouldUseDarkColors) !== null && _a !== void 0 ? _a : true);
    registerDualMonitors(mainWindow);
    setWindowOpenHandler(mainWindow);
    registerMarvel();
    initMainWindowSize();
    addScreenSharingIpc({
        mainWindow: mainWindow,
        initMainWindowSize: initMainWindowSize,
    });
    setThemeColor();
    addIpcMainListeners(mainWindow);
    mainWindow.initMainWindowSize = initMainWindowSize;
    return mainWindow;
}
function closeMeetingWindow() {
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.destroy();
    mainWindow = null;
    closeScreenSharingWindow();
    removeIpcMainListeners();
    removeGlobalIpcMainListeners();
    unregisterDualMonitors();
}
module.exports = {
    openMeetingWindow: openMeetingWindow,
    closeMeetingWindow: closeMeetingWindow,
};