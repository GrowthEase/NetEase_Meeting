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
var neroom_types_1 = require("neroom-types");
var meeting_kit_1 = require("../meeting_kit");
var meeting_electron_base_service_1 = require("./meeting_electron_base_service");
var MODULE_NAME = 'NEMeetingMessageChannelService';
var seqCount = 0;
var NEMeetingMessageChannelService = /** @class */ (function (_super) {
    __extends(NEMeetingMessageChannelService, _super);
    function NEMeetingMessageChannelService(_win) {
        var _this = _super.call(this, _win) || this;
        _this._listeners = [];
        _this._addListening();
        return _this;
    }
    NEMeetingMessageChannelService.prototype.addMeetingMessageChannelListener = function (listener) {
        if (listener) {
            this._listeners.push(listener);
        }
    };
    NEMeetingMessageChannelService.prototype.removeMeetingMessageChannelListener = function (listener) {
        var index = this._listeners.indexOf(listener);
        if (index !== -1) {
            this._listeners.splice(index, 1);
        }
    };
    NEMeetingMessageChannelService.prototype.queryUnreadMessageList = function (sessionId) {
        var functionName = 'queryUnreadMessageList';
        var seqId = this._generateSeqId(functionName);
        if (this._win.isDestroyed()) {
            console.log('queryUnreadMessageList window is destroyed');
            return Promise.resolve((0, neroom_types_1.SuccessBody)([]));
        }
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [sessionId],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingMessageChannelService.prototype.clearUnreadCount = function (sessionId) {
        var functionName = 'clearUnreadCount';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [sessionId],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingMessageChannelService.prototype.deleteAllSessionMessage = function (sessionId) {
        var functionName = 'deleteAllSessionMessage';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [sessionId],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingMessageChannelService.prototype.getSessionMessagesHistory = function (param) {
        var functionName = 'getSessionMessagesHistory';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [param],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEMeetingMessageChannelService.prototype._addListening = function () {
        var _this = this;
        var channel = "NEMeetingKitListener::".concat(MODULE_NAME);
        electron_1.ipcMain.removeAllListeners(channel);
        electron_1.ipcMain.removeHandler(channel);
        electron_1.ipcMain.on(channel, function (_, data) {
            var module = data.module, event = data.event, payload = data.payload;
            if (module !== MODULE_NAME) {
                return;
            }
            _this._listeners.forEach(function (l) {
                var _a;
                (_a = l[event]) === null || _a === void 0 ? void 0 : _a.call.apply(_a, __spreadArray([l], __read(payload), false));
            });
        });
    };
    NEMeetingMessageChannelService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEMeetingMessageChannelService.prototype._IpcMainListener = function (seqId) {
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
    return NEMeetingMessageChannelService;
}(meeting_electron_base_service_1.default));
exports.default = NEMeetingMessageChannelService;