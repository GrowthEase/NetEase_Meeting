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
Object.defineProperty(exports, "__esModule", { value: true });
exports.BUNDLE_NAME = void 0;
var electron_1 = require("electron");
var neroom_types_1 = require("neroom-types");
var constant_1 = require("../../constant");
var meeting_contacts_service_1 = require("./service/meeting_contacts_service");
var meeting_invite_service_1 = require("./service/meeting_invite_service");
var meeting_service_1 = require("./service/meeting_service");
var pre_meeting_service_1 = require("./service/pre_meeting_service");
var settings_service_1 = require("./service/settings_service");
var meeting_account_service_1 = require("./service/meeting_account_service");
var meeting_message_channel_service_1 = require("./service/meeting_message_channel_service");
var index_1 = require("../../mainMeetingWindow/index");
var feedback_service_1 = require("./service/feedback_service");
var guest_service_1 = require("./service/guest_service");
exports.BUNDLE_NAME = 'NEMeetingKit';
var seqCount = 0;
var NEMeetingKit = /** @class */ (function () {
    function NEMeetingKit() {
        this._exceptionHandlers = [];
        this._isInitialized = false;
        this._win = (0, index_1.openMeetingWindow)();
    }
    NEMeetingKit.getInstance = function () {
        if (!NEMeetingKit._instance) {
            NEMeetingKit._instance = new NEMeetingKit();
        }
        return NEMeetingKit._instance;
    };
    Object.defineProperty(NEMeetingKit.prototype, "isInitialized", {
        get: function () {
            return this._isInitialized;
        },
        enumerable: false,
        configurable: true
    });
    NEMeetingKit.prototype.initialize = function (config) {
        return __awaiter(this, void 0, Promise, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._initialize(config)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingKit.prototype.unInitialize = function () {
        var _this = this;
        var functionName = 'unInitialize';
        var seqId = this._generateSeqId(functionName);
        this._isInitialized = false;
        this._win.webContents.send(exports.BUNDLE_NAME, {
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId).then(function () {
            (0, index_1.closeMeetingWindow)();
            _this._win = (0, index_1.openMeetingWindow)();
            return (0, neroom_types_1.SuccessBody)(void 0);
        });
    };
    NEMeetingKit.prototype.switchLanguage = function (language) {
        var functionName = 'switchLanguage';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(exports.BUNDLE_NAME, {
            method: functionName,
            args: [language],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingKit.prototype.getMeetingService = function () {
        return this._meetingService;
    };
    NEMeetingKit.prototype.getMeetingInviteService = function () {
        return this._meetingInviteService;
    };
    NEMeetingKit.prototype.getAccountService = function () {
        return this._accountService;
    };
    NEMeetingKit.prototype.getSettingsService = function () {
        return this._settingsService;
    };
    NEMeetingKit.prototype.getPreMeetingService = function () {
        return this._preMeetingService;
    };
    NEMeetingKit.prototype.getFeedbackService = function () {
        return this._feedbackService;
    };
    NEMeetingKit.prototype.getMeetingMessageChannelService = function () {
        return this._meetingMessageChannelService;
    };
    NEMeetingKit.prototype.getContactsService = function () {
        return this._contactsService;
    };
    NEMeetingKit.prototype.getGuestService = function () {
        return this._guestService;
    };
    NEMeetingKit.prototype.addGlobalEventListener = function (listener) {
        this._globalEventListeners = this._globalEventListeners
            ? __assign(__assign({}, this._globalEventListeners), listener) : listener;
    };
    NEMeetingKit.prototype.removeGlobalEventListener = function (listener) {
        var _this = this;
        if (listener) {
            var keys = Object.keys(listener);
            keys.forEach(function (key) {
                _this._globalEventListeners && delete _this._globalEventListeners[key];
            });
        }
        else {
            this._globalEventListeners = undefined;
        }
    };
    NEMeetingKit.prototype.getSDKLogPath = function () {
        var functionName = 'getSDKLogPath';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(exports.BUNDLE_NAME, {
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingKit.prototype.getAppNoticeTips = function () {
        var functionName = 'getAppNoticeTips';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(exports.BUNDLE_NAME, {
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingKit.prototype.setExceptionHandler = function (handler) {
        this._exceptionHandlers.push(handler);
    };
    NEMeetingKit.prototype.startMarvel = function () {
        var functionName = 'startMarvel';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(exports.BUNDLE_NAME, {
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingKit.prototype._initialize = function (config_1) {
        return __awaiter(this, arguments, Promise, function (config, recover) {
            var _fn;
            var _this = this;
            if (recover === void 0) { recover = false; }
            return __generator(this, function (_a) {
                _fn = function () {
                    var _a;
                    var functionName = 'initialize';
                    var seqId = _this._generateSeqId(functionName);
                    if (!((_a = _this._win) === null || _a === void 0 ? void 0 : _a.isDestroyed())) {
                        _this._win.webContents.send(exports.BUNDLE_NAME, {
                            method: functionName,
                            args: [config],
                            seqId: seqId,
                        });
                    }
                    return _this._IpcMainListener(seqId).then(function (res) {
                        var _a, _b, _c, _d, _e, _f, _g, _h, _j;
                        if (recover) {
                            (_a = _this._meetingService) === null || _a === void 0 ? void 0 : _a.setWin(_this._win);
                            (_b = _this._meetingInviteService) === null || _b === void 0 ? void 0 : _b.setWin(_this._win);
                            (_c = _this._accountService) === null || _c === void 0 ? void 0 : _c.setWin(_this._win);
                            (_d = _this._settingsService) === null || _d === void 0 ? void 0 : _d.setWin(_this._win);
                            (_e = _this._preMeetingService) === null || _e === void 0 ? void 0 : _e.setWin(_this._win);
                            (_f = _this._contactsService) === null || _f === void 0 ? void 0 : _f.setWin(_this._win);
                            (_g = _this._meetingMessageChannelService) === null || _g === void 0 ? void 0 : _g.setWin(_this._win);
                            (_h = _this._feedbackService) === null || _h === void 0 ? void 0 : _h.setWin(_this._win);
                            (_j = _this._guestService) === null || _j === void 0 ? void 0 : _j.setWin(_this._win);
                        }
                        else {
                            _this._isInitialized = true;
                            _this._initConfig = config;
                            _this._meetingService = new meeting_service_1.default(_this._win);
                            _this._meetingInviteService = new meeting_invite_service_1.default(_this._win);
                            _this._accountService = new meeting_account_service_1.default(_this._win);
                            _this._settingsService = new settings_service_1.default(_this._win);
                            _this._preMeetingService = new pre_meeting_service_1.default(_this._win);
                            _this._contactsService = new meeting_contacts_service_1.default(_this._win);
                            _this._meetingMessageChannelService =
                                new meeting_message_channel_service_1.default(_this._win);
                            _this._feedbackService = new feedback_service_1.default(_this._win);
                            _this._guestService = new guest_service_1.default(_this._win);
                            _this._onMeetingEnd();
                        }
                        _this._daemonProcess();
                        return res;
                    });
                };
                if (this._win.isDomReady) {
                    return [2 /*return*/, _fn()];
                }
                else {
                    return [2 /*return*/, new Promise(function (resolve) {
                            _this._win.domReadyCallback = function () {
                                resolve(_fn());
                            };
                        })];
                }
                return [2 /*return*/];
            });
        });
    };
    NEMeetingKit.prototype._onMeetingEnd = function () {
        var _this = this;
        if (this._meetingService) {
            this._meetingService.addMeetingStatusListener({
                onMeetingStatusChanged: function (_a) { return __awaiter(_this, [_a], void 0, function (_b) {
                    var _this = this;
                    var status = _b.status;
                    return __generator(this, function (_c) {
                        if (status === 6 || status === -1) {
                            // 先直接隐藏
                            this._win.initMainWindowSize();
                            this._win.inMeeting = false;
                            if (constant_1.isWin32) {
                                this._win.hide();
                            }
                            else {
                                // mac 需要判断是否全屏
                                if (this._win.isFullScreen()) {
                                    this._win.on('leave-full-screen', function () {
                                        if (!_this._win.inMeeting) {
                                            _this._win.hide();
                                        }
                                    });
                                }
                                else {
                                    this._win.hide();
                                }
                            }
                        }
                        return [2 /*return*/];
                    });
                }); },
            });
        }
    };
    NEMeetingKit.prototype._daemonProcess = function () {
        var _this = this;
        var _a;
        (_a = this._win) === null || _a === void 0 ? void 0 : _a.webContents.on('crashed', function () { return __awaiter(_this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._recover()];
                    case 1:
                        _a.sent();
                        this._exceptionHandlers.forEach(function (handler) {
                            handler.onError(0);
                        });
                        return [2 /*return*/];
                }
            });
        }); });
    };
    NEMeetingKit.prototype._recover = function () {
        return __awaiter(this, void 0, void 0, function () {
            var accountInfo;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!this._accountService) return [3 /*break*/, 4];
                        (0, index_1.closeMeetingWindow)();
                        this._win = (0, index_1.openMeetingWindow)();
                        if (!this._initConfig) return [3 /*break*/, 2];
                        return [4 /*yield*/, this._initialize(this._initConfig, true)];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        accountInfo = this._accountService.accountInfo;
                        if (!accountInfo) return [3 /*break*/, 4];
                        return [4 /*yield*/, this._accountService.loginByToken(accountInfo.userUuid, accountInfo.userToken)];
                    case 3:
                        _a.sent();
                        _a.label = 4;
                    case 4: return [2 /*return*/];
                }
            });
        });
    };
    NEMeetingKit.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(exports.BUNDLE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEMeetingKit.prototype._IpcMainListener = function (seqId) {
        return new Promise(function (resolve, reject) {
            electron_1.ipcMain.once(seqId, function (_, res) {
                if (res.error) {
                    reject(res.error);
                }
                else {
                    resolve(res.result);
                }
            });
        });
    };
    NEMeetingKit._instance = null;
    return NEMeetingKit;
}());
exports.default = NEMeetingKit;