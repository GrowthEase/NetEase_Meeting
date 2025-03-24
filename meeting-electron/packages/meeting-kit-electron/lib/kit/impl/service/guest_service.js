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
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
var meeting_electron_base_service_1 = require("./meeting_electron_base_service");
var meeting_kit_1 = require("../meeting_kit");
var MODULE_NAME = 'NEGuestService';
var seqCount = 0;
var NEGuestService = /** @class */ (function (_super) {
    __extends(NEGuestService, _super);
    function NEGuestService(win) {
        return _super.call(this, win) || this;
    }
    NEGuestService.prototype.joinMeetingAsGuest = function (param, opts) {
        var _this = this;
        var functionName = 'joinMeetingAsGuest';
        var seqId = this._generateSeqId(functionName);
        console.log('seqId>>>', seqId);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [param, opts],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId).then(function (res) {
            var _a, _b;
            _this._win.show();
            (_b = (_a = _this._win).initMainWindowSize) === null || _b === void 0 ? void 0 : _b.call(_a);
            _this._win.inMeeting = true;
            return res;
        });
    };
    NEGuestService.prototype.requestSmsCodeForGuestJoin = function (meetingNum, phoneNumber) {
        var functionName = 'requestSmsCodeForGuestJoin';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [meetingNum, phoneNumber],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEGuestService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEGuestService.prototype._IpcMainListener = function (seqId) {
        return new Promise(function (resolve, reject) {
            electron_1.ipcMain.once(seqId, function (_, res) {
                console.log('_IpcMainListener>>>', seqId, res);
                if (res.error) {
                    reject(res.error);
                }
                else {
                    resolve(res.result);
                }
            });
        });
    };
    return NEGuestService;
}(meeting_electron_base_service_1.default));
exports.default = NEGuestService;