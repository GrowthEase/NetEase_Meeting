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
var NESettingsServiceHandle = /** @class */ (function () {
    function NESettingsServiceHandle(settingsServic) {
        this._settingsService = settingsServic;
    }
    NESettingsServiceHandle.prototype.onMethodHandle = function (cid, data) {
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
                            case 27: return [3 /*break*/, 27];
                            case 29: return [3 /*break*/, 29];
                            case 31: return [3 /*break*/, 31];
                            case 33: return [3 /*break*/, 33];
                            case 35: return [3 /*break*/, 35];
                            case 37: return [3 /*break*/, 37];
                            case 39: return [3 /*break*/, 39];
                            case 41: return [3 /*break*/, 41];
                            case 43: return [3 /*break*/, 43];
                            case 45: return [3 /*break*/, 45];
                            case 47: return [3 /*break*/, 47];
                            case 49: return [3 /*break*/, 49];
                            case 51: return [3 /*break*/, 51];
                            case 53: return [3 /*break*/, 53];
                            case 55: return [3 /*break*/, 55];
                            case 57: return [3 /*break*/, 57];
                            case 59: return [3 /*break*/, 59];
                            case 61: return [3 /*break*/, 61];
                            case 63: return [3 /*break*/, 63];
                            case 65: return [3 /*break*/, 65];
                            case 67: return [3 /*break*/, 67];
                            case 69: return [3 /*break*/, 69];
                            case 71: return [3 /*break*/, 71];
                            case 73: return [3 /*break*/, 73];
                            case 75: return [3 /*break*/, 75];
                            case 77: return [3 /*break*/, 77];
                            case 79: return [3 /*break*/, 79];
                            case 81: return [3 /*break*/, 81];
                            case 83: return [3 /*break*/, 83];
                            case 85: return [3 /*break*/, 85];
                            case 87: return [3 /*break*/, 87];
                            case 89: return [3 /*break*/, 89];
                            case 91: return [3 /*break*/, 91];
                            case 93: return [3 /*break*/, 93];
                            case 95: return [3 /*break*/, 95];
                            case 97: return [3 /*break*/, 97];
                            case 1099: return [3 /*break*/, 99];
                            case 1101: return [3 /*break*/, 101];
                            case 1103: return [3 /*break*/, 103];
                            case 1105: return [3 /*break*/, 105];
                            case 1107: return [3 /*break*/, 107];
                            case 1109: return [3 /*break*/, 109];
                            case 1111: return [3 /*break*/, 111];
                            case 1113: return [3 /*break*/, 113];
                            case 1115: return [3 /*break*/, 115];
                            case 1117: return [3 /*break*/, 117];
                            case 1119: return [3 /*break*/, 119];
                            case 1121: return [3 /*break*/, 121];
                            case 1123: return [3 /*break*/, 123];
                            case 1125: return [3 /*break*/, 125];
                            case 1127: return [3 /*break*/, 127];
                            case 1129: return [3 /*break*/, 129];
                            case 1131: return [3 /*break*/, 131];
                            case 1133: return [3 /*break*/, 133];
                        }
                        return [3 /*break*/, 135];
                    case 1: return [4 /*yield*/, this.openSettingsWindow()];
                    case 2:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 3: return [4 /*yield*/, this.enableShowMyMeetingElapseTime(data)];
                    case 4:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 5: return [4 /*yield*/, this.isShowMyMeetingElapseTimeEnabled()];
                    case 6:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 7: return [4 /*yield*/, this.enableTurnOnMyVideoWhenJoinMeeting(data)];
                    case 8:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 9: return [4 /*yield*/, this.isTurnOnMyVideoWhenJoinMeetingEnabled()];
                    case 10:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 11: return [4 /*yield*/, this.enableTurnOnMyAudioWhenJoinMeeting(data)];
                    case 12:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 13: return [4 /*yield*/, this.isTurnOnMyAudioWhenJoinMeetingEnabled()];
                    case 14:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 15: return [4 /*yield*/, this.isMeetingLiveSupported()];
                    case 16:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 17: return [4 /*yield*/, this.isMeetingWhiteboardSupported()];
                    case 18:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 19: return [4 /*yield*/, this.isMeetingCloudRecordSupported()];
                    case 20:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 21: return [4 /*yield*/, this.enableAudioAINS(data)];
                    case 22:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 23: return [4 /*yield*/, this.isAudioAINSEnabled()];
                    case 24:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 25: return [4 /*yield*/, this.enableVirtualBackground(data)];
                    case 26:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 27: return [4 /*yield*/, this.isVirtualBackgroundEnabled()];
                    case 28:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 29: return [4 /*yield*/, this.setBuiltinVirtualBackgroundList(data)];
                    case 30:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 31: return [4 /*yield*/, this.getBuiltinVirtualBackgroundList()];
                    case 32:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 33: return [4 /*yield*/, this.setExternalVirtualBackgroundList(data)];
                    case 34:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 35: return [4 /*yield*/, this.getExternalVirtualBackgroundList()];
                    case 36:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 37: return [4 /*yield*/, this.setCurrentVirtualBackground(data)];
                    case 38:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 39: return [4 /*yield*/, this.getCurrentVirtualBackground()];
                    case 40:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 41: return [4 /*yield*/, this.enableSpeakerSpotlight(data)];
                    case 42:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 43: return [4 /*yield*/, this.isSpeakerSpotlightEnabled()];
                    case 44:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 45: return [4 /*yield*/, this.enableCameraMirror(data)];
                    case 46:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 47: return [4 /*yield*/, this.isCameraMirrorEnabled()];
                    case 48:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 49: return [4 /*yield*/, this.enableFrontCameraMirror(data)];
                    case 50:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 51: return [4 /*yield*/, this.isFrontCameraMirrorEnabled()];
                    case 52:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 53: return [4 /*yield*/, this.enableTransparentWhiteboard(data)];
                    case 54:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 55: return [4 /*yield*/, this.isTransparentWhiteboardEnabled()];
                    case 56:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 57: return [4 /*yield*/, this.isBeautyFaceSupported()];
                    case 58:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 59: return [4 /*yield*/, this.getBeautyFaceValue()];
                    case 60:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 61: return [4 /*yield*/, this.setBeautyFaceValue(data)];
                    case 62:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 63: return [4 /*yield*/, this.isWaitingRoomSupported()];
                    case 64:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 65: return [4 /*yield*/, this.isVirtualBackgroundSupported()];
                    case 66:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 67: return [4 /*yield*/, this.setChatroomDefaultFileSavePath(data)];
                    case 68:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 69: return [4 /*yield*/, this.getChatroomDefaultFileSavePath()];
                    case 70:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 71: return [4 /*yield*/, this.setGalleryModeMaxMemberCount(data)];
                    case 72:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 73: return [4 /*yield*/, this.enableUnmuteAudioByPressSpaceBar(data)];
                    case 74:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 75: return [4 /*yield*/, this.isUnmuteAudioByPressSpaceBarEnabled()];
                    case 76:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 77: return [4 /*yield*/, this.isGuestJoinSupported()];
                    case 78:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 79: return [4 /*yield*/, this.isTranscriptionSupported()];
                    case 80:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 81: return [4 /*yield*/, this.getInterpretationConfig()];
                    case 82:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 83: return [4 /*yield*/, this.getScheduledMemberConfig()];
                    case 84:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 85: return [4 /*yield*/, this.isNicknameUpdateSupported()];
                    case 86:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 87: return [4 /*yield*/, this.isAvatarUpdateSupported()];
                    case 88:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 89: return [4 /*yield*/, this.isCaptionsSupported()];
                    case 90:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 91: return [4 /*yield*/, this.setASRTranslationLanguage(data)];
                    case 92:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 93: return [4 /*yield*/, this.getASRTranslationLanguage()];
                    case 94:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 95: return [4 /*yield*/, this.enableCaptionBilingual(data)];
                    case 96:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 97: return [4 /*yield*/, this.isCaptionBilingualEnabled()];
                    case 98:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 99: return [4 /*yield*/, this.enableTranscriptionBilingual(data)];
                    case 100:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 101: return [4 /*yield*/, this.isTranscriptionBilingualEnabled()];
                    case 102:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 103: return [4 /*yield*/, this.isMeetingChatSupported()];
                    case 104:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 105: return [4 /*yield*/, this.enableShowNotYetJoinedMembers(data)];
                    case 106:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 107: return [4 /*yield*/, this.isShowNotYetJoinedMembersEnabled()];
                    case 108:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 109: return [4 /*yield*/, this.setChatMessageNotificationType(data)];
                    case 110:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 111: return [4 /*yield*/, this.getChatMessageNotificationType()];
                    case 112:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 113: return [4 /*yield*/, this.isShowNameInVideoEnabled()];
                    case 114:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 115: return [4 /*yield*/, this.enableShowNameInVideo(data)];
                    case 116:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 117: return [4 /*yield*/, this.isHideMyVideoEnabled()];
                    case 118:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 119: return [4 /*yield*/, this.enableHideMyVideo(data)];
                    case 120:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 121: return [4 /*yield*/, this.enableHideVideoOffAttendees(data)];
                    case 122:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 123: return [4 /*yield*/, this.isHideVideoOffAttendeesEnabled()];
                    case 124:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 125: return [4 /*yield*/, this.enableShowMyMeetingParticipationTime(data)];
                    case 126:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 127: return [4 /*yield*/, this.isShowMyMeetingParticipationTimeEnabled()];
                    case 128:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 129: return [4 /*yield*/, this.isCallOutRoomSystemDeviceSupported()];
                    case 130:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 131: return [4 /*yield*/, this.enableLeaveTheMeetingRequiresConfirmation(data)];
                    case 132:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 133: return [4 /*yield*/, this.isLeaveTheMeetingRequiresConfirmationEnabled()];
                    case 134:
                        res = _b.sent();
                        return [3 /*break*/, 136];
                    case 135: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'method not found'))];
                    case 136: return [2 /*return*/, JSON.stringify(res)];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.openSettingsWindow = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.openSettingsWindow()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableShowMyMeetingElapseTime = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableShowMyMeetingElapseTime(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isShowMyMeetingElapseTimeEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isShowMyMeetingElapseTimeEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableShowNotYetJoinedMembers = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableShowNotYetJoinedMembers(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isShowNotYetJoinedMembersEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isShowNotYetJoinedMembersEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableTurnOnMyVideoWhenJoinMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableTurnOnMyVideoWhenJoinMeeting(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isTurnOnMyVideoWhenJoinMeetingEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableTurnOnMyAudioWhenJoinMeeting = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableTurnOnMyAudioWhenJoinMeeting(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isTurnOnMyAudioWhenJoinMeetingEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isMeetingLiveSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isMeetingLiveSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isMeetingWhiteboardSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isMeetingWhiteboardSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isMeetingCloudRecordSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isMeetingCloudRecordSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableAudioAINS = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableAudioAINS(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isAudioAINSEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isAudioAINSEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableVirtualBackground = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableVirtualBackground(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isVirtualBackgroundEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isVirtualBackgroundEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setBuiltinVirtualBackgroundList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var pathList;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        pathList = JSON.parse(data).pathList;
                        return [4 /*yield*/, this._settingsService.setBuiltinVirtualBackgroundList(pathList)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getBuiltinVirtualBackgroundList = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getBuiltinVirtualBackgroundList()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setExternalVirtualBackgroundList = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var pathList;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        pathList = JSON.parse(data).pathList;
                        return [4 /*yield*/, this._settingsService.setExternalVirtualBackgroundList(pathList)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getExternalVirtualBackgroundList = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getExternalVirtualBackgroundList()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setCurrentVirtualBackground = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var path;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        path = JSON.parse(data).path;
                        return [4 /*yield*/, this._settingsService.setCurrentVirtualBackground(path)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getCurrentVirtualBackground = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getCurrentVirtualBackground()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableSpeakerSpotlight = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableSpeakerSpotlight(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isSpeakerSpotlightEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isSpeakerSpotlightEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableCameraMirror = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableCameraMirror(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isCameraMirrorEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isCameraMirrorEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableFrontCameraMirror = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableFrontCameraMirror(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isFrontCameraMirrorEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isFrontCameraMirrorEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableTransparentWhiteboard = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableTransparentWhiteboard(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isTransparentWhiteboardEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isTransparentWhiteboardEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isBeautyFaceSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isBeautyFaceSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setBeautyFaceValue = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var value;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        value = JSON.parse(data).value;
                        return [4 /*yield*/, this._settingsService.setBeautyFaceValue(value)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getBeautyFaceValue = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getBeautyFaceValue()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isWaitingRoomSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isWaitingRoomSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isVirtualBackgroundSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isVirtualBackgroundSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setChatroomDefaultFileSavePath = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var filePath;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        filePath = JSON.parse(data).filePath;
                        return [4 /*yield*/, this._settingsService.setChatroomDefaultFileSavePath(filePath)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getChatroomDefaultFileSavePath = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getChatroomDefaultFileSavePath()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setGalleryModeMaxMemberCount = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var count;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        count = JSON.parse(data).count;
                        return [4 /*yield*/, this._settingsService.setGalleryModeMaxMemberCount(count)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableUnmuteAudioByPressSpaceBar = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableUnmuteAudioByPressSpaceBar(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isUnmuteAudioByPressSpaceBarEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isUnmuteAudioByPressSpaceBarEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isGuestJoinSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isGuestJoinSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isTranscriptionSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isTranscriptionSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getInterpretationConfig = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getInterpretationConfig];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getScheduledMemberConfig = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getScheduledMemberConfig()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isNicknameUpdateSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isNicknameUpdateSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isAvatarUpdateSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isAvatarUpdateSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isCaptionsSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isCaptionsSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isMeetingChatSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isMeetingChatSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setChatMessageNotificationType = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var type;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        type = JSON.parse(data).type;
                        return [4 /*yield*/, this._settingsService.setChatMessageNotificationType(type)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getChatMessageNotificationType = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getChatMessageNotificationType()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.setASRTranslationLanguage = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var language;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        language = JSON.parse(data).language;
                        return [4 /*yield*/, this._settingsService.setASRTranslationLanguage(language)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.getASRTranslationLanguage = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.getASRTranslationLanguage()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableCaptionBilingual = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableCaptionBilingual(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isCaptionBilingualEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isCaptionBilingualEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableTranscriptionBilingual = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableTranscriptionBilingual(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isTranscriptionBilingualEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isTranscriptionBilingualEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableShowNameInVideo = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableShowNameInVideo(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isShowNameInVideoEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isShowNameInVideoEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableShowMyMeetingParticipationTime = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableShowMyMeetingParticipationTime(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isShowMyMeetingParticipationTimeEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isShowMyMeetingParticipationTimeEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableHideVideoOffAttendees = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableHideVideoOffAttendees(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isHideVideoOffAttendeesEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isHideVideoOffAttendeesEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableHideMyVideo = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableHideMyVideo(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isHideMyVideoEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isHideMyVideoEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.enableLeaveTheMeetingRequiresConfirmation = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var enable;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        enable = JSON.parse(data).enable;
                        return [4 /*yield*/, this._settingsService.enableLeaveTheMeetingRequiresConfirmation(enable)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isLeaveTheMeetingRequiresConfirmationEnabled = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isLeaveTheMeetingRequiresConfirmationEnabled()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NESettingsServiceHandle.prototype.isCallOutRoomSystemDeviceSupported = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._settingsService.isCallOutRoomSystemDeviceSupported()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    return NESettingsServiceHandle;
}());
exports.default = NESettingsServiceHandle;