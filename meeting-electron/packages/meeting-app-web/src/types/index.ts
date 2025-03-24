import { NEmeetingItemLivePushThirdPart } from '@meeting-module/kit/interface';

export enum IPCEvent {
  beforeLogin = 'beforeLogin',
  beforeEnterRoom = 'beforeEnterRoom',
  enterRoom = 'enterRoom',
  openSetting = 'openSetting',
  closeSetting = 'closeSetting',
  openChatroomOrMemberList = 'openChatroomOrMemberList',
  openChatroomOrMemberListReply = 'openChatroomOrMemberList-reply',
  changeSetting = 'changeSetting',
  changeSettingDevice = 'changeSettingDevice',
  changeSettingDeviceFromControlBar = 'changeSettingDeviceFromControlBar',
  showSettingWindow = 'showSettingWindow',
  openNPS = 'open-meeting-nps',
  needOpenNPS = 'need-open-meeting-nps',
  setNPS = 'set-meeting-nps',
  isMainFullscreen = 'isMainFullScreen',
  isMainFullscreenReply = 'isMainFullscreen-reply',
  quiteFullscreen = 'leave-full-screen',
  enterFullscreen = 'enter-full-screen',
  meetingStatus = 'meetingStatus',
  createMeeting = 'createMeeting',
  joinMeeting = 'joinMeeting',
  mouseLeave = 'mouseLeave',
  mouseEnter = 'mouseEnter',
  changeMirror = 'changeMirror',
  whiteboardTransparentMirror = 'whiteboardTransparentMirror',
  getLogPath = 'getLogPath',
  getPrivateConfig = 'getPrivateConfig',
  previewController = 'previewController',
  getMemberListWindowIsOpen = 'getMemberListWindowIsOpen',

  updateProgress = 'update-progress',
  showUpdateProgressBar = 'show-update-progress-bar',
  checkUpdate = 'check-update',
  getCheckUpdateInfo = 'get-check-update-info',
  getLocalUpdateInfo = 'get-local-update-info',
  updateError = 'update-error',
  semverLt = 'semver-lt',
  decodeBase64 = 'decode-base64',
  downloadFileByURL = 'download-file-by-url',
  cancelUpdate = 'cancel-update',
  exitApp = 'exit-app',

  noPermission = 'no-permission',
  alreadyInMeeting = 'already-in-meeting',
  changeMeetingStatus = 'change-meeting-status',
  deleteAudioDump = 'delete-audio-dump',

  joinMeetingLoading = 'join-meeting-loading',
  inWaitingRoom = 'in-waiting-room',

  notifyShow = 'notify-show',
  notifyHide = 'notify-hide',
  memberNotifyViewMemberMsg = 'member-notify-view-member-msg',
  memberNotifyClose = 'member-notify-close',
  memberNotifyNotNotify = 'member-notify-not-notify',
  memberNotifyMourseMove = 'member-notify-mousemove',

  sharingScreen = 'nemeeting-sharing-screen',
  minimizeWindow = 'minimize-window',
  maximizeWindow = 'maximize-window',
  isStartByUrl = 'isStartByUrl',
  openBrowserWindow = 'open-browser-window',
  choseFile = 'nemeeting-choose-file',
  choseFileDone = 'nemeeting-choose-file-done',
  beauty = 'nemeeting-beauty',
  downloadPath = 'nemeeting-download-path',
  downloadPathReply = 'nemeeting-download-path-reply',
  relaunch = 'relaunch',
  focusWindow = 'focusWindow',
  annotationWindow = 'annotationWindow',
  electronJoinMeeting = 'electron-join-meeting',
  getThemeColor = 'get-theme-color',
  setThemeColor = 'set-theme-color',
  getDeviceAccessStatus = 'getDeviceAccessStatus',
  openMeetingAbout = 'open-meeting-about',
  setExcludeWindowList = 'setExcludeWindowList',
  mainCloseBefore = 'main-close-before',
  openMeetingFeedback = 'open-meeting-feedback',
  getSystemManufacturer = 'get-system-manufacturer',
  openMeeting = 'nemeeting-open-meeting',
  childWindowClosed = 'childWindow:closed',
  getMonitoringInfo = 'getMonitoringInfo',
  getVirtualBackground = 'getVirtualBackground',
  getConverImage = 'getConverImage',
  getImageBase64 = 'nemeeting-get-image-base64',
  addVirtualBackgroundReply = 'addVirtualBackground-reply',

  interpreterWindowChange = 'interpreterWindowChange',
  openDevTools = 'openDevTools',
  displayChanged = 'display-changed',
  NEMeetingKitCrash = 'NEMeetingKitCrash',
}

export enum UpdateType {
  noUpdate,
  normalUpdate,
  forceUpdate,
}

export interface ResUpdateInfo {
  forceVersionCode: number;
  latestVersionName: string;
  latestVersionCode: number;
  downloadUrl: string;
  description: string;
  title: string;
  url: string;
  notify: number;
  checkCode: string;
  extVersionConfig?: Record<string, unknown>;
}

export interface UpdateInfo {
  versionCode: number;
  clientAppCode: number;
  accountId: string;
  framework: 'Electron-native' | 'Electron-web';
  osVer: string;
  buildVersion: string;
}

export interface SelectedDeviceInfo {
  selectedVideoDeviceId: string;
  selectedMicDeviceId: string;
  selectedSpeakerDeviceId: string;
}

export interface DeviceInfo {
  id: string;
  name: string;
  selected: boolean;
  isDefault: boolean;
}
export interface DevicesInfo {
  name: string;
  model: string;
  video: {
    in: DeviceInfo[];
  };
  audio: {
    in: DeviceInfo[];
    out: DeviceInfo[];
  };
}

export interface EnterPriseInfo {
  appKey: string;
  appName: string;
  idpList: Array<IdpInfo>;
  ssoLevel: number;
}
export interface IdpInfo {
  id: number;
  name: string;
  type: number;
}

export interface LoginUserInfo {
  username: string;
  userUuid: string;
  userToken: string;
  nickname: string;
  privateMeetingNum: string;
  initialPassword?: boolean;
  shortMeetingNum: string;
  sipCid: string;
  avatar: string;
  phoneNumber: string;
  email: string;
  settings: Record<string, unknown>;
  serviceBundle: {
    name: string;
    meetingMaxMinutes: number;
    meetingMaxMembers: number;
  };
}

export interface GuestMeetingInfo {
  /** 跨应用入会token */
  meetingUserToken: string;
  /** 跨应用入会uuid */
  meetingUserUuid: string;
  /** 跨应用入会appKey */
  meetingAppKey: string;
  /** 跨应用鉴权类型 */
  meetingAuthType: string;
  /** 访客跨应用入会类型 0 不允许访客入会 1 实名访客入会 2 匿名访客入会*/
  guestJoinType: string;
}

export enum ServerGuestErrorCode {
  MEETING_GUEST_JOIN_DISABLED = 3432,
  MEETING_GUEST_NEED_VERIFY = 3433,
}

export interface PushThirdPart {
  pushThirdParties;
}

export interface LiveSettingInfo {
  background?: LiveBackground;
  password?: string;
  title?: string;
  pushThirdParties?: NEmeetingItemLivePushThirdPart[];
  enableThirdParties?: boolean;
  liveChatRoomEnable?: boolean;
}

export interface LiveBackground {
  backgroundUrl?: string;
  notStartCoverUrl?: string;
  backgroundFile?: Blob | string;
  thumbnailBackUrl?: string;
  notStartThumbnailUrl?: string;
  thumbnailBackFile?: Blob | string;
}

export interface PlatformInfo {
  platformName: string;
  pushUrl: string;
  pushSecretKey?: string;
  id?: string;
}
