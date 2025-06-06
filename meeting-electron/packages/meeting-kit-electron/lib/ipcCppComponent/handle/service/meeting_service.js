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
Object.defineProperty(exports, "__esModule", { value: true });
var neroom_types_1 = require("neroom-types");
var NEMeetingServiceHandle = /** @class */ (function () {
    function NEMeetingServiceHandle(meetingService, listenerInvokeCallback) {
        var _this = this;
        this._listenerInvokeCallback = listenerInvokeCallback;
        this._meetingService = meetingService;
        this._meetingService.addMeetingStatusListener({
            onMeetingStatusChanged: function (event) {
                _this._listenerInvokeCallback(2, 101, JSON.stringify({ event: event }), 0);
            },
        });
        this._meetingService.setOnInjectedMenuItemClickListener({
            onInjectedMenuItemClick: function (clickInfo, meetingInfo) {
                _this._listenerInvokeCallback(2, 102, JSON.stringify({ clickInfo: clickInfo, meetingInfo: meetingInfo }), 0);
            },
        });
    }
    NEMeetingServiceHandle.prototype.onMethodHandle = function (cid, data) {
        return __awaiter(this, void 0, Promise, function () {
            var res, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = cid;
                        switch (_a) {
                            case 1: return [3 /*break*/, 1];
                            case 3: return [3 /*break*/, 3];
                            case 5: return [3 /*break*/, 5];
                            case 7: return [3 /*break*/, 7];
                            case 9: return [3 /*break*/, 9];
                            case 11: return [3 /*break*/, 11];
                            case 15: return [3 /*break*/, 13];
                            case 17: return [3 /*break*/, 15];
                        }
                        return [3 /*break*/, 17];
                    case 1: return [4 /*yield*/, this.startMeeting(data)];
                    case 2:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 3: return [4 /*yield*/, this.joinMeeting(data)];
                    case 4:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 5: return [4 /*yield*/, this.anonymousJoinMeeting(data)];
                    case 6:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 7: return [4 /*yield*/, this.getMeetingStatus()];
                    case 8:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 9: return [4 /*yield*/, this.leaveCurrentMeeting(data)];
                    case 10:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 11: return [4 /*yield*/, this.getCurrentMeetingInfo()];
                    case 12:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 13: return [4 /*yield*/, this.updateInjectedMenuItem(data)];
                    case 14:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 15: return [4 /*yield*/, this.getLocalHistoryMeetingList()];
                    case 16:
                        res = _b.sent();
                        return [3 /*break*/, 18];
                    case 17: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'method not found'))];
                    case 18: return [2 /*return*/, JSON.stringify(res)];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.joinMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, param, opts;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), param = _a.param, opts = _a.opts;
                        return [4 /*yield*/, this._meetingService.joinMeeting(param, opts)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.startMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, param, opts;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), param = _a.param, opts = _a.opts;
                        return [4 /*yield*/, this._meetingService.startMeeting(param, opts)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.anonymousJoinMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, param, opts;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), param = _a.param, opts = _a.opts;
                        return [4 /*yield*/, this._meetingService.anonymousJoinMeeting(param, opts)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.getMeetingStatus = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingService.getMeetingStatus()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.getCurrentMeetingInfo = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingService.getCurrentMeetingInfo()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.updateInjectedMenuItem = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var item;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        item = JSON.parse(data).item;
                        return [4 /*yield*/, this._meetingService.updateInjectedMenuItem(item)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.leaveCurrentMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var closeIfHost;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        closeIfHost = JSON.parse(data).closeIfHost;
                        return [4 /*yield*/, this._meetingService.leaveCurrentMeeting(closeIfHost)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingServiceHandle.prototype.getLocalHistoryMeetingList = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingService.getLocalHistoryMeetingList()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    return NEMeetingServiceHandle;
}());
exports.default = NEMeetingServiceHandle;