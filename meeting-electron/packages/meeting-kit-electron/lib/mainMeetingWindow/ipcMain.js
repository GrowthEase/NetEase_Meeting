"use strict";
var _a = require('electron'), ipcMain = _a.ipcMain, BrowserWindow = _a.BrowserWindow, screen = _a.screen;
var _b = require('./childWindow'), newWins = _b.newWins, openNewWindow = _b.openNewWindow;
var _c = require('../constant'), MINI_WIDTH = _c.MINI_WIDTH, MINI_HEIGHT = _c.MINI_HEIGHT, isWin32 = _c.isWin32;
var _d = require('../utils/popup'), showElectronPopover = _d.showElectronPopover, hideElectronPopover = _d.hideElectronPopover, updateElectronPopover = _d.updateElectronPopover;
var EventType = {
    OpenChatroomOrMemberList: 'openChatroomOrMemberList',
    OpenChatroomOrMemberListReply: 'openChatroomOrMemberList-reply',
    FocusWindow: 'focusWindow',
    AnnotationWindow: 'annotationWindow',
    InterpreterWindowChange: 'interpreterWindowChange',
    CaptionWindowChange: 'captionWindowChange',
    ChangeSetting: 'changeSetting',
    IgnoreMouseEvents: 'ignoreMouseEvents',
    ShowPopover: 'showPopover',
    HidePopover: 'hidePopover',
    UpdatePopover: 'updatePopover',
};
var currentWindow = null;
var preFloatingWindow = false;
function focusWindow(event, url) {
    var win = BrowserWindow.fromWebContents(event.sender);
    if (win === currentWindow) {
        if (url === 'mainWindow') {
            win.show();
        }
        else if (newWins[url] && !newWins[url].isDestroyed()) {
            openNewWindow(url);
            newWins[url].show();
        }
    }
}
function changeSetting(_, setting) {
    if (currentWindow && !currentWindow.isDestroyed()) {
        currentWindow.webContents.send('changeSetting', setting);
    }
    Object.values(newWins).forEach(function (win) {
        if (win && !win.isDestroyed()) {
            win.webContents.send('changeSetting', setting);
        }
    });
}
var annotationWindowSetBoundsTimer = null;
function annotationWindow(_, data) {
    var annotationWindow = newWins['#/annotation'];
    if (annotationWindow && !annotationWindow.isDestroyed()) {
        var event = data.event, payload_1 = data.payload;
        if (event === 'setBounds') {
            if (!isWin32) {
                var primaryDisplay = screen.getPrimaryDisplay();
                payload_1.y =
                    primaryDisplay.bounds.y +
                        primaryDisplay.bounds.height -
                        payload_1.height -
                        payload_1.y;
            }
            if (payload_1.width < 60 || payload_1.height < 60) {
                annotationWindow.setOpacity(0);
            }
            else {
                annotationWindow.setOpacity(1);
                if (isWin32) {
                    if (annotationWindowSetBoundsTimer) {
                        clearTimeout(annotationWindowSetBoundsTimer);
                        annotationWindowSetBoundsTimer = null;
                    }
                    var mousePosition = screen.getCursorScreenPoint();
                    var nowDisplay = screen.getDisplayNearestPoint(mousePosition);
                    var scaleFactor_1 = nowDisplay.scaleFactor;
                    annotationWindowSetBoundsTimer = setTimeout(function () {
                        payload_1.x = Math.round(payload_1.x / scaleFactor_1);
                        payload_1.y = Math.round(payload_1.y / scaleFactor_1);
                        payload_1.width = Math.round(payload_1.width / scaleFactor_1);
                        payload_1.height = Math.round(payload_1.height / scaleFactor_1);
                        annotationWindow.setBounds(payload_1, true);
                    }, 300);
                }
                else {
                    annotationWindow.setBounds(payload_1);
                }
            }
        }
        else if (event === 'setIgnoreMouseEvents') {
            annotationWindow.setIgnoreMouseEvents(payload_1);
        }
    }
}
function captionWindowChange(_, data) {
    var newWin = newWins['#/captionWindow'];
    if (!newWin) {
        console.log('captionWindowChange: newWin is null');
    }
    var height = data.height;
    newWin.setBounds({
        height: height,
    });
}
function interpreterWindowChange(_, data) {
    var newWin = newWins['#/interpreterWindow'];
    if (!newWin) {
        console.log('interpreterWindowChange: newWin is null');
    }
    var width = data.width, height = data.height, floatingWindow = data.floatingWindow;
    var nowDisplay = screen.getPrimaryDisplay();
    var _a = nowDisplay.workArea, workWidth = _a.width, workHeight = _a.height;
    if (floatingWindow) {
        newWin.setBounds({
            x: workWidth - 42,
            y: workHeight - 230,
            width: width,
            height: height,
        });
    }
    else {
        if (preFloatingWindow) {
            newWin.setBounds({
                x: workWidth - 225,
                y: workHeight - 390,
                width: width,
                height: height,
            });
        }
        else {
            newWin.setBounds({
                width: width,
                height: height,
            });
        }
    }
    preFloatingWindow = floatingWindow;
}
var setIgnoreMouseEventsTimer = null;
function handleIgnoreMouseEvents(event, data) {
    var win = BrowserWindow.fromWebContents(event.sender);
    setIgnoreMouseEventsTimer && clearTimeout(setIgnoreMouseEventsTimer);
    if (data) {
        win.setIgnoreMouseEvents(true, { forward: true });
        setIgnoreMouseEventsTimer = setTimeout(function () {
            win.setIgnoreMouseEvents(false, { forward: true });
        }, 1000);
    }
    else {
        win.setIgnoreMouseEvents(false, { forward: true });
    }
}
function showPopover(event, items) {
    var mainWindow = BrowserWindow.fromWebContents(event.sender);
    showElectronPopover(items, mainWindow);
}
function hidePopover() {
    hideElectronPopover();
}
function updatePopover(event, items) {
    var mainWindow = BrowserWindow.fromWebContents(event.sender);
    updateElectronPopover(items, mainWindow);
}
function addIpcMainListeners(window) {
    currentWindow = window;
    // let alreadySetWidth = false
    ipcMain.on(EventType.FocusWindow, focusWindow);
    ipcMain.on(EventType.AnnotationWindow, annotationWindow);
    ipcMain.on(EventType.InterpreterWindowChange, interpreterWindowChange);
    ipcMain.on(EventType.CaptionWindowChange, captionWindowChange);
    ipcMain.on(EventType.OpenChatroomOrMemberList, function (event, isOpen) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        if (!mainWindow) {
            return;
        }
        if (isOpen) {
            mainWindow.setMinimumSize(MINI_WIDTH + 320, MINI_HEIGHT);
        }
        else {
            mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT);
        }
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send('openChatroomOrMemberList-reply', isOpen);
        // resize结束通知渲染进程
        if ((mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isFullScreen()) ||
            (mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isMaximized()) ||
            (mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isFullScreenPrivate) ||
            (mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isMaximizedPrivate)) {
            return;
        }
        var mainWindowBounds = mainWindow.getBounds();
        var _a = screen.getDisplayMatching(mainWindowBounds).workArea, displayX = _a.x, displayW = _a.width; // 鼠标所在屏幕的大小
        var mainX = mainWindowBounds.x, mainW = mainWindowBounds.width; // 当前窗口的大小
        if (isOpen) {
            // alreadySetWidth = true
            var newWidth = mainW + 320;
            var exceedW = newWidth + mainX - (displayX + displayW);
            if (exceedW > 0) {
                mainWindow.setBounds({
                    x: Math.round(mainX - exceedW),
                    width: Math.round(newWidth),
                });
            }
            else {
                mainWindow.setBounds({
                    width: Math.round(newWidth),
                });
            }
        }
        else {
            // alreadySetWidth = false
            mainWindow.setBounds({ width: Math.round(mainW - 320) });
        }
        event.sender.send(EventType.OpenChatroomOrMemberListReply);
    });
    ipcMain.on(EventType.ChangeSetting, changeSetting);
    ipcMain.on(EventType.IgnoreMouseEvents, handleIgnoreMouseEvents);
    ipcMain.on(EventType.ShowPopover, showPopover);
    ipcMain.on(EventType.HidePopover, hidePopover);
    ipcMain.on(EventType.UpdatePopover, updatePopover);
}
function removeIpcMainListeners() {
    ipcMain.removeListener(EventType.FocusWindow, focusWindow);
    ipcMain.removeListener(EventType.AnnotationWindow, annotationWindow);
    ipcMain.removeListener(EventType.InterpreterWindowChange, interpreterWindowChange);
    ipcMain.removeListener(EventType.CaptionWindowChange, captionWindowChange);
    ipcMain.removeListener(EventType.changeSetting, changeSetting);
    ipcMain.removeAllListeners(EventType.OpenChatroomOrMemberList);
    ipcMain.removeListener(EventType.IgnoreMouseEvents, handleIgnoreMouseEvents);
    ipcMain.removeListener(EventType.ShowPopover, showPopover);
    ipcMain.removeListener(EventType.HidePopover, hidePopover);
    ipcMain.removeListener(EventType.UpdatePopover, updatePopover);
}
module.exports = {
    addIpcMainListeners: addIpcMainListeners,
    removeIpcMainListeners: removeIpcMainListeners,
};