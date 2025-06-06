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
var screen = require('electron').screen;
var sharingScreen = require('../sharingScreen').sharingScreen;
var path = require('path');
var handleDualMonitorsWin = require('../module/dualMonitors').handleDualMonitorsWin;
var isWin32 = process.platform === 'win32';
var isLinux = process.platform === 'linux';
var MEETING_HEADER_HEIGHT = isWin32 ? 31 : 28;
var selfWindow = null;
var newWins = {};
function setExcludeWindowList() {
    selfWindow.webContents.send('setExcludeWindowList', [
        __spreadArray(__spreadArray([], __read(Object.values(newWins)), false), [selfWindow], false).filter(function (item) { return item && !item.isDestroyed(); })
            .map(function (item) {
            return isWin32
                ? item.getNativeWindowHandle()
                : Number(item.getMediaSourceId().split(':')[1]);
        }),
        isWin32,
    ]);
}
function openNewWindow(url) {
    var _a, _b, _c, _d, _e;
    var newWin = newWins[url];
    if (!newWin || newWin.isDestroyed())
        return;
    if (sharingScreen.isSharing) {
        newWin === null || newWin === void 0 ? void 0 : newWin.setContentProtection(true);
    }
    else {
        newWin === null || newWin === void 0 ? void 0 : newWin.setContentProtection(false);
    }
    if (url.includes('bulletScreenMessage')) {
        (_a = newWin.setWindowButtonVisibility) === null || _a === void 0 ? void 0 : _a.call(newWin, false);
        // 通过位置信息获取对应的屏幕
        var currentScreen = screen.getPrimaryDisplay();
        // 获取屏幕的位置，宽度和高度
        var screenX = currentScreen.bounds.x;
        var screenY = currentScreen.bounds.y;
        var screenHeight = currentScreen.bounds.height;
        // 计算窗口的新位置
        var newY = screenY + screenHeight - newWin.getSize()[1] - 100;
        // 将窗口移动到新位置
        newWin.setPosition(screenX, newY);
        newWin.setAlwaysOnTop(true, 'screen-saver');
    }
    else if (url.includes('screenSharing/video')) {
        (_b = newWin.setWindowButtonVisibility) === null || _b === void 0 ? void 0 : _b.call(newWin, false);
        // 通过位置信息获取对应的屏幕
        var currentScreen = screen.getPrimaryDisplay();
        // 获取屏幕的位置，宽度和高度
        var screenX = currentScreen.bounds.x;
        var screenY = currentScreen.bounds.y;
        var screenWidth = currentScreen.bounds.width;
        // 计算窗口的新位置
        var newX = screenX + screenWidth - newWin.getSize()[0] - 20;
        var newY = screenY;
        // 将窗口移动到新位置
        newWin.setPosition(newX, newY);
        newWin.setAlwaysOnTop(true, 'screen-saver');
    }
    else if (url.includes('notification/card')) {
        (_c = newWin.setWindowButtonVisibility) === null || _c === void 0 ? void 0 : _c.call(newWin, false);
        // 获取主窗口的位置信息
        // 通过位置信息获取对应的屏幕
        var currentScreen = screen.getPrimaryDisplay();
        // 获取屏幕的位置，宽度和高度
        var screenX = currentScreen.bounds.x;
        var screenY = currentScreen.bounds.y;
        var screenWidth = currentScreen.bounds.width;
        var screenHeight = currentScreen.bounds.height;
        // 计算窗口的新位置
        var newX = screenX + screenWidth - newWin.getSize()[0] - 60;
        var newY = screenY + screenHeight - newWin.getSize()[1] - 60;
        // 将窗口移动到新位置
        newWin.setPosition(newX, newY);
        newWin.setAlwaysOnTop(true, 'screen-saver');
    }
    else if (url.includes('/screenSharing/screenMarker')) {
        var index = url.split('/').pop();
        var display = screen.getAllDisplays()[Number(index)];
        if (display) {
            var _f = display.workArea, x = _f.x, y = _f.y;
            newWin.setBounds({
                x: x + 30,
                y: y + 30,
            });
            (_d = newWin.setWindowButtonVisibility) === null || _d === void 0 ? void 0 : _d.call(newWin, false);
            newWin.show();
        }
    }
    else if (url.includes('/annotation')) {
        (_e = newWin.setWindowButtonVisibility) === null || _e === void 0 ? void 0 : _e.call(newWin, false);
        newWin.setIgnoreMouseEvents(true);
        newWin.setAlwaysOnTop(true, 'normal', 99);
        if (sharingScreen.shareScreen) {
            newWin.setBounds(sharingScreen.shareScreen.bounds);
        }
    }
    else if (url.includes('/dualMonitors')) {
        handleDualMonitorsWin(newWin);
    }
    setExcludeWindowList();
}
function setWindowOpenHandler(mainWindow) {
    selfWindow = mainWindow;
    mainWindow.webContents.setWindowOpenHandler(function (_a) {
        var originalUrl = _a.url;
        var url = originalUrl.replace(/.*?(?=#)/, '');
        var commonOptions = {
            width: 375,
            height: 670,
            titleBarStyle: 'hidden',
            frame: !isLinux,
            maximizable: false,
            minimizable: false,
            resizable: false,
            autoHideMenuBar: true,
            title: '',
            fullscreenable: false,
            webPreferences: {
                contextIsolation: false,
                nodeIntegration: true,
                backgroundThrottling: false,
                preload: path.join(__dirname, '../ipc.js'),
            },
        };
        if (url.endsWith('screenSharing/video')) {
            var pW = 215;
            var pH = MEETING_HEADER_HEIGHT + 120;
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: pW - 2, height: pH, titleBarStyle: 'hidden', frame: !isLinux, transparent: true }),
            };
        }
        else if (url.includes('#/plugin?')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { frame: !isLinux, titleBarStyle: mainWindow.inMeeting ? 'default' : 'hidden' }),
            };
        }
        else if (url.includes('#/notification/card')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 360, height: 260 }),
            };
        }
        else if (url.includes('#/notification/list')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { frame: true, titleBarStyle: 'default' }),
            };
        }
        else if (url.includes('#/setting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 800, height: 600, title: '设置', trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        else if (url.includes('#/invite')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { frame: true, titleBarStyle: 'default', width: 498, height: 520 }),
            };
        }
        else if (url.includes('#/member')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { frame: true, titleBarStyle: 'default', width: 400, height: 600 }),
            };
        }
        else if (url.includes('#/chat')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { titleBarStyle: 'hidden', frame: !isLinux }),
            };
        }
        else if (url.includes('#/transcriptionInMeeting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { titleBarStyle: 'default', frame: true, width: 400, height: 600 }),
            };
        }
        else if (url.includes('#/monitoring')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { height: 300, width: 455, trafficLightPosition: {
                        x: 16,
                        y: 19,
                    } }),
            };
        }
        else if (url.includes('#/about')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { height: 460 }),
            };
        }
        else if (url.includes('#/screenSharing/screenMarker')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { height: 100, width: 100, autoHideMenuBar: true, hiddenInMissionControl: true, title: '', transparent: true, hasShadow: false, resizable: false, minimizable: false, skipTaskbar: true, show: false }),
            };
        }
        else if (url.includes('#/annotation')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { height: 100, width: 100, autoHideMenuBar: true, hiddenInMissionControl: true, title: '', transparent: true, hasShadow: false, resizable: false, minimizable: false, skipTaskbar: true, enableLargerThanScreen: true, 
                    // 避免 win 下，透明窗口影响底下窗口渲染
                    type: 'toolbar' }),
            };
        }
        else if (url.includes('#/interpreterSetting')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 520, height: 543, trafficLightPosition: {
                        x: 10,
                        y: 13,
                    } }),
            };
        }
        else if (url.includes('#/interpreterWindow')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { maximizable: false, titleBarStyle: 'hidden', frame: !isLinux, minimizable: false, fullscreenable: false, transparent: true, alwaysOnTop: 'screen-saver', resizable: false, skipTaskbar: true, width: 220, height: 350, x: 42, y: 42 }),
            };
        }
        else if (url.includes('#/captionWindow')) {
            var mousePosition = screen.getCursorScreenPoint();
            var nowDisplay = screen.getDisplayNearestPoint(mousePosition);
            var _b = nowDisplay.workArea, x = _b.x, width = _b.width, height = _b.height;
            var minWidth = 492;
            var minHeight = 128;
            var commonOptions_1 = {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions_1), { maximizable: false, titleBarStyle: 'hidden', frame: !isLinux, minimizable: false, fullscreenable: false, hasShadow: false, alwaysOnTop: 'screen-saver', resizable: true, skipTaskbar: true, minHeight: minHeight, minWidth: minWidth, width: minWidth, height: minHeight, x: Math.round(x + (width - minWidth) / 2), y: height - minHeight }),
            };
            if (isWin32 || isLinux) {
                commonOptions_1.overrideBrowserWindowOptions = __assign(__assign({}, commonOptions_1.overrideBrowserWindowOptions), { transparent: true });
            }
            else {
                commonOptions_1.overrideBrowserWindowOptions = __assign(__assign({}, commonOptions_1.overrideBrowserWindowOptions), { backgroundColor: 'rgba(0, 0, 0, 0.01)', roundedCorners: false });
            }
            return commonOptions_1;
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
        else if (url.includes('#/bulletScreenMessage')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 350, height: 400, transparent: isWin32 || isLinux, roundedCorners: false, backgroundColor: 'rgba(0, 0, 0, 0.01)', skipTaskbar: true }),
            };
        }
        else if (url.includes('#/live')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { width: 904, height: 638 }),
            };
        }
        else if (url.includes('#/dualMonitors')) {
            return {
                action: 'allow',
                overrideBrowserWindowOptions: __assign(__assign({}, commonOptions), { maximizable: true, minimizable: true, resizable: true, fullscreenable: false, fullscreen: false, width: 904, height: 638, minWidth: 904, minHeight: 638 }),
            };
        }
        return { action: 'deny' };
    });
    mainWindow.webContents.on('did-create-window', function (newWin, _a) {
        // newWin.setParentWindow(mainWindow);
        var _b, _c;
        var originalUrl = _a.url;
        var url = originalUrl.replace(/.*?(?=#)/, '');
        newWins[url] = newWin;
        // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
        newWin.on('close', function (event) {
            mainWindow.webContents.send("windowClosed:".concat(url));
            var needDelay = url.includes('/annotation');
            // 通过隐藏处理关闭，关闭有一定概率崩溃
            setTimeout(function () {
                if (newWin.isDestroyed())
                    return;
                newWin.hide();
            }, needDelay ? 1000 : 0);
            event.preventDefault();
        });
        if (url.includes('interpreterWindow')) {
            (_b = newWin.setWindowButtonVisibility) === null || _b === void 0 ? void 0 : _b.call(newWin, false);
            newWin.setAlwaysOnTop(true, 'screen-saver', 100);
        }
        else if (url.includes('captionWindow')) {
            (_c = newWin.setWindowButtonVisibility) === null || _c === void 0 ? void 0 : _c.call(newWin, false);
            newWin.setAlwaysOnTop(true, 'screen-saver');
            // 需要设置最小否则可以拖拽消失
            if (isLinux) {
                newWin.setMinimumSize(429, 128);
                newWin.on('maximize', function (event) {
                    event.preventDefault();
                    return false;
                });
            }
            newWin.on('will-resize', function (event, newBounds) {
                event.preventDefault();
                newWin.setBounds({
                    width: Math.max(newBounds.width, 492),
                });
            });
        }
        // windows下alt键会触发菜单栏，需要屏蔽
        if (isWin32) {
            newWin.webContents.on('before-input-event', function (event, input) {
                if (input.alt) {
                    event.preventDefault();
                }
            });
        }
        openNewWindow(url);
        //newWin.webContents.openDevTools()
    });
}
module.exports = {
    openNewWindow: openNewWindow,
    setWindowOpenHandler: setWindowOpenHandler,
    newWins: newWins,
};