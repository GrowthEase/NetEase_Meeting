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
  quiteFullscreen = 'quiteFullscreen',
  meetingStatus = 'meetingStatus',
  createMeeting = 'createMeeting',
  joinMeeting = 'joinMeeting',
  mouseLeave = 'mouseLeave',
  mouseEnter = 'mouseEnter',
  changeMirror = 'changeMirror',
  whiteboardTransparentMirror = 'whiteboardTransparentMirror',
  getLogPath = 'getLogPath',
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
  extVersionConfig?: Record<string, any>;
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
  settings: Record<string, any>;
  serviceBundle: {
    name: string;
    meetingMaxMinutes: number;
    meetingMaxMembers: number;
  };
}
