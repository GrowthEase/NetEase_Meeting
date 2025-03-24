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
var meeting_kit_1 = require("../meeting_kit");
var meeting_electron_base_service_1 = require("./meeting_electron_base_service");
var MODULE_NAME = 'NEFeedbackService';
var seqCount = 0;
var NEFeedbackService = /** @class */ (function (_super) {
    __extends(NEFeedbackService, _super);
    function NEFeedbackService(_win) {
        return _super.call(this, _win) || this;
    }
    NEFeedbackService.prototype.feedback = function (feedback) {
        var functionName = 'feedback';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [feedback],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEFeedbackService.prototype.showFeedbackView = function () {
        var functionName = 'showFeedbackView';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NEFeedbackService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEFeedbackService.prototype._IpcMainListener = function (seqId) {
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
    return NEFeedbackService;
}(meeting_electron_base_service_1.default));
exports.default = NEFeedbackService;