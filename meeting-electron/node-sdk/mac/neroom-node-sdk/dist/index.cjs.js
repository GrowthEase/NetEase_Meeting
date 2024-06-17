'use strict';

/******************************************************************************
Copyright (c) Microsoft Corporation.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
***************************************************************************** */

var __assign = function() {
  __assign = Object.assign || function __assign(t) {
      for (var s, i = 1, n = arguments.length; i < n; i++) {
          s = arguments[i];
          for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
      }
      return t;
  };
  return __assign.apply(this, arguments);
};

function __awaiter(thisArg, _arguments, P, generator) {
  function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
  return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
      function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
      function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
  });
}

function __generator(thisArg, body) {
  var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
  return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
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
}

function __read(o, n) {
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
}

function __spreadArray(to, from, pack) {
  if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
      if (ar || !(i in from)) {
          if (!ar) ar = Array.prototype.slice.call(from, 0, i);
          ar[i] = from[i];
      }
  }
  return to.concat(ar || Array.prototype.slice.call(from));
}

typeof SuppressedError === "function" ? SuppressedError : function (error, suppressed, message) {
  var e = new Error(message);
  return e.name = "SuppressedError", e.error = error, e.suppressed = suppressed, e;
};

/**
 * 储存器
 * @ignore
 */
/**
 * 客户端类型
 * @ignore
 */
var NEClientType;
(function (NEClientType) {
    NEClientType["WEB"] = "web";
    NEClientType["ANDROID"] = "android";
    NEClientType["IOS"] = "ios";
    NEClientType["PC"] = "pc";
    NEClientType["MINIAPP"] = "miniApp";
    NEClientType["MAC"] = "mac";
    NEClientType["SIP"] = "SIP";
    NEClientType["UNKNOWN"] = "unknown";
})(NEClientType || (NEClientType = {}));
var NEMediaTypeEnum;
(function (NEMediaTypeEnum) {
    NEMediaTypeEnum["Audio"] = "audio";
    NEMediaTypeEnum["Video"] = "video";
    NEMediaTypeEnum["Screen"] = "screen";
    NEMediaTypeEnum["AudioSlave"] = "audioSlave";
})(NEMediaTypeEnum || (NEMediaTypeEnum = {}));
/**
 * 房间事件枚举
 * @ignore
 */
var NERoomEvent;
(function (NERoomEvent) {
    NERoomEvent["MEMBER_AUDIO_MUTE_CHANGED"] = "memberAudioMuteChanged";
    NERoomEvent["MEMBER_JOIN_CHATROOM"] = "memberJoinChatroom";
    NERoomEvent["MEMBER_JOIN_ROOM"] = "memberJoinRoom";
    NERoomEvent["MEMBER_JOIN_RTC_CHANNEL"] = "memberJoinRtcChannel";
    NERoomEvent["MEMBER_LEAVE_CHATROOM"] = "memberLeaveChatroom";
    NERoomEvent["MEMBER_LEAVE_ROOM"] = "memberLeaveRoom";
    NERoomEvent["MEMBER_LEAVE_RT_CHANNEL"] = "memberLeaveRtcChannel";
    NERoomEvent["MEMBER_ROLE_CHANGED"] = "memberRoleChanged";
    NERoomEvent["MEMBER_SCREEN_SHARE_STATE_CHANGED"] = "memberScreenShareStateChanged";
    NERoomEvent["MEMBER_VIDEO_MUTE_CHANGED"] = "memberVideoMuteChanged";
    NERoomEvent["MEMBER_WHITEBOARD_STATE_CHANGED"] = "memberWhiteboardStateChanged";
    NERoomEvent["MEMBER_WHITEBOARD_PERMISSION_CHANGED"] = "memberWhiteboardPermissionChanged";
    NERoomEvent["RECEIVE_CHATROOM_MESSAGES"] = "receiveChatroomMessages";
    NERoomEvent["ROOM_ENDED"] = "roomEnded";
    NERoomEvent["RTC_CHANNEL_ERROR"] = "rtcChannelError";
    NERoomEvent["SYNC_DATA_ERROR"] = "syncDataError";
    NERoomEvent["SYNC_DATA_DONE"] = "syncDataDone";
})(NERoomEvent || (NERoomEvent = {}));
/**
 * IM通知事件枚举
 * @ignore
 */
var NERoomEventFromServer;
(function (NERoomEventFromServer) {
    NERoomEventFromServer[NERoomEventFromServer["ROOM_STATE_CHANGED"] = 1] = "ROOM_STATE_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["ROOM_STATE_DELETE"] = 2] = "ROOM_STATE_DELETE";
    NERoomEventFromServer[NERoomEventFromServer["ROOM_PROPERTIES_CHANGED"] = 10] = "ROOM_PROPERTIES_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["ROOM_PROPERTIES_DELETE"] = 11] = "ROOM_PROPERTIES_DELETE";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_PROPERTIES_CHANGED"] = 20] = "MEMBER_PROPERTIES_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_PROPERTIES_DELETE"] = 21] = "MEMBER_PROPERTIES_DELETE";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_JOIN_ROOM"] = 30] = "MEMBER_JOIN_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_LEAVE_ROOM"] = 33] = "MEMBER_LEAVE_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_JOIN_RTC_ROOM"] = 32] = "MEMBER_JOIN_RTC_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_LEAVE_RTC_ROOM"] = 31] = "MEMBER_LEAVE_RTC_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_JOIN_CHATROOM_ROOM"] = 34] = "MEMBER_JOIN_CHATROOM_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_LEAVE_CHATROOM_ROOM"] = 35] = "MEMBER_LEAVE_CHATROOM_ROOM";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_STREAM_STATE_CHANGED"] = 40] = "MEMBER_STREAM_STATE_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_STREAM_STATE_DELETE"] = 41] = "MEMBER_STREAM_STATE_DELETE";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_STREAM_STATE_INIT"] = 42] = "MEMBER_STREAM_STATE_INIT";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_ROLE_TYPE_CHANGED"] = 70] = "MEMBER_ROLE_TYPE_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["MEMBER_NICKNAME_CHANGED"] = 71] = "MEMBER_NICKNAME_CHANGED";
    NERoomEventFromServer[NERoomEventFromServer["ROOM_ENDED"] = 51] = "ROOM_ENDED";
    NERoomEventFromServer[NERoomEventFromServer["PASS_THROUGH_MESSAGE"] = 99] = "PASS_THROUGH_MESSAGE";
    NERoomEventFromServer[NERoomEventFromServer["ROOM_LIVE_STATE_CHANGED"] = 111] = "ROOM_LIVE_STATE_CHANGED";
})(NERoomEventFromServer || (NERoomEventFromServer = {}));
/**
 * 登录事件枚举
 */
var NEAuthEvent;
(function (NEAuthEvent) {
    /**
     * 被踢出登录
     */
    NEAuthEvent[NEAuthEvent["KICK_OUT"] = 0] = "KICK_OUT";
    /**
     * 授权失败
     */
    NEAuthEvent[NEAuthEvent["UNAUTHORIZED"] = 1] = "UNAUTHORIZED";
    /**
     * 服务端禁止登录
     */
    NEAuthEvent[NEAuthEvent["FORBIDDEN"] = 2] = "FORBIDDEN";
    /**
     * 账号或密码错误
     */
    NEAuthEvent[NEAuthEvent["ACCOUNT_TOKEN_ERROR"] = 3] = "ACCOUNT_TOKEN_ERROR";
    /**
     * 登录成功
     */
    NEAuthEvent[NEAuthEvent["LOGGED_IN"] = 4] = "LOGGED_IN";
    /**
     * 未登录
     */
    NEAuthEvent[NEAuthEvent["LOGGED_OUT"] = 5] = "LOGGED_OUT";
    /**
     * token过期
     */
    NEAuthEvent[NEAuthEvent["TOKEN_EXPIRED"] = 1026] = "TOKEN_EXPIRED";
    /**
     * token 不正确
     */
    NEAuthEvent[NEAuthEvent["TOKEN_INCORRECT"] = 1027] = "TOKEN_INCORRECT";
})(NEAuthEvent || (NEAuthEvent = {}));
/**
 * 预览设备改变事件
 * @ignore
 */
var NEPreviewDeviceChangeEvent;
(function (NEPreviewDeviceChangeEvent) {
    NEPreviewDeviceChangeEvent[NEPreviewDeviceChangeEvent["ACTIVE"] = 0] = "ACTIVE";
    NEPreviewDeviceChangeEvent[NEPreviewDeviceChangeEvent["INACTIVE"] = 1] = "INACTIVE";
    NEPreviewDeviceChangeEvent[NEPreviewDeviceChangeEvent["CHANGED"] = 2] = "CHANGED";
})(NEPreviewDeviceChangeEvent || (NEPreviewDeviceChangeEvent = {}));
var NERoomChatMessageType;
(function (NERoomChatMessageType) {
    NERoomChatMessageType["TEXT"] = "text";
    NERoomChatMessageType["IMAGE"] = "image";
    NERoomChatMessageType["AUDIO"] = "audio";
    NERoomChatMessageType["VIDEO"] = "video";
    NERoomChatMessageType["FILE"] = "file";
    NERoomChatMessageType["GEO"] = "geo";
    NERoomChatMessageType["CUSTOM"] = "custom";
    NERoomChatMessageType["TIP"] = "tip";
    NERoomChatMessageType["NOTIFICATION"] = "notification";
    NERoomChatMessageType["ATTACHSTR"] = "attachStr";
})(NERoomChatMessageType || (NERoomChatMessageType = {}));
// 房间结束类型
var NERoomEndReason;
(function (NERoomEndReason) {
    NERoomEndReason["UNKNOWN"] = "UNKNOWN";
    NERoomEndReason["LOGIN_STATE_ERROR"] = "LOGIN_STATE_ERROR";
    NERoomEndReason["CLOSE_BY_BACKEND"] = "CLOSE_BY_BACKEND";
    NERoomEndReason["ALL_MEMBERS_OUT"] = "ALL_MEMBERS_OUT";
    NERoomEndReason["END_OF_LIFE"] = "END_OF_LIFE";
    NERoomEndReason["CLOSE_BY_MEMBER"] = "CLOSE_BY_MEMBER";
    NERoomEndReason["KICK_OUT"] = "KICK_OUT";
    NERoomEndReason["SYNC_DATA_ERROR"] = "SYNC_DATA_ERROR";
    NERoomEndReason["LEAVE_BY_SELF"] = "LEAVE_BY_SELF";
    NERoomEndReason["kICK_BY_SELF"] = "kICK_BY_SELF";
})(NERoomEndReason || (NERoomEndReason = {}));
var ServiceType;
(function (ServiceType) {
    ServiceType["NEAuthService"] = "authService";
    ServiceType["NERoomService"] = "roomService";
    ServiceType["NEMessageService"] = "messageService";
})(ServiceType || (ServiceType = {}));
var NEErrorCode;
(function (NEErrorCode) {
    NEErrorCode[NEErrorCode["FAILURE"] = -1] = "FAILURE";
    NEErrorCode[NEErrorCode["SUCCESS"] = 0] = "SUCCESS";
    NEErrorCode[NEErrorCode["UNAUTHORIZED"] = 402] = "UNAUTHORIZED";
    NEErrorCode[NEErrorCode["TOKEN_EXPIRED"] = 1026] = "TOKEN_EXPIRED";
    NEErrorCode[NEErrorCode["TOKEN_INCORRECT"] = 1027] = "TOKEN_INCORRECT";
    NEErrorCode[NEErrorCode["IM_REUSE_NOT_LOGIN"] = 100004] = "IM_REUSE_NOT_LOGIN";
    NEErrorCode[NEErrorCode["IM_REUSE_ACCOUNT_NOT_MATCH"] = 100005] = "IM_REUSE_ACCOUNT_NOT_MATCH";
})(NEErrorCode || (NEErrorCode = {}));
var NEErrorMessage;
(function (NEErrorMessage) {
    NEErrorMessage["SUCCESS"] = "success";
    NEErrorMessage["FAILURE"] = "failure";
    NEErrorMessage["NOT_SUPPORT"] = "not support";
    NEErrorMessage["NOT_INIT_RTC"] = "not init rtc";
    NEErrorMessage["NOT_INIT_CHATROOM"] = "not init chatroom";
    NEErrorMessage["NOT_JOIN_ROOMKIT"] = "not join roomkit";
    NEErrorMessage["NOT_JOIN_RTC"] = "not join rtc";
    NEErrorMessage["NOT_JOIN_WHITEBOARD"] = "not join whiteboard";
    NEErrorMessage["NOT_INIT_PREVIEW"] = "not init preview";
    NEErrorMessage["NOT_JOIN_CHATROOM"] = "not join chatroom";
    NEErrorMessage["CHATROOM_JOIN_FAIL"] = "join chatroom fail";
    NEErrorMessage["NO_UUID"] = "lack of uuid";
    NEErrorMessage["NO_DEVICEID"] = "no deviceId";
    NEErrorMessage["GET_REMOTE_MEMBER_FAILED_BY_UUID"] = "get remote member fail by uuid";
    NEErrorMessage["NO_MESSAGE_CONTENT"] = "lack of message content";
    NEErrorMessage["NO_APPKEY"] = "lack of appKey";
    NEErrorMessage["NOT_OPEN_VIDEO"] = "not open video";
    NEErrorMessage["NOT_SHARING_SCREEN"] = "Member is not sharing screen";
    NEErrorMessage["MEMBER_IS_EMPTY"] = "Member is empty";
    NEErrorMessage["PARAMS_IS_INCORRECT"] = "params is incorrect";
})(NEErrorMessage || (NEErrorMessage = {}));
/**
 * 接口操作状态码
 * @ignore
 */
var OperateCodeForApi;
(function (OperateCodeForApi) {
    OperateCodeForApi[OperateCodeForApi["OPEN"] = 1] = "OPEN";
    OperateCodeForApi[OperateCodeForApi["CLOSE"] = 0] = "CLOSE";
})(OperateCodeForApi || (OperateCodeForApi = {}));
var IM_EVENT;
(function (IM_EVENT) {
    IM_EVENT["CHATROOM_MESSAGE_RECEIVE"] = "chatroomMessagesReceive";
    IM_EVENT["CHATROOM_FILE_UPLOAD_PROGRESS"] = "chatroomFileUploadProgress";
})(IM_EVENT || (IM_EVENT = {}));
var HTTP_EVENT;
(function (HTTP_EVENT) {
    HTTP_EVENT["UNAUTHORIZED"] = "unauthorized";
    HTTP_EVENT["TOKEN_EXPIRED"] = "tokenExpired";
    HTTP_EVENT["TOKEN_INCORRECT"] = "tokenIncorrect";
})(HTTP_EVENT || (HTTP_EVENT = {}));
/**
 * RTC事件枚举
 * @ignore
 */
var RTC_EVENT;
(function (RTC_EVENT) {
    RTC_EVENT["STREAM_ADDED"] = "streamAdded";
    RTC_EVENT["STREAM_REMOVED"] = "streamRemoved";
    RTC_EVENT["STREAM_SUBSCRIBED"] = "streamSubscribed";
    RTC_EVENT["NETWORK_QUALITY"] = "network-quality";
    RTC_EVENT["CLIENT_BANNED"] = "clientBanned";
    RTC_EVENT["CHANNEL_CLOSED"] = "channelClosed";
    RTC_EVENT["CONNECTION_STATE_CHHANGE"] = "connectionStateChange";
    RTC_EVENT["STOP_SCREEN_SHARE"] = "stopScreenShare";
    RTC_EVENT["VOLUME_INDICATOR"] = "volume-indicator";
    RTC_EVENT["PEER_ONLINE"] = "peer-online";
    RTC_EVENT["PEER_LEAVE"] = "peer-leave";
    RTC_EVENT["RTC_STATS"] = "rtcStats";
    RTC_EVENT["ACTIVE_SPEAKER"] = "activeSpeaker";
    RTC_EVENT["DISCONNECTED"] = "disconnected";
    RTC_EVENT["OPEN"] = "open";
    RTC_EVENT["WILLRECONNECT"] = "willreconnect";
    RTC_EVENT["RECONNECTED"] = "reconnected";
    RTC_EVENT["SENDCOMMANDOVERTIME"] = "sendCommandOverTime";
    RTC_EVENT["ERROR"] = "error";
    RTC_EVENT["ROLE_CHANGED"] = "roleChanged";
    RTC_EVENT["SYNCDONE"] = "syncDone";
    RTC_EVENT["MUTE_AUDIO"] = "muteAudio";
    RTC_EVENT["MUTE_VIDEO"] = "muteVideo";
    RTC_EVENT["UNMUTE_VIDEO"] = "unmuteVideo";
    RTC_EVENT["UNMUTE_AUDIO"] = "unmuteAudio";
    RTC_EVENT["ABILITY_NOT_SUPPORT"] = "ability-not-support";
    RTC_EVENT["RECORD_DEVICES_CHANGE"] = "recording-device-changed";
    RTC_EVENT["CAMERA_DEVICE_CHANGE"] = "camera-changed";
    RTC_EVENT["SPEAKER_DEVICE_CHANGE"] = "playout-device-changed";
    RTC_EVENT["CONNECTION_STATE_CHANGE"] = "connection-state-change";
    RTC_EVENT["VIDEO_TRACK_ENDED"] = "videoTrackEnded";
    RTC_EVENT["MINIAPP_STREAM_CHANGED"] = "miniapp-stream-changed";
    RTC_EVENT["ACCESS_DENIED"] = "accessDenied";
    RTC_EVENT["UNMUTE_SCREEN"] = "unmute-screen";
    RTC_EVENT["NOTALLOWEDERROR"] = "notAllowedError";
    RTC_EVENT["START_SCREEN_AUDIO"] = "startScreenAudio";
    RTC_EVENT["STOP_SCREEN_AUDIO"] = "stopScreenAudio";
})(RTC_EVENT || (RTC_EVENT = {}));
/**
 * 房间内行为类型枚举
 * @ignore
 */
var NEActionType;
(function (NEActionType) {
    NEActionType[NEActionType["kickout"] = 0] = "kickout";
    NEActionType[NEActionType["muteVideo"] = 10] = "muteVideo";
    NEActionType[NEActionType["muteAudio"] = 11] = "muteAudio";
    NEActionType[NEActionType["muteAllAudio"] = 12] = "muteAllAudio";
    NEActionType[NEActionType["lockRoom"] = 13] = "lockRoom";
    NEActionType[NEActionType["unmuteVideo"] = 15] = "unmuteVideo";
    NEActionType[NEActionType["unmuteAudio"] = 16] = "unmuteAudio";
    NEActionType[NEActionType["unmuteAllAudio"] = 17] = "unmuteAllAudio";
    NEActionType[NEActionType["unlockRoom"] = 18] = "unlockRoom";
    NEActionType[NEActionType["muteAllVideo"] = 20] = "muteAllVideo";
    NEActionType[NEActionType["unmuteAllVideo"] = 21] = "unmuteAllVideo";
    NEActionType[NEActionType["changeHost"] = 22] = "changeHost";
    NEActionType[NEActionType["focusVideo"] = 30] = "focusVideo";
    NEActionType[NEActionType["unfocusVideo"] = 31] = "unfocusVideo";
    NEActionType[NEActionType["hangUp"] = 32] = "hangUp";
    NEActionType[NEActionType["unHangUp"] = 33] = "unHangUp";
    NEActionType[NEActionType["forceMuteAllAudio"] = 40] = "forceMuteAllAudio";
    NEActionType[NEActionType["acceptHandsUp"] = 41] = "acceptHandsUp";
    NEActionType[NEActionType["rejectHandsUp"] = 42] = "rejectHandsUp";
    NEActionType[NEActionType["muteVideoBySelf"] = 50] = "muteVideoBySelf";
    NEActionType[NEActionType["muteAudioBySelf"] = 51] = "muteAudioBySelf";
    NEActionType[NEActionType["stopScreenShareBySelf"] = 52] = "stopScreenShareBySelf";
    NEActionType[NEActionType["stopScreenShare"] = 53] = "stopScreenShare";
    NEActionType[NEActionType["unmuteVideoBySelf"] = 55] = "unmuteVideoBySelf";
    NEActionType[NEActionType["unmuteAudioBySelf"] = 56] = "unmuteAudioBySelf";
    NEActionType[NEActionType["startScreenShareBySelf"] = 57] = "startScreenShareBySelf";
    NEActionType[NEActionType["handsUp"] = 58] = "handsUp";
    NEActionType[NEActionType["unHandsUp"] = 59] = "unHandsUp";
    NEActionType[NEActionType["startWhiteBoard"] = 60] = "startWhiteBoard";
    NEActionType[NEActionType["stopWhiteBoard"] = 61] = "stopWhiteBoard";
    NEActionType[NEActionType["enableWhiteBoard"] = 62] = "enableWhiteBoard";
    NEActionType[NEActionType["disableWhiteBoard"] = 63] = "disableWhiteBoard";
    NEActionType[NEActionType["common"] = 66] = "common";
    NEActionType[NEActionType["transformAudioToVideo"] = 67] = "transformAudioToVideo";
    NEActionType[NEActionType["transformVideoToAudio"] = 68] = "transformVideoToAudio";
    NEActionType[NEActionType["audioStateChanged"] = 100] = "audioStateChanged";
    NEActionType[NEActionType["videoStateChanged"] = 101] = "videoStateChanged";
    NEActionType[NEActionType["focusVideoChanged"] = 102] = "focusVideoChanged";
    NEActionType[NEActionType["hostChanged"] = 103] = "hostChanged";
    NEActionType[NEActionType["roleTypeChanged"] = 23] = "roleTypeChanged";
    NEActionType[NEActionType["roomNameChanged"] = 104] = "roomNameChanged";
    NEActionType[NEActionType["screenShareChanged"] = 105] = "screenShareChanged";
    NEActionType[NEActionType["memberComeBack"] = 106] = "memberComeBack";
    NEActionType[NEActionType["lockStateChanged"] = 107] = "lockStateChanged";
    NEActionType[NEActionType["memberKickedOut"] = 108] = "memberKickedOut";
    NEActionType[NEActionType["kickedOutByOtherClient"] = 109] = "kickedOutByOtherClient";
    NEActionType[NEActionType["roomInfoChanged"] = 110] = "roomInfoChanged";
    NEActionType[NEActionType["memberHandsUp"] = 111] = "memberHandsUp";
    NEActionType[NEActionType["passwordChangedByOtherClient"] = 1000] = "passwordChangedByOtherClient";
})(NEActionType || (NEActionType = {}));
var NEVideoStreamType;
(function (NEVideoStreamType) {
    NEVideoStreamType[NEVideoStreamType["HIGH"] = 0] = "HIGH";
    NEVideoStreamType[NEVideoStreamType["LOW"] = 1] = "LOW";
})(NEVideoStreamType || (NEVideoStreamType = {}));
var NetworkStatus;
(function (NetworkStatus) {
    NetworkStatus[NetworkStatus["UNKNOWN"] = 0] = "UNKNOWN";
    NetworkStatus[NetworkStatus["EXCELLENT"] = 1] = "EXCELLENT";
    NetworkStatus[NetworkStatus["GOOD"] = 2] = "GOOD";
    NetworkStatus[NetworkStatus["POOR"] = 3] = "POOR";
    NetworkStatus[NetworkStatus["BAD"] = 4] = "BAD";
    NetworkStatus[NetworkStatus["VERYBAD"] = 5] = "VERYBAD";
    NetworkStatus[NetworkStatus["DOWN"] = 6] = "DOWN";
})(NetworkStatus || (NetworkStatus = {}));
var StreamType;
(function (StreamType) {
    StreamType["AUDIO_DEVICE"] = "audio_device";
    StreamType["VIDEO_DEVICE"] = "video_device";
    StreamType["AUDIO"] = "audio";
    StreamType["VIDEO"] = "video";
    StreamType["SUB_VIDEO"] = "subVideo";
})(StreamType || (StreamType = {}));
var NERoomLiveStreamAudioSampleRate;
(function (NERoomLiveStreamAudioSampleRate) {
    NERoomLiveStreamAudioSampleRate[NERoomLiveStreamAudioSampleRate["SAMPLE_RATE_32000"] = 32000] = "SAMPLE_RATE_32000";
    NERoomLiveStreamAudioSampleRate[NERoomLiveStreamAudioSampleRate["SAMPLE_RATE_44100"] = 44100] = "SAMPLE_RATE_44100";
    NERoomLiveStreamAudioSampleRate[NERoomLiveStreamAudioSampleRate["SAMPLE_RATE_48000"] = 48000] = "SAMPLE_RATE_48000";
})(NERoomLiveStreamAudioSampleRate || (NERoomLiveStreamAudioSampleRate = {}));
var NERoomLiveStreamAudioCodecProfile;
(function (NERoomLiveStreamAudioCodecProfile) {
    NERoomLiveStreamAudioCodecProfile[NERoomLiveStreamAudioCodecProfile["LC-AAC"] = 0] = "LC-AAC";
    NERoomLiveStreamAudioCodecProfile[NERoomLiveStreamAudioCodecProfile["HE-AAC"] = 1] = "HE-AAC";
})(NERoomLiveStreamAudioCodecProfile || (NERoomLiveStreamAudioCodecProfile = {}));
var NERoomLiveLayout;
(function (NERoomLiveLayout) {
    /** 无布局 */
    NERoomLiveLayout[NERoomLiveLayout["NONE"] = 0] = "NONE";
    /** 画廊布局 */
    NERoomLiveLayout[NERoomLiveLayout["GALLERY"] = 1] = "GALLERY";
    /** 焦点布局 */
    NERoomLiveLayout[NERoomLiveLayout["FOCUS"] = 2] = "FOCUS";
    /** 共享屏幕布局 */
    NERoomLiveLayout[NERoomLiveLayout["SCREEN_SHARE"] = 4] = "SCREEN_SHARE";
})(NERoomLiveLayout || (NERoomLiveLayout = {}));
var NERoomLiveState;
(function (NERoomLiveState) {
    /** 无效状态 */
    NERoomLiveState[NERoomLiveState["INVALID"] = 0] = "INVALID";
    /** 初始状态 */
    NERoomLiveState[NERoomLiveState["INIT"] = 1] = "INIT";
    /** 直播中状态 */
    NERoomLiveState[NERoomLiveState["STARTED"] = 2] = "STARTED";
    /** 直播结束状态 */
    NERoomLiveState[NERoomLiveState["ENDED"] = 3] = "ENDED";
})(NERoomLiveState || (NERoomLiveState = {}));
var NEChatRoomMemberQueryType;
(function (NEChatRoomMemberQueryType) {
    /**
     * 固定成员（包括创建者,管理员,普通等级用户,受限用户(禁言+黑名单),即使非在线也可以在列表中看到,有数量限制 ）
     */
    NEChatRoomMemberQueryType[NEChatRoomMemberQueryType["NORMAL"] = 0] = "NORMAL";
    /**
     * 仅在线的固定成员
     */
    NEChatRoomMemberQueryType[NEChatRoomMemberQueryType["ONLINE_NORMAL"] = 1] = "ONLINE_NORMAL";
    /**
     * 非固定成员 (又称临时成员,只有在线时才能在列表中看到,数量无上限) 按照进入聊天室时间倒序排序，进入时间越晚的越靠前
     */
    NEChatRoomMemberQueryType[NEChatRoomMemberQueryType["GUEST_DESC"] = 2] = "GUEST_DESC";
    /**
     * 非固定成员 (又称临时成员,只有在线时才能在列表中看到,数量无上限) 按照进入聊天室时间顺序排序，进入时间越早的越靠前
     */
    NEChatRoomMemberQueryType[NEChatRoomMemberQueryType["GUEST_ASC"] = 3] = "GUEST_ASC";
})(NEChatRoomMemberQueryType || (NEChatRoomMemberQueryType = {}));
var Format;
(function (Format) {
    Format[Format["I420"] = 0] = "I420";
    Format[Format["NV21"] = 1] = "NV21";
    Format[Format["RGBA"] = 2] = "RGBA";
    Format[Format["TEXTURE_OES"] = 3] = "TEXTURE_OES";
    Format[Format["TEXTURE_RGB"] = 4] = "TEXTURE_RGB";
})(Format || (Format = {}));
var NERoomLiveStreamMode;
(function (NERoomLiveStreamMode) {
    NERoomLiveStreamMode[NERoomLiveStreamMode["ModeVideo"] = 0] = "ModeVideo";
    NERoomLiveStreamMode[NERoomLiveStreamMode["ModeAudio"] = 1] = "ModeAudio";
})(NERoomLiveStreamMode || (NERoomLiveStreamMode = {}));
var AudioProfile;
(function (AudioProfile) {
    AudioProfile["speech_low_quality"] = "speech_low_quality";
    AudioProfile["speech_standard"] = "speech_standard";
    AudioProfile["music_standard"] = "music_standard";
    AudioProfile["standard_stereo"] = "standard_stereo";
    AudioProfile["high_quality"] = "high_quality";
    AudioProfile["high_quality_stereo"] = "high_quality_stereo";
})(AudioProfile || (AudioProfile = {}));
/**
 * 组件当前支持的语言类型
 * CHINESE: 中文; ENGLISH: 英文; JAPANESE: 日文;
 */
