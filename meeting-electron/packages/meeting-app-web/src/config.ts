const isApp = typeof process != 'undefined';

export const DOMAIN_SERVER = isApp ? process.env.MEETING_DOMAIN : '';

export const APP_KEY = isApp ? process.env.APP_KEY : '';

export const UPDATE_URL = isApp ? process.env.UPDATE_URL : '';

export const LOCALSTORAGE_USER_INFO = 'userinfoV2';

export const NOT_FIRST_LOGIN = 'nemeeting-notFirstLogin';

export const LOCALSTORAGE_LOGIN_BACK = 'ne-meeting-loginBackUrl';

export const LOCALSTORAGE_MEETING_SETTING = 'ne-meeting-setting';

export const LOCALSTORAGE_SSO_APP_KEY = 'ne-meeting-sso-app-key';
export const LOCALSTORAGE_INVITE_MEETING_URL = 'invite-ne-meeting-url';

export const LOCAL_GUEST_RECENT_MEETING_LIST =
  'ne-meeting-guest-recent-meeting-list';

export const LOCAL_GUEST_JOIN_NICKNAME = 'ne-meeting-guest-join-nickname';
export const LOCAL_GUEST_REMEMBER_NICKNAME =
  'ne-meeting-guest-remember-nickname';

export const SSO_APP_KEY = isApp ? process.env.SSO_APP_KEY : ''; // test

export const PROTOCOL = 'nemeeting';

export const MEETING_ENV = isApp ? process.env.MEETING_ENV : '';

export const PRIVATE_CONFIG = isApp ? process.env.PRIVATE_CONFIG : '';

export const RECORD_URL = process.env.RECORD_URL;

export const IMAGE_SIZE_LIMIT = 5 * 1024 * 1024;

/**
 * 上线需修改配置
 */

// prod发布
export const WEBSITE_URL = isApp ? process.env.WEBSITE_URL : '';

// test发布
// export const WEBSITE_URL =
//   'https://yiyong-qa.netease.im/yiyong-static/statics/ne-meeting-website/';
