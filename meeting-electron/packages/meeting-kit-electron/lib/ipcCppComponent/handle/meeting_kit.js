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
var meeting_kit_1 = require("../../kit/impl/meeting_kit");
var meeting_account_service_1 = require("./service/meeting_account_service");
var meeting_service_1 = require("./service/meeting_service");
var meeting_contacts_service_1 = require("./service/meeting_contacts_service");
var meeting_message_channel_service_1 = require("./service/meeting_message_channel_service");
var meeting_invite_service_1 = require("./service/meeting_invite_service");
var settings_service_1 = require("./service/settings_service");
var pre_meeting_service_1 = require("./service/pre_meeting_service");
var feedback_service_1 = require("./service/feedback_service");
var NEMeetingKitHandle = /** @class */ (function () {
    function NEMeetingKitHandle(listenerInvokeCallback) {
        this._sidMap = new Map();
        this._listenerInvokeCallback = listenerInvokeCallback;
        this._meetingKit = meeting_kit_1.default.getInstance();
        this._sidMap.set(0, this);
    }
    NEMeetingKitHandle.prototype.onIPCMessageReceived = function (sid, cid, data) {
        return __awaiter(this, void 0, Promise, function () {
            var service, error_1, failureError;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        console.log('onIPCMessageReceived');
                        console.log('sid:', sid);
                        console.log('cid:', cid);
                        console.log('data:');
                        console.log(data);
                        service = this._sidMap.get(sid);
                        if (!service) return [3 /*break*/, 5];
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, service.onMethodHandle(cid, data)];
                    case 2: return [2 /*return*/, _a.sent()];
                    case 3:
                        error_1 = _a.sent();
                        console.error('onMethodHandle error', error_1);
                        if (typeof error_1 === 'string') {
                            return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, error_1))];
                        }
                        else {
                            failureError = error_1;
                            return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, failureError.message, failureError.code))];
                        }
                        return [3 /*break*/, 4];
                    case 4: return [3 /*break*/, 6];
                    case 5: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'service not found'))];
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.onMethodHandle = function (cid, data) {
        return __awaiter(this, void 0, Promise, function () {
            var res, _a, error_2, failureError, errorMsg;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 13, , 14]);
                        res = void 0;
                        _a = cid;
                        switch (_a) {
                            case 1: return [3 /*break*/, 1];
                            case 3: return [3 /*break*/, 3];
                            case 9: return [3 /*break*/, 5];
                            case 11: return [3 /*break*/, 7];
                            case 13: return [3 /*break*/, 9];
                        }
                        return [3 /*break*/, 11];
                    case 1: return [4 /*yield*/, this.initialize(data)];
                    case 2:
                        res = _b.sent();
                        return [3 /*break*/, 12];
                    case 3: return [4 /*yield*/, this.unInitialize()];
                    case 4:
                        res = _b.sent();
                        return [3 /*break*/, 12];
                    case 5: return [4 /*yield*/, this.switchLanguage(data)];
                    case 6:
                        res = _b.sent();
                        return [3 /*break*/, 12];
                    case 7: return [4 /*yield*/, this.getLogPath()];
                    case 8:
                        res = _b.sent();
                        return [3 /*break*/, 12];
                    case 9: return [4 /*yield*/, this.getAppNoticeTips()];
                    case 10:
                        res = _b.sent();
                        return [3 /*break*/, 12];
                    case 11: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'method not found'))];
                    case 12: return [2 /*return*/, JSON.stringify(res)];
                    case 13:
                        error_2 = _b.sent();
                        console.error('onMethodHandle error', error_2);
                        failureError = error_2;
                        if (failureError.message) {
                            return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, failureError.message))];
                        }
                        if (error_2 instanceof neroom_types_1.FailureBodySync) {
                            return [2 /*return*/, JSON.stringify(error_2)];
                        }
                        else {
                            errorMsg = 'error';
                            if (typeof error_2 === 'string') {
                                errorMsg = error_2;
                            }
                            // 未知错误
                            return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, errorMsg))];
                        }
                        return [3 /*break*/, 14];
                    case 14: return [2 /*return*/];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.initialize = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var config, res, accountService, meetingService, settingsService, preMeetingService, meetingInviteService, contactsService, meetingMessageChannelService, feedbackService;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        config = JSON.parse(data);
                        console.log('initialize config:', config);
                        return [4 /*yield*/, this._meetingKit.initialize(config)];
                    case 1:
                        res = _a.sent();
                        if (res.code === 0) {
                            accountService = this._meetingKit.getAccountService();
                            if (accountService) {
                                this._sidMap.set(1, new meeting_account_service_1.default(accountService, this._listenerInvokeCallback));
                            }
                            meetingService = this._meetingKit.getMeetingService();
                            if (meetingService) {
                                this._sidMap.set(2, new meeting_service_1.default(meetingService, this._listenerInvokeCallback));
                            }
                            settingsService = this._meetingKit.getSettingsService();
                            if (settingsService) {
                                this._sidMap.set(3, new settings_service_1.default(settingsService));
                            }
                            preMeetingService = this._meetingKit.getPreMeetingService();
                            if (preMeetingService) {
                                this._sidMap.set(6, new pre_meeting_service_1.default(preMeetingService, this._listenerInvokeCallback));
                            }
                            meetingInviteService = this._meetingKit.getMeetingInviteService();
                            if (meetingInviteService) {
                                this._sidMap.set(7, new meeting_invite_service_1.default(meetingInviteService, this._listenerInvokeCallback));
                            }
                            contactsService = this._meetingKit.getContactsService();
                            if (contactsService) {
                                this._sidMap.set(8, new meeting_contacts_service_1.default(contactsService));
                            }
                            meetingMessageChannelService = this._meetingKit.getMeetingMessageChannelService();
                            if (meetingMessageChannelService) {
                                this._sidMap.set(9, new meeting_message_channel_service_1.default(meetingMessageChannelService, this._listenerInvokeCallback));
                            }
                            feedbackService = this._meetingKit.getFeedbackService();
                            if (feedbackService) {
                                this._sidMap.set(10, new feedback_service_1.default(feedbackService));
                            }
                        }
                        return [2 /*return*/, res];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.unInitialize = function () {
        return __awaiter(this, void 0, void 0, function () {
            var res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingKit.unInitialize()];
                    case 1:
                        res = _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.switchLanguage = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var language, res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        language = JSON.parse(data).language;
                        return [4 /*yield*/, this._meetingKit.switchLanguage(language)];
                    case 1:
                        res = _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.getLogPath = function () {
        return __awaiter(this, void 0, void 0, function () {
            var res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingKit.getSDKLogPath()];
                    case 1:
                        res = _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    NEMeetingKitHandle.prototype.getAppNoticeTips = function () {
        return __awaiter(this, void 0, void 0, function () {
            var res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._meetingKit.getAppNoticeTips()];
                    case 1:
                        res = _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    return NEMeetingKitHandle;
}());
exports.default = NEMeetingKitHandle;