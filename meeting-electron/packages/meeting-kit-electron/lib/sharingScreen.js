"use strict";
var _a = require('electron'), BrowserWindow = _a.BrowserWindow, ipcMain = _a.ipcMain, screen = _a.screen;
var path = require('path');
var isLocal = process.env.ENV_MODE === 'local';
var isWin32 = process.platform === 'win32';
var MEETING_HEADER_HEIGHT = 28;
var NOTIFY_WINDOW_WIDTH = 408;
var NOTIFY_WINDOW_HEIGHT = 200;
var COLLAPSE_WINDOW_WIDTH = 350;
var WINDOW_WIDTH = 1080;
var MEETING_CONTROL_BAR_FOLD_HEIGHT = 44;
var MEETING_CONTROL_BAR_UNFOLD_HEIGHT = 64;
var isLinux = process.platform === 'linux';
var mY = 0;
var memberNotifyTimer = null;
var mainWindowAlwaysOnTopTimer;
var sharingScreen = {
    isSharing: false,
    memberNotifyWindow: null,
    shareScreen: null,
};
var closeScreenSharingWindow = function () {
    ipcMain.removeAllListeners('nemeeting-sharing-screen');
    closeMemberNotifyWindow();
};
function createNotifyWindow(mainWindow) {
    if (sharingScreen.memberNotifyWindow &&
        !sharingScreen.memberNotifyWindow.isDestroyed()) {
        return;
    }
    var nowDisplay = screen.getPrimaryDisplay();
    var _a = nowDisplay.workArea, x = _a.x, y = _a.y, width = _a.width, height = _a.height;
    sharingScreen.memberNotifyWindow = new BrowserWindow({
        width: NOTIFY_WINDOW_WIDTH,
        height: NOTIFY_WINDOW_HEIGHT,
        x: Math.round(width + NOTIFY_WINDOW_WIDTH),
        y: Math.round(height + NOTIFY_WINDOW_HEIGHT),
        titleBarStyle: 'hidden',
        frame: !isLinux,
        maximizable: false,
        minimizable: false,
        fullscreenable: false,
        closable: false,
        resizable: false,
        skipTaskbar: true,
        transparent: true,
        show: false,
        hasShadow: false,
        webPreferences: {
            webSecurity: false,
            contextIsolation: false,
            nodeIntegration: true,
            preload: path.join(__dirname, './ipc.js'),
        },
    });
    var notifyWindow = sharingScreen.memberNotifyWindow;
    // 先强制保护窗口内容，避免共享被捕获
    notifyWindow.setContentProtection(true);
    if (isLocal) {
        notifyWindow.loadURL('https://localhost:8000/#/memberNotify');
    }
    else {
        notifyWindow.loadFile(path.join(__dirname, '../build/index.html'), {
            hash: 'memberNotify',
        });
    }
    notifyWindow.setAlwaysOnTop(true, 'screen-saver');
    notifyWindow.show();
    setTimeout(function () {
        setNotifyWindowPosition(width, height);
    });
    if (isWin32) {
        ipcMain.on('member-notify-mousemove', function () {
            if (memberNotifyTimer) {
                clearNotifyWIndowTimeout();
            }
        });
    }
    ipcMain.on('notify-show', function (event, arg) {
        var _a, _b;
        (_a = sharingScreen.memberNotifyWindow) === null || _a === void 0 ? void 0 : _a.webContents.send('notify-show', arg);
        (_b = sharingScreen.memberNotifyWindow) === null || _b === void 0 ? void 0 : _b.setPosition(Math.round(width - NOTIFY_WINDOW_WIDTH), Math.round(height - NOTIFY_WINDOW_HEIGHT));
        if (isWin32) {
            clearNotifyWIndowTimeout();
            memberNotifyTimer = setTimeout(function () {
                setNotifyWindowPosition(width, height);
            }, 5000);
        }
    });
    ipcMain.on('notify-hide', function (event, arg) {
        var _a;
        (_a = sharingScreen.memberNotifyWindow) === null || _a === void 0 ? void 0 : _a.webContents.send('notify-hide', arg);
        setNotifyWindowPosition(width, height);
    });
    ipcMain.on('member-notify-view-member-msg', function (event, arg) {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('member-notify-view-member-msg');
    });
    ipcMain.on('member-notify-close', function (event, arg) {
        // mainWindow?.webContents.send('member-notify-close')
        setNotifyWindowPosition(width, height);
    });
    ipcMain.on('member-notify-not-notify', function (event, arg) {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('member-notify-not-notify');
        setNotifyWindowPosition(width, height);
    });
    sharingScreen.memberNotifyWindow.on('destroyed', function (event) {
        removeMemberNotifyListener();
        sharingScreen.memberNotifyWindow = null;
    });
}
function setNotifyWindowPosition(width, height) {
    if (sharingScreen.memberNotifyWindow &&
        !sharingScreen.memberNotifyWindow.isDestroyed()) {
        sharingScreen.memberNotifyWindow.setPosition(Math.round(width + NOTIFY_WINDOW_WIDTH), Math.round(height + NOTIFY_WINDOW_HEIGHT));
    }
    clearNotifyWIndowTimeout();
}
function clearNotifyWIndowTimeout() {
    memberNotifyTimer && clearTimeout(memberNotifyTimer);
    memberNotifyTimer = null;
}
function removeMemberNotifyListener() {
    ipcMain.removeAllListeners('notify-show');
    ipcMain.removeAllListeners('notify-hide');
    ipcMain.removeAllListeners('member-notify-view-member-msg');
    ipcMain.removeAllListeners('member-notify-close');
    ipcMain.removeAllListeners('member-notify-not-notify');
    if (isWin32) {
        ipcMain.removeAllListeners('member-notify-mousemove');
    }
}
function closeMemberNotifyWindow() {
    var _a;
    (_a = sharingScreen.memberNotifyWindow) === null || _a === void 0 ? void 0 : _a.destroy();
    sharingScreen.memberNotifyWindow = null;
    removeMemberNotifyListener();
    memberNotifyTimer && clearTimeout(memberNotifyTimer);
    memberNotifyTimer = null;
}
function addScreenSharingIpc(_a) {
    var mainWindow = _a.mainWindow, initMainWindowSize = _a.initMainWindowSize;
    var shareScreen = null;
    // 用来改变工具栏视图的高度
    var mainHeight = [MEETING_CONTROL_BAR_UNFOLD_HEIGHT];
    function mainWindowCenter(mainWindow) {
        // const nowDisplay = shareScreen || screen.getPrimaryDisplay()
        var nowDisplay = screen.getPrimaryDisplay();
        var _a = nowDisplay.workArea, x = _a.x, width = _a.width;
        var mainWindowWidth = mainWindow.getBounds().width;
        mainWindow.setBounds({
            x: Math.floor(x + width / 2 - mainWindowWidth / 2),
            y: mY,
        });
    }
    function removeMainHeight(height) {
        var index = mainHeight.findIndex(function (item) { return item === height; });
        if (index !== -1) {
            mainHeight.splice(index, 1);
        }
    }
    function setMainWindowHeight() {
        if (!mainWindow || mainWindow.isDestroyed()) {
            return;
        }
        var height = Math.max.apply(null, mainHeight);
        // 如果高度没有超过 100 ， 说明是工具栏的高度，不需要改变主窗口的高度。 只有 40 ， 60  两种
        if (height < 100) {
            height = mainHeight[mainHeight.length - 1];
        }
        if (sharingScreen.isSharing) {
            mainWindow.setBounds({
                height: height,
            });
        }
        if (height === MEETING_CONTROL_BAR_UNFOLD_HEIGHT) {
            mainWindow.setBounds({
                width: WINDOW_WIDTH,
            });
        }
        else if (height === MEETING_CONTROL_BAR_FOLD_HEIGHT) {
            mainWindow.setBounds({
                width: COLLAPSE_WINDOW_WIDTH,
            });
        }
        else {
            mainWindow.setBounds({
                width: WINDOW_WIDTH,
            });
        }
        // mainWindow.center();
        mainWindowCenter(mainWindow);
    }
    ipcMain.on('nemeeting-sharing-screen', function (event, value) {
        var _a, _b;
        var method = value.method, data = value.data;
        switch (method) {
            case 'start': {
                sharingScreen.isSharing = true;
                // 先强制保护窗口内容，避免共享被捕获
                mainWindow.setContentProtection(true);
                // const nowDisplay = shareScreen || screen.getPrimaryDisplay()
                var nowDisplay = screen.getPrimaryDisplay();
                var _c = nowDisplay.workArea, x = _c.x, y = _c.y, width = _c.width;
                mainWindow.setOpacity(0);
                setTimeout(function () {
                    mainWindow.setOpacity(1);
                }, 800);
                createNotifyWindow(mainWindow);
                mainWindow.setMinimizable(false);
                mainWindow.setMinimumSize(1, 1);
                (_a = mainWindow.setWindowButtonVisibility) === null || _a === void 0 ? void 0 : _a.call(mainWindow, false);
                mainWindow.setHasShadow(false);
                mainWindow.setResizable(false);
                var mainWidth = 760;
                var mainX = x + width / 2 - mainWidth / 2;
                // 记录主窗口的y坐标
                mY = y;
                mainWindow.setBounds({
                    x: Math.round(mainX),
                    y: y,
                    width: WINDOW_WIDTH,
                });
                mainWindow.setMovable(true);
                mainHeight = [MEETING_CONTROL_BAR_UNFOLD_HEIGHT];
                setMainWindowHeight();
                mainWindow.setAlwaysOnTop(true, 'normal', 100);
                break;
            }
            case 'share-screen': {
                shareScreen = screen.getAllDisplays()[data];
                sharingScreen.shareScreen = shareScreen;
                screen.on('display-removed', function (_, data) {
                    var isSameDisplay = data.label === (shareScreen === null || shareScreen === void 0 ? void 0 : shareScreen.label);
                    if (isSameDisplay) {
                        // TODO: 退出共享
                    }
                });
                break;
            }
            case 'stop':
                closeMemberNotifyWindow();
                if (sharingScreen.isSharing && !mainWindow.isDestroyed()) {
                    if (!(data === null || data === void 0 ? void 0 : data.immediately)) {
                        mainWindow.setOpacity(0);
                        setTimeout(function () {
                            if (mainWindow.isDestroyed())
                                return;
                            mainWindow.setOpacity(1);
                        }, 800);
                    }
                    shareScreen = null;
                    sharingScreen.isSharing = false;
                    mainWindow.setMinimizable(true);
                    (_b = mainWindow.setWindowButtonVisibility) === null || _b === void 0 ? void 0 : _b.call(mainWindow, true);
                    mainWindow.setHasShadow(true);
                    mainWindow.setAlwaysOnTop(false);
                    mainWindow.setResizable(true);
                    initMainWindowSize();
                    mainWindow.show();
                    if (mainWindowAlwaysOnTopTimer) {
                        clearInterval(mainWindowAlwaysOnTopTimer);
                        mainWindowAlwaysOnTopTimer = null;
                    }
                }
                // 先强制结束内容保护
                mainWindow.setContentProtection(false);
                break;
            case 'startAnnotation':
                if (isWin32) {
                    mainWindowAlwaysOnTopTimer = setInterval(function () {
                        if (mainWindow && !mainWindow.isDestroyed()) {
                            mainWindow.setAlwaysOnTop(true, 'normal', 100);
                        }
                        else {
                            clearInterval(mainWindowAlwaysOnTopTimer);
                            mainWindowAlwaysOnTopTimer = null;
                        }
                    }, 1000);
                }
                break;
            case 'stopAnnotation':
                if (mainWindowAlwaysOnTopTimer) {
                    clearInterval(mainWindowAlwaysOnTopTimer);
                    mainWindowAlwaysOnTopTimer = null;
                }
                break;
            case 'controlBarVisibleChangeByMouse':
                if (sharingScreen.isSharing) {
                    if (data.width && data.width > 500 && WINDOW_WIDTH !== data.width) {
                        WINDOW_WIDTH = data.width;
                    }
                    if (data.open) {
                        mainWindow.setBounds({
                            width: WINDOW_WIDTH,
                        });
                        removeMainHeight(MEETING_CONTROL_BAR_UNFOLD_HEIGHT);
                        mainHeight.push(MEETING_CONTROL_BAR_UNFOLD_HEIGHT);
                        setMainWindowHeight(true);
                    }
                    else {
                        mainWindow.setBounds({
                            width: COLLAPSE_WINDOW_WIDTH,
                        });
                        removeMainHeight(MEETING_CONTROL_BAR_FOLD_HEIGHT);
                        mainHeight.push(MEETING_CONTROL_BAR_FOLD_HEIGHT);
                        setMainWindowHeight(true);
                    }
                    mainWindowCenter(mainWindow);
                }
                break;
            case 'openDeviceList':
                if (sharingScreen.isSharing) {
                    mainHeight.push(800);
                    setMainWindowHeight();
                }
                break;
            case 'closeDeviceList':
                if (sharingScreen.isSharing) {
                    removeMainHeight(800);
                    setMainWindowHeight(true);
                }
                break;
            case 'openPopover':
                mainHeight.push(150);
                setMainWindowHeight(true);
                break;
            case 'closePopover':
                removeMainHeight(150);
                setMainWindowHeight(true);
                break;
            case 'openModal':
                if (sharingScreen.isSharing) {
                    mainHeight.push(300);
                    setMainWindowHeight();
                }
                break;
            case 'closeModal':
                if (sharingScreen.isSharing) {
                    removeMainHeight(300);
                    setMainWindowHeight(true);
                }
                break;
            case 'openToast':
                if (sharingScreen.isSharing) {
                    mainHeight.push(120);
                    setMainWindowHeight();
                }
                event.sender.send('nemeeting-sharing-screen', {
                    method: method,
                    data: sharingScreen.isSharing,
                });
                break;
            case 'closeToast':
                if (sharingScreen.isSharing) {
                    removeMainHeight(120);
                    setMainWindowHeight(true);
                }
                break;
            case 'videoWindowHeightChange': {
                var height = data.height;
                var videoWindow = BrowserWindow.fromWebContents(event.sender);
                if (videoWindow) {
                    videoWindow === null || videoWindow === void 0 ? void 0 : videoWindow.setBounds({
                        height: Math.round(height + MEETING_HEADER_HEIGHT),
                    });
                }
                break;
            }
            default:
                break;
        }
    });
}
module.exports = {
    sharingScreen: sharingScreen,
    closeScreenSharingWindow: closeScreenSharingWindow,
    addScreenSharingIpc: addScreenSharingIpc,
};