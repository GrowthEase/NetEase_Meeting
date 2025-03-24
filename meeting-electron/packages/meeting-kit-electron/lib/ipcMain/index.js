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
var __values = (this && this.__values) || function(o) {
    var s = typeof Symbol === "function" && Symbol.iterator, m = s && o[s], i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
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
var _a = require('electron'), app = _a.app, ipcMain = _a.ipcMain, dialog = _a.dialog, BrowserWindow = _a.BrowserWindow, nativeTheme = _a.nativeTheme, shell = _a.shell, systemPreferences = _a.systemPreferences;
var promisify = require('util').promisify;
var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var os = require('os');
var si = require('systeminformation');
var sizeOf = require('image-size');
var isWin32 = require('../constant').isWin32;
var EventType = {
    Beauty: 'nemeeting-beauty',
    AddVirtualBackgroundReply: 'addVirtualBackground-reply',
    Relaunch: 'relaunch',
    MaximizeWindow: 'maximize-window',
    MinimizeWindow: 'minimize-window',
    GetImageBase64: 'nemeeting-get-image-base64',
    ExitApp: 'exit-app',
    GetLogPath: 'getLogPath',
    SaveAvatarToPath: 'saveAvatarToPath',
    NoPermission: 'no-permission',
    getSystemManufacturer: 'get-system-manufacturer',
    getThemeColor: 'get-theme-color',
    downloadFileByUrl: 'download-file-by-url',
    DownloadPath: 'nemeeting-download-path',
    DownloadPathReply: 'nemeeting-download-path-reply',
    FileSaveAs: 'nemeeting-file-save-as',
    FileSaveAsReply: 'nemeeting-file-save-as-reply',
    openFile: 'nemeeting-open-file',
    openFileReply: 'nemeeting-open-file-reply',
    DeleteDirectory: 'nemeeting-delete-directory',
    chooseFile: 'nemeeting-choose-file',
    chooseFileDone: 'nemeeting-choose-file-done',
    openBrowserWindow: 'open-browser-window',
    FlushStorageData: 'flushStorageData',
    QuiteFullscreen: 'leave-full-screen',
    EnterFullscreen: 'enter-full-screen',
    IsMainFullScreen: 'isMainFullScreen',
    IsMaximized: 'isMaximized',
    GetDeviceAccessStatus: 'getDeviceAccessStatus',
    GetVirtualBackground: 'getVirtualBackground',
    GetCoverImage: 'getCoverImage',
    OpenDevTools: 'openDevTools',
    CheckDiskSpace: 'check-disk-space',
    GetMeetingRecordPath: 'local-record-meetingid-path'
};
var tagNEBackgroundSourceType = {
    kNEBackgroundColor: 1, /**< 背景图像为纯色（默认） */
    kNEBackgroundImage: 2, /**< 背景图像只支持 PNG 或 JPG 格式的文件 */
    kNEBackgroundVideo: 4, /**< 背景图像只支持 mov 或  mp4 格式的文件 */
};
var readFileAsync = promisify(fs.readFile);
var readDirAsync = promisify(fs.readdir);
var isLinux = process.platform === 'linux';
var virtualBackgroundList = [];
function getVirtualBackground() {
    return __awaiter(this, arguments, void 0, function (forceUpdate, event) {
        var userDataPath, virtualBackgroundDirPath, defaultVirtualBackgroundPath, virtualBackgroundFileList, virtualBackgroundFileList_1, virtualBackgroundFileList_1_1, item, filePath, isDefault, ext, base64Prefix, data, base64Image, e_1_1;
        var e_1, _a;
        if (forceUpdate === void 0) { forceUpdate = false; }
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    userDataPath = app.getPath('userData');
                    if (virtualBackgroundList &&
                        virtualBackgroundList.length > 0 &&
                        !forceUpdate) {
                        return [2 /*return*/, virtualBackgroundList];
                    }
                    virtualBackgroundList = [];
                    virtualBackgroundDirPath = path.join(userDataPath, 'virtualBackground');
                    if (!fs.existsSync(virtualBackgroundDirPath)) {
                        fs.mkdirSync(virtualBackgroundDirPath);
                    }
                    fs.readdirSync(virtualBackgroundDirPath).map(function (item) {
                        var filePath = path.join(virtualBackgroundDirPath, item);
                        var isDefault = path.basename(filePath).includes('default');
                        var ext = path.extname(filePath);
                        var isImage = ext === '.png' || ext === '.jpg' || ext === '.jpeg';
                        //win系统下，对视频文件存在引用，不能直接删除
                        if (isDefault && isImage) {
                            fs.unlinkSync(filePath);
                        }
                    });
                    defaultVirtualBackgroundPath = path.join(__dirname, '../assets/virtual/');
                    fs.readdirSync(defaultVirtualBackgroundPath).forEach(function (item) {
                        var filePath = path.join(defaultVirtualBackgroundPath, item);
                        fs.copyFileSync(filePath, path.join(virtualBackgroundDirPath, item));
                    });
                    return [4 /*yield*/, readDirAsync(virtualBackgroundDirPath)];
                case 1:
                    virtualBackgroundFileList = _b.sent();
                    virtualBackgroundFileList = virtualBackgroundFileList.filter(function (item) {
                        return ['.png', '.jpg', '.jpeg', '.mov', '.mp4', '.MOV', '.MP4'].includes(path.extname(item));
                    });
                    _b.label = 2;
                case 2:
                    _b.trys.push([2, 8, 9, 10]);
                    virtualBackgroundFileList_1 = __values(virtualBackgroundFileList), virtualBackgroundFileList_1_1 = virtualBackgroundFileList_1.next();
                    _b.label = 3;
                case 3:
                    if (!!virtualBackgroundFileList_1_1.done) return [3 /*break*/, 7];
                    item = virtualBackgroundFileList_1_1.value;
                    filePath = path.join(virtualBackgroundDirPath, item);
                    isDefault = path.basename(filePath).includes('default');
                    ext = path.extname(filePath);
                    if (!(ext === '.mov' || ext === '.mp4' || ext === '.MOV' || ext === '.MP4')) return [3 /*break*/, 4];
                    virtualBackgroundList.push({
                        src: filePath,
                        path: filePath,
                        isDefault: isDefault,
                        type: 'video',
                    });
                    return [3 /*break*/, 6];
                case 4:
                    base64Prefix = "data:image/".concat(path
                        .extname(filePath)
                        .substring(1), ";base64,");
                    return [4 /*yield*/, readFileAsync(filePath, 'base64')];
                case 5:
                    data = _b.sent();
                    base64Image = base64Prefix + data;
                    virtualBackgroundList.push({
                        src: base64Image,
                        path: filePath,
                        isDefault: isDefault,
                        type: 'image',
                    });
                    _b.label = 6;
                case 6:
                    virtualBackgroundFileList_1_1 = virtualBackgroundFileList_1.next();
                    return [3 /*break*/, 3];
                case 7: return [3 /*break*/, 10];
                case 8:
                    e_1_1 = _b.sent();
                    e_1 = { error: e_1_1 };
                    return [3 /*break*/, 10];
                case 9:
                    try {
                        if (virtualBackgroundFileList_1_1 && !virtualBackgroundFileList_1_1.done && (_a = virtualBackgroundFileList_1.return)) _a.call(virtualBackgroundFileList_1);
                    }
                    finally { if (e_1) throw e_1.error; }
                    return [7 /*endfinally*/];
                case 10:
                    event === null || event === void 0 ? void 0 : event.sender.send('nemeeting-beauty-virtual-background', virtualBackgroundList);
                    return [2 /*return*/, virtualBackgroundList];
            }
        });
    });
}
function getCoverImage(dirNmae, filePath) {
    return __awaiter(this, void 0, void 0, function () {
        var userDataPath, coverImageList, coverImageDirPath_1, localRecordDirPath, defaultCoverImagePath_1, coverImageFileList, coverImageFileList_1, coverImageFileList_1_1, item, tempFilePath, isDefaultConver, e_2;
        var e_3, _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    _b.trys.push([0, 2, , 3]);
                    console.log('getCoverImage() dirNmae: ', dirNmae, ', filePath: ', filePath);
                    userDataPath = app.getPath('userData');
                    console.log('getCoverImage() userDataPath: ', userDataPath);
                    coverImageList = [];
                    coverImageDirPath_1 = path.join(userDataPath, 'localRecordCoverImage');
                    console.log('getCoverImage() coverImageDirPath: ', coverImageDirPath_1);
                    if (!filePath) {
                        filePath = app.getPath('downloads');
                    }
                    else if (!fs.existsSync(filePath)) {
                        console.warn('设置的录制文件文件不存在,使用默认下载路径');
                        filePath = app.getPath('downloads');
                    }
                    console.log('getCoverImage() filePath: ', filePath);
                    localRecordDirPath = path.join(filePath, dirNmae);
                    console.log('getCoverImage() localRecordDirPath: ', localRecordDirPath);
                    if (!fs.existsSync(localRecordDirPath)) {
                        fs.mkdirSync(localRecordDirPath);
                    }
                    if (!fs.existsSync(coverImageDirPath_1)) {
                        fs.mkdirSync(coverImageDirPath_1);
                    }
                    console.log('getCoverImage() coverImageDirPath: ', coverImageDirPath_1);
                    //删除原目标目录的所有文件资源
                    fs.readdirSync(coverImageDirPath_1).map(function (item) {
                        var tempPath = path.join(coverImageDirPath_1, item);
                        var isCover = path.basename(tempPath).includes('Cover');
                        if (isCover) {
                            fs.unlinkSync(tempPath);
                        }
                    });
                    defaultCoverImagePath_1 = path.join(__dirname, '../assets/localRecord/');
                    console.log('getCoverImage() defaultCoverImagePath: ', defaultCoverImagePath_1);
                    fs.readdirSync(defaultCoverImagePath_1).forEach(function (item) {
                        var tempFilePath = path.join(defaultCoverImagePath_1, item);
                        fs.copyFileSync(tempFilePath, path.join(coverImageDirPath_1, item));
                    });
                    return [4 /*yield*/, readDirAsync(coverImageDirPath_1)];
                case 1:
                    coverImageFileList = _b.sent();
                    console.log('getCoverImage() coverImageFileList: ', coverImageFileList);
                    coverImageFileList = coverImageFileList.filter(function (item) {
                        return ['.png', '.jpg', '.jpeg', '.mov', '.mp4', '.MOV', '.MP4'].includes(path.extname(item));
                    });
                    try {
                        for (coverImageFileList_1 = __values(coverImageFileList), coverImageFileList_1_1 = coverImageFileList_1.next(); !coverImageFileList_1_1.done; coverImageFileList_1_1 = coverImageFileList_1.next()) {
                            item = coverImageFileList_1_1.value;
                            tempFilePath = path.join(coverImageDirPath_1, item);
                            isDefaultConver = path.basename(tempFilePath).includes('defaultCover');
                            coverImageList.push({
                                dirPath: localRecordDirPath,
                                path: tempFilePath,
                                isDefaultConver: isDefaultConver,
                                filePath: filePath
                            });
                        }
                    }
                    catch (e_3_1) { e_3 = { error: e_3_1 }; }
                    finally {
                        try {
                            if (coverImageFileList_1_1 && !coverImageFileList_1_1.done && (_a = coverImageFileList_1.return)) _a.call(coverImageFileList_1);
                        }
                        finally { if (e_3) throw e_3.error; }
                    }
                    return [2 /*return*/, coverImageList];
                case 2:
                    e_2 = _b.sent();
                    console.error('getCoverImage() error: ', e_2.message);
                    //返回错误仍然返回
                    return [2 /*return*/, [{ errorMessage: e_2.message }]];
                case 3: return [2 /*return*/];
            }
        });
    });
}
function getMeetingRecordPath(meetingNum, meetingStartTime, directory, needGetMeetingRecordPath) {
    return __awaiter(this, void 0, void 0, function () {
        var meetingRecordPath, meetingRecordFirstMp4FilePath, meetingRecordFirstAacFilePath, meetingRecordPathMatchMeetingNumOnly;
        return __generator(this, function (_a) {
            console.log('getMeetingRecordPath() meetingNum: ', meetingNum, 'meetingStartTime: ', meetingStartTime, ', directory: ', directory, ', needGetMeetingRecordPath: ', needGetMeetingRecordPath);
            meetingRecordPath = '';
            meetingRecordFirstMp4FilePath = '';
            meetingRecordFirstAacFilePath = '';
            console.log("getMeetingRecordPath() directory: ".concat(directory));
            if (!fs.existsSync("".concat(directory))) {
                console.log("getMeetingRecordPath() ".concat(directory, " \u4E0D\u5B58\u5728"));
                return [2 /*return*/, {
                        meetingRecordPath: meetingRecordPath,
                        meetingRecordFirstMp4FilePath: meetingRecordFirstMp4FilePath,
                        meetingRecordFirstAacFilePath: meetingRecordFirstAacFilePath
                    }];
            }
            meetingRecordPathMatchMeetingNumOnly = '';
            if (needGetMeetingRecordPath) {
                //遍历目标目录的所有文件资源
                fs.readdirSync(directory).map(function (item) {
                    //console.log('录制文件下的item: ', item)
                    if (item.includes(meetingNum)) {
                        meetingRecordPathMatchMeetingNumOnly = item;
                        if (item.includes(meetingStartTime)) {
                            //console.warn('找到了目标目录: ', item)
                            meetingRecordPath = item;
                            return;
                        }
                    }
                });
                meetingRecordPath == '' ? meetingRecordPath = meetingRecordPathMatchMeetingNumOnly : null;
            }
            else {
                meetingRecordPath = directory;
            }
            console.log("getMeetingRecordPath() meetingRecordPath: ".concat(meetingRecordPath));
            if (meetingRecordPath !== '') {
                needGetMeetingRecordPath ? meetingRecordPath = path.join(directory, meetingRecordPath) : null;
                console.log("getMeetingRecordPath() meetingRecordPath 11: ".concat(meetingRecordPath));
                fs.readdirSync(meetingRecordPath).map(function (file) {
                    if (!meetingRecordFirstMp4FilePath && file.includes('mp4')) {
                        meetingRecordFirstMp4FilePath = file;
                    }
                    if (!meetingRecordFirstAacFilePath && file.includes('aac')) {
                        meetingRecordFirstAacFilePath = file;
                    }
                });
                console.log('找到了目标mp4文件: ', meetingRecordFirstMp4FilePath);
                console.log('找到了目标aac文件: ', meetingRecordFirstMp4FilePath);
                if (meetingRecordFirstMp4FilePath != '') {
                    meetingRecordFirstMp4FilePath = path.join(meetingRecordPath, meetingRecordFirstMp4FilePath);
                }
                if (meetingRecordFirstAacFilePath != '') {
                    meetingRecordFirstAacFilePath = path.join(meetingRecordPath, meetingRecordFirstAacFilePath);
                }
            }
            console.log("getMeetingRecordPath() \u8FD4\u56DE\u7ED3\u679C meetingRecordPath: ".concat(meetingRecordPath, ", meetingRecordFirstMp4FilePath: ").concat(meetingRecordFirstMp4FilePath));
            return [2 /*return*/, {
                    meetingRecordPath: meetingRecordPath,
                    meetingRecordFirstMp4FilePath: meetingRecordFirstMp4FilePath,
                    meetingRecordFirstAacFilePath: meetingRecordFirstAacFilePath
                }];
        });
    });
}
function deleteFolder(folderPath) {
    if (fs.existsSync(folderPath)) {
        fs.readdirSync(folderPath).forEach(function (file, index) {
            var curPath = path.join(folderPath, file);
            if (fs.lstatSync(curPath).isDirectory()) { // recurse
                deleteFolder(curPath);
            }
            else { // delete file
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(folderPath);
    }
}
function addGlobalIpcMainListeners() {
    var _this = this;
    var userDataPath = app.getPath('userData');
    ipcMain.on(EventType.Beauty, function (event, data) { return __awaiter(_this, void 0, void 0, function () {
        var path_1;
        return __generator(this, function (_a) {
            if (data.event === 'addVirtualBackground') {
                dialog
                    .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
                    properties: ['openFile'],
                    filters: [{ name: 'image', extensions: ['jpg', 'png', 'jpeg', 'mov', 'mp4'] }],
                })
                    .then(function (response) {
                    if (!response.canceled) {
                        // handle fully qualified file name
                        var filePath = response.filePaths[0];
                        var userVirtualBackgroundPath = path.join(userDataPath, 'virtualBackground');
                        var toPath = path.join(userVirtualBackgroundPath, "user-".concat(Date.now()).concat(path.extname(filePath)));
                        var ext = path.extname(filePath);
                        var sourceType = 0;
                        if (ext === '.mov' || ext === '.mp4' || ext === '.MOV' || ext === '.MP4') {
                            sourceType = tagNEBackgroundSourceType.kNEBackgroundVideo;
                        }
                        else if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
                            sourceType = tagNEBackgroundSourceType.kNEBackgroundImage;
                        }
                        var fileSize = fs.statSync(filePath).size;
                        var error = null;
                        //限制文件大小为500M
                        if (fileSize > 500 * 1024 * 1024) {
                            error = '文件过大';
                            event.sender.send(EventType.AddVirtualBackgroundReply, '', sourceType, error);
                            return;
                        }
                        fs.copyFileSync(filePath, toPath);
                        getVirtualBackground(true, event);
                        event.sender.send(EventType.AddVirtualBackgroundReply, toPath, sourceType);
                    }
                    else {
                        event.sender.send(EventType.AddVirtualBackgroundReply, '', sourceType);
                        console.log('no file selected');
                    }
                });
            }
            else if (data.event === 'removeVirtualBackground') {
                path_1 = data.value.path;
                try {
                    fs.unlinkSync(path_1);
                    getVirtualBackground(true, event);
                }
                catch (e) {
                    console.log('removeVirtualBackground error', e);
                }
            }
            return [2 /*return*/];
        });
    }); });
    ipcMain.on(EventType.Relaunch, function () {
        app.relaunch();
        app.exit(0);
    });
    ipcMain.handle(EventType.GetVirtualBackground, function () {
        return getVirtualBackground();
    });
    ipcMain.handle(EventType.GetCoverImage, function (_, _a) {
        var dirNmae = _a.dirNmae, filePath = _a.filePath;
        return getCoverImage(dirNmae, filePath);
    });
    ipcMain.handle(EventType.CheckDiskSpace, function (_, _a) {
        var directory = _a.directory;
        try {
            console.log("\u67E5\u770B\u5269\u4F59\u7A7A\u95F4\uFF0C\u5F53\u524D\u8981\u67E5\u627E\u7684\u8DEF\u5F84\u4E3A\uFF1A ".concat(directory));
            function bytesToSize(bytes) {
                var sizes = ['Bytes', 'K', 'M', 'G'];
                if (bytes == 0)
                    return '0 Byte';
                var i = Math.floor(Math.log(bytes) / Math.log(1024));
                if (i == 0)
                    return bytes + ' ' + sizes[i];
                if (i == 1)
                    return Math.floor(bytes / Math.pow(1024, i)) + ' ' + sizes[i];
                return Math.floor(bytes / Math.pow(1024, i)) + '' + sizes[i];
            }
            return new Promise(function (resolve, reject) {
                var rootPath = directory.charAt(0); // 指定目录路径
                if (os.type() == 'Windows_NT') {
                    //windows平台
                    console.log('查看剩余空间 windows平台');
                    exec("wmic logicaldisk where \"DeviceID='".concat(rootPath, ":'\" get FreeSpace"), function (err, stdout, stderr) {
                        if (err) {
                            console.error('查看剩余空间 error: ', err);
                            resolve('');
                        }
                        if (stderr) {
                            console.error('查看剩余空间 stderr: ', stderr);
                            resolve('');
                        }
                        console.log('查看剩余空间 shell命令: ', stdout);
                        var lines = stdout.split('\n');
                        // 第二行包含可用空间的信息
                        if (lines && lines.length && lines[1]) {
                            var availableSpaceBytes = lines[1].trim();
                            var availableSpaceGB = bytesToSize(availableSpaceBytes);
                            console.log("\u6307\u5B9A\u76EE\u5F55\u7684\u53EF\u7528\u7A7A\u95F4\u5927\u5C0F\uFF1A".concat(availableSpaceBytes, " bytes, ").concat(availableSpaceGB));
                            resolve(availableSpaceGB);
                        }
                        else {
                            resolve('');
                        }
                    });
                }
                else if (os.type() == 'Darwin') {
                    console.log('查看剩余空间 mac平台');
                    exec("df -h ".concat(rootPath), function (err, stdout, stderr) {
                        if (err) {
                            console.error('查看剩余空间 error: ', err);
                            resolve('');
                        }
                        console.log('查看剩余空间 shell命令: ', stdout);
                        var regex = /\b(\d+\.?\d*)([KMG]?iB?)\b/g;
                        var list = stdout.match(regex);
                        if (list && list.length && list.length > 1 && list[2]) {
                            resolve(list[2].slice(0, -1));
                        }
                        else {
                            resolve('');
                        }
                    });
                }
                else if (os.type() == 'Linux') {
                    //Linux平台
                    console.log('Linux平台');
                }
            });
        }
        catch (error) {
            console.error('Error getting disk space:', error);
            throw error;
        }
    });
    ipcMain.handle(EventType.GetMeetingRecordPath, function (_, _a) {
        var meetingNum = _a.meetingNum, meetingStartTime = _a.meetingStartTime, directory = _a.directory, needGetMeetingRecordPath = _a.needGetMeetingRecordPath;
        return getMeetingRecordPath(meetingNum, meetingStartTime, directory, needGetMeetingRecordPath);
    });
    ipcMain.on(EventType.MaximizeWindow, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        if (mainWindow.isMaximized()) {
            mainWindow.unmaximize();
            // linux 不设置，否则最大化窗口再全屏会有问题
            if (mainWindow.isMainWindow && !isLinux) {
                mainWindow.setResizable(true);
                mainWindow.setMovable(true);
            }
        }
        else {
            mainWindow.maximize();
            if (mainWindow.isMainWindow && !isLinux) {
                mainWindow.setResizable(false);
                mainWindow.setMovable(false);
            }
        }
    });
    ipcMain.handle(EventType.GetDeviceAccessStatus, function () {
        if (process.platform === 'linux') {
            return {
                camera: 'unknown',
                microphone: 'unknown'
            };
        }
        return {
            camera: systemPreferences.getMediaAccessStatus('camera'),
            microphone: systemPreferences.getMediaAccessStatus('microphone'),
        };
    });
    ipcMain.on(EventType.MinimizeWindow, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.minimize();
    });
    ipcMain.handle(EventType.GetImageBase64, function (_, _a) {
        var filePath = _a.filePath, isDelete = _a.isDelete;
        var base64Prefix = "data:image/".concat(path
            .extname(filePath)
            .substring(1), ";base64,");
        var base64 = base64Prefix + fs.readFileSync(filePath, 'base64');
        if (isDelete) {
            fs.unlinkSync(filePath);
        }
        return base64;
    });
    ipcMain.handle(EventType.GetLogPath, function () {
        var cacheDirectoryName = 'logs';
        var logPath = path.join(userDataPath, cacheDirectoryName);
        return logPath;
    });
    ipcMain.handle(EventType.SaveAvatarToPath, function (event_1, base64String_1) {
        var args_1 = [];
        for (var _i = 2; _i < arguments.length; _i++) {
            args_1[_i - 2] = arguments[_i];
        }
        return __awaiter(_this, __spreadArray([event_1, base64String_1], __read(args_1), false), void 0, function (event, base64String, defaultPath, fileName) {
            var base64Data, imageCacheDirPath, filePath, error_1;
            if (defaultPath === void 0) { defaultPath = null; }
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        console.log('保存图片到本地 defaultPath: ', defaultPath, 'fileName: ', fileName);
                        base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
                        imageCacheDirPath = path.join(userDataPath, 'imageCache');
                        if (!fs.existsSync(imageCacheDirPath)) {
                            fs.mkdirSync(imageCacheDirPath);
                        }
                        filePath = path.join(defaultPath || imageCacheDirPath, fileName || 'avatar.png');
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, fs.promises.writeFile(filePath, base64Data, 'base64')];
                    case 2:
                        _a.sent();
                        return [2 /*return*/, { status: 'success', filePath: filePath }];
                    case 3:
                        error_1 = _a.sent();
                        console.error('Error saving image:', error_1);
                        return [2 /*return*/, { status: 'error', message: error_1.message }];
                    case 4: return [2 /*return*/];
                }
            });
        });
    });
    ipcMain.on(EventType.NoPermission, function (_, type) {
        if (isWin32) {
            if (type === 'audio') {
                shell.openExternal('ms-settings:privacy-microphone');
            }
            else {
                shell.openExternal('ms-settings:privacy-webcam');
            }
        }
        else {
            var command = 'open "x-apple.systempreferences:"';
            exec(command, function (error) {
                if (error) {
                    console.error("\u6253\u5F00\u7CFB\u7EDF\u504F\u597D\u8BBE\u7F6E\u65F6\u51FA\u9519\uFF1A ".concat(error));
                }
            });
        }
    });
    ipcMain.handle(EventType.getSystemManufacturer, function () {
        return si
            .system()
            .then(function (data) {
            var manufacturer = data.manufacturer;
            var model = data.model;
            return { manufacturer: manufacturer, model: model, os_ver: os.release() };
        })
            .catch(function (error) {
            console.error(error);
        });
    });
    ipcMain.handle(EventType.getThemeColor, function () {
        var _a;
        return (_a = nativeTheme.shouldUseDarkColors) !== null && _a !== void 0 ? _a : true();
    });
    ipcMain.handle(EventType.downloadFileByUrl, function (_, url) {
        shell.openExternal(url);
        return true;
    });
    ipcMain.on(EventType.DownloadPath, function (event, value) {
        if (value === 'get') {
            event.returnValue = app.getPath('downloads');
        }
        if (value === 'set') {
            dialog
                .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
                properties: ['openDirectory'],
            })
                .then(function (response) {
                if (!response.canceled) {
                    // handle fully qualified file name
                    var filePath = response.filePaths[0];
                    event.sender.send(EventType.DownloadPathReply, filePath);
                }
                else {
                    console.log('no file selected');
                }
            });
        }
        if (value === 'open') {
        }
    });
    ipcMain.on(EventType.FileSaveAs, function (event, value) {
        var defaultPath = value.defaultPath, filePath = value.filePath;
        dialog
            .showSaveDialog(BrowserWindow.fromWebContents(event.sender), {
            defaultPath: defaultPath,
            filters: [{ name: '', extensions: '*' }],
        })
            .then(function (response) {
            var resFilePath = '';
            if (!response.canceled) {
                // handle fully qualified file name
                if (filePath && fs.existsSync(filePath)) {
                    fs.copyFileSync(filePath, response.filePath);
                }
                else {
                    resFilePath = response.filePath;
                }
            }
            event.sender.send(EventType.FileSaveAsReply, resFilePath);
        })
            .catch(function () {
            event.sender.send(EventType.FileSaveAsReply, '');
        });
    });
    ipcMain.on(EventType.openFile, function (event, value) {
        var isDir = value.isDir, filePath = value.filePath;
        fs.exists(filePath, function (exists) {
            if (exists) {
                if (isDir) {
                    shell.showItemInFolder(filePath);
                }
                else {
                    shell.openPath(filePath);
                }
            }
            event.sender.send(EventType.openFileReply, exists);
        });
    });
    ipcMain.on(EventType.chooseFile, function (event, value) {
        var type = value.type, extensions = value.extensions, extendedData = value.extendedData;
        dialog
            .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
            properties: ['openFile'],
            filters: [{ name: type, extensions: extensions }],
        })
            .then(function (response) {
            if (!response.canceled) {
                // handle fully qualified file name
                var filePath_1 = response.filePaths[0];
                fs.stat(filePath_1, function (err, stats) {
                    if (err) {
                        console.error(err);
                    }
                    else {
                        var base64Image = '';
                        var width = 0;
                        var height = 0;
                        if (type === 'image') {
                            var base64Prefix = "data:image/".concat(path
                                .extname(filePath_1)
                                .substring(1), ";base64,");
                            base64Image = base64Prefix + fs.readFileSync(filePath_1, 'base64');
                            try {
                                var dimensions = sizeOf(filePath_1);
                                width = dimensions.width;
                                height = dimensions.height;
                            }
                            catch (e) {
                                console.error(e);
                            }
                        }
                        event.sender.send(EventType.chooseFileDone, {
                            type: type,
                            file: {
                                url: filePath_1,
                                name: path.basename(filePath_1),
                                size: stats.size,
                                base64: base64Image,
                                width: width,
                                height: height,
                            },
                            extendedData: extendedData,
                        });
                    }
                });
            }
            else {
                console.log('no file selected');
            }
        })
            .catch(function (err) {
            console.log('no file selected', err);
        });
    });
    ipcMain.handle(EventType.DeleteDirectory, function (event, value) {
        console.log('删除路径: ', value);
        var directory = value.directory;
        deleteFolder(directory);
        return true;
    });
    ipcMain.on(EventType.openBrowserWindow, function (event, url) {
        shell.openExternal(url);
    });
    var _isMaximized = false;
    ipcMain.on(EventType.QuiteFullscreen, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        !isLinux && mainWindow.setFullScreenable(true);
        mainWindow.isFullScreenPrivate && mainWindow.setFullScreen(false);
        !isLinux && _isMaximized && mainWindow.maximize();
    });
    ipcMain.on(EventType.EnterFullscreen, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        // linux 不设置，否则最大化窗口再全屏会有问题
        if (!isLinux) {
            mainWindow.setFullScreenable(true);
            _isMaximized = mainWindow.isMaximized();
            _isMaximized && mainWindow.unmaximize();
        }
        !mainWindow.isFullScreenPrivate && mainWindow.setFullScreen(true);
    });
    ipcMain.on(EventType.FlushStorageData, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        // 强制缓存
        try {
            mainWindow.webContents.session.flushStorageData();
        }
        catch (_a) {
            console.log('flushStorageData error');
        }
    });
    // 主窗口是否为全屏状态
    ipcMain.handle(EventType.IsMainFullScreen, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        var isFullscreen = mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isFullScreen();
        return isFullscreen;
    });
    ipcMain.handle(EventType.IsMaximized, function (event) {
        var mainWindow = BrowserWindow.fromWebContents(event.sender);
        var isMaximized = mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.isMaximized();
        return isMaximized;
    });
    ipcMain.on(EventType.OpenDevTools, function (event) { return __awaiter(_this, void 0, void 0, function () {
        var mainWindow;
        return __generator(this, function (_a) {
            mainWindow = BrowserWindow.fromWebContents(event.sender);
            mainWindow.webContents.openDevTools();
            return [2 /*return*/];
        });
    }); });
}
function removeGlobalIpcMainListeners() {
    Object.keys(EventType).forEach(function (key) {
        ipcMain.removeAllListeners(EventType[key]);
        ipcMain.removeHandler(EventType[key]);
    });
}
module.exports = {
    addGlobalIpcMainListeners: addGlobalIpcMainListeners,
    removeGlobalIpcMainListeners: removeGlobalIpcMainListeners,
};