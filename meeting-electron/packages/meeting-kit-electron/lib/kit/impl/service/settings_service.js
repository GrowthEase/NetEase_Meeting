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
var MODULE_NAME = 'NESettingsService';
var seqCount = 0;
var NESettingsService = /** @class */ (function (_super) {
    __extends(NESettingsService, _super);
    function NESettingsService(_win) {
        return _super.call(this, _win) || this;
    }
    NESettingsService.prototype.openSettingsWindow = function (type) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'openSettingsWindow';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [type],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.setChatMessageNotificationType = function (type) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setChatMessageNotificationType';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [type],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.enableShowNameInVideo = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableShowNameInVideo';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isShowNameInVideoEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isShowNameInVideoEnabled';
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
    NESettingsService.prototype.isMeetingChatSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingChatSupported';
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
    NESettingsService.prototype.getChatMessageNotificationType = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getChatMessageNotificationType';
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
    /**
     * 设置应用聊天室默认文件下载保存路径
     * @param filePath 聊天室文件保存路径
     */
    NESettingsService.prototype.setChatroomDefaultFileSavePath = function (filePath) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setChatroomDefaultFileSavePath';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [filePath],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    /**
     * 查询应用聊天室文件下载默认保存路径
     */
    NESettingsService.prototype.getChatroomDefaultFileSavePath = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getChatroomDefaultFileSavePath';
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
    NESettingsService.prototype.setCloudRecordConfig = function (config) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setCloudRecordConfig';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [config],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.getCloudRecordConfig = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getCloudRecordConfig';
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
    NESettingsService.prototype.getScheduledMemberConfig = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getScheduledMemberConfig';
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
    NESettingsService.prototype.getInterpretationConfig = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getInterpretationConfig';
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
    NESettingsService.prototype.isGuestJoinSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isGuestJoinSupported';
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
    NESettingsService.prototype.getAppNotifySessionId = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getAppNotifySessionId';
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
    NESettingsService.prototype.isMeetingCloudRecordSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingCloudRecordSupported';
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
    NESettingsService.prototype.isMeetingWhiteboardSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingWhiteboardSupported';
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
    NESettingsService.prototype.isWaitingRoomSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isWaitingRoomSupported';
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
    NESettingsService.prototype.isNicknameUpdateSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isNicknameUpdateSupported';
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
    NESettingsService.prototype.isAvatarUpdateSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isAvatarUpdateSupported';
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
    NESettingsService.prototype.isCaptionsSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isCaptionsSupported';
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
    NESettingsService.prototype.enableShowMyMeetingElapseTime = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableShowMyMeetingElapseTime';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isShowMyMeetingElapseTimeEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isShowMyMeetingElapseTimeEnabled';
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
    NESettingsService.prototype.enableShowMyMeetingParticipationTime = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableShowMyMeetingParticipationTime';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isShowMyMeetingParticipationTimeEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isShowMyMeetingParticipationTimeEnabled';
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
    NESettingsService.prototype.enableHideVideoOffAttendees = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableHideVideoOffAttendees';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isHideVideoOffAttendeesEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isHideVideoOffAttendeesEnabled';
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
    NESettingsService.prototype.enableHideMyVideo = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableHideMyVideo';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isHideMyVideoEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isHideMyVideoEnabled';
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
    NESettingsService.prototype.enableLeaveTheMeetingRequiresConfirmation = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableLeaveTheMeetingRequiresConfirmation';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isLeaveTheMeetingRequiresConfirmationEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isLeaveTheMeetingRequiresConfirmationEnabled';
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
    NESettingsService.prototype.enableAudioAINS = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableAudioAINS';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isAudioAINSEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isAudioAINSEnabled';
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
    NESettingsService.prototype.enableTurnOnMyVideoWhenJoinMeeting = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableTurnOnMyVideoWhenJoinMeeting';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isTurnOnMyVideoWhenJoinMeetingEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isTurnOnMyVideoWhenJoinMeetingEnabled';
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
    NESettingsService.prototype.enableTurnOnMyAudioWhenJoinMeeting = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableTurnOnMyAudioWhenJoinMeeting';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isTurnOnMyAudioWhenJoinMeetingEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isTurnOnMyAudioWhenJoinMeetingEnabled';
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
    NESettingsService.prototype.isBeautyFaceSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isBeautyFaceSupported';
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
    NESettingsService.prototype.isCallOutRoomSystemDeviceSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isCallOutRoomSystemDeviceSupported';
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
    NESettingsService.prototype.getBeautyFaceValue = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getBeautyFaceValue';
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
    NESettingsService.prototype.setBeautyFaceValue = function (value) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setBeautyFaceValue';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [value],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isMeetingLiveSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingLiveSupported';
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
    NESettingsService.prototype.isWaitingRoomEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isWaitingRoomEnabled';
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
    NESettingsService.prototype.isMeetingWhiteboardEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingWhiteboardEnabled';
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
    NESettingsService.prototype.isMeetingCloudRecordEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingCloudRecordEnabled';
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
    NESettingsService.prototype.enableVirtualBackground = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableVirtualBackground';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isVirtualBackgroundEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isVirtualBackgroundEnabled';
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
    NESettingsService.prototype.isVirtualBackgroundSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isVirtualBackgroundSupported';
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
    NESettingsService.prototype.shouldUnpubOnAudioMute = function () {
        var functionName = 'shouldUnpubOnAudioMute';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.setBuiltinVirtualBackgroundList = function (pathList) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setBuiltinVirtualBackgroundList';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [pathList],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.getBuiltinVirtualBackgroundList = function () {
        var functionName = 'getBuiltinVirtualBackgroundList';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.setCurrentVirtualBackground = function (path) {
        var functionName = 'setCurrentVirtualBackground';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [path],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.getCurrentVirtualBackground = function () {
        var functionName = 'getCurrentVirtualBackground';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.setExternalVirtualBackgroundList = function (pathList) {
        var functionName = 'setExternalVirtualBackgroundList';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [pathList],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.getExternalVirtualBackgroundList = function () {
        var functionName = 'getExternalVirtualBackgroundList';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.enableSpeakerSpotlight = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableSpeakerSpotlight';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isSpeakerSpotlightEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isSpeakerSpotlightEnabled';
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
    NESettingsService.prototype.enableShowNotYetJoinedMembers = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableShowNotYetJoinedMembers';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isShowNotYetJoinedMembersEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isShowNotYetJoinedMembersEnabled';
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
    NESettingsService.prototype.enableTransparentWhiteboard = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableTransparentWhiteboard';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isTransparentWhiteboardEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isTransparentWhiteboardEnabled';
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
    NESettingsService.prototype.enableCameraMirror = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableCameraMirror';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isCameraMirrorEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isCameraMirrorEnabled';
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
    NESettingsService.prototype.enableFrontCameraMirror = function (enable) {
        var functionName = 'enableFrontCameraMirror';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [enable],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.isFrontCameraMirrorEnabled = function () {
        var functionName = 'isFrontCameraMirrorEnabled';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.setGalleryModeMaxMemberCount = function (count) {
        var functionName = 'setGalleryModeMaxMemberCount';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [count],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.isTranscriptionSupported = function () {
        var functionName = 'isTranscriptionSupported';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.enableUnmuteAudioByPressSpaceBar = function (enable) {
        var functionName = 'enableUnmuteAudioByPressSpaceBar';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [enable],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.isUnmuteAudioByPressSpaceBarEnabled = function () {
        var functionName = 'isUnmuteAudioByPressSpaceBarEnabled';
        var seqId = this._generateSeqId(functionName);
        this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
            module: MODULE_NAME,
            method: functionName,
            args: [],
            seqId: seqId,
        });
        return this._IpcMainListener(seqId);
    };
    NESettingsService.prototype.setASRTranslationLanguage = function (language) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'setASRTranslationLanguage';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [language],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.getASRTranslationLanguage = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getASRTranslationLanguage';
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
    NESettingsService.prototype.enableCaptionBilingual = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableCaptionBilingual';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isCaptionBilingualEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isCaptionBilingualEnabled';
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
    NESettingsService.prototype.enableTranscriptionBilingual = function (enable) {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'enableTranscriptionBilingual';
                seqId = this._generateSeqId(functionName);
                this._win.webContents.send(meeting_kit_1.BUNDLE_NAME, {
                    module: MODULE_NAME,
                    method: functionName,
                    args: [enable],
                    seqId: seqId,
                });
                return [2 /*return*/, this._IpcMainListener(seqId)];
            });
        });
    };
    NESettingsService.prototype.isTranscriptionBilingualEnabled = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isTranscriptionBilingualEnabled';
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
    NESettingsService.prototype.getLiveMaxThirdPartyCount = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'getLiveMaxThirdPartyCount';
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
    NESettingsService.prototype.isMeetingLiveOfficialPushSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingLiveOfficialPushSupported';
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
    NESettingsService.prototype.isMeetingLiveThirdPartyPushSupported = function () {
        return __awaiter(this, void 0, Promise, function () {
            var functionName, seqId;
            return __generator(this, function (_a) {
                functionName = 'isMeetingLiveThirdPartyPushSupported';
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
    NESettingsService.prototype._generateSeqId = function (functionName) {
        seqCount++;
        return "".concat(meeting_kit_1.BUNDLE_NAME, "::").concat(MODULE_NAME, "::").concat(functionName, "::").concat(seqCount);
    };
    NESettingsService.prototype._IpcMainListener = function (seqId) {
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
    return NESettingsService;
}(meeting_electron_base_service_1.default));
exports.default = NESettingsService;