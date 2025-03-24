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
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
var meeting_kit_1 = require("../meeting_kit");
var meeting_electron_base_service_1 = require("./meeting_electron_base_service");
var MODULE_NAME = 'NEContactsService';
var seqCount = 0;
var NEContactsService = /** @class */ (function (_super) {
    __extends(NEContactsService, _super);
    function NEContactsService(_win) {
        return _super.call(this, _win) || this;
    }
    NEContactsService.prototype.searchContactListByName = function (name, pageSize, pageNum) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'searchContactListByName';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [name, pageSize, pageNum],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEContactsService.prototype.searchContactListByPhoneNumber = function (phoneNumber, pageSize, pageNum) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'searchContactListByPhoneNumber';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [phoneNumber, pageSize, pageNum],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEContactsService.prototype.getContactsInfo = function (userUuids) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getContactsInfo';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [userUuids],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NEContactsService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NEContactsService.prototype._IpcMainListener = function (seqId) {
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
    return NEContactsService;
}(meeting_electron_base_service_1.default));
exports.default = NEContactsService;