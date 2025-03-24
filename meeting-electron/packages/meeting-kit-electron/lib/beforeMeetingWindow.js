"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
var _a = require('electron'), BrowserWindow = _a.BrowserWindow, screen = _a.screen, shell = _a.shell, ipcMain = _a.ipcMain, globalShortcut = _a.globalShortcut, app = _a.app;
var path = require('path');
var NEMeetingKit = require('./kit/impl/meeting_kit');
var isLocal = process.env.ENV_MODE === 'local';
var newWins = {};
var isLinux = process.platform === 'linux';
function createBeforeMeetingWindow() {
    // 获取当前，鼠标所在的屏幕中心
    var mousePosition = screen.getCursorScreenPoint();
    var nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    var _a = nowDisplay.workArea, x = _a.x, y = _a.y, width = _a.width, height = _a.height;
    var beforeMeetingWindow = new BrowserWindow({
        titleBarStyle: 'hidden',
        frame: !isLinux,
        width: 720,
        height: 480,
        x: Math.round(x + (width - 720) / 2),
        y: Math.round(y + (height - 480) / 2),
        trafficLightPosition: {
            x: 6,
            y: 6,
        },
        resizable: false,
        maximizable: false,
        backgroundColor: '#fff',
        show: false,
        fullscreenable: false,
        webPreferences: {
            contextIsolation: false,
            nodeIntegration: true,
            enableRemoteModule: true,
            preload: path.join(__dirname, './preload.js'),
        },
    });
    var homeWindowHeight = 480;
    var homeWindowWidth = 720;
    if (isLocal) {
        beforeMeetingWindow.loadURL('https://localhost:8000/');
        setTimeout(function () {
            beforeMeetingWindow.webContents.openDevTools();
        }, 1000);
    }
    else {
        beforeMeetingWindow.loadFile(path.join(__dirname, '../build/index.html'));
    }
    beforeMeetingWindow.webContents.on('did-create-window', function (newWin, _a) {
        var _b;
        var originalUrl = _a.url;
        var url = originalUrl.replace(/.*?(?=#)/, '');
        newWins[url] = newWin;
        // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
        newWin.on('close', function (event) {
            event.preventDefault();
            if (url.includes('scheduleMeeting')) {
                newWin.webContents.send('scheduleMeetingWindow:close');
                return;
            }
            else if (url.includes('interpreterSetting')) {
                newWin.webContents.send('interpreterSettingWindow:close');
                return;
            }
            beforeMeetingWindow.webContents.send("windowClosed:".concat(url));
            newWin.hide();
        });
        if (url.includes('notification/card')) {
            (_b = newWin.setWindowButtonVisibility) === null || _b === void 0 ? void 0 : _b.call(newWin, false);
        }
        if (isLocal) {
            //newWin.webContents.openDevTools()
        }
    });
    beforeMeetingWindow.webContents.setWindowOpenHandler(function (_a) {
        var originalUrl = _a.url;
        var url = originalUrl.replace(/.*?(?=#)/, '');
        var _b = beforeMeetingWindow.getBounds(), x = _b.x, y = _b.y;
        var commonOptions = {
            width: 375,
            height: 670,
            titleBarStyle: 'hidden',
            frame: !isLinux,
            maximizable: false,
            minimizable: false,
            resizable: false,
            fullscreenable: false,
            trafficLightPosition: {
                x: 10,
                y: 13,
            },
            webPreferences: {
                contextIsolation: false,
                nodeIntegration: true,
                preload: path.join(__dirname, './ipc.js'),
            },
        };
        if (url.includes('#/notification/list')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { x: x + 375, y: y }),
            };
        }
        else if (url.includes('#/history')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { trafficLightPosition: {
                        x: 19,
                        y: 19,
                    }, width: 375, height: 664, x: Math.round(x + (homeWindowWidth - 375) / 2), y: Math.round(y + (homeWindowHeight - 664) / 2) }),
            };
        }
        else if (url.includes('#/transcriptionWindow')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { trafficLightPosition: {
                        x: 19,
                        y: 19,
                    }, width: 375, height: 664, x: Math.round(x + (homeWindowWidth - 375) / 2), y: Math.round(y + (homeWindowHeight - 664) / 2) }),
            };
        }
        else if (url.includes('#/imageCrop')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 600, height: 380 }),
            };
        }
        else if (url.includes('#/about')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { trafficLightPosition: {
                        x: 19,
                        y: 19,
                    }, width: 375, height: 731 }),
            };
        }
        else if (url.includes('#/nps')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 601, height: 395, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        else if (url.includes('#/plugin')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { frame: true }),
            };
        }
        else if (url.includes('#/chat')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign({}, commonOptions),
            };
        }
        else if (url.includes('#/setting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 800, height: 600, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        else if (url.includes('#/addressBook')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 498, height: 449, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        else if (url.includes('#/notification/card')) {
            var nowDisplay_1 = screen.getPrimaryDisplay();
            var _c = nowDisplay_1.workArea, width_1 = _c.width, height_1 = _c.height;
            var notifyWidth = 360;
            var notifyHeight = 260;
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { maximizable: false, titleBarStyle: 'hidden', frame: !isLinux, minimizable: false, fullscreenable: false, alwaysOnTop: 'screen-saver', resizable: false, skipTaskbar: true, width: 360, height: 260, x: Math.round(width_1 - notifyWidth - 60), y: Math.round(height_1 - notifyHeight - 20) }),
            };
        }
        else if (url.includes('#/scheduleMeeting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { trafficLightPosition: {
                        x: 19,
                        y: 19,
                    }, width: 375, height: 664, x: Math.round(x + (homeWindowWidth - 375) / 2), y: Math.round(y + (homeWindowHeight - 664) / 2) }),
            };
        }
        else if (url.includes('#/joinMeeting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 375, height: 400, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    }, x: Math.round(x + (homeWindowWidth - 375) / 2), y: Math.round(y + (homeWindowHeight - 402) / 2) }),
            };
        }
        else if (url.includes('#/immediateMeeting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 375, height: 450, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    }, x: Math.round(x + (homeWindowWidth - 375) / 2), y: Math.round(y + (homeWindowHeight - 594) / 2) }),
            };
        }
        else if (url.includes('#/interpreterSetting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 520, height: 541, trafficLightPosition: {
                        x: 10,
                        y: 13,
                    } }),
            };
        }
        else if (url.includes('#/feedback')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 375, height: 731, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        return { action: 'deny' };
    });
    function getKeyByValue(obj, value) {
        return Object.keys(obj).find(function (key) { return obj[key] === value; });
    }
    ipcMain.on('focusWindow', function (event, url) {
        var win = BrowserWindow.fromWebContents(event.sender);
        if (win === beforeMeetingWindow) {
            if (newWins[url] && !newWins[url].isDestroyed()) {
                newWins[url].show();
            }
        }
    });
    ipcMain.on('changeSetting', function (event, setting) {
        if (beforeMeetingWindow && !beforeMeetingWindow.isDestroyed()) {
            beforeMeetingWindow.webContents.send('changeSetting', setting);
        }
        Object.values(newWins).forEach(function (win) {
            if (win && !win.isDestroyed()) {
                win.webContents.send('changeSetting', setting);
            }
        });
    });
    beforeMeetingWindow.on('focus', function () {
        globalShortcut.register('f5', function () {
            console.log('f5 is pressed');
            //mainWindow.reload()
        });
        globalShortcut.register('CommandOrControl+R', function () {
            console.log('CommandOrControl+R is pressed');
            //mainWindow.reload()
        });
    });
    beforeMeetingWindow.on('blur', function () {
        globalShortcut.unregister('f5', function () {
            console.log('f5 is pressed');
            //mainWindow.reload()
        });
        globalShortcut.unregister('CommandOrControl+R', function () {
            console.log('CommandOrControl+R is pressed');
            //mainWindow.reload()
        });
    });
    ipcMain.on('childWindow:closed', function (event) {
        var win = BrowserWindow.fromWebContents(event.sender);
        var url = getKeyByValue(newWins, win);
        url && beforeMeetingWindow.webContents.send("windowClosed:".concat(url));
        win === null || win === void 0 ? void 0 : win.hide();
    });
    ipcMain.on('NEMeetingKitElectron', function (event, data) {
        var _a;
        var neMeetingKit = NEMeetingKit.default.getInstance();
        var module = data.event;
        var _b = data.payload, replyKey = _b.replyKey, fnKey = _b.fnKey, args = _b.args;
        var modules = {
            neMeetingKit: neMeetingKit,
            getMeetingService: neMeetingKit.getMeetingService(),
            getAccountService: neMeetingKit.getAccountService(),
            getSettingsService: neMeetingKit.getSettingsService(),
            getMeetingInviteService: neMeetingKit.getMeetingInviteService(),
            getPreMeetingService: neMeetingKit.getPreMeetingService(),
            getMeetingMessageChannelService: neMeetingKit.getMeetingMessageChannelService(),
            getContactsService: neMeetingKit.getContactsService(),
            getFeedbackService: neMeetingKit.getFeedbackService(),
            getGuestService: neMeetingKit.getGuestService(),
        };
        (_a = modules[module]) === null || _a === void 0 ? void 0 : _a[fnKey].apply(_a, __spreadArray([], __read(args), false)).then(function (res) {
            event.sender.send(replyKey, {
                result: res,
            });
            if (fnKey === 'initialize') {
                console.log('开始初始化');
                neMeetingKit.setExceptionHandler({
                    onError: function () {
                        // 会中进程崩溃
                        beforeMeetingWindow.webContents.send('NEMeetingKitCrash');
                    },
                });
                neMeetingKit.getMeetingService().addMeetingStatusListener({
                    onMeetingStatusChanged: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingStatusListeners',
                            fnKey: 'onMeetingStatusChanged',
                            args: args,
                        });
                    },
                });
                neMeetingKit.getMeetingService().setOnInjectedMenuItemClickListener({
                    onInjectedMenuItemClick: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingOnInjectedMenuItemClickListeners',
                            fnKey: 'onInjectedMenuItemClick',
                            args: args,
                        });
                    },
                });
                neMeetingKit.getAccountService().addListener({
                    onKickOut: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'accountServiceListeners',
                            fnKey: 'onKickOut',
                            args: args,
                        });
                    },
                    onAuthInfoExpired: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'accountServiceListeners',
                            fnKey: 'onAuthInfoExpired',
                            args: args,
                        });
                    },
                    onReconnected: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'accountServiceListeners',
                            fnKey: 'onReconnected',
                            args: args,
                        });
                    },
                    onAccountInfoUpdated: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'accountServiceListeners',
                            fnKey: 'onAccountInfoUpdated',
                            args: args,
                        });
                    },
                });
                neMeetingKit.getPreMeetingService().addListener({
                    onMeetingItemInfoChanged: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'preMeetingListeners',
                            fnKey: 'onMeetingItemInfoChanged',
                            args: args,
                        });
                    },
                    onLocalRecorderStatus: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'preMeetingListeners',
                            fnKey: 'onLocalRecorderStatus',
                            args: args,
                        });
                    },
                    onLocalRecorderError: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'preMeetingListeners',
                            fnKey: 'onLocalRecorderError',
                            args: args,
                        });
                    },
                });
                neMeetingKit
                    .getMeetingInviteService()
                    .addMeetingInviteStatusListener({
                    onMeetingInviteStatusChanged: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingInviteStatusListeners',
                            fnKey: 'onMeetingInviteStatusChanged',
                            args: args,
                        });
                    },
                });
                neMeetingKit
                    .getMeetingMessageChannelService()
                    .addMeetingMessageChannelListener({
                    onSessionMessageReceived: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingMessageChannelListeners',
                            fnKey: 'onSessionMessageReceived',
                            args: args,
                        });
                    },
                    onSessionMessageRecentChanged: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingMessageChannelListeners',
                            fnKey: 'onSessionMessageRecentChanged',
                            args: args,
                        });
                    },
                    onSessionMessageDeleted: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingMessageChannelListeners',
                            fnKey: 'onSessionMessageDeleted',
                            args: args,
                        });
                    },
                    onSessionMessageAllDeleted: function () {
                        var args = [];
                        for (var _i = 0; _i < arguments.length; _i++) {
                            args[_i] = arguments[_i];
                        }
                        beforeMeetingWindow.webContents.send('NEMeetingKitElectron-Listener', {
                            module: 'meetingMessageChannelListeners',
                            fnKey: 'onSessionMessageAllDeleted',
                            args: args,
                        });
                    },
                });
            }
        }).catch(function (error) {
            event.sender.send(replyKey, {
                error: error,
            });
        });
    });
    return beforeMeetingWindow;
}
module.exports = {
    createBeforeMeetingWindow: createBeforeMeetingWindow,
    beforeNewWins: newWins,
};