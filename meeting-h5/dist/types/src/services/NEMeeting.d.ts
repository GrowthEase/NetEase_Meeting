import { AccountInfo, CreateMeetingResponse, Dispatch, hostAction, IMInfo, memberAction, NEMeetingCreateOptions, NEMeetingGetListOptions, NEMeetingInitConfig, NEMeetingJoinOptions, NEMeetingLoginByPasswordOptions, NEMeetingLoginByTokenOptions, GetMeetingConfigResponse } from '../types';
import { AudioProfile, DeviceType, NEMediaTypes, NEPreviewController, NERoomChatController, NERoomContext, NERoomLiveController, NERoomLiveInfo, NERoomLiveRequest, NERoomRtcController, NERoomWhiteboardController, Roomkit } from 'neroom-web-sdk';
import EventEmitter from 'eventemitter3';
import { Logger } from '../utils/Logger';
import { MeetingList, NEMeetingSDK, SipMember } from '../types/type';
export declare function updateMeetingService(neMeeting: NEMeetingService | null, dispatch: Dispatch): void;
export default class NEMeetingService {
    roomContext: NERoomContext | null;
    rtcController: NERoomRtcController | null;
    chatController: NERoomChatController | null;
    whiteboardController: NERoomWhiteboardController | null;
    liveController: NERoomLiveController | null;
    previewController: NEPreviewController | null;
    isUnMutedAudio: boolean;
    isUnMutedVideo: boolean;
    private _isAnonymous;
    private _isLoginedByAccount;
    private _meetingStatus;
    private roomService;
    private authService;
    private messageService;
    private _roomkit;
    private _eventEmitter;
    private _userUuid;
    private _appKey;
    private _token;
    private _meetingServerDomain;
    private _privateMeetingNum;
    private _request;
    private _meetingInfo;
    private _meetingType;
    private _isReuseIM;
    private _language;
    private _logger;
    private _accountInfo;
    private _noChat;
    private _xkitReport;
    private _meetingStartTime;
    constructor(params: {
        roomkit: Roomkit;
        eventEmitter: EventEmitter;
        logger: Logger;
    });
    get eventEmitter(): EventEmitter;
    get localMember(): any;
    get meetingId(): number;
    get meetingNum(): string;
    get roomDeviceId(): string;
    get accountInfo(): AccountInfo | null;
    get avRoomUid(): string;
    get meetingStatus(): string;
    get microphoneId(): string;
    get cameraId(): string;
    get speakerId(): string;
    switchLanguage(language?: 'zh-CN' | 'en-US' | 'ja-JP'): void;
    removeGlobalEventListener(): void;
    get imInfo(): IMInfo | null;
    init(params: NEMeetingInitConfig): Promise<void>;
    getGlobalConfig(): Promise<GetMeetingConfigResponse>;
    login(options: NEMeetingLoginByPasswordOptions | NEMeetingLoginByTokenOptions): Promise<void>;
    getAppInfo(): Promise<{
        appName: string;
    }>;
    getAppTips(): Promise<any>;
    getAppConfig(): Promise<any>;
    updateUserNickname(nickname: string): Promise<void>;
    getMeetingList(options: NEMeetingGetListOptions): Promise<CreateMeetingResponse[]>;
    getMeetingInfoByFetch(meetingId: string): Promise<CreateMeetingResponse>;
    scheduleMeeting(options: NEMeetingCreateOptions): Promise<void>;
    cancelMeeting(meetingId: string): Promise<void>;
    create(options: NEMeetingCreateOptions): Promise<void>;
    addSipMember(sipNum: string, sipHost: string): Promise<any>;
    startLive(options: NERoomLiveRequest): Promise<import("neroom-web-sdk").NEResult<NERoomLiveInfo>> | undefined;
    stopLive(): Promise<import("neroom-web-sdk").NEResult<null>> | undefined;
    updateLive(options: NERoomLiveRequest): Promise<import("neroom-web-sdk").NEResult<NERoomLiveInfo>> | undefined;
    getLiveInfo(): NERoomLiveInfo | null;
    getSipMemberList(): Promise<{
        list: SipMember[];
    }>;
    getLocalVideoStats(): Promise<import("neroom-web-sdk").NERoomRtcVideoSendStats> | undefined;
    getRemoteVideoStats(): Promise<import("neroom-web-sdk").NERoomRtcVideoRecvStats[]> | undefined;
    anonymousJoin(options: NEMeetingJoinOptions): Promise<any>;
    logout(): Promise<void>;
    leave(role?: string): Promise<void>;
    end(): Promise<void>;
    resetStatus(): void;
    getMeetingInfo(): NEMeetingSDK | null;
    sendMemberControl(type: memberAction, uuid?: string): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    sendHostControl(type: hostAction, uuid: string): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    muteLocalAudio(need?: boolean): Promise<false | import("neroom-web-sdk").NEResult<null> | undefined>;
    unmuteLocalAudio(deviceId?: string, need?: boolean): Promise<false | import("neroom-web-sdk").NEResult<null> | import("neroom-web-sdk").NEResult<import("neroom-web-sdk").NEDeviceSwitchInfo> | undefined>;
    switchDevice(options: {
        type: DeviceType;
        deviceId: string;
    }): Promise<import("neroom-web-sdk").NEResult<import("neroom-web-sdk").NEDeviceSwitchInfo>> | undefined;
    muteLocalVideo(need?: boolean): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    unmuteLocalVideo(deviceId?: string, need?: boolean): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    muteLocalScreenShare(): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    unmuteLocalScreenShare(params?: {
        sourceId?: string;
    }): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    changeLocalAudio(deviceId: string): Promise<import("neroom-web-sdk").NEResult<import("neroom-web-sdk").NEDeviceSwitchInfo> | undefined>;
    changeLocalVideo(deviceId: string, need?: boolean): Promise<import("neroom-web-sdk").NEResult<import("neroom-web-sdk").NEDeviceSwitchInfo> | undefined>;
    join(options: NEMeetingJoinOptions): Promise<any>;
    getSelectedRecordDevice(): string;
    getSelectedCameraDevice(): string;
    getSelectedPlayoutDevice(): string;
    getMicrophones(): Promise<import("neroom-web-sdk").NEDeviceBaseInfo[]>;
    getCameras(): Promise<import("neroom-web-sdk").NEDeviceBaseInfo[] | undefined>;
    getSpeakers(): Promise<import("neroom-web-sdk").NEDeviceBaseInfo[] | undefined>;
    selectSpeakers(speakerId: string): Promise<import("neroom-web-sdk").NEResult<import("neroom-web-sdk").NEDeviceSwitchInfo> | undefined>;
    setVideoProfile(resolution: number, frameRate?: number): Promise<void | undefined>;
    setAudioProfile(profile: AudioProfile): Promise<void | undefined>;
    modifyNickName(options: {
        nickName: string;
    }): Promise<import("neroom-web-sdk").NEResult<null> | undefined>;
    replayRemoteStream(options: {
        userUuid: string;
        type: NEMediaTypes;
    }): void;
    checkSystemRequirements(): Promise<boolean>;
    destroy(): Promise<void>;
    release(): Promise<void>;
    destroyRoomContext(): Promise<void>;
    /**
     * 获取参会记录列表
     */
    getHistoryMeetingList(params?: {
        startId?: number;
        limit?: number;
    }): Promise<{
        meetingList: MeetingList[];
    }>;
    /**
     * 获取收藏参会列表
     */
    getCollectMeetingList(params?: {
        startId?: number;
        limit?: number;
    }): Promise<{
        favoriteList: MeetingList[];
    }>;
    /**
     * 收藏会议
     */
    collectMeeting(roomArchiveId: number): Promise<any>;
    /**
     * 取消收藏会议
     */
    cancelCollectMeeting(roomArchiveId: number): Promise<any>;
    private _reset;
    private _addRtcListener;
    private _addRoomListener;
    private _joinHandler;
    private _deviceChange;
    private _connectionStateChange;
    private _handleMemberAction;
    private _handleHostAction;
    private _transformReason;
    private _joinRoomkit;
    private _clientBanned;
    private createRequest;
}