var NERoomLanguage;
(function (NERoomLanguage) {
    NERoomLanguage["CHINESE"] = "CHINESE";
    NERoomLanguage["ENGLISH"] = "ENGLISH";
    NERoomLanguage["JAPANESE"] = "JAPANESE";
})(NERoomLanguage || (NERoomLanguage = {}));
var NEVideoResolution;
(function (NEVideoResolution) {
    NEVideoResolution[NEVideoResolution["kNEVideoProfileUsingTemplate"] = -1] = "kNEVideoProfileUsingTemplate"; /**< 使用模板配置 */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileLowest"] = 0] = "kNEVideoProfileLowest"; /**< 普清（160x90/120, 15fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileLow"] = 1] = "kNEVideoProfileLow"; /**< 标清（320x180/240, 15fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileStandard"] = 2] = "kNEVideoProfileStandard"; /**< 高清（640x360/480, 30fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileHD720P"] = 3] = "kNEVideoProfileHD720P"; /**< 超清（1280x720, 30fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileHD1080P"] = 4] = "kNEVideoProfileHD1080P"; /**< 1080P（1920x1080, 30fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfile4KUHD"] = 5] = "kNEVideoProfile4KUHD"; /**< 4K（3840x2160, 30fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfile8KUHD"] = 6] = "kNEVideoProfile8KUHD"; /**< 8K（7680x4320, 30fps） */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileNone"] = 7] = "kNEVideoProfileNone"; /**< 无效果 */
    NEVideoResolution[NEVideoResolution["kNEVideoProfileMAX"] = 6] = "kNEVideoProfileMAX";
})(NEVideoResolution || (NEVideoResolution = {}));
var tagNERoomRtcAudioProfileType;
(function (tagNERoomRtcAudioProfileType) {
    /**
     * 默认设置。Speech 场景下为 kNEAudioProfileStandardExtend，Music 场景下为 kNEAudioProfileHighQuality
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileDefault"] = 0] = "kNEAudioProfileDefault";
    /**
     * 普通质量的音频编码，16000Hz，20Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileStandard"] = 1] = "kNEAudioProfileStandard";
    /**
     * 普通质量的音频编码，16000Hz，32Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileStandardExtend"] = 2] = "kNEAudioProfileStandardExtend";
    /**
     * 中等质量的音频编码，48000Hz，32Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileMiddleQuality"] = 3] = "kNEAudioProfileMiddleQuality";
    /**
     * 中等质量的立体声编码，48000Hz * 2，64Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileMiddleQualityStereo"] = 4] = "kNEAudioProfileMiddleQualityStereo";
    /**
     * 高质量的音频编码，48000Hz，64Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileHighQuality"] = 5] = "kNEAudioProfileHighQuality";
    /**
     * 高质量的立体声编码，48000Hz * 2，128Kbps
     */
    tagNERoomRtcAudioProfileType[tagNERoomRtcAudioProfileType["kNEAudioProfileHighQualityStereo"] = 6] = "kNEAudioProfileHighQualityStereo";
})(tagNERoomRtcAudioProfileType || (tagNERoomRtcAudioProfileType = {}));
var tagNERoomRtcAudioScenarioType;
(function (tagNERoomRtcAudioScenarioType) {
    /**
     * 默认设置
     * kNEChannelProfileCommunication 下为 kNEAudioScenarioSpeech
     * kNEChannelProfileLiveBroadcasting 下为 kNEAudioScenarioMusic
     */
    tagNERoomRtcAudioScenarioType[tagNERoomRtcAudioScenarioType["kNEAudioScenarioDefault"] = 0] = "kNEAudioScenarioDefault";
    /**
     * 语音场景。NERoomRtcAudioProfileType 推荐使用 kNEAudioProfileMiddleQuality 及以下
     */
    tagNERoomRtcAudioScenarioType[tagNERoomRtcAudioScenarioType["kNEAudioScenarioSpeech"] = 1] = "kNEAudioScenarioSpeech";
    /**
     * 音乐场景。NERoomRtcAudioProfileType 推荐使用 kNEAudioProfileMiddleQualityStereo 及以上
     */
    tagNERoomRtcAudioScenarioType[tagNERoomRtcAudioScenarioType["kNEAudioScenarioMusic"] = 2] = "kNEAudioScenarioMusic";
})(tagNERoomRtcAudioScenarioType || (tagNERoomRtcAudioScenarioType = {}));
/**
 * 房间云录制状态类型
 */
var NERoomCloudRecordState;
(function (NERoomCloudRecordState) {
    /**
     * 云录制中
     */
    NERoomCloudRecordState[NERoomCloudRecordState["RecordingStart"] = 0] = "RecordingStart";
    /**
     * 未在云录制
     */
    NERoomCloudRecordState[NERoomCloudRecordState["RecordingStop"] = 1] = "RecordingStop";
})(NERoomCloudRecordState || (NERoomCloudRecordState = {}));
var NEAudioDumpType;
(function (NEAudioDumpType) {
    NEAudioDumpType[NEAudioDumpType["kNEAudioDumpTypePCM"] = 0] = "kNEAudioDumpTypePCM"; /**< 仅输出.dump文件（默认） */
    NEAudioDumpType[NEAudioDumpType["kNEAudioDumpTypeAll"] = 1] = "kNEAudioDumpTypeAll"; /**< 输出.dump和.wav文件 */
    NEAudioDumpType[NEAudioDumpType["kNEAudioDumpTypeWAV"] = 2] = "kNEAudioDumpTypeWAV"; /**< 仅输出.wav文件 */
})(NEAudioDumpType || (NEAudioDumpType = {}));

function SuccessBody(data, message) {
    return {
        code: NEErrorCode.SUCCESS,
        message: message || NEErrorMessage.SUCCESS,
        data: data,
    };
}
function FailureBody(data, message, code) {
    if (data) {
        if (data.code) {
            throw {
                code: code || data.code,
                message: data.msg || data.message || NEErrorMessage.FAILURE,
            };
        }
        throw {
            code: code || NEErrorCode.FAILURE,
            message: message || NEErrorMessage.FAILURE,
            data: data,
        };
    }
    else {
        throw {
            code: code || NEErrorCode.FAILURE,
            message: message || NEErrorMessage.FAILURE,
        };
    }
}
function FailureBodySync(data, message, code) {
    if (data) {
        if (data.code) {
            return {
                code: code || data.code,
                message: data.msg || NEErrorMessage.FAILURE,
                data: data,
            };
        }
        return {
            code: code || NEErrorCode.FAILURE,
            message: message || NEErrorMessage.FAILURE,
            data: data,
        };
    }
    else {
        return {
            code: code || NEErrorCode.FAILURE,
            message: message || NEErrorMessage.FAILURE,
            data: null,
        };
    }
}

