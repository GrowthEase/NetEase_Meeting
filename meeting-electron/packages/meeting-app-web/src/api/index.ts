import request from './request';
import { APP_KEY } from '../config';
import { EnterPriseInfo, GuestMeetingInfo, LoginUserInfo } from '../types';
import { getUUID } from '@meeting-module/utils';

function getDeviceId(): string {
  let uuid = window.sessionStorage.getItem('NERoomkit-uuid');

  if (uuid) {
    return uuid;
  } else {
    uuid = getUUID();
    window.sessionStorage.setItem('NERoomkit-uuid', uuid);
  }

  return uuid;
}

// 发送短信验证码-新接口
export function sendVerifyCodeApi(params: {
  appKey?: string;
  mobile?: string;
  scene?: number;
}) {
  return request({
    method: 'GET',
    url: `/scene/meeting/${params.appKey || APP_KEY}/v1/sms/${params.mobile}/${
      params.scene
    }`,
  });
}

export function loginApi(params: {
  verifyCode?: string;
  username?: string;
  mobile?: string;
  appKey?: string;
}) {
  const appKey = params.appKey || APP_KEY;
  const url = params.verifyCode
    ? `/scene/meeting/${appKey}/v1/mobile/${params.mobile}/login` // 验证码登录
    : `/scene/meeting/${appKey}/v1/login/${params.username}`; // 账号密码登录

  return request({
    url,
    method: 'POST',
    data: params,
  }) as unknown as Promise<LoginUserInfo>;
}

export function loginApiNew(params: {
  username?: string;
  phone?: string;
  email?: string;
  appKey?: string;
}) {
  const appKey = params.appKey || APP_KEY || '';
  let url: string = '/scene/meeting/v1/login-username';

  if (params.username) {
    url = `/scene/meeting/v1/login-username`; // 账号密码登录
  }

  if (params.phone) {
    url = `/scene/meeting/v1/login-phone`; // 手机号登录
  }

  if (params.email) {
    url = `/scene/meeting/v1/login-email`; // 邮箱登录
  }

  return request({
    url,
    method: 'POST',
    data: params,
    headers: {
      AppKey: appKey,
    },
  }) as unknown as Promise<LoginUserInfo>;
}

export function getEnterPriseInfoApi(params: {
  code?: string;
  email?: string;
}): Promise<EnterPriseInfo> {
  return request({
    url: `/scene/meeting/v2/app-info`,
    params,
    method: 'GET',
  }) as unknown as Promise<EnterPriseInfo>;
}

export function modifyPasswordApi(params: {
  password: string;
  newPassword: string;
  appKey?: string;
  username: string;
}): Promise<LoginUserInfo> {
  const { password, username, appKey, newPassword } = params;

  return request({
    url: `/scene/meeting/v2/password`,
    data: {
      username,
      password,
      newPassword,
    },
    headers: {
      AppKey: appKey || (APP_KEY as string),
    },
    method: 'POST',
  }) as unknown as Promise<LoginUserInfo>;
}

export function getMeetingInfoForGuest(
  meetingNum: string,
): Promise<GuestMeetingInfo> {
  return request({
    url: `/scene/meeting/v2/meetingInfoForGuest/${meetingNum}`,
    headers: {
      deviceId: getDeviceId(),
    },
    method: 'GET',
  }) as unknown as Promise<GuestMeetingInfo>;
}

export function sendVerifyCodeApiByGuest(
  meetingNum: string,
  phoneNum: string,
): Promise<void> {
  return request({
    url: `/scene/meeting/v2/smsForGuestJoinWithMeetingNum/${meetingNum}`,
    params: {
      phoneNum,
    },
    headers: {
      deviceId: getDeviceId(),
    },
    method: 'GET',
  }) as unknown as Promise<void>;
}

export function getMeetingInfoForGuestByPhoneNum(data: {
  meetingNum: string;
  phoneNum: string;
  verifyCode: string;
}): Promise<GuestMeetingInfo> {
  const { meetingNum, phoneNum, verifyCode } = data;

  return request({
    url: `/scene/meeting/v2/meetingInfoForGuest/${meetingNum}`,
    params: {
      phoneNum,
      verifyCode,
    },
    headers: {
      deviceId: getDeviceId(),
    },
    method: 'GET',
  }) as unknown as Promise<GuestMeetingInfo>;
}
