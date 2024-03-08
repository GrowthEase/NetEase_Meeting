import { DevicesInfo } from '@/types';
import { message } from 'antd';
import axios from 'axios';

// const PERF_BASE_URL = 'https://roomkit-dev.netease.im/perf';
// const DEV_BASE_URL = 'https://roomkit-dev.netease.im';
// const PROD_BASE_URL = 'https://roomkit.netease.im';

export const domain = process.env.ROOMS_DOMAIN;

function uuidv4() {
  if (
    typeof crypto !== 'undefined' &&
    typeof crypto.randomUUID === 'function'
  ) {
    return crypto.randomUUID();
  }
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0,
      v = c == 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

function getDeviceId() {
  const STORE_KEY = 'NetEase-Rooms-DeviceId';
  let deviceId = localStorage.getItem(STORE_KEY);
  if (!deviceId) {
    deviceId = uuidv4();
    localStorage.setItem(STORE_KEY, deviceId);
    window.ipcRenderer?.send('flushStorageData');
  }
  return deviceId;
}

interface AccountInfo {
  appKey: string;
  userUuid: string;
  userToken: string;
}

const APP_USER_ACCOUNT_INFO_KEY = 'NetEase-Rooms-User-Account-Info';

export function setAccountInfo(info: AccountInfo): void {
  localStorage.setItem(APP_USER_ACCOUNT_INFO_KEY, JSON.stringify(info));
}
export function removeAccountInfo(): void {
  localStorage.removeItem(APP_USER_ACCOUNT_INFO_KEY);
}

export function getAccountInfo(): AccountInfo | undefined {
  const accountInfo = localStorage.getItem(APP_USER_ACCOUNT_INFO_KEY);
  if (accountInfo) {
    return JSON.parse(accountInfo);
  }
}

function getHeaders() {
  const account = getAccountInfo();
  if (account) {
    return {
      AppKey: account.appKey,
      user: account.userUuid,
      token: account.userToken,
    };
  }
  return undefined;
}

const request = axios.create({
  baseURL: domain,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json;charset=UTF-8',
    'accept-language': 'zh-CN',
    clientType: 'mac',
    deviceid: getDeviceId(),
    appver: '1.0.0',
  },
});

request.interceptors.response.use(
  (response) => {
    if (response.data.code === 0) {
      return response.data.data;
    } else if (response.data.code === 996) {
      return response.data.data;
    } else {
      let msg = response.data.msg;
      if (response.config.url === '/rooms_sdk/v1/activate') {
        if (response.data.code === 1602) {
          msg = '激活码错误，请重新输入激活码';
        }
        if (response.data.code === 1603) {
          msg = '激活码已被使用，请联系管理员解除绑定';
        }
      }
      message.error(msg);
      throw response.data.msg;
    }
  },
  /*
  (error) => {
    
    if (error.message && error.message === 'Network Error') {
      message.error('网络错误');
      throw '网络错误';
    }
    throw error;
  },
  */
);

export interface QRCodeRes extends AccountInfo {
  qrcode: string;
  expireSeconds: number;
}

export function getRoomsQRCode(): Promise<QRCodeRes> {
  const url = '/rooms_sdk/v1/qrcode';
  return request.get(url);
}

export function activateRooms(code: string): Promise<AccountInfo> {
  const url = '/rooms_sdk/v1/activate';
  return request.post(url, { code });
}

export function deactivateRooms(): Promise<RoomsInfo> {
  const url = `/rooms_sdk/v1/deactivate`;
  return request.post(
    url,
    {},
    {
      headers: getHeaders(),
    },
  );
}

const DEFAULT_SETTINGS = {
  speakerOutputVolume: 100,
  videoMirrorEnabled: true,
  micInputVolume: 100,
  audioAINSEnabled: true,
  highlightActiveUserEnabled: true,
  videoBeautyEnabled: true,
  showMeetingTimeEnabled: true,
  showShareCodeEnabled: true,
  showMeetingNumEnabled: true,
  audioEnabled: true,
  videoEnabled: true,
};

export interface Settings {
  pairingCode: string;
  enableAutoUpdate: boolean;
  enablePassword: boolean;
  enableRecord: boolean;
  recordModel: number;
  // selectedMicDeviceId: string;
  // selectedSpeakerDeviceId: string;
  // selectedVideoDeviceId: string;
  speakerOutputVolume: number;
  videoMirrorEnabled: boolean;
  micInputVolume: number;
  audioAINSEnabled: boolean;
  highlightActiveUserEnabled: boolean;
  videoBeautyEnabled: boolean;
  showMeetingTimeEnabled: boolean;
  showShareCodeEnabled: boolean;
  showMeetingNumEnabled: boolean;
  audioEnabled: boolean;
  videoEnabled: boolean;
  updateVersion?: {
    mac: PlatformVersion;
    pc: PlatformVersion;
  };
}

export interface PlatformVersion {
  versionName: string;
}

export interface VersionInfo {
  forceVersionCode: number;
  versionName: string;
  versionCode: number;
  downloadUrl: string;
  description: string;
  title: string;
  url: string;
  notify: number;
  checkCode: string;
}

type Control = {
  controlId: number;
  account: string;
  deviceId: string;
};

type BrandInfo = {
  brandIconUrl: string;
  brandLogoUrl: string;
  brandName: string;
  clausesUrl: string;
  privacyUrl: string;
};

export interface RoomsInfo {
  nickname: string;
  pairingCode: string;
  corpName: string;
  shortMeetingNum: string;
  settings: Settings;
  brandInfo: BrandInfo;
  controls?: Control[];
  device: DevicesInfo;
}

export function getRoomsInfo(): Promise<RoomsInfo> {
  const url = `/rooms_sdk/v1/node_info`;
  return request
    .get<any, RoomsInfo>(url, {
      headers: getHeaders(),
    })
    .then((res) => {
      res.settings = {
        ...DEFAULT_SETTINGS,
        ...res.settings,
      };
      return res;
    });
}

export function reportDevices(params: DevicesInfo): Promise<void> {
  const url = `/rooms_sdk/v1/hb_node_device`;
  return request.post(url, params, {
    headers: getHeaders(),
  });
}

interface CustomMessageParams {
  toUserUuid: string;
  cmdId: number;
  message: string;
}

export function sendCustomMessage(params: CustomMessageParams): Promise<void> {
  const { appKey } = getAccountInfo() || {};
  const url = `/scene/apps/${appKey}/v1/${params.toUserUuid}/send`;
  return request.post(url, params, {
    headers: getHeaders(),
  });
}

export default {
  getAccountInfo,
  getRoomsQRCode,
  activateRooms,
  deactivateRooms,
  getRoomsInfo,
  reportDevices,
  sendCustomMessage,
  removeAccountInfo,
  setAccountInfo,
};