var NEAuthService = /** @class */ (function () {
    function NEAuthService(initOptions) {
        this._listenerMap = new Map();
        this._authService = initOptions.roomKit.getAuthService();
    }
    NEAuthService.prototype.addAuthListener = function (listener) {
        function _authListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._authService.addAuthListener(_authListenerCallback);
        this._listenerMap.set(listener, index);
    };
    NEAuthService.prototype.login = function (account, token) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._authService.login(account, token, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEAuthService.prototype.logout = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._authService.logout(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEAuthService.prototype.loginByIM = function () {
        return new Promise(function () {
            // todo
        });
    };
    NEAuthService.prototype.loginByDynamicToken = function () {
        return new Promise(function () {
            // todo
        });
    };
    NEAuthService.prototype.removeAuthListener = function (listener) {
        var index = this._listenerMap.get(listener);
        if (typeof index !== 'undefined') {
            this._authService.removeAuthListener(index);
        }
    };
    Object.defineProperty(NEAuthService.prototype, "isLoggedIn", {
        get: function () {
            return this._authService.isLoggedIn();
        },
        enumerable: false,
        configurable: true
    });
    NEAuthService.prototype.destroy = function () {
        this._authService.destroy();
    };
    NEAuthService.prototype.renewToken = function () {
        return new Promise(function () {
            // todo
        });
    };
    return NEAuthService;
}());

var NEMessageChannelService = /** @class */ (function () {
    function NEMessageChannelService(initOptions) {
        this._listenerMap = new Map();
        this._messageChannelService = initOptions.messageChannelService;
    }
    NEMessageChannelService.prototype.addMessageChannelListener = function (listener) {
        var _onCustomMessageReceived = listener.onCustomMessageReceived;
        if (_onCustomMessageReceived) {
            listener.onCustomMessageReceived = function (message) {
                var roomUuid = message.roomUuid, senderUuid = message.senderUuid, commandId = message.commandId, data = message.data;
                var resData = data;
                if (commandId === 99) {
                    resData = {
                        body: data,
                    };
                }
                _onCustomMessageReceived({
                    roomUuid: roomUuid,
                    senderUuid: senderUuid,
                    commandId: commandId,
                    data: resData,
                });
            };
        }
        function _messageChannelListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._messageChannelService.addMessageChannelListener(_messageChannelListenerCallback);
        this._listenerMap.set(listener, index);
    };
    NEMessageChannelService.prototype.removeMessageChannelListener = function (listener) {
        var index = this._listenerMap.get(listener);
        if (index !== undefined) {
            this._messageChannelService.removeMessageChannelListener(index);
        }
    };
    NEMessageChannelService.prototype.sendCustomMessage = function (roomUuid, userUuid, commandId, data) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.sendCustomMessage(roomUuid, userUuid, commandId, data, function (code, message) {
                if (code === 0) {
                    resolve({ code: 0, message: null, data: null });
                }
                else {
                    reject({ code: code, message: message });
                }
            });
        });
    };
    NEMessageChannelService.prototype.sendCustomMessageToRoom = function () {
        throw new Error('Method not implemented.');
    };
    NEMessageChannelService.prototype.queryUnreadMessageList = function (sessionId, sessionType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.queryUnreadMessageList(sessionId, sessionType, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEMessageChannelService.prototype.clearUnreadCount = function (sessionId, sessionType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.clearUnreadCount(sessionId, sessionType, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEMessageChannelService.prototype.deleteSessionMessage = function (sessionId, sessionType, messageId) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.deleteSessionMessage(sessionId, sessionType, messageId, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEMessageChannelService.prototype.deleteAllSessionMessage = function (sessionId, sessionType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.deleteAllSessionMessage(sessionId, sessionType, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEMessageChannelService.prototype.getSessionMessagesHistory = function (param) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._messageChannelService.getSessionMessagesHistory(param, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEMessageChannelService.prototype.destroy = function () {
        return new Promise(function () {
            // todo
        });
    };
    return NEMessageChannelService;
}());

var NENosService = /** @class */ (function () {
    function NENosService(initOptions) {
        this._nosService = initOptions.roomKit.getNosService();
    }
    NENosService.prototype.setNosDownloadFilePath = function (path) {
        return this._nosService.setNosDownloadFilePath(path);
    };
    NENosService.prototype.uploadResource = function (path) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._nosService.uploadResource(path, function (code, message, data) {
                if (code === 200) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NENosService.TAG_NAME = 'NEAuthService';
    return NENosService;
}());

var NERoomLiveController = /** @class */ (function () {
    function NERoomLiveController(initOptions) {
        this._liveController = initOptions.liveController;
    }
    Object.defineProperty(NERoomLiveController.prototype, "isSupported", {
        get: function () {
            var _a, _b;
            return ((_b = (_a = this._liveController) === null || _a === void 0 ? void 0 : _a.isSupported) === null || _b === void 0 ? void 0 : _b.call(_a)) || false;
        },
        enumerable: false,
        configurable: true
    });
    NERoomLiveController.prototype.startLive = function (request) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.startLive(request, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.stopLive = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.stopLive(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.updateLive = function (params) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.updateLive(params, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.getLiveInfo = function () {
        var info = this._liveController.getLiveInfo();
        try {
            // 目前sdk返回的info.userUuIdList不是最新，需要取extensionConfig中的listUids
            if (info.extensionConfig) {
                var _config = JSON.parse(info.extensionConfig);
                if (Array.isArray(_config === null || _config === void 0 ? void 0 : _config.listUids)) {
                    info.userUuidList = [].concat(_config.listUids);
                }
            }
        }
        catch (error) {
            console.log('getLiveInfo json parse extensionConfig error:', error);
        }
        return info;
    };
    //  不需要实现
    NERoomLiveController.prototype.setLiveInfoFromRoomPropertiesLive = function () {
        throw new Error('Method not implemented.');
    };
    NERoomLiveController.prototype.setLiveInfo = function () {
        throw new Error('Method not implemented.');
    };
    NERoomLiveController.prototype.addLiveStreamTask = function (taskInfo) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.addLiveStreamTask(taskInfo, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.updateLiveStreamTask = function (taskInfo) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.updateLiveStreamTask(taskInfo, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.getBackgroundInfo = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.getBackgroundInfo(function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.updateBackgroundInfo = function (param) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            console.log('updateBackgroundInfo>>>>>>', param, _this._liveController.updateBackgroundInfo);
            _this._liveController.updateBackgroundInfo(param, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomLiveController.prototype.removeLiveStreamTask = function (taskId) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._liveController.removeLiveStreamTask(taskId, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    // 不需要实现
    NERoomLiveController.prototype._getUuidListByRtcUidList = function () {
        throw new Error('Method not implemented.');
    };
    return NERoomLiveController;
}());

var NERoomRtcController = /** @class */ (function () {
    function NERoomRtcController(initOptions) {
        this.rtcClient = null;
        this.muteMyAudioTimer = null;
        this.muteMyVideoTimer = null;
        this._rtcController = initOptions.rtcController;
    }
    Object.defineProperty(NERoomRtcController.prototype, "isSupported", {
        get: function () {
            var _a;
            return ((_a = this._rtcController) === null || _a === void 0 ? void 0 : _a.isSupported()) || false;
        },
        enumerable: false,
        configurable: true
    });
    NERoomRtcController.prototype.switchDevice = function (params) {
        return __awaiter(this, void 0, void 0, function () {
            var code;
            return __generator(this, function (_a) {
                code = -1;
                switch (params.type) {
                    case 'camera':
                        code = this._rtcController.selectCameraDevice(params.deviceId);
                        break;
                    case 'microphone':
                        code = this._rtcController.selectRecordDevice(params.deviceId);
                        break;
                    case 'speaker':
                        code = this._rtcController.selectPlayoutDevice(params.deviceId);
                        break;
                }
                if (code === 0) {
                    return [2 /*return*/, SuccessBody({
                            type: params.type,
                            deviceId: params.deviceId,
                        })];
                }
                else {
                    return [2 /*return*/, FailureBody(null, undefined, code)];
                }
            });
        });
    };
    NERoomRtcController.prototype.getSelectedRecordDevice = function () {
        return this._rtcController.getSelectedRecordDevice();
    };
    NERoomRtcController.prototype.getSelectedCameraDevice = function () {
        // todo
        return this._rtcController.getSelectedCameraDevice();
    };
    NERoomRtcController.prototype.getSelectedPlayoutDevice = function () {
        return this._rtcController.getSelectedPlayoutDevice();
    };
    NERoomRtcController.prototype.enumRecordDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                deviceList = this._rtcController.enumRecordDevices();
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NERoomRtcController.prototype.enumCameraDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                console.log('_preRtcController>>>', this._rtcController);
                deviceList = this._rtcController.enumCameraDevices();
                console.log('deviceList>>', deviceList);
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NERoomRtcController.prototype.enumPlayoutDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                deviceList = this._rtcController.enumPlayoutDevices();
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NERoomRtcController.prototype.joinRtcChannel = function (channelName) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var callback = function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            };
            if (channelName) {
                return _this._rtcController.joinRtcChannel(channelName, callback);
            }
            else {
                return _this._rtcController.joinRtcChannel(callback);
            }
        });
    };
    NERoomRtcController.prototype.leaveRtcChannel = function (channelName) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var cb = function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            };
            if (channelName) {
                return _this._rtcController.leaveRtcChannel(channelName, cb);
            }
            else {
                return _this._rtcController.leaveRtcChannel(cb);
            }
        });
    };
    NERoomRtcController.prototype.enableMediaPub = function (channelName, mediaType, enable) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var code = _this._rtcController.enableMediaPub(channelName, mediaType, enable);
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    NERoomRtcController.prototype.adjustChannelPlaybackSignalVolume = function (channelName, volume) {
        this._rtcController.adjustChannelPlaybackSignalVolume(channelName, volume);
    };
    NERoomRtcController.prototype.enableLocalAudio = function (channelName, enable) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var code = _this._rtcController.enableLocalAudio(channelName, enable);
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    NERoomRtcController.prototype.muteMyAudio = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.muteMyAudio(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.muteMyVideo = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.muteMyVideo(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.setupLocalVideoCanvas = function (videoView, mirroring) {
        return this._rtcController.setupLocalVideoCanvas(Buffer.from([]), !!mirroring);
    };
    NERoomRtcController.prototype.setRemoteMemberMap = function () {
        return SuccessBody(null);
    };
    NERoomRtcController.prototype.setLocalMember = function () {
        return SuccessBody(null);
    };
    NERoomRtcController.prototype.setupRemoteVideoSubStreamCanvas = function (videoView, userUuid) {
        return this._rtcController.setupRemoteVideoSubStreamCanvas(userUuid, Buffer.from([]));
    };
    NERoomRtcController.prototype.setupRemoteVideoCanvas = function (videoView, userUuid) {
        return this._rtcController.setupRemoteVideoCanvas(userUuid, Buffer.from([]));
    };
    NERoomRtcController.prototype.setupRemoteStreamContext = function () {
        return 0;
    };
    NERoomRtcController.prototype.getScreenSharingUserUuid = function () {
        return this._rtcController.getScreenSharingUserUuid();
    };
    NERoomRtcController.prototype.setScreenSharingUserUuid = function (userUuid) {
        console.log('setScreenSharingUserUuid', userUuid);
    };
    NERoomRtcController.prototype._getRtcUidByUuid = function () {
        return 0;
    };
    NERoomRtcController.prototype._getUuidByRtcUid = function () {
        return '';
    };
    NERoomRtcController.prototype.startScreenShare = function (screenConfig) {
        var _this = this;
        if (screenConfig === null || screenConfig === void 0 ? void 0 : screenConfig.isApp) {
            return this.startAppShare(Number(screenConfig === null || screenConfig === void 0 ? void 0 : screenConfig.sourceId) || 0);
        }
        else {
            return new Promise(function (resolve, reject) {
                _this._rtcController.startScreenShare(Number(screenConfig === null || screenConfig === void 0 ? void 0 : screenConfig.sourceId), function (code, message) {
                    if (code === 0) {
                        return resolve(SuccessBody(null));
                    }
                    else {
                        return reject(FailureBodySync(null, message, code));
                    }
                });
            });
        }
    };
    NERoomRtcController.prototype.stopScreenShare = function () {
        var _this = this;
        // todo
        return new Promise(function (resolve, reject) {
            _this._rtcController.stopShare(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.stopMemberScreenShare = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.stopMemberShare(userUuid, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.muteMemberAudio = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.muteMemberAudio(userUuid, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.muteMemberVideo = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.muteMemberVideo(userUuid, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.unmuteMemberAudio = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.unmuteMemberAudio(userUuid, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.unmuteMemberVideo = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.unmuteMemberVideo(userUuid, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.subscribeRemoteVideoSubStream = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var result = _this._rtcController.subscribeRemoteVideoSubStream(userUuid);
            if (result === 0) {
                return resolve(SuccessBody(null));
            }
            else {
                return reject(FailureBodySync(null));
            }
        });
    };
    NERoomRtcController.prototype.unsubscribeRemoteVideoSubStream = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var result = _this._rtcController.unsubscribeRemoteVideoSubStream(userUuid);
            if (result === 0) {
                return resolve(SuccessBody(null));
            }
            else {
                return reject(FailureBodySync(null));
            }
        });
    };
    NERoomRtcController.prototype.subscribeRemoteVideoStream = function (userUuid, streamType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var result = _this._rtcController.subscribeRemoteVideoStream(userUuid, streamType);
            if (result === 0) {
                return resolve(SuccessBody(null));
            }
            else {
                return reject(FailureBodySync(null));
            }
        });
    };
    NERoomRtcController.prototype.unsubscribeRemoteVideoStream = function (userUuid, streamType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var result = _this._rtcController.unsubscribeRemoteVideoStream(userUuid, streamType);
            if (result === 0) {
                return resolve(SuccessBody(null));
            }
            else {
                return reject(FailureBodySync(null));
            }
        });
    };
    NERoomRtcController.prototype.setLocalVideoConfig = function (profile) {
        // toto
        if (profile.resolution || profile.resolution === 0) {
            var resolutionMap = {
                1080: NEVideoResolution.kNEVideoProfileHD1080P,
                720: NEVideoResolution.kNEVideoProfileHD720P,
                480: NEVideoResolution.kNEVideoProfileStandard,
            };
            this._rtcController.setLocalVideoResolution(resolutionMap[profile.resolution] || profile.resolution);
        }
    };
    NERoomRtcController.prototype.setLocalAudioProfile = function (profile) {
        var _a, _b;
        (_b = (_a = this._rtcController).setLocalAudioProfile) === null || _b === void 0 ? void 0 : _b.call(_a, profile);
    };
    NERoomRtcController.prototype.setAudioProfile = function (profile) {
        var _a, _b;
        (_b = (_a = this._rtcController).setAudioProfile) === null || _b === void 0 ? void 0 : _b.call(_a, profile);
    };
    NERoomRtcController.prototype.setAudioProfileInEle = function (profile, scenario) {
        var _a;
        (_a = this._rtcController) === null || _a === void 0 ? void 0 : _a.setAudioProfile(profile, scenario);
    };
    NERoomRtcController.prototype.setLocalScreenProfile = function () {
        // todo
    };
    // web 内部接口无须实现
    NERoomRtcController.prototype.operateStream = function (type, isOpen) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                console.log('operateStream', type, isOpen);
                return [2 /*return*/];
            });
        });
    };
    // web 内部接口无须实现
    NERoomRtcController.prototype.playLocalStream = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/, SuccessBody(null)];
            });
        });
    };
    // switchDevice(params: {
    //   type: DeviceType
    //   deviceId: string
    // }): Promise<NEResult<NEDeviceSwitchInfo>> {
    //   // todo
    //   throw new Error('Method not implemented.')
    // }
    NERoomRtcController.prototype.disconnectMyAudio = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.disconnectMyAudio(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.reconnectMyAudio = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.reconnectMyAudio(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.unmuteMyAudio = function (enableMediaPub) {
        var _this = this;
        if (enableMediaPub === void 0) { enableMediaPub = true; }
        return new Promise(function (resolve, reject) {
            _this._rtcController.unmuteMyAudio(enableMediaPub, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.unmuteMyVideo = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.unmuteMyVideo(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.selectedRecordDevice = function (deviceId) {
        return this.switchDevice({ type: 'microphone', deviceId: deviceId });
    };
    NERoomRtcController.prototype.selectedCameraDevice = function (deviceId) {
        return this.switchDevice({ type: 'camera', deviceId: deviceId });
    };
    NERoomRtcController.prototype.selectedPlayoutDevice = function (deviceId) {
        return this.switchDevice({ type: 'speaker', deviceId: deviceId });
    };
    // web内部使用无需实现
    NERoomRtcController.prototype.addLiveStreamTask = function () {
        return Promise.resolve(SuccessBody(null));
    };
    // web内部使用无需实现
    NERoomRtcController.prototype.updateLiveStreamTask = function () {
        return Promise.resolve(SuccessBody(null));
    };
    NERoomRtcController.prototype.removeLiveStreamTask = function () {
        return Promise.resolve(SuccessBody(null));
    };
    NERoomRtcController.prototype.enableAudioVolumeIndication = function (enable, interval, enableVad, channelName) {
        if (channelName) {
            return this._rtcController.enableAudioVolumeIndication(channelName, enable, interval, !!enableVad);
        }
        else {
            return this._rtcController.enableAudioVolumeIndication(!!enable, interval);
        }
    };
    NERoomRtcController.prototype.pushExternalVideoFrame = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.seExternalVideoSource = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.enableEarBack = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                throw new Error('Method not implemented.');
            });
        });
    };
    NERoomRtcController.prototype.disableEarBack = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.startAudioMixing = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.playEffect = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.stopAudioMixing = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.stopEffect = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.setAudioMixingPlaybackVolume = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.setEffectSendVolume = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.stopAllEffects = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.replayRemoteStream = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.adjustRecordingSignalVolume = function (volume) {
        return this._rtcController.adjustRecordingSignalVolume(Number(volume * 4));
    };
    NERoomRtcController.prototype.pauseEffect = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.pauseAllEffects = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.resumeEffect = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.resumeAllEffects = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.getEffectDuration = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.setChannelProfile = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.enableLocalSubStreamAudio = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.disableLocalSubStreamAudio = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.pauseLocalAudioRecording = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.resumeLocalAudioRecording = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.pauseLocalVideoCapture = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.resumeLocalVideoCapture = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.adjustPlaybackSignalVolume = function (volume) {
        return this._rtcController.adjustPlaybackSignalVolume(Number(volume * 4));
    };
    // 不需要实现
    NERoomRtcController.prototype.getLocalAudioStats = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.getTransportStats = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.getLocalVideoStats = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.getRemoteAudioStats = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.getRemoteVideoStats = function () {
        throw new Error('Method not implemented.');
    };
    // 不需要实现
    NERoomRtcController.prototype.getSessionStats = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.getScreenCaptureSourceList = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.getScreenCaptureSourceList(function (code, message, data) {
                if (code === 0) {
                    return resolve(SuccessBody(data));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.startAppShare = function (index) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.startAppShare(index, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.setExcludeWindowList = function (windowList, isWin32) {
        return this._rtcController.setExcludeWindowList(windowList, isWin32);
    };
    NERoomRtcController.prototype.startSystemAudioLoopbackCapture = function () {
        return this._rtcController.startSystemAudioLoopbackCapture();
    };
    NERoomRtcController.prototype.stopSystemAudioLoopbackCapture = function () {
        return this._rtcController.stopSystemAudioLoopbackCapture();
    };
    NERoomRtcController.prototype.getPlayoutDeviceVolume = function () {
        return this._rtcController.getPlayoutDeviceVolume();
    };
    NERoomRtcController.prototype.getRecordDeviceVolume = function () {
        return this._rtcController.getRecordDeviceVolume();
    };
    NERoomRtcController.prototype.destroy = function () {
        throw new Error('Method not implemented.');
    };
    NERoomRtcController.prototype.enableAudioAINS = function (enable) {
        return this._rtcController.enableAudioAINS(enable);
    };
    NERoomRtcController.prototype.enableAudioEchoCancellation = function (enable) {
        return this._rtcController.enableAudioEchoCancellation(enable);
    };
    NERoomRtcController.prototype.enableAudioVolumeAutoAdjust = function (enable) {
        return this._rtcController.enableAudioVolumeAutoAdjust(enable);
    };
    NERoomRtcController.prototype.startAudioDump = function (type) {
        if (!type) {
            type = NEAudioDumpType.kNEAudioDumpTypePCM;
        }
        return this._rtcController.startAudioDump(type);
    };
    NERoomRtcController.prototype.stopAudioDump = function () {
        return this._rtcController.stopAudioDump();
    };
    NERoomRtcController.prototype.getPlayoutDeviceMute = function () {
        return this._rtcController.getPlayoutDeviceMute();
    };
    NERoomRtcController.prototype.takeRemoteSnapshot = function (userUuid, streamType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.takeRemoteSnapshot(userUuid, streamType, function (code, message, data) {
                if (code === 0) {
                    return resolve(SuccessBody(data));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomRtcController.prototype.takeLocalSnapshot = function (streamType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._rtcController.takeLocalSnapshot(streamType, function (code, message, data) {
                if (code === 0) {
                    return resolve(SuccessBody(data));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    return NERoomRtcController;
}());

var NEChatroomType;
(function (NEChatroomType) {
    /**
     * 主聊天室
     */
    NEChatroomType[NEChatroomType["COMMON"] = 0] = "COMMON";
    /**
     * 等候室聊天室
     */
    NEChatroomType[NEChatroomType["WAITING_ROOM"] = 1] = "WAITING_ROOM";
})(NEChatroomType || (NEChatroomType = {}));

var NERoomChatController = /** @class */ (function () {
    function NERoomChatController(initOptions) {
        this._roomChatController = initOptions.roomChatController;
        this._waitingRoomChatController = initOptions.waitingRoomChatController;
    }
    Object.defineProperty(NERoomChatController.prototype, "isSupported", {
        get: function () {
            var _a, _b;
            return ((_b = (_a = this._roomChatController) === null || _a === void 0 ? void 0 : _a.isSupported) === null || _b === void 0 ? void 0 : _b.call(_a)) || false;
        },
        enumerable: false,
        configurable: true
    });
    NERoomChatController.prototype.joinChatroom = function (chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.joinChatroom(function (code, message) {
                if (code === 0) {
                    resolve({ code: 0, message: null, data: null });
                }
                else {
                    reject({ code: code, message: message });
                }
            });
        });
    };
    NERoomChatController.prototype.leaveChatroom = function (chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.leaveChatroom(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.updateMyChatroomMemberInfo = function () {
        throw new Error('Method not implemented.');
    };
    NERoomChatController.prototype.fetchChatRoomMembers = function () {
        throw new Error('Method not implemented.');
    };
    NERoomChatController.prototype.sendBroadcastTextMessage = function (message, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.sendBroadcastTextMessage(message, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.sendDirectTextMessage = function (userUuid, message, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.sendDirectTextMessage(userUuid, message, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.sendGroupTextMessage = function (userUuids, message, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.sendGroupTextMessage(userUuids, message, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.sendTextMessage = function (messageUuid, message, userUuids, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            console.log('sendTextMessage', chatroomType);
            controller.sendTextMessage(messageUuid, message, userUuids || [], function (code, message, data) {
                console.log('sendTextMessage', code, message, data);
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.sendFileMessage = function (messageUuid, file, userUuids, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.sendFileMessage(messageUuid, file, userUuids || [], function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.sendImageMessage = function (messageUuid, image, width, height, userUuids, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.sendImageMessage(messageUuid, image, width, height, userUuids || [], function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.cancelSendFileMessage = function (messageUuid, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.cancelSendFileMessage(messageUuid, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.downloadAttachment = function (messageUuid, fileUrl, filePath, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.downloadAttachment(messageUuid, fileUrl, filePath, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.cancelDownloadAttachment = function (messageUuid, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.cancelDownloadAttachment(messageUuid, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.fetchChatroomHistoryMessages = function (option, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.fetchChatroomHistoryMessages(option, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data.filter(Boolean)));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.recallChatroomMessage = function (messageUUID, messageTime, chatroomType) {
        var _this = this;
        if (chatroomType === void 0) { chatroomType = NEChatroomType.COMMON; }
        return new Promise(function (resolve, reject) {
            var controller = chatroomType === NEChatroomType.COMMON
                ? _this._roomChatController
                : _this._waitingRoomChatController;
            controller.recallChatroomMessage(messageUUID, messageTime, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomChatController.prototype.destroy = function () {
        return Promise.resolve(SuccessBody(null));
    };
    return NERoomChatController;
}());

var NERoomWhiteboardController = /** @class */ (function () {
    function NERoomWhiteboardController(initOptions) {
        this.isSupported = true;
        this.isJoinedWhiteboard = true;
        this._roomWhiteboardController = initOptions.roomWhiteboardController;
    }
    NERoomWhiteboardController.prototype.setWhiteboardNeedInfo = function () {
        throw new Error('Method not implemented.');
    };
    NERoomWhiteboardController.prototype.initWhiteboard = function () {
        return Promise.resolve(SuccessBody(null));
    };
    NERoomWhiteboardController.prototype.getWhiteboardUrl = function () {
        return this._roomWhiteboardController.getWhiteboardUrl();
    };
    NERoomWhiteboardController.prototype.login = function () {
        return this._roomWhiteboardController.login();
    };
    NERoomWhiteboardController.prototype.auth = function () {
        return this._roomWhiteboardController.auth();
    };
    NERoomWhiteboardController.prototype.setupWhiteboardCanvas = function (view) {
        function _viewCallBack(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (view[key]) {
                view[key].apply(view, __spreadArray([], __read(args), false));
            }
        }
        this._roomWhiteboardController.setupWhiteboardCanvas(_viewCallBack);
        return Promise.resolve(SuccessBody(null));
    };
    NERoomWhiteboardController.prototype.resetWhiteboardCanvas = function () {
        throw new Error('Method not implemented.');
    };
    NERoomWhiteboardController.prototype.startWhiteboardShare = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomWhiteboardController.startWhiteboardShare(function (code, message) {
                console.log('startWhiteboardShare', code, message);
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomWhiteboardController.prototype.stopWhiteboardShare = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomWhiteboardController.stopWhiteboardShare(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomWhiteboardController.prototype.getWhiteboardSharingUserUuid = function () {
        return this._roomWhiteboardController.getWhiteboardSharingUserUuid();
    };
    NERoomWhiteboardController.prototype.stopMemberWhiteboardShare = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomWhiteboardController.stopMemberWhiteboardShare(userUuid, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomWhiteboardController.prototype.setEnableDraw = function (enable) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var res = _this._roomWhiteboardController.setEnableDraw(enable);
            if (res === 0) {
                resolve(SuccessBody(null));
            }
            else {
                reject(FailureBodySync({ code: res, message: 'setEnableDraw failed' }));
            }
        });
    };
    NERoomWhiteboardController.prototype.setCanvasBackgroundColor = function () {
        throw new Error('Method not implemented.');
    };
    NERoomWhiteboardController.prototype.lockCameraWithContent = function () {
        throw new Error('Method not implemented.');
    };
    NERoomWhiteboardController.prototype.destroy = function () {
        return Promise.resolve(SuccessBody(null));
    };
    return NERoomWhiteboardController;
}());

var NEWaitingRoomController = /** @class */ (function () {
    function NEWaitingRoomController(inintOptions) {
        this._waitingRoomController = null;
        this._roomListenerMap = new Map();
        this._waitingRoomController = inintOptions.waitingRoomController;
    }
    Object.defineProperty(NEWaitingRoomController.prototype, "isSupported", {
        get: function () {
            var _a;
            return ((_a = this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.isSupported()) || false;
        },
        enumerable: false,
        configurable: true
    });
    NEWaitingRoomController.prototype.getWaitingRoomInfo = function () {
        var _a;
        return ((_a = this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.getWaitingRoomInfo()) || {};
    };
    NEWaitingRoomController.prototype.enableWaitingRoomOnEntry = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.enableWaitingRoomOnEntry(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.disableWaitingRoomOnEntry = function (admitAll) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.disableWaitingRoomOnEntry(!!admitAll, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.isWaitingRoomEnabledOnEntry = function () {
        var _a;
        return (_a = this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.isWaitingRoomEnabledOnEntry();
    };
    NEWaitingRoomController.prototype.getMemberList = function (joinTime, size, asc) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.getMemberList(joinTime, size, asc ? 1 : 0, function (code, message, data) {
                if (code === 0) {
                    return resolve(SuccessBody(data));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.admitMember = function (userUuid, autoAdmit) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.admitMember(String(userUuid), !!autoAdmit, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.admitAllMembers = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.admitAllMembers(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.expelMember = function (userUuid, disallowRejoin) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.expelMember(String(userUuid), !!disallowRejoin, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.expelAllMembers = function (disallowRejoin) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.expelAllMembers(!!disallowRejoin, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.putInWaitingRoom = function (userUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.putInWaitingRoom(String(userUuid), function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.addListener = function (listener) {
        function _roomListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._waitingRoomController.addListener(_roomListenerCallback);
        this._roomListenerMap.set(listener, index);
    };
    NEWaitingRoomController.prototype.removeListener = function (listener) {
        var index = this._roomListenerMap.get(listener);
        if (index !== undefined) {
            this._waitingRoomController.removeListener(index);
        }
    };
    NEWaitingRoomController.prototype.changeMemberName = function (userUuid, name) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.changeMemberName(String(userUuid), String(name), function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NEWaitingRoomController.prototype.getWaitingRoomManagerList = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            (_a = _this._waitingRoomController) === null || _a === void 0 ? void 0 : _a.getWaitingRoomManagerList(function (code, message, data) {
                if (code === 0) {
                    return resolve(SuccessBody(data));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    /**
     * @ignore 不对外暴露
     */
    NEWaitingRoomController.prototype.on = function () {
        throw new Error('Method not implemented.');
    };
    /**
     * @ignore 不对外暴露
     */
    NEWaitingRoomController.prototype.off = function () {
        throw new Error('Method not implemented.');
    };
    return NEWaitingRoomController;
}());

var NERoomSipController = /** @class */ (function () {
    function NERoomSipController(initOptions) {
        this._sipController = initOptions.sipController;
    }
    Object.defineProperty(NERoomSipController.prototype, "isSupported", {
        get: function () {
            var _a, _b;
            return ((_b = (_a = this._sipController) === null || _a === void 0 ? void 0 : _a.isSupported) === null || _b === void 0 ? void 0 : _b.call(_a)) || false;
        },
        enumerable: false,
        configurable: true
    });
    // 根据手机号码进行呼叫
    NERoomSipController.prototype.callByNumber = function (number, countryCode, name) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._sipController.callByNumber(number, countryCode, name, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    /**
     * 根据用户uuid进行呼叫(可多个同时呼叫)
     * @param userUuids
     */
    NERoomSipController.prototype.callByUserUuids = function (userUuids) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._sipController.callByUserUuids(userUuids, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    /**
     * 根据用户id进行呼叫
     * @param userUuid
     */
    NERoomSipController.prototype.callByUserUuid = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._sipController.callByUserUuid(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    /**
     * 移除呼叫
     * @param userUuid
     */
    NERoomSipController.prototype.removeCall = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._sipController.removeCall(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    /**
     * 取消正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
     * @param userUuid
     */
    NERoomSipController.prototype.cancelCall = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._sipController.cancelCall(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    /**
     * 挂断通话，挂断后成员将被踢出会议并移除列表
     * @param userUuid
     */
    NERoomSipController.prototype.hangUpCall = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._sipController.hangUpCall(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    return NERoomSipController;
}());

var NERoomAppInviteController = /** @class */ (function () {
    function NERoomAppInviteController(initOptions) {
        this._appInviteController = initOptions.appInviteController;
    }
    Object.defineProperty(NERoomAppInviteController.prototype, "isSupported", {
        get: function () {
            var _a, _b;
            return ((_b = (_a = this._appInviteController) === null || _a === void 0 ? void 0 : _a.isSupported) === null || _b === void 0 ? void 0 : _b.call(_a)) || false;
        },
        enumerable: false,
        configurable: true
    });
    /**
     * 根据用户uuid进行呼叫(可多个同时呼叫)
     * @param userUuids
     */
    NERoomAppInviteController.prototype.callByUserUuids = function (userUuids) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._appInviteController.callByUserUuids(userUuids, function (code, message, data) {
                if (code === 0) {
                    resolve(SuccessBody(data));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    /**
     * 根据用户id进行呼叫
     * @param userUuid
     */
    NERoomAppInviteController.prototype.callByUserUuid = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._appInviteController.callByUserUuid(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    /**
     * 移除呼叫
     * @param userUuid
     */
    NERoomAppInviteController.prototype.removeCall = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._appInviteController.removeCall(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    /**
     * 取消正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
     * @param userUuid
     */
    NERoomAppInviteController.prototype.cancelCall = function (userUuid) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        _this._appInviteController.cancelCall(userUuid, function (code, message, data) {
                            if (code === 0) {
                                resolve(SuccessBody(data));
                            }
                            else {
                                reject(FailureBodySync(null, message, code));
                            }
                        });
                    })];
            });
        });
    };
    return NERoomAppInviteController;
}());

var NERoomAnnotationController = /** @class */ (function () {
    function NERoomAnnotationController(initOptions) {
        this.isSupported = true;
        this._roomAnnotationController = initOptions.roomAnnotationController;
    }
    NERoomAnnotationController.prototype.getWhiteboardUrl = function () {
        return 'https://roomkit.netease.im/static/wbsdk/3.9.13/g2/webview.html';
    };
    NERoomAnnotationController.prototype.isAnnotationEnabled = function () {
        return this._roomAnnotationController.getIsAnnotationEnabled();
    };
    NERoomAnnotationController.prototype.login = function () {
        return this._roomAnnotationController.login();
    };
    NERoomAnnotationController.prototype.logout = function () {
        return this._roomAnnotationController.logout();
    };
    NERoomAnnotationController.prototype.auth = function () {
        return this._roomAnnotationController.auth();
    };
    NERoomAnnotationController.prototype.setupCanvas = function (view) {
        function _viewCallBack(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (key === 'onLogin' || key === 'onLogout' || key === 'onAuth') {
                view[key].apply(view, __spreadArray([], __read(args), false));
            }
        }
        this._annotationView = view;
        this._roomAnnotationController.setupAnnotationCanvas(_viewCallBack);
    };
    NERoomAnnotationController.prototype.resetCanvas = function (view) {
        function _viewCallBack(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (key === 'onLogin' || key === 'onLogout' || key === 'onAuth') {
                view === null || view === void 0 ? void 0 : view[key].apply(view, __spreadArray([], __read(args), false));
            }
        }
        this._annotationView = view;
        this._roomAnnotationController.resetAnnotationCanvas(_viewCallBack);
    };
    NERoomAnnotationController.prototype.startAnnotation = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomAnnotationController.startAnnotationShare(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomAnnotationController.prototype.stopAnnotation = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomAnnotationController.stopAnnotationShare(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    NERoomAnnotationController.prototype.setEnableDraw = function (enable) {
        var _a, _b, _c, _d;
        var opt = {
            action: 'jsDirectCall',
            param: {
                action: 'enableDraw',
                params: [enable],
                target: 'drawPlugin',
            },
        };
        (_a = this._annotationView) === null || _a === void 0 ? void 0 : _a.onDrawEnableChanged("WebJSBridge(".concat(JSON.stringify(opt), ");"));
        if (enable) {
            (_b = this._annotationView) === null || _b === void 0 ? void 0 : _b.onToolConfigChanged("WebJSBridge({\"action\":\"jsDirectCall\",\"param\":{\"action\":\"show\",\"params\":[],\"target\":\"toolCollection\"}});");
            var tool = {
                action: 'jsDirectCall',
                param: {
                    action: 'setVisibility',
                    target: 'toolCollection',
                    params: [
                        {
                            bottomRight: {
                                visible: false,
                            },
                            bottomLeft: {
                                visible: false,
                            },
                            topRight: {
                                visible: false,
                            },
                            left: {
                                visible: true,
                                exclude: [
                                    'pan',
                                    'image',
                                    'exportImage',
                                    'uploadLog',
                                    'uploadCenter',
                                ],
                            },
                        },
                    ],
                },
            };
            (_c = this._annotationView) === null || _c === void 0 ? void 0 : _c.onToolConfigChanged("WebJSBridge(".concat(JSON.stringify(tool), ");"));
        }
        else {
            (_d = this._annotationView) === null || _d === void 0 ? void 0 : _d.onToolConfigChanged("WebJSBridge({\"action\":\"jsDirectCall\",\"param\":{\"action\":\"hide\",\"params\":[],\"target\":\"toolCollection\"}});");
        }
    };
    NERoomAnnotationController.prototype.destroy = function () {
        return Promise.resolve(SuccessBody(null));
    };
    NERoomAnnotationController.prototype.setAnnotationState = function (state) {
        throw new Error("Method not implemented. setAnnotationState : ".concat(state));
    };
    return NERoomAnnotationController;
}());

var NERoomContext = /** @class */ (function () {
    // private _eventEmitter: EventEmitter
    function NERoomContext(initOptions) {
        this._roomListenerMap = new Map();
        this._rtcStatsListenerMap = new Map();
        this._roomContext = initOptions.roomService.getRoomContext(initOptions.roomUuid);
    }
    NERoomContext.prototype.initialize = function () {
        return Promise.resolve();
    };
    Object.defineProperty(NERoomContext.prototype, "isInitialize", {
        get: function () {
            return !!this._roomContext;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "localMember", {
        get: function () {
            var member = this._roomContext.getLocalMember();
            if (member.properties) {
                Object.keys(member.properties).forEach(function (key) {
                    member.properties[key] = {
                        value: member.properties[key],
                    };
                });
            }
            return member;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "remoteMembers", {
        get: function () {
            var members = this._roomContext.getRemoteMembers();
            members.forEach(function (member) {
                if (member.properties) {
                    Object.keys(member.properties).forEach(function (key) {
                        member.properties[key] = {
                            value: member.properties[key],
                        };
                    });
                }
            });
            return members;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "inSIPInvitingMembers", {
        get: function () {
            var members = this._roomContext.getInSIPInvitingMembers();
            return members;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "inAppInvitingMembers", {
        get: function () {
            var members = this._roomContext.getInAppInvitingMembers();
            return members;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "roomProperties", {
        get: function () {
            var obj = this._roomContext.getRoomProperties();
            Object.keys(obj).forEach(function (key) {
                obj[key] = {
                    value: obj[key],
                };
            });
            return obj;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "roomName", {
        get: function () {
            return this._roomContext.getRoomName();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "roomUuid", {
        get: function () {
            return this._roomContext.getRoomUuid();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "password", {
        get: function () {
            return this._roomContext.getPassword();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "maxMembers", {
        get: function () {
            return this._roomContext.getMaxMembers();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "remainingSeconds", {
        get: function () {
            return this._roomContext.getRemainingSeconds();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "rtcStartTime", {
        get: function () {
            return this._roomContext.getRtcStartTime();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "sipCid", {
        get: function () {
            return this._roomContext.getSipCid();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "isRoomLocked", {
        get: function () {
            return this._roomContext.isRoomLocked();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "isCloudRecording", {
        get: function () {
            return this._roomContext.isCloudRecording();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "chatController", {
        get: function () {
            if (!this._roomChatController) {
                this._roomChatController = new NERoomChatController({
                    roomChatController: this._roomContext.getChatController(),
                    waitingRoomChatController: this._roomContext.getWaitingRoomChatController(),
                });
            }
            return this._roomChatController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "rtcController", {
        get: function () {
            if (!this._rtcController) {
                this._rtcController = new NERoomRtcController({
                    rtcController: this._roomContext.getRtcController(),
                });
            }
            return this._rtcController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "SIPController", {
        get: function () {
            if (!this._sipController) {
                this._sipController = new NERoomSipController({
                    sipController: this._roomContext.getSIPController(),
                });
            }
            return this._sipController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "appInviteController", {
        get: function () {
            if (!this._appInviteController) {
                this._appInviteController = new NERoomAppInviteController({
                    appInviteController: this._roomContext.getAppInviteController(),
                });
            }
            return this._appInviteController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "liveController", {
        get: function () {
            if (!this._liveController) {
                this._liveController = new NERoomLiveController({
                    liveController: this._roomContext.getLiveController(),
                });
            }
            return this._liveController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "whiteboardController", {
        get: function () {
            if (!this._roomWhiteboardController) {
                this._roomWhiteboardController = new NERoomWhiteboardController({
                    roomWhiteboardController: this._roomContext.getWhiteboardController(),
                });
            }
            return this._roomWhiteboardController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "annotationController", {
        get: function () {
            if (!this._roomAnnotationController) {
                this._roomAnnotationController = new NERoomAnnotationController({
                    roomAnnotationController: this._roomContext.getAnnotationController(),
                });
            }
            return this._roomAnnotationController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "waitingRoomController", {
        get: function () {
            if (!this._waitingRoomController) {
                this._waitingRoomController = new NEWaitingRoomController({
                    waitingRoomController: this._roomContext.getWaitingRoomController(),
                });
            }
            return this._waitingRoomController;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(NERoomContext.prototype, "isRoomBlacklistEnabled", {
        get: function () {
            return this._roomContext.isRoomBlacklistEnabled();
        },
        enumerable: false,
        configurable: true
    });
    NERoomContext.prototype.isInWaitingRoom = function () {
        return this._roomContext.isInWaitingRoom();
    };
    NERoomContext.prototype.lockRoom = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.lockRoom(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.unlockRoom = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.unlockRoom(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.addRoomListener = function (listener) {
        var _this = this;
        var _onMemberRoleChanged = listener.onMemberRoleChanged;
        var _onMemberPropertiesChanged = listener.onMemberPropertiesChanged;
        var _onRoomEnded = listener.onRoomEnded;
        if (_onMemberRoleChanged) {
            // @ts-ignore
            listener.onMemberRoleChanged = function (userUuid, beforeRole, afterRole) {
                var member = _this.getMember(userUuid);
                _onMemberRoleChanged(member || userUuid, beforeRole, afterRole);
            };
        }
        if (_onMemberPropertiesChanged) {
            // @ts-ignore
            listener.onMemberPropertiesChanged = function (userUuid, properties) {
                var member = _this.getMember(userUuid);
                Object.keys(properties).forEach(function (key) {
                    properties[key] = {
                        value: properties[key],
                    };
                });
                _onMemberPropertiesChanged(member || userUuid, properties);
            };
        }
        if (_onRoomEnded) {
            // @ts-ignore
            listener.onRoomEnded = function (reason) {
                _this.destroy();
                var reasonMap = {
                    0: 'LEAVE_BY_SELF',
                    1: 'SYNC_DATA_ERROR',
                    2: 'kICK_BY_SELF',
                    3: 'CLOSE_BY_MEMBER',
                    4: 'END_OF_LIFE',
                    5: 'ALL_MEMBERS_OUT',
                    6: 'CLOSE_BY_BACKEND',
                    7: 'KICK_OUT',
                    8: 'LOGIN_STATE_ERROR',
                    9: 'RTC_CHANNEL_ERROR',
                };
                _onRoomEnded(reasonMap[reason]);
            };
        }
        function _roomListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._roomContext.addRoomListener(_roomListenerCallback);
        this._roomListenerMap.set(listener, index);
    };
    NERoomContext.prototype.removeRoomListener = function (listener) {
        var index = this._roomListenerMap.get(listener);
        if (index !== undefined) {
            this._roomContext.removeRoomListener(index);
        }
    };
    NERoomContext.prototype.changeMemberRole = function (userUuid, role) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.changeMemberRole(userUuid, role, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.changeMembersRole = function (userRoleMap) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.changeMembersRole(userRoleMap, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.endRoom = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.endRoom(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.kickMemberOut = function (userUuid, toBlacklist) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.kickMemberOut(userUuid, !!toBlacklist, function (code, message) {
                console.log('kickMemberOut', code, message);
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.changeMyName = function (name) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.changeMyName(name, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.changeMemberName = function (userUuid, name) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.changeMemberName(userUuid, name, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.handOverMyRole = function (name) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.handOverMyRole(name, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.leaveRoom = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            console.log('leaveRoom>>>>>>>>2', _this._roomContext);
            _this._roomContext.leaveRoom(function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.updateRoomProperty = function (key, value, associatedUserUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.updateRoomProperty(key, value, associatedUserUuid || '', function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.deleteRoomProperty = function (key) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.deleteRoomProperty(key, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.updateMemberProperty = function (userUuid, key, value) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var _a;
            var _value = value;
            if (Object.prototype.toString.call(value) === '[object String]') {
                _value = (_a = JSON.parse(_value)) === null || _a === void 0 ? void 0 : _a.value;
            }
            _this._roomContext.updateMemberProperty(userUuid, key, _value, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.deleteMemberProperty = function (userUuid, key) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.deleteMemberProperty(userUuid, key, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.getMember = function (uuid) {
        var _a;
        return this.localMember.uuid === uuid
            ? this.localMember
            : (_a = this.remoteMembers.find(function (member) { return member.uuid === uuid; })) !== null && _a !== void 0 ? _a : null;
    };
    NERoomContext.prototype.addRtcStatsListener = function (listener) {
        function _rtcStatsListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._roomContext.addRtcStatsListener(_rtcStatsListenerCallback);
        this._rtcStatsListenerMap.set(listener, index);
    };
    NERoomContext.prototype.removeRtcStatsListener = function (listener) {
        var index = this._rtcStatsListenerMap.get(listener);
        if (index !== undefined) {
            this._roomContext.removeRtcStatsListener(index);
        }
    };
    NERoomContext.prototype.startCloudRecord = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.startCloudRecord(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.stopCloudRecord = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.stopCloudRecord(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.rejoinAfterAdmittedToRoom = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.rejoinAfterAdmittedToRoom(function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    NERoomContext.prototype.enableRoomBlacklist = function (enable) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomContext.enableRoomBlacklist(!!enable, function (code, message) {
                if (code === 0) {
                    return resolve(SuccessBody(null));
                }
                else {
                    return reject(FailureBodySync(null, message, code));
                }
            });
        });
    };
    /**
     * @ignore 不对外暴露
     */
    NERoomContext.prototype.on = function () {
        throw new Error('Method not implemented.');
    };
    /**
     * @ignore 不对外暴露
     */
    NERoomContext.prototype.off = function () {
        throw new Error('Method not implemented.');
    };
    NERoomContext.prototype.destroy = function () {
        this._roomChatController = undefined;
        this._liveController = undefined;
        this._rtcController = undefined;
        this._roomChatController = undefined;
        this._roomListenerMap = new Map();
        this._rtcStatsListenerMap = new Map();
        this._roomContext = undefined;
        return Promise.resolve(SuccessBody(null));
    };
    return NERoomContext;
}());

var NEPreviewController = /** @class */ (function () {
    function NEPreviewController(initOptions) {
        this._preRtcController = initOptions.preRtcController;
    }
    NEPreviewController.prototype.init = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                console.log('NEPreviewController init');
                return [2 /*return*/];
            });
        });
    };
    Object.defineProperty(NEPreviewController.prototype, "isSupported", {
        get: function () {
            return this._preRtcController.isSupported() || false;
        },
        enumerable: false,
        configurable: true
    });
    // addDeviceChangeListener: (listener: NEPreviewListener) => void
    /**
     * 设置本地视图
     * @param videoView 视频画布
     */
    NEPreviewController.prototype.setupLocalVideoCanvas = function (videoView, mirroring) {
        return this._preRtcController.setupLocalVideoCanvas(Buffer.from([]), !!mirroring);
    };
    /**
     * 开始测试麦克风
     */
    NEPreviewController.prototype.startRecordDeviceTest = function () {
        var _this = this;
        // todo 需要处理回调
        return new Promise(function (resolve, reject) {
            var code = _this._preRtcController.startRecordDeviceTest(500);
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    /**
     * 停止测试麦克风
     */
    NEPreviewController.prototype.stopRecordDeviceTest = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var code = _this._preRtcController.stopRecordDeviceTest();
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    /**
     * 开始测试扬声器设备
     * @param audioResource 音频源
     */
    NEPreviewController.prototype.startPlayoutDeviceTest = function (audioResource) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var code = _this._preRtcController.startPlayoutDeviceTest(audioResource);
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    /**
     * 停止测试扬声器设备
     */
    NEPreviewController.prototype.stopPlayoutDeviceTest = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var code = _this._preRtcController.stopPlayoutDeviceTest();
            return code === 0
                ? resolve(SuccessBody(null))
                : reject(FailureBodySync(null));
        });
    };
    /**
     * 开启预览
     */
    // @ts-ignore
    NEPreviewController.prototype.startPreview = function () {
        return this._preRtcController.startVideoPreview();
    };
    /**
     * 关闭预览
     */
    // @ts-ignore
    NEPreviewController.prototype.stopPreview = function () {
        return this._preRtcController.stopVideoPreview();
    };
    NEPreviewController.prototype.checkSystemRequirements = function () {
        return true;
    };
    // getDeviceListData: () => Promise<DeviceCompilations>
    /**
     * 切换设备
     * @param DeviceType 切换设备类型 'camera' | 'microphone' | 'speaker'
     * @param string
     */
    NEPreviewController.prototype.switchDevice = function (params) {
        return __awaiter(this, void 0, void 0, function () {
            var code;
            return __generator(this, function (_a) {
                code = -1;
                switch (params.type) {
                    case 'camera':
                        code = this._preRtcController.selectCameraDevice(params.deviceId);
                        break;
                    case 'microphone':
                        code = this._preRtcController.selectRecordDevice(params.deviceId);
                        break;
                    case 'speaker':
                        code = this._preRtcController.selectPlayoutDevice(params.deviceId);
                        break;
                }
                if (code === 0) {
                    return [2 /*return*/, SuccessBody({
                            type: params.type,
                            deviceId: params.deviceId,
                        })];
                }
                else {
                    return [2 /*return*/, FailureBody(null, undefined, code)];
                }
            });
        });
    };
    NEPreviewController.prototype.getSelectedRecordDevice = function () {
        return this._preRtcController.getSelectedRecordDevice();
    };
    NEPreviewController.prototype.getSelectedCameraDevice = function () {
        // todo
        return this._preRtcController.getSelectedCameraDevice();
    };
    NEPreviewController.prototype.getSelectedPlayoutDevice = function () {
        return this._preRtcController.getSelectedPlayoutDevice();
    };
    NEPreviewController.prototype.enumRecordDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                deviceList = this._preRtcController.enumRecordDevices();
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NEPreviewController.prototype.enumCameraDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                deviceList = this._preRtcController.enumCameraDevices();
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NEPreviewController.prototype.enumPlayoutDevices = function () {
        return __awaiter(this, void 0, void 0, function () {
            var deviceList;
            return __generator(this, function (_a) {
                deviceList = this._preRtcController.enumPlayoutDevices();
                return [2 /*return*/, SuccessBody(deviceList)];
            });
        });
    };
    NEPreviewController.prototype.setPlayoutDeviceVolume = function (volume) {
        return this._preRtcController.setPlayoutDeviceVolume(Number(volume * 2.55));
    };
    NEPreviewController.prototype.setRecordDeviceVolume = function (volume) {
        return this._preRtcController.setRecordDeviceVolume(Number(volume * 2.55));
    };
    NEPreviewController.prototype.adjustPlaybackSignalVolume = function (volume) {
        return this._preRtcController.adjustPlaybackSignalVolume(Number(volume * 4));
    };
    NEPreviewController.prototype.adjustRecordingSignalVolume = function (volume) {
        return this._preRtcController.adjustRecordingSignalVolume(Number(volume * 4));
    };
    NEPreviewController.prototype.selectedRecordDevice = function (deviceId) {
        return this.switchDevice({ type: 'microphone', deviceId: deviceId });
    };
    NEPreviewController.prototype.selectedCameraDevice = function (deviceId) {
        return this.switchDevice({ type: 'camera', deviceId: deviceId });
    };
    NEPreviewController.prototype.selectedPlayoutDevice = function (deviceId) {
        return this.switchDevice({ type: 'speaker', deviceId: deviceId });
    };
    NEPreviewController.prototype.startBeauty = function () {
        var path = require('path');
        var beautyPath = process.platform === 'win32'
            ? path.join(__dirname, '../assets/')
            : path.join(__dirname, '../assets/beauty/');
        return this._preRtcController.startBeauty(beautyPath.replace('app.asar', 'app.asar.unpacked'));
    };
    NEPreviewController.prototype.stopBeauty = function () {
        return this._preRtcController.stopBeauty();
    };
    NEPreviewController.prototype.enableBeauty = function (isOpenBeauty) {
        return this._preRtcController.enableBeauty(isOpenBeauty);
    };
    NEPreviewController.prototype.setBeautyEffect = function (beautyType, level) {
        return this._preRtcController.setBeautyEffect(beautyType, level);
    };
    NEPreviewController.prototype.enableVirtualBackground = function (enable, path) {
        return this._preRtcController.enableVirtualBackground(enable, path);
    };
    NEPreviewController.prototype.enableAudioVolumeAutoAdjust = function (enable) {
        return this._preRtcController.enableAudioVolumeAutoAdjust(enable);
    };
    NEPreviewController.prototype.enableAudioVolumeIndication = function (enable, interval) {
        return this._preRtcController.enableAudioVolumeIndication(enable, interval);
    };
    NEPreviewController.prototype.enableAudioAINS = function (enable) {
        return this._preRtcController.enableAudioAINS(enable);
    };
    NEPreviewController.prototype.getPlayoutDeviceVolume = function () {
        return this._preRtcController.getPlayoutDeviceVolume();
    };
    NEPreviewController.prototype.getRecordDeviceVolume = function () {
        return this._preRtcController.getRecordDeviceVolume();
    };
    NEPreviewController.prototype.setPlayoutDeviceMute = function (mute) {
        return this._preRtcController.setPlayoutDeviceMute(mute);
    };
    NEPreviewController.prototype.setRecordDeviceMute = function (mute) {
        return this._preRtcController.setRecordDeviceMute(mute);
    };
    NEPreviewController.prototype.installAudioCaptureDriver = function () {
        return this._preRtcController.installAudioCaptureDriver();
    };
    NEPreviewController.prototype.startAudioDump = function (type) {
        if (!type) {
            type = NEAudioDumpType.kNEAudioDumpTypePCM;
        }
        return this._preRtcController.startAudioDump(type);
    };
    NEPreviewController.prototype.stopAudioDump = function () {
        return this._preRtcController.stopAudioDump();
    };
    /**
     * @ignore 不对外暴露
     */
    NEPreviewController.prototype.destroy = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                console.log('destroy');
                return [2 /*return*/];
            });
        });
    };
    return NEPreviewController;
}());

var NEPreviewRoomContextService = /** @class */ (function () {
    function NEPreviewRoomContextService(initOptions) {
        this._roomListenerMap = new Map();
        this._previewRoomContext = initOptions.previewRoomContext;
        this.previewController = new NEPreviewController({
            preRtcController: this._previewRoomContext.getPreviewRoomRtcController(),
        });
    }
    NEPreviewRoomContextService.prototype.addPreviewRoomListener = function (listener) {
        function _previewRoomListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        var index = this._previewRoomContext.addPreviewRoomListener(_previewRoomListenerCallback);
        this._roomListenerMap.set(listener, index);
    };
    NEPreviewRoomContextService.prototype.removePreviewRoomListener = function (listener) {
        var index = this._roomListenerMap.get(listener);
        if (index !== undefined) {
            try {
                this._previewRoomContext.removePreviewRoomListener(index);
            }
            catch (e) {
                console.log('removePreviewRoomListener', index);
            }
        }
    };
    return NEPreviewRoomContextService;
}());

var NERoomService = /** @class */ (function () {
    function NERoomService(initOptions) {
        this._roomContext = null;
        this._preRoomContext = null;
        this._roomService = initOptions.roomKit.getRoomService();
    }
    NERoomService.prototype.createRoom = function (params, options) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomService.createRoom(params, options, function (code, message) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: null });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    NERoomService.prototype.getRoomContext = function (roomUuid) {
        // if (!this._roomContext) {
        this._roomContext = new NERoomContext({
            roomService: this._roomService,
            roomUuid: roomUuid,
        });
        // }
        return this._roomContext;
    };
    NERoomService.prototype.joinRoom = function (params, options) {
        return this._joinRoomHandler(params, options, 'joinRoom');
    };
    NERoomService.prototype.joinRoomByInvite = function (params, options) {
        return this._joinRoomHandler(params, options, 'joinRoomByInvite');
    };
    NERoomService.prototype.previewRoom = function (params, options) {
        var _this = this;
        return new Promise(function (resolve) {
            _this._roomService.previewRoom(params, options, function (code, message, previewRoomContext) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: previewRoomContext });
                }
                else {
                    resolve({ code: code, message: message, data: previewRoomContext });
                }
            });
        });
    };
    NERoomService.prototype.getPreviewRoomContext = function () {
        if (!this._preRoomContext) {
            var previewRoomContext = this._roomService.getPreviewRoomContext();
            this._preRoomContext = new NEPreviewRoomContextService({
                previewRoomContext: previewRoomContext,
            });
        }
        return this._preRoomContext;
    };
    NERoomService.prototype.getRoomCloudRecordList = function (roomArchiveId) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            roomArchiveId = String(roomArchiveId);
            _this._roomService.getRoomCloudRecordList(roomArchiveId, function (code, message, data) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: data });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    NERoomService.prototype.fetchChatroomHistoryMessages = function (roomArchiveId, option) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomService.fetchChatroomHistoryMessages(roomArchiveId, option, function (code, message, data) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: data });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    NERoomService.prototype.exportChatroomHistoryMessages = function (roomArchiveId) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            roomArchiveId = String(roomArchiveId);
            _this._roomService.exportChatroomHistoryMessages(roomArchiveId, function (code, message, data) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: data });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    NERoomService.prototype.rejectInvite = function (roomUuid) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            roomUuid = String(roomUuid);
            _this._roomService.rejectInvite(roomUuid, function (code, message, data) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: data });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    NERoomService.prototype.destroy = function () {
        return this._roomService.destroy();
    };
    NERoomService.prototype._joinRoomHandler = function (params, options, type) {
        if (params.initialProperties) {
            // initialProperties: Record<string,string>
            Object.keys(params.initialProperties).forEach(function (key) {
                if (typeof params.initialProperties[key] === 'object') {
                    params.initialProperties[key] = JSON.stringify(params.initialProperties[key]);
                }
            });
        }
        Object.keys(params).forEach(function (key) {
            if (typeof params[key] === 'undefined') {
                delete params[key];
            }
        });
        var func = type === 'joinRoom'
            ? this._roomService.joinRoom.bind(this._roomService)
            : this._roomService.joinRoomByInvite.bind(this._roomService);
        return new Promise(function (resolve, reject) {
            func(params, __assign(__assign({}, options), { enableMyAudioDeviceOnJoinRtc: true }), function (code, message, roomContext) {
                if (code === 0) {
                    resolve({ code: code, message: null, data: roomContext });
                }
                else {
                    reject({ code: code, message: message, data: null });
                }
            });
        });
    };
    return NERoomService;
}());

var neroom = require('../build/Release/neroom.node');
// @ts-ignore
if (process.platform === 'win32') {
    // @ts-ignore
    var path = require('path');
    // @ts-ignore
    var asarPath = path.join(__dirname, '../build/Release/');
    var unpackedPath = asarPath.replace('app.asar', 'app.asar.unpacked');
    // @ts-ignore
    process.env.PATH = "".concat(unpackedPath, ";").concat(process.env.PATH);
}
var Roomkit = /** @class */ (function () {
    function Roomkit() {
        this._roomService = null;
        this._authService = null;
        this._messageChannelService = null;
        this._nosService = null;
        this._roomkit = new neroom.INERoomKit();
    }
    Object.defineProperty(Roomkit.prototype, "isInitialized", {
        get: function () {
            var _a;
            return !!((_a = this._roomkit) === null || _a === void 0 ? void 0 : _a.isInitialized());
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(Roomkit.prototype, "sdkVersions", {
        get: function () {
            return this._roomkit.getSdkVersions();
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(Roomkit.prototype, "authService", {
        get: function () {
            if (!this._authService) {
                this._authService = new NEAuthService({
                    roomKit: this._roomkit,
                });
            }
            return this._authService;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(Roomkit.prototype, "roomService", {
        get: function () {
            if (!this._roomService) {
                this._roomService = new NERoomService({
                    roomKit: this._roomkit,
                });
            }
            return this._roomService;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(Roomkit.prototype, "nosService", {
        get: function () {
            if (!this._nosService) {
                this._nosService = new NENosService({
                    roomKit: this._roomkit,
                });
            }
            return this._nosService;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(Roomkit.prototype, "messageChannelService", {
        get: function () {
            if (!this._messageChannelService) {
                this._messageChannelService = new NEMessageChannelService({
                    messageChannelService: this._roomkit.getMessageChannelService(),
                });
            }
            return this._messageChannelService;
        },
        enumerable: false,
        configurable: true
    });
    Roomkit.prototype.getService = function (type) {
        if (type === 'roomService') {
            return this.roomService;
        }
        else if (type === 'authService') {
            return this.authService;
        }
        else if (type === 'messageService') {
            return this.messageChannelService;
        }
    };
    Object.defineProperty(Roomkit.prototype, "deviceId", {
        get: function () {
            return this._roomkit.getDeviceId();
        },
        enumerable: false,
        configurable: true
    });
    Roomkit.prototype.switchLanguage = function (language) {
        var roomLanguageMap = {
            default: 0,
            CHINESE: 1,
            ENGLISH: 2,
            JAPANESE: 3,
        };
        return this._roomkit.switchLanguage(roomLanguageMap[language || 'default']);
    };
    Roomkit.prototype.initialize = function (options) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomkit.initialize(options, function (code, message) {
                if (code === 0) {
                    resolve(SuccessBody(null));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    Roomkit.prototype.release = function () {
        try {
            this._roomkit.release();
            this._roomkit = undefined;
            return SuccessBody(null);
        }
        catch (error) {
            return FailureBodySync(error, NEErrorMessage.FAILURE);
        }
    };
    Roomkit.prototype.addGlobalEventListener = function (listener) {
        function _globalEventListenerCallback(key) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            if (listener[key]) {
                listener[key].apply(listener, __spreadArray([], __read(args), false));
            }
        }
        this._roomkit.addGlobalEventListener(_globalEventListenerCallback);
    };
    Roomkit.prototype.removeGlobalEventListener = function (listener) {
        this._roomkit.removeGlobalEventListener(listener);
    };
    Roomkit.prototype.reuseIM = function () {
        // todo
    };
    Roomkit.prototype.emit = function () {
        // todo
    };
    Roomkit.prototype.uploadLog = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            _this._roomkit.uploadLog(function (code, message, url) {
                if (code === 0) {
                    resolve(SuccessBody(url));
                }
                else {
                    reject(FailureBodySync({ code: code, message: message }));
                }
            });
        });
    };
    return Roomkit;
}());

module.exports = Roomkit;
//# sourceMappingURL=index.cjs.js.map
