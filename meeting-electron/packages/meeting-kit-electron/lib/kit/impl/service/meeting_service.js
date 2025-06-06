"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
var meeting_kit_1 = require("../meeting_kit");
var meeting_electron_base_service_1 = require("./meeting_electron_base_service");
var MODULE_NAME = 'NEMeetingService';
var seqCount = 0;
var NEMeetingService = /** @class */ (function (_super) {
    __extends(NEMeetingService, _super);
    function NEMeetingService(_win) {
        var _this = _super.call(this, _win) || this;
        _this._meetingStatusListeners = [];
        _this._menuItemClickListeners = [];
        _this._addListening();
        return _this;
    }
    NEMeetingService.prototype.startMeeting = function (param, opts) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            var _this = this;
            return __generator(this, function (_a) {
                functionName = 'startMeeting';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [param, opts],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId).then(function (res) {
                        var _a, _b;
                        _this._win.show();
                        (_b = (_a = _this._win).initMainWindowSize) === null || _b === void 0 ? void 0 : _b.call(_a);
                        _this._win.inMeeting = true;
                        return res;
                    })];
            });
        });
    };
    NEMeetingService.prototype.joinMeeting = function (param, opts) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            var _this = this;
            return __generator(this, function (_a) {
                functionName = 'joinMeeting';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [param, opts],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId).then(function (res) {
                        var _a, _b;
                        _this._win.show();
                        (_b = (_a = _this._win).initMainWindowSize) === null || _b === void 0 ? void 0 : _b.call(_a);
                        _this._win.inMeeting = true;
                        return res;
                    })];
            });
        });
    };
    NEMeetingService.prototype.anonymousJoinMeeting = function (param, opts) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            var _this = this;
            return __generator(this, function (_a) {
                functionName = 'anonymousJoinMeeting';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [param, opts],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId).then(function (res) {
                        var _a, _b;
                        _this._win.show();
                        (_b = (_a = _this._win).initMainWindowSize) === null || _b === void 0 ? void 0 : _b.call(_a);
                        _this._win.inMeeting = true;
                        return res;
                    })];
            });
        });
    };
    NEMeetingService.prototype.updateInjectedMenuItem = function (item) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'updateInjectedMenuItem';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [item],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEMeetingService.prototype.getMeetingStatus = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getMeetingStatus';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEMeetingService.prototype.getCurrentMeetingInfo = function () {
        var functionName = 'getCurrentMeetingInfo';
        var seqId = this._generateSeqId(functionName);
        if (!this._win.isDestroyed()) {
            this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                module: MODULE_NAME,
                method: functionName,
                args: [],
                seqId: seqId,
            });
        }
        return this._IpcMainListener(seqId);
    };
    NEMeetingService.prototype.setOnInjectedMenuItemClickListener = function (listener) {
        this._menuItemClickListeners.push(listener);
    };
    NEMeetingService.prototype.addMeetingStatusListener = function (listener) {
        this._meetingStatusListeners.push(listener);
    };
    NEMeetingService.prototype.removeMeetingStatusListener = function (listener) {
        var index = this._meetingStatusListeners.indexOf(listener);
        if (index > -1) {
            this._meetingStatusListeners.splice(index, 1);
        }
    };
    NEMeetingService.prototype.getLocalHistoryMeetingList = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getLocalHistoryMeetingList';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEMeetingService.prototype.clearLocalHistoryMeetingList = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'clearLocalHistoryMeetingList';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEMeetingService.prototype.leaveCurrentMeeting = function (closeIfHost) {
        var functionName = 'leaveCurrentMeeting';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [closeIfHost],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingService.prototype._addListening = function () {
        var _this = this;
        var channel = "NEMeetingKitListener::".concat(MODULE_NAME);
        electron_1.ipcMain.removeAllListeners(channel);
        electron_1.ipcMain.removeHandler(channel);
        electron_1.ipcMain.on(channel, function (_, data) {
            var module = data.module, event = data.event, payload = data.payload;
            if (module !== MODULE_NAME) {
                return;
            }
            if (event === 'onMeetingStatusChanged') {
                _this._meetingStatusListeners.forEach(function (l) {
                    var _a;
                    (_a = l[event]) === null || _a === void 0 ? void 0 : _a.call.apply(_a, __spreadArray([l], __read(payload), false));
                });
            }
            else if (event === 'onInjectedMenuItemClick') {
                _this._menuItemClickListeners.forEach(function (l) {
                    var _a;
                    (_a = l[event]) === null || _a === void 0 ? void 0 : _a.call.apply(_a, __spreadArray([l], __read(payload), false));
                });
            }
        });
    };
    NEMeetingService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEMeetingService.prototype._IpcMainListener = function (seqId) {
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
    return NEMeetingService;
}(meeting_electron_base_service_1.default));
exports.default = NEMeetingService;