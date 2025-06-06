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
var NEPreMeetingServiceHandle = /** @class */ (function () {
    function NEPreMeetingServiceHandle(preMeetingService, listenerInvokeCallback) {
        var _this = this;
        this._preMeetingService = preMeetingService;
        this._listenerInvokeCallback = listenerInvokeCallback;
        this._preMeetingService.addListener({
            onMeetingItemInfoChanged: function (meetingItemList) {
                _this._listenerInvokeCallback(6, 101, JSON.stringify({ meetingItemList: meetingItemList }), 0);
            },
        });
    }
    NEPreMeetingServiceHandle.prototype.onMethodHandle = function (cid, data) {
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
                            case 13: return [3 /*break*/, 13];
                            case 15: return [3 /*break*/, 15];
                            case 17: return [3 /*break*/, 17];
                            case 19: return [3 /*break*/, 19];
                            case 21: return [3 /*break*/, 21];
                            case 23: return [3 /*break*/, 23];
                            case 25: return [3 /*break*/, 25];
                            case 31: return [3 /*break*/, 27];
                            case 33: return [3 /*break*/, 29];
                            case 35: return [3 /*break*/, 31];
                            case 37: return [3 /*break*/, 33];
                            case 39: return [3 /*break*/, 35];
                            case 41: return [3 /*break*/, 37];
                            case 43: return [3 /*break*/, 39];
                            case 45: return [3 /*break*/, 41];
                            case 47: return [3 /*break*/, 43];
                            case 49: return [3 /*break*/, 45];
                            case 51: return [3 /*break*/, 47];
                        }
                        return [3 /*break*/, 49];
                    case 1: return [4 /*yield*/, this.getFavoriteMeetingList(data)];
                    case 2:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 3: return [4 /*yield*/, this.addFavoriteMeeting(data)];
                    case 4:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 5: return [4 /*yield*/, this.removeFavoriteMeeting(data)];
                    case 6:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 7: return [4 /*yield*/, this.getHistoryMeetingList(data)];
                    case 8:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 9: return [4 /*yield*/, this.getHistoryMeetingDetail(data)];
                    case 10:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 11: return [4 /*yield*/, this.getHistoryMeeting(data)];
                    case 12:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 13: return [4 /*yield*/, this.scheduleMeeting(data)];
                    case 14:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 15: return [4 /*yield*/, this.getScheduledMeetingMemberList(data)];
                    case 16:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 17: return [4 /*yield*/, this.getMeetingList(data)];
                    case 18:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 19: return [4 /*yield*/, this.getMeetingItemById(data)];
                    case 20:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 21: return [4 /*yield*/, this.cancelMeeting(data)];
                    case 22:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 23: return [4 /*yield*/, this.editMeeting(data)];
                    case 24:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 25: return [4 /*yield*/, this.getMeetingItemByNum(data)];
                    case 26:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 27: return [4 /*yield*/, this.getLocalHistoryMeetingList()];
                    case 28:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 29: return [4 /*yield*/, this.getMeetingCloudRecordList(data)];
                    case 30:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 31: return [4 /*yield*/, this.getHistoryMeetingTranscriptionInfo(data)];
                    case 32:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 33: return [4 /*yield*/, this.getHistoryMeetingTranscriptionFileUrl(data)];
                    case 34:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 35: return [4 /*yield*/, this.loadWebAppView(data)];
                    case 36:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 37: return [4 /*yield*/, this.fetchChatroomHistoryMessageList(data)];
                    case 38:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 39: return [4 /*yield*/, this.exportChatroomHistoryMessageList(data)];
                    case 40:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 41: return [4 /*yield*/, this.clearLocalHistoryMeetingList()];
                    case 42:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 43: return [4 /*yield*/, this.getHistoryMeetingTranscriptionMessageList(data)];
                    case 44:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 45: return [4 /*yield*/, this.loadChatroomHistoryMessageView(data)];
                    case 46:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 47: return [4 /*yield*/, this.getScheduledMeetingList(data)];
                    case 48:
                        res = _b.sent();
                        return [3 /*break*/, 50];
                    case 49: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'method not found'))];
                    case 50: return [2 /*return*/, JSON.stringify(res)];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getFavoriteMeetingList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, anchorId, limit;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), anchorId = _a.anchorId, limit = _a.limit;
                        return [4 /*yield*/, this._preMeetingService.getFavoriteMeetingList(anchorId, limit)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.addFavoriteMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.addFavoriteMeeting(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.removeFavoriteMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.removeFavoriteMeeting(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeetingList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, anchorId, limit;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), anchorId = _a.anchorId, limit = _a.limit;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeetingList(anchorId, limit)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeetingDetail = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeetingDetail(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeeting(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.createScheduleMeetingItem = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._preMeetingService.createScheduleMeetingItem()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.scheduleMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var item;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        item = JSON.parse(data).item;
                        return [4 /*yield*/, this._preMeetingService.scheduleMeeting(item)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.editMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, item, editRecurringMeeting;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), item = _a.item, editRecurringMeeting = _a.editRecurringMeeting;
                        return [4 /*yield*/, this._preMeetingService.editMeeting(item, editRecurringMeeting)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.cancelMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, meetingId, cancelRecurringMeeting;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), meetingId = _a.meetingId, cancelRecurringMeeting = _a.cancelRecurringMeeting;
                        return [4 /*yield*/, this._preMeetingService.cancelMeeting(meetingId, cancelRecurringMeeting)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getMeetingItemByNum = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingNum;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingNum = JSON.parse(data).meetingNum;
                        return [4 /*yield*/, this._preMeetingService.getMeetingItemByNum(meetingNum)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getMeetingItemById = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.getMeetingItemById(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getMeetingList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var status;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        status = JSON.parse(data).status;
                        return [4 /*yield*/, this._preMeetingService.getMeetingList(status)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getScheduledMeetingMemberList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingNum;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingNum = JSON.parse(data).meetingNum;
                        return [4 /*yield*/, this._preMeetingService.getScheduledMeetingMemberList(meetingNum)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getLocalHistoryMeetingList = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._preMeetingService.getLocalHistoryMeetingList()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.clearLocalHistoryMeetingList = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._preMeetingService.clearLocalHistoryMeetingList()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getMeetingCloudRecordList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.getMeetingCloudRecordList(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeetingTranscriptionInfo = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeetingTranscriptionInfo(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeetingTranscriptionFileUrl = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, meetingId, fileKey;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), meetingId = _a.meetingId, fileKey = _a.fileKey;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeetingTranscriptionFileUrl(meetingId, fileKey)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.loadWebAppView = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, meetingId, item;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), meetingId = _a.meetingId, item = _a.item;
                        return [4 /*yield*/, this._preMeetingService.loadWebAppView(meetingId, item)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.fetchChatroomHistoryMessageList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, meetingId, option;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), meetingId = _a.meetingId, option = _a.option;
                        return [4 /*yield*/, this._preMeetingService.fetchChatroomHistoryMessageList(meetingId, option)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.exportChatroomHistoryMessageList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.exportChatroomHistoryMessageList(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getHistoryMeetingTranscriptionMessageList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, meetingId, fileKey;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), meetingId = _a.meetingId, fileKey = _a.fileKey;
                        return [4 /*yield*/, this._preMeetingService.getHistoryMeetingTranscriptionMessageList(meetingId, fileKey)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.loadChatroomHistoryMessageView = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var meetingId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        meetingId = JSON.parse(data).meetingId;
                        return [4 /*yield*/, this._preMeetingService.loadChatroomHistoryMessageView(meetingId)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEPreMeetingServiceHandle.prototype.getScheduledMeetingList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var status;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        status = JSON.parse(data).status;
                        return [4 /*yield*/, this._preMeetingService.getScheduledMeetingList(status)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    return NEPreMeetingServiceHandle;
}());
exports.default = NEPreMeetingServiceHandle;