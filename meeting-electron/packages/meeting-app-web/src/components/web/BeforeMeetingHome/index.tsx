import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';

import CloseOutlined from '@ant-design/icons/CloseOutlined';
import EditOutlined from '@ant-design/icons/EditOutlined';
import ExclamationCircleFilled from '@ant-design/icons/ExclamationCircleFilled';
import {
  Badge,
  Button,
  Dropdown,
  Input,
  MenuProps,
  notification,
  Spin,
  Tag,
  Progress,
} from 'antd';
import {
  AttendeeOffType,
  getLocalStorageSetting,
  Modal,
  NEAccountInfo,
  NELocalHistoryMeeting,
  NEMeetingItem,
  NEMenuVisibility,
  setLocalStorageSetting,
  Toast,
  CommonModal,
  NEMeetingLanguage,
  closeAllWindows,
} from 'nemeeting-web-sdk';

import dayjs from 'dayjs';
import { useTranslation } from 'react-i18next';
import MeetingPopover from '@meeting-module/components/common/Popover';

import EmptyScheduleMeetingImg from '../../../assets/empty-schedule-meeting.png';

import BeforeMeetingHomeHeader from '../../../assets/before-meeting-home-header.png';
import {
  copyElementValue,
  getMeetingDisplayId,
  getCurrentDateTime,
  formatTimeWithLanguage,
  parsePrivateConfig,
} from '@meeting-module/utils';
import AboutModal from '../BeforeMeetingModal/AboutModal';
import HistoryMeetingModal from '../BeforeMeetingModal/HistoryMeetingModal';
import ImmediateMeetingModal from '../BeforeMeetingModal/ImmediateMeetingModal';
import JoinMeetingModal from '../BeforeMeetingModal/JoinMeetingModal';
import ScheduleMeetingModal from '../BeforeMeetingModal/ScheduleMeetingModal';
import NotificationListModal from '../BeforeMeetingModal/NotificationListModal';
import ImageCropModal from '../BeforeMeetingModal/ImageCropModal';
import UpdateUserNicknameModal from '@meeting-module/components/web/UpdateUserNicknameModal';
import './index.less';
import Eventemitter from 'eventemitter3';
import {
  LOCALSTORAGE_INVITE_MEETING_URL,
  LOCALSTORAGE_USER_INFO,
  NOT_FIRST_LOGIN,
  PRIVATE_CONFIG,
  LOCALSTORAGE_LOCAL_RECORD_INFO,
  FREE_APP_KEY,
  FREE_DOMAIN_SERVER,
} from '../../../config';

import { NECustomSessionMessage, NECommonError } from 'neroom-types';
import qs from 'qs';
import { IPCEvent, ServerGuestErrorCode } from '../../../types';
import usePostMessageHandle from '@meeting-module/hooks/usePostMessagehandle';
import {
  CreateOptions,
  EventType,
  BeforeMeetingConfig,
  JoinOptions,
  MeetingRepeatType,
  MeetingSetting,
  NEMeetingIdDisplayOption,
} from '@meeting-module/types';
import {
  NEMeetingCode,
  NEMeetingInviteInfo,
  NEMeetingInviteStatus,
  NEMeetingPrivateConfig,
  NEMeetingStatus,
} from '@meeting-module/types/type';
import {
  closeWindow,
  getWindow,
  openWindow,
} from '@meeting-module/utils/windowsProxy';
import UserAvatar from '@meeting-module/components/common/Avatar';
import MeetingNotification from '@meeting-module/components/common/Notification';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';

import { SettingTabType } from '@meeting-module/components/web/Setting/Setting';

import NPSModal from '../../NPS/NPSModal';
import classNames from 'classnames';
import { NEJoinMeetingOptions } from '@meeting-module/kit/interface/service/meeting_service';
import {
  NEMeetingRecentSession,
  NEMeetingSessionMessage,
  NEMeetingSessionTypeEnum,
} from '@meeting-module/kit/interface/service/meeting_message_channel_service';
import UnSupportBrowserModal from '../BeforeMeetingModal/unSupportBrowser';
import InviteScheduleMeetingModal from '../BeforeMeetingModal/ScheduleMeeting/InviteScheduleMeetingModal';
import getMeetingKitInstance, { checkSystemRequirements } from './neMeetingKit';
import { useUpdateEffect } from 'ahooks';
import { getMeetingIdFromUrl } from '@/utils';

const MeetingKitInstance = getMeetingKitInstance();

const eventEmitter = new Eventemitter();
const pageSize = 20;

let appKey = '';
let userUuid = '';
let userToken = '';
const domain = process.env.MEETING_DOMAIN;

type MeetingListGroupByDate = {
  date: string;
  list: NEMeetingItem[];
}[];

interface BeforeMeetingHomeProps {
  onLogout: () => void;
}

const BeforeMeetingHome: React.FC<BeforeMeetingHomeProps> = ({ onLogout }) => {
  const { t, i18n: i18next } = useTranslation();

  const i18n = {
    appTitle: t('appTitle'),
    immediateMeeting: t('immediateMeeting'),
    sponsorMeeting: t('sponsorMeeting'),
    joinMeeting: t('meetingJoin'),
    scheduleMeeting: t('scheduleMeeting'),
    scheduleMeetingSuccess: t('scheduleMeetingSuccess'),
    scheduleMeetingFail: t('scheduleMeetingFail'),
    editScheduleMeetingSuccess: t('editScheduleMeetingSuccess'),
    editScheduleMeetingFail: t('editScheduleMeetingFail'),
    cancelScheduleMeetingSuccess: t('cancelScheduleMeetingSuccess'),
    tokenExpired: t('tokenExpired'),
    cancelScheduleMeetingFail: t('cancelScheduleMeetingFail'),
    updateUserNicknameSuccess: t('updateUserNicknameSuccess'),
    updateUserNicknameFail: t('updateUserNicknameFail'),
    emptyScheduleMeeting: t('emptyScheduleMeeting'),
    meetingId: t('meetingId'),
    weekdays: [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ],
    month: t('globalMonth'),
    historyMeeting: t('historyMeeting'),
    currentVersion: t('currentVersion'),
    personalMeetingNum: t('personalMeetingNum'),
    personalShortMeetingNum: t('personalShortMeetingNum'),
    internalUse: t('internalOnly'),
    feedback: t('feedback'),
    about: t('about'),
    logout: t('logout'),
    logoutConfirm: t('logoutConfirm'),
    today: t('today'),
    tomorrow: t('tomorrow'),
    join: t('join'),
    notStarted: t('notStarted'),
    inProgress: t('inProgress'),
    ended: t('ended'),
    copySuccess: t('copySuccess'),
    password: t('meetingPassword'),
    passwordPlaceholder: t('livePasswordTip'),
    passwordError: t('meetingWrongPassword'),
    hint: t('commonTitle'),
    gotIt: t('gotIt'),
    cancel: t('globalCancel'),
    confirm: t('globalSure'),
    networkError: t('networkAbnormalityAndCheck'),
    restoreMeetingTips: t('restoreMeetingTips'),
    restore: t('restore'),
    uploadLoadingText: t('uploadLoadingText'),
    youCanOpen: t('supportedMeetings'),
    settingServiceBundleExpirationDate: t('settingServiceBundleExpirationDate'),
    meetingRoomScreenCasting: t('meetingRoomScreenCasting'),
    copyMeetingIdTip: t('copyMeetingIdTip'),
    comingSoon: t('comingSoon'),
    localRecordRemuxTitle: t('localRecordRemuxTitle'),
    localRecordRemuxContent: t('localRecordRemuxContent'),
    localRecordRemuxOkText: t('localRecordRemuxOkText'),
    localRecordStopRemuxTitle: t('localRecordStopRemuxTitle'),
    localRecordStopRemuxContent: t('localRecordStopRemuxContent'),
  };

  const passwordRef = React.useRef<string>('');
  const [isInitialized, setIsInitialized] = useState(false);
  const [isLogin, setIsLogin] = useState(false);
  const [immediateMeetingModalOpen, setImmediateMeetingModalOpen] =
    useState(false);
  const [joinMeetingModalOpen, setJoinMeetingModalOpen] = useState(false);
  const [scheduleMeetingModalOpen, setScheduleMeetingModalOpen] =
    useState(false);
  const [inviteScheduleMeetingModalOpen, setInviteScheduleMeetingModalOpen] =
    useState(false);
  const [npsModalOpen, setNpsModalOpen] = useState(false);
  const [historyMeetingModalOpen, setHistoryMeetingModalOpen] = useState(false);
  const [notificationListModalOpen, setNotificationListModalOpen] =
    useState(false);
  const [updateUserNicknameModalOpen, setUpdateUserNicknameModalOpen] =
    useState(false);
  const [imageCropModalOpen, setImageCropModalOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);
  // 不支持当前浏览器的弹窗
  const [unSupportBrowserModalOpen, setUnSupportBrowserModalOpen] =
    useState(false);
  const [accountInfo, setAccountInfo] = useState<NEAccountInfo>();
  const accountInfoRef = React.useRef<NEAccountInfo>();
  const joinByGuestRef = useRef<boolean>(false);

  accountInfoRef.current = accountInfo;

  const [editMeeting, setEditMeeting] = useState<NEMeetingItem>();
  const [submitLoading, setSubmitLoading] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [inMeeting, setInMeeting] = useState(false);
  const [loginLoading, setLoginLoading] = useState(true);
  const [meetingList, setMeetingList] = useState<NEMeetingItem[]>([]);

  const meetingListRef = useRef(meetingList);

  meetingListRef.current = meetingList;

  const getMeetingListLoadingRef = useRef(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const currentOffsetRef = useRef(0);

  const inMeetingRef = useRef<boolean>(false);

  const isJoiningRef = useRef<boolean>(false);

  inMeetingRef.current = inMeeting;
  const settingOpen = false;

  const [localHistoryMeetingList, setLocalHistoryMeetingList] = useState<
    NELocalHistoryMeeting[]
  >([]);
  // 当前的预约会议详情，传递给InviteScheduleMeetingModal，展示会议邀请信息
  const [currentScheduleMeetingInfo, setCurrentScheduleMeetingInfo] =
    useState<NEMeetingItem>();
  const [isAvatarUpdateSupported, setIsAvatarUpdateSupported] = useState(false);
  const [isNicknameUpdateSupported, setIsNicknameUpdateSupported] =
    useState(false);

  const currentMeetingInfoRef = useRef({
    meetingId: 0,
    meetingNum: '',
    sipId: '',
    sessionId: '',
    time: 0,
  });

  const [setting, setSetting] = useState<MeetingSetting | null>(null);
  const settingRef = React.useRef<MeetingSetting | null>(null);

  settingRef.current = setting;

  const [meetingId, setMeetingId] = useState<string>('');
  const appName = '';
  const [tipInfo, setTipInfo] = useState<{
    content: string;
    title: string;
    url: string;
  }>();
  const [appLiveAvailable, setAppLiveAvailable] = useState<boolean>(false);
  const [showTipInfo, setShowTipInfo] = useState<boolean>(true);
  const [showExpireTip, setShowExpireTip] = useState<boolean>(true);
  const [isOffLine, setIsOffLine] = useState<boolean>(false);
  const isLoginRef = useRef<boolean>(false);

  isLoginRef.current = isLogin;
  const [historyMeetingId, setHistoryMeetingId] = useState<number>();
  const [globalConfig, setGlobalConfig] = useState<BeforeMeetingConfig>();
  const [invitationMeetingNum, setInvitationMeetingNum] = useState<string>('');
  const [notificationMessages, setNotificationMessages] = useState<
    NECustomSessionMessage[]
  >([]);
  const [showLoading, setShowLoading] = useState<boolean>(false);

  const electronInMeetingRef = useRef<boolean>(false);

  const [customMessage, setCustomMessage] =
    useState<NECustomSessionMessage | null>(null);

  const meetingService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getMeetingService();
    }
  }, [isInitialized]);

  const settingsService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getSettingsService();
    }
  }, [isInitialized]);

  const preMeetingService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getPreMeetingService();
    }
  }, [isInitialized]);

  const accountService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getAccountService();
    }
  }, [isInitialized]);

  const contactsService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getContactsService();
    }
  }, [isInitialized]);

  const meetingInviteService = useMemo(() => {
    if (isInitialized) {
      return MeetingKitInstance.getMeetingInviteService();
    }
  }, [isInitialized]);

  // 用于被邀请端打开会议详情时候，邀请端取消会议，被邀请端关闭会议详情
  const openMeetingDetailMeetingNumRef = useRef('');
  const { handlePostMessage } = usePostMessageHandle();
  const [privateConfig, setPrivateConfig] =
    useState<NEMeetingPrivateConfig | null>(null);

  const [notificationApi, contextHolder] = notification.useNotification({
    stack: false,
    bottom: 60,
    getContainer: () =>
      document.getElementById('before-meeting-home') || document.body,
  });

  const joinRoomByInvite = (meetingNum: string) => {
    setSubmitLoading(true);

    joinMeeting(
      {
        meetingNum: meetingNum,
      },
      true,
    ).finally(() => {
      setSubmitLoading(false);
    });
  };

  const onNotificationClickHandler = (
    action: string,
    message?: NECustomSessionMessage,
  ) => {
    if (!message) return;
    const data = message.data?.data;

    console.log('onNotificationClickHandler', data);
    const type = data?.type;

    if (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START') {
      setCustomMessage(null);
      // 拒绝加入
      if (action === 'reject') {
        meetingInviteService?.rejectInvite(data.meetingId);
        notificationApi?.destroy(data?.meetingId);
      } else if (action === 'join') {
        Modal.destroyAll();
        joinRoomByInvite(data.meetingNum);
        notificationApi.destroy();
      }
    }
  };

  const imageCropValueRef = useRef<string>('');

  useEffect(() => {
    if (!window.isElectronNative && !checkSystemRequirements()) {
      setUnSupportBrowserModalOpen(true);
    }
  }, []);

  useEffect(() => {
    if (!isLogin) {
      return;
    }

    const setting = getLocalStorageSetting();

    // 处理邀请链接入会
    if (window.isElectronNative) {
      const url = localStorage.getItem(LOCALSTORAGE_INVITE_MEETING_URL);

      if (url) {
        handleInvitationUrl(url);
        localStorage.removeItem(LOCALSTORAGE_INVITE_MEETING_URL);
      }
    } else {
      handleInvitationUrl(location.href);
    }

    // 根据设置初始化主进程中的视频镜像配置
    window.ipcRenderer?.send(
      IPCEvent.changeMirror,
      !!setting?.videoSetting?.enableVideoMirroring,
    );
    function handleUrl(e, url) {
      handleInvitationUrl(url);
    }

    window.ipcRenderer?.on(IPCEvent.electronJoinMeeting, handleUrl);
    window.ipcRenderer?.on(
      IPCEvent.beforeLogin,
      (e, beforeMeeting: boolean) => {
        electronInMeetingRef.current = !beforeMeeting;
      },
    );
    return () => {
      window.ipcRenderer?.removeListener(
        IPCEvent.electronJoinMeeting,
        handleUrl,
      );
      window.ipcRenderer?.removeAllListeners(IPCEvent.beforeLogin);
    };
  }, [isLogin]);

  useEffect(() => {
    const scrollElement = scrollRef.current;

    if (!scrollElement) {
      return;
    }

    function handleScroll() {
      if (
        scrollElement &&
        scrollElement.scrollTop + scrollElement.clientHeight >=
          scrollElement.scrollHeight
      ) {
        if (getMeetingListLoadingRef.current) {
          return;
        }

        getMeetingList?.({
          size: pageSize,
          offset: currentOffsetRef.current,
        });
      }
    }

    scrollElement.addEventListener('scroll', handleScroll);
    return () => {
      scrollElement.removeEventListener('scroll', handleScroll);
    };
  }, [preMeetingService]);

  function handleInvitationUrl(url: string) {
    let meetingNum = '';

    if (window.isElectronNative) {
      meetingNum = getMeetingIdFromUrl(url);
    } else {
      const query = qs.parse(url.split('?')[1]?.split('#/')[0]);

      meetingNum = query.meetingId as string;
      // 如果是处理一次后，删除url中的meetingId参数
      if (meetingNum) {
        delete query.meetingId;
        history.replaceState(
          {},
          '',
          qs.stringify(query, { addQueryPrefix: true }),
        );
      }
    }

    if (meetingNum && isLoginRef.current) {
      setInvitationMeetingNum(meetingNum);
      onOpenJoinMeeting(meetingNum);
      setImmediateMeetingModalOpen(false);
      setScheduleMeetingModalOpen(false);
      setUpdateUserNicknameModalOpen(false);
    }
  }

  function handleLogoutModal(): { destroy: () => void } {
    const modal = CommonModal.confirm({
      title: i18n.logout,
      content: i18n.logoutConfirm,
      focusTriggerAfterClose: false,
      transitionName: '',
      mask: false,
      width: 300,
      zIndex: 2000,
      footer: (
        <div className="nemeeting-modal-confirm-btns nemeeting-logout-modal-btns">
          <Button
            className="nemeeting-logout-modal-btns-cancel"
            onClick={() => modal.destroy()}
          >
            {i18n.cancel}
          </Button>
          <Button
            type="primary"
            className="nemeeting-logout-modal-btns-confirm"
            onClick={() => {
              modal.destroy();
              logout();
            }}
          >
            {i18n.confirm}
          </Button>
        </div>
      ),
    });

    return modal;
  }

  const onOpenFeedback = () => {
    setUserMenuOpen(false);
    MeetingKitInstance.getFeedbackService()?.showFeedbackView();
  };

  const items: MenuProps['items'] = [
    {
      key: '1',
      label: (
        <div className="user-menu-head-item">
          <UserAvatar
            nickname={accountInfo?.nickname}
            avatar={accountInfo?.avatar}
            size={48}
            className="user-avatar"
            isEdit={isAvatarUpdateSupported}
            onClick={() => {
              isAvatarUpdateSupported && openImageCrop();
            }}
          />
          <div className="user-name-wrap">
            <div className="user-name">
              <div
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
                className="user-name-content"
              >
                {accountInfo?.nickname}{' '}
              </div>
              {!isNicknameUpdateSupported ? null : (
                <EditOutlined
                  onClick={() => {
                    setUserMenuOpen(false);
                    setUpdateUserNicknameModalOpen(true);
                  }}
                />
              )}
            </div>
            <div className="sub-title">{appName}</div>
          </div>
        </div>
      ),
    },
    {
      key: '2',
      label: (
        <div className="nemeeting-open-meeting-info-wrap">
          {accountInfo?.serviceBundle && (
            <div className="nemeeting-open-meeting-info">
              <div className="you-can-open">
                <span>{i18n.youCanOpen}</span>
                {accountInfo.serviceBundle.expireTimeStamp !== -1 ? (
                  <span>
                    {i18n.settingServiceBundleExpirationDate}
                    {dayjs(accountInfo.serviceBundle.expireTimeStamp).format(
                      'YYYY-MM-DD',
                    )}
                  </span>
                ) : null}
              </div>
              <div className="meeting-limit-info">
                <div className="box"></div>
                <div className="info">
                  {accountInfo.serviceBundle.meetingMaxMinutes < 0 ||
                  !accountInfo.serviceBundle.meetingMaxMinutes
                    ? t('meetingNoLimit', {
                        maxCount: accountInfo.serviceBundle.meetingMaxMembers,
                      })
                    : t('meetingLimit', {
                        maxCount: accountInfo.serviceBundle.meetingMaxMembers,
                        maxMinutes: accountInfo.serviceBundle.meetingMaxMinutes,
                      })}
                </div>
              </div>
              {accountInfo.serviceBundle.expireTimeStamp !== -1 ? (
                <div className="expire-tip">
                  {accountInfo.serviceBundle.expireTip}
                </div>
              ) : null}
            </div>
          )}
        </div>
      ),
    },
    {
      key: '2.5',
      label: (
        <div className="user-menu-item normal-item user-menu-item-meeting-num">
          <div className="title">
            <div
              className="personal-meeting-num"
              style={{
                fontWeight: 'bold',
              }}
            >
              {i18n.personalShortMeetingNum}
            </div>
            {/* <Tag color="#EBF2FF" className="custom-tag">
              {i18n.internalUse}
            </Tag> */}
          </div>
          <div className="sub-title">
            <div className="short-meeting-num">
              {accountInfo?.shortMeetingNum}
            </div>
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.shortMeetingNum, () => {
                  Toast.success(i18n.copySuccess);
                });
              }}
              className="icon icon-blue iconfont iconfuzhi1"
              aria-hidden="true"
            >
              <use xlinkHref="#iconfuzhi1"></use>
            </svg>
          </div>
        </div>
      ),
      hidden: !accountInfo?.shortMeetingNum,
    },
    {
      key: '3',
      label: (
        <div className="user-menu-item normal-item user-menu-item-meeting-num">
          <div className="title">
            <div
              style={{
                fontWeight: 'bold',
              }}
              className="personal-meeting-num"
            >
              {i18n.personalMeetingNum}
            </div>
          </div>
          <div className="sub-title">
            <div className="short-meeting-num">
              {getMeetingDisplayId(accountInfo?.privateMeetingNum)}
            </div>
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.privateMeetingNum, () => {
                  Toast.success(i18n.copySuccess);
                });
              }}
              className="icon icon-blue iconfont iconfuzhi1"
              aria-hidden="true"
            >
              <use xlinkHref="#iconfuzhi1"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '4',
      label: (
        <div
          className="user-menu-item normal-item feedback"
          style={{ cursor: 'pointer' }}
          onClick={() => {
            onOpenFeedback();
          }}
        >
          <div
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {i18n.feedback}
          </div>
          <div className="sub-title">
            <svg
              style={{
                fontSize: '24px',
                position: 'relative',
                left: '5px',
              }}
              className="icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '5',
      label: (
        <div
          className="user-menu-item normal-item about"
          style={{ cursor: 'pointer' }}
          onClick={() => {
            setUserMenuOpen(false);
            if (window.isElectronNative) {
              openBeforeMeetingWindow({ name: 'aboutWindow' });
            } else {
              setAboutModalOpen(true);
            }
          }}
        >
          <div
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {i18n.about}
          </div>
          <div className="sub-title">
            <svg
              style={{
                fontSize: '24px',
                position: 'relative',
                left: '5px',
              }}
              className="icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '6',
      label: (
        <div
          className="user-menu-item logout"
          onClick={() => {
            setUserMenuOpen(false);
            handleLogoutModal();
          }}
          style={{ cursor: 'pointer' }}
        >
          <div className="logout-button">{i18n.logout}</div>
        </div>
      ),
    },
  ].filter((item) => !item.hidden);

  const logout = useCallback(async () => {
    onLogout();
    setIsLogin(false);
    await accountService?.logout();

    await MeetingKitInstance.unInitialize();
    closeAllWindows();

    window.location.reload();
  }, [onLogout, accountService]);

  function setNPS(meetingId?: string) {
    console.log('setNps>>>>', meetingId);
    const npsString = localStorage.getItem('ne-meeting-nps');

    if (npsString) {
      const nps = JSON.parse(npsString);

      nps.meetingId = meetingId || currentMeetingInfoRef.current.meetingId;
      nps.need = true;
      localStorage.setItem('ne-meeting-nps', JSON.stringify(nps));
    } else {
      localStorage.setItem(
        'ne-meeting-nps',
        JSON.stringify({
          meetingId: meetingId || currentMeetingInfoRef.current.meetingId,
          need: true,
        }),
      );
    }
  }

  async function init(crossAppKey?: string) {
    if (MeetingKitInstance.isInitialized) {
      setIsInitialized(true);
      return;
    }

    const _appKey = crossAppKey || appKey;

    let domainUrl = domain;

    if (_appKey === FREE_APP_KEY) {
      domainUrl = FREE_DOMAIN_SERVER;
    }

    let config = {
      appKey: crossAppKey || appKey, //云信服务appkey
      meetingServerDomain: domainUrl, //会议服务器地址，支持私有化部署
      locale: i18next.language, //语言
    };
    // 判断是否有私有化配置文件
    let privateConfig: NEMeetingPrivateConfig | null = null;

    if (window.isElectronNative) {
      try {
        privateConfig = await window.ipcRenderer?.invoke(
          IPCEvent.getPrivateConfig,
        );
        privateConfig = parsePrivateConfig(
          privateConfig as NEMeetingPrivateConfig,
        );
      } catch (error) {
        console.log('getPrivateConfig error', error);
      }
    } else {
      privateConfig = PRIVATE_CONFIG as unknown as NEMeetingPrivateConfig;
      console.log('privateConfig>>>', privateConfig);
    }

    if (privateConfig) {
      setPrivateConfig(privateConfig as NEMeetingPrivateConfig);
      privateConfig.appKey && (config.appKey = privateConfig.appKey);
      privateConfig.meetingServerDomain &&
        (config.meetingServerDomain = privateConfig.meetingServerDomain);
      config = { ...config, ...privateConfig };
    }

    //白板防盗链
    const whiteboardAppConfig = {
      nosAntiLeech: true,
      nosAntiLeechExpire: 7200,
    };

    return MeetingKitInstance.initialize({
      appKey: config.appKey,
      serverUrl: config.meetingServerDomain,
      width: 0,
      height: 0,
      whiteboardAppConfig,
    }).then(() => {
      setIsInitialized(true);

      // 启动Marvel
      MeetingKitInstance.startMarvel();
    });
  }

  function createMeeting(createOptions: Partial<CreateOptions>) {
    // 不支持的浏览器直接return
    if (!window.isElectronNative && !checkSystemRequirements()) {
      setUnSupportBrowserModalOpen(true);
      return;
    }

    const options = {
      meetingNum: '',
      nickName: accountInfoRef.current?.nickname || '',
      avatar: accountInfoRef.current?.avatar,
      showMeetingRemainingTip: true,
      ...createOptions,
    };

    !window.isElectronNative && setSubmitLoading(true);

    setImmediateMeetingModalOpen(false);
    setJoinMeetingModalOpen(false);
    setScheduleMeetingModalOpen(false);

    const storeNicknameStr = localStorage.getItem(
      'ne-meeting-nickname-' + accountInfo?.account,
    );

    if (storeNicknameStr) {
      const storeNickname = JSON.parse(storeNicknameStr);

      if (storeNickname[options.meetingNum]) {
        options.nickName = storeNickname[options.meetingNum];
      } else {
        localStorage.removeItem('ne-meeting-nickname-' + accountInfo?.account);
      }
    }

    const { param, opts } = joinOptionsToMeetingJoinOptions(options);

    meetingService
      ?.startMeeting(param, opts)
      .then(async () => {
        try {
          const { data: currentMeetingInfo } =
            await meetingService.getCurrentMeetingInfo();

          currentMeetingInfoRef.current = {
            ...currentMeetingInfoRef.current,
            meetingId: currentMeetingInfo?.meetingId || 0,
            meetingNum: currentMeetingInfo?.meetingNum || '',
            sipId: currentMeetingInfo?.sipId || '',
            time: Date.now(),
          };

          localStorage.setItem(
            'ne-meeting-current-info',
            JSON.stringify(currentMeetingInfoRef.current),
          );
          window.ipcRenderer?.send('flushStorageData');
        } catch (error) {
          console.log('getCurrentMeetingInfo error', error);
        }

        window.ipcRenderer?.send(IPCEvent.enterRoom);
        setNPS();
        setInMeeting(true);
      })
      .catch((error) => {
        const errorMsg = error.message || error.msg || t('networkError');

        if (error.code === 3100) {
          Modal.confirm({
            title: t('meetingExist'),
            content: t('joinTheExistMeeting'),
            onOk: () => {
              joinMeeting(createOptions);
            },
          });
        } else {
          Toast.fail(errorMsg);

          if (window.isElectronNative) {
            const immediateMeetingWindow = getWindow('immediateMeetingWindow');

            immediateMeetingWindow?.postMessage(
              {
                event: 'createMeetingFail',
                payload: {
                  code: error.code,
                  errorMsg,
                },
              },
              immediateMeetingWindow.origin,
            );
          }
        }
      })
      .finally(() => {
        closeWindow('immediateMeetingWindow');
        setSubmitLoading(false);
      });
  }

  // 取消预约会议
  function cancelScheduleMeeting(
    meetingId: number,
    cancelRecurringMeeting: boolean = false,
  ) {
    setScheduleMeetingModalOpen(false);
    if (window.isElectronNative) {
      closeWindow('scheduleMeetingWindow');
    }

    setEditMeeting(undefined);

    preMeetingService
      ?.cancelMeeting(meetingId, cancelRecurringMeeting)
      .then(() => {
        Toast.success(i18n.cancelScheduleMeetingSuccess);
        getMeetingList({
          size: currentOffsetRef.current,
          offset: 0,
        });
      })
      .catch((error) => {
        Toast.fail(
          error.msg ||
            (navigator.onLine
              ? i18n.cancelScheduleMeetingFail
              : i18n.networkError),
        );
      });
  }

  async function createOrEditScheduleMeeting(value) {
    const {
      subject,
      startTime,
      endTime,
      password,
      audioOff,
      openLive,
      meetingId,
      liveOnlyEmployees,
      attendeeAudioOffType,
      enableWaitingRoom,
      enableJoinBeforeHost,
      recurringRule,
      scheduledMembers,
      enableGuestJoin,
      interpretation,
      timezoneId,
      cloudRecordConfig,
      livePrivateConfig,
      liveChatRoomEnable,
    } = value;

    setImmediateMeetingModalOpen(false);
    setJoinMeetingModalOpen(false);

    if (!preMeetingService) {
      return;
    }

    const { data: meetingItem } =
      await preMeetingService.createScheduleMeetingItem();

    if (audioOff) {
      meetingItem.settings.controls = [
        {
          type: 'audio',
          attendeeOff:
            attendeeAudioOffType === AttendeeOffType.offAllowSelfOn ? 1 : 2,
        },
      ];
    }

    if (interpretation) {
      meetingItem.interpretationSettings = {
        interpreterList: [],
      };
      if (interpretation.interpreters) {
        Object.keys(interpretation.interpreters).forEach((key) => {
          const item = {
            userId: key,
            firstLang: interpretation.interpreters[key][0],
            secondLang: interpretation.interpreters[key][1],
            isValid: true,
          };

          meetingItem.interpretationSettings?.interpreterList.push(item);
        });
      }
    }

    meetingItem.meetingId = meetingId;
    meetingItem.subject = subject;
    meetingItem.startTime = startTime;
    meetingItem.endTime = endTime;
    meetingItem.password = password;
    meetingItem.live.enable = openLive;
    meetingItem.live.liveWebAccessControlLevel = liveOnlyEmployees ? 2 : 0;
    meetingItem.waitingRoomEnabled = enableWaitingRoom;
    meetingItem.enableJoinBeforeHost = enableJoinBeforeHost;
    meetingItem.recurringRule = recurringRule;
    meetingItem.scheduledMemberList = scheduledMembers;
    meetingItem.enableGuestJoin = enableGuestJoin;
    meetingItem.timezoneId = timezoneId;
    meetingItem.cloudRecordConfig = cloudRecordConfig;
    if (openLive) {
      meetingItem.live.title = livePrivateConfig?.title ?? subject;
      if (livePrivateConfig) {
        meetingItem.live.liveBackground = livePrivateConfig.background;
        meetingItem.live.livePushThirdParties =
          livePrivateConfig.pushThirdParties;
        meetingItem.live.livePassword = livePrivateConfig.password;
        meetingItem.live.liveChatRoomEnable = liveChatRoomEnable;
        meetingItem.live.enableThirdParties =
          livePrivateConfig.enableThirdParties;
      }
    }

    const promise = meetingId
      ? preMeetingService.editMeeting(meetingItem, !!meetingItem.recurringRule)
      : preMeetingService.scheduleMeeting(meetingItem);

    promise
      .then((res) => {
        setScheduleMeetingModalOpen(false);
        setSubmitLoading(false);

        getMeetingList({
          size: currentOffsetRef.current,
          offset: 0,
        });
        if (meetingId) {
          Toast.success(i18n.editScheduleMeetingSuccess);
        } else {
          Toast.success(i18n.scheduleMeetingSuccess);
          setCurrentScheduleMeetingInfo(res.data);
          setInviteScheduleMeetingModalOpen(true);
        }

        if (window.isElectronNative) {
          closeWindow('scheduleMeetingWindow');
        }
      })
      .catch((error) => {
        console.log('createOrEditScheduleMeeting error', error);

        const errorMsg =
          error.msg ||
          (navigator.onLine ? i18n.scheduleMeetingFail : i18n.networkError);

        // 会议已不存在则关闭弹窗
        if (window.isElectronNative) {
          if (error.code === 3104) {
            Toast.fail(t('meetingNotExist'));
            closeWindow('scheduleMeetingWindow');
          }

          const scheduleMeetingWindow = getWindow('scheduleMeetingWindow');

          scheduleMeetingWindow?.postMessage(
            {
              event: 'createOrEditScheduleMeetingFail',
              payload: {
                errorMsg,
              },
            },
            scheduleMeetingWindow.origin,
          );
        } else {
          if (error.code === 3104) {
            setScheduleMeetingModalOpen(false);
            Toast.fail(t('meetingNotExist'));
          } else {
            Toast.fail(errorMsg);
          }

          setSubmitLoading(false);
        }
      });
  }

  function joinOptionsToMeetingJoinOptions(options: JoinOptions) {
    const param = {
      displayName: options.nickName,
      meetingNum: options.meetingNum,
      password: options.password,
      avatar: options.avatar,
      watermarkConfig: {
        name: accountInfoRef.current?.nickname || '',
        phone: accountInfoRef.current?.phoneNumber || '',
        email: accountInfoRef.current?.email || '',
      },
    };
    const joinOptions: NEJoinMeetingOptions = {
      ...options,
      noAudio: options.audio !== 1,
      noVideo: options.video !== 1,
      noSip: false,
      noChat: options.noChat,
      noWhiteBoard: options.noWhiteboard,
      meetingIdDisplayOption: NEMeetingIdDisplayOption.DISPLAY_ALL,
      showCloudRecordingUI: true,
      showLocalRecordingUI: true,
      fullMoreMenuItems: options.moreBarList?.map((item) => {
        const menuItem = {
          itemId: item.id,
          visibility: item.visibility ?? NEMenuVisibility.VISIBLE_ALWAYS,
        };

        if (!item.btnConfig) {
          return menuItem;
        } else {
          if (Array.isArray(item.btnConfig)) {
            const checkedItem = item.btnConfig.find(
              (item) => item.status === true,
            );
            const uncheckItem = item.btnConfig.find(
              (item) => item.status === false,
            );

            if (checkedItem && uncheckItem && item.btnStatus !== undefined) {
              return {
                ...menuItem,
                checkedStateItem: {
                  icon: checkedItem.icon,
                  text: checkedItem.text,
                },
                uncheckStateItem: {
                  icon: uncheckItem.icon,
                  text: uncheckItem.text,
                },
                checked: item.btnStatus,
              };
            } else {
              return menuItem;
            }
          } else {
            return {
              ...menuItem,
              singleStateItem: {
                icon: item.btnConfig.icon,
                text: item.btnConfig.text,
              },
            };
          }
        }
      }),
    };

    return {
      param,
      opts: joinOptions,
    };
  }

  async function checkJoinByGuest(joinOptions: Partial<JoinOptions>) {
    let result = false;

    if (!joinOptions.meetingNum) {
      return result;
    }

    let info: NEMeetingItem | undefined = undefined;

    try {
      const res = await preMeetingService?.getMeetingItemByNum(
        joinOptions.meetingNum,
      );

      info = res?.data;
    } catch (error: unknown) {
      const e = error as NECommonError;

      if (e.code === ServerGuestErrorCode.MEETING_GUEST_JOIN_DISABLED) {
        if (window.isElectronNative) {
          const joinMeetingWindow = getWindow('joinMeetingWindow');

          joinMeetingWindow?.postMessage(
            {
              event: 'joinMeetingFail',
              payload: {
                code: ServerGuestErrorCode.MEETING_GUEST_JOIN_DISABLED,
                errorMsg: '',
              },
            },
            joinMeetingWindow.origin,
          );
          return true;
        } else {
          CommonModal.warning({
            width: 400,
            content: (
              <div className="nemeeting-cross-app-permission">
                {t('meetingCrossAppNoPermission')}
              </div>
            ),
            okText: t('IkonwIt'),
          });
        }

        return true;
      } else if (e.code === 'ERR_NETWORK') {
        throw e;
      } else {
        return false;
      }
    }

    if (!info) {
      return result;
    }

    const {
      meetingAppKey,
      meetingUserToken,
      meetingUserUuid,
      meetingAuthType,
      guestJoinType,
    } = info;

    if (
      meetingAppKey &&
      meetingUserToken &&
      meetingUserUuid &&
      meetingAuthType &&
      guestJoinType
    ) {
      result = true;

      if (window.isElectronNative) {
        const joinMeetingWindow = getWindow('joinMeetingWindow');

        joinMeetingWindow?.postMessage(
          {
            event: 'joinMeetingFail',
            payload: {
              code: ServerGuestErrorCode.MEETING_GUEST_JOIN_DISABLED,
              errorMsg: '',
            },
          },
          joinMeetingWindow.origin,
        );
        return result;
      }

      // 不允许访客入会
      if (guestJoinType == '0') {
        CommonModal.warning({
          width: 400,
          content: (
            <div className="nemeeting-cross-app-permission">
              {t('meetingCrossAppNoPermission')}
            </div>
          ),
          okText: t('IkonwIt'),
        });
      } else {
        CommonModal.confirm({
          width: 400,
          content: (
            <div className="nemeeting-cross-app-permission">
              {t('meetingCrossAppJoinTip')}
            </div>
          ),
          okText: t('meetingJoin'),
          cancelText: t('globalCancel'),
          onOk: async () => {
            try {
              await accountService?.logout();
              await MeetingKitInstance.unInitialize();
              setIsInitialized(false);
              await init(meetingAppKey);
              await MeetingKitInstance.getAccountService()?.loginByDynamicToken(
                meetingUserUuid,
                meetingUserToken,
                meetingAuthType,
              );
              await joinMeeting(joinOptions, false, 'guestJoin');
            } catch (error: unknown) {
              const e = error as NECommonError;

              Toast.fail(e?.message || e?.msg || 'Failure');
            }
          },
        });
      }
    }

    return result;
  }

  async function joinMeeting(
    joinOptions: Partial<JoinOptions>,
    joinByInvite?: boolean,
    type?: 'join' | 'guestJoin',
  ) {
    const isGuest =
      type !== 'guestJoin' &&
      (await checkJoinByGuest(joinOptions).catch((e) => {
        const joinMeetingWindow = getWindow('joinMeetingWindow');

        if (window.isElectronNative && joinMeetingWindow) {
          const errorMsg = e.message || e.msg || e.code;

          joinMeetingWindow?.postMessage(
            {
              event: 'joinMeetingFail',
              payload: {
                code: e.code,
                errorMsg,
              },
            },
            joinMeetingWindow.origin,
          );
          // 需要把窗口重新重置到前面
          if (!joinByInvite) {
            onOpenJoinMeeting();
          }
        }

        throw e;
      }));

    if (isGuest) {
      setSubmitLoading(false);
      return;
    }

    // 不支持的浏览器直接return
    if (!window.isElectronNative && !checkSystemRequirements()) {
      setUnSupportBrowserModalOpen(true);
      return;
    }

    const audio = await MeetingKitInstance.getSettingsService()
      ?.isTurnOnMyAudioWhenJoinMeetingEnabled()
      .catch(() => {
        // 忽略错误
      });
    const video = await MeetingKitInstance.getSettingsService()
      ?.isTurnOnMyVideoWhenJoinMeetingEnabled()
      .catch(() => {
        // 忽略错误
      });
    const options = {
      meetingNum: '',
      nickName: accountInfoRef.current?.nickname || '',
      video: video?.data ? 1 : 2,
      audio: audio?.data ? 1 : 2,
      avatar: accountInfoRef.current?.avatar,
      showMeetingRemainingTip: true,
      ...joinOptions,
    };

    !window.isElectronNative && setSubmitLoading(true);
    setImmediateMeetingModalOpen(false);
    setScheduleMeetingModalOpen(false);
    setNotificationListModalOpen(false);

    const currentMeetingInfoRes = await meetingService?.getCurrentMeetingInfo();

    console.log('currentMeetingInfoRes', currentMeetingInfoRes);

    const sessionIdRes = await settingsService?.getAppNotifySessionId();

    currentMeetingInfoRef.current = {
      meetingId: currentMeetingInfoRes?.data?.meetingId || 0,
      meetingNum: currentMeetingInfoRes?.data?.meetingNum || '',
      sipId: currentMeetingInfoRes?.data?.sipId || '',
      sessionId: sessionIdRes?.data || '',
      time: Date.now(),
    };
    const storeNicknameStr = localStorage.getItem(
      'ne-meeting-nickname-' + accountInfo?.account,
    );

    if (storeNicknameStr) {
      const storeNickname = JSON.parse(storeNicknameStr);

      if (storeNickname[options.meetingNum]) {
        options.nickName = storeNickname[options.meetingNum];
      } else {
        localStorage.removeItem('ne-meeting-nickname-' + accountInfo?.account);
      }
    }

    function fetchJoin(options: JoinOptions): Promise<void> {
      return new Promise((resolve, reject) => {
        const { param, opts } = joinOptionsToMeetingJoinOptions(options);

        console.warn('joinOptions', param, opts);
        if (joinByInvite) {
          meetingInviteService
            ?.acceptInvite(param, opts)
            .then(() => {
              resolve();
            })
            .catch((e) => {
              reject(e);
            });
        } else {
          meetingService
            ?.joinMeeting(param, opts)
            .then(() => {
              resolve();
            })
            .catch((e) => {
              reject(e);
            });
        }
      });
    }

    let modal;

    return fetchJoin(options)
      .then(() => {
        console.warn('fetchJoin meeting callback');
        setJoinMeetingModalOpen(false);
        window.ipcRenderer?.send(IPCEvent.enterRoom);
        setNPS();
        setInMeeting(true);
        joinByGuestRef.current = type === 'guestJoin';

        meetingService?.getCurrentMeetingInfo().then((res) => {
          if (res.code === 0) {
            currentMeetingInfoRef.current = {
              ...currentMeetingInfoRef.current,
              meetingId: res.data.meetingId,
              meetingNum: res.data.meetingNum,
              sipId: res.data.sipId ?? '',
            };
            localStorage.setItem(
              'ne-meeting-current-info',
              JSON.stringify(currentMeetingInfoRef.current),
            );
            window.ipcRenderer?.send('flushStorageData');
          }
        });
      })
      .catch((e) => {
        console.log('fetchJoin meeting error', e);

        // 会议详情点击加入会议， 会议已经结束
        if (e.code === 3102) {
          closeWindow('scheduleMeetingWindow');
        }

        const joinMeetingWindow = getWindow('joinMeetingWindow');

        if (window.isElectronNative && joinMeetingWindow) {
          const errorMsg = e.message || e.msg || e.code;

          joinMeetingWindow?.postMessage(
            {
              event: 'joinMeetingFail',
              payload: {
                code: e.code,
                errorMsg,
              },
            },
            joinMeetingWindow.origin,
          );
          // 需要把窗口重新重置到前面
          if (!joinByInvite) {
            onOpenJoinMeeting();
          }
        } else {
          const InputComponent = (inputValue) => {
            return (
              <Input
                placeholder={i18n.passwordPlaceholder}
                value={inputValue}
                maxLength={6}
                allowClear
                onChange={(event) => {
                  passwordRef.current = event.target.value.replace(
                    /[^0-9]/g,
                    '',
                  );
                  modal.update({
                    content: <>{InputComponent(passwordRef.current)}</>,
                    okButtonProps: {
                      disabled: !passwordRef.current,
                      style: !passwordRef.current
                        ? { color: 'rgba(22, 119, 255, 0.5)' }
                        : {},
                    },
                  });
                }}
              />
            );
          };

          if (e.code === 1020) {
            passwordRef.current = '';
            modal = Modal.confirm({
              title: i18n.password,
              width: 375,
              content: <>{InputComponent('')}</>,
              okButtonProps: {
                disabled: true,
                style: { color: 'rgba(22, 119, 255, 0.5)' },
              },
              onOk: async () => {
                try {
                  await fetchJoin({
                    ...options,
                    password: passwordRef.current,
                  });
                  setJoinMeetingModalOpen(false);
                  window.ipcRenderer?.send(IPCEvent.enterRoom);
                  setNPS();
                  setInMeeting(true);
                } catch (error: unknown) {
                  const e = error as NECommonError;

                  if (e.code === 1020) {
                    modal.update({
                      content: (
                        <>
                          {InputComponent(passwordRef.current)}
                          <div
                            style={{
                              color: '#fe3b30',
                              textAlign: 'left',
                              margin: '5px 0px -10px 0px',
                            }}
                          >
                            {i18n.passwordError}
                          </div>
                        </>
                      ),
                    });
                  }

                  throw e;
                }
              },
            });
          } else if (e?.code === 1019) {
            Toast.info(t('meetingLocked'));
            throw e;
          } else if (e?.code === 1004) {
            Toast.fail(t('meetingNotExist'));
            throw e;
          } else {
            setInMeeting(false);
            Toast.fail(e.msg || e.message || t('meetingJoinFail'));
            throw e;
          }
        }
      })
      .finally(() => {
        setSubmitLoading(false);
      });
  }

  function getMeetingListGroupByDate(list: NEMeetingItem[]) {
    const groupedData = list.reduce(
      (acc: Record<string, NEMeetingItem[]>, obj) => {
        const key = dayjs(obj.startTime).startOf('day').valueOf();

        if (!acc[key]) {
          acc[key] = [];
        }

        acc[key].push(obj);
        return acc;
      },
      {},
    );
    const meetingListGroupByDate: MeetingListGroupByDate = [];

    Object.keys(groupedData).forEach((key) => {
      meetingListGroupByDate.push({
        date: key,
        list: groupedData[key],
      });
    });
    return meetingListGroupByDate;
  }

  // 会议列表根据日期归类排序
  const meetingListGroupByDate = useMemo(() => {
    return getMeetingListGroupByDate(meetingList);
  }, [meetingList]);

  async function getMeetingList(options?: { size: number; offset: number }) {
    if (!preMeetingService || getMeetingListLoadingRef.current) {
      return;
    }

    // size需要判断不能小于20，否则第一次进入界面只有一个会议的话，后续无法获取
    if (options) {
      options.size = Math.max(options.size, pageSize);
    }

    getMeetingListLoadingRef.current = true;
    await preMeetingService
      ?.getMeetingList([1, 2, 3], options?.offset || 0, options?.size || 20)
      .then((data) => {
        // 从0 开始，重置meetingList, 否则进行添加
        if (!options?.offset) {
          setMeetingList(data.data);
          currentOffsetRef.current = data.data.length || 0;
        } else {
          const list = [...meetingListRef.current, ...data.data];

          currentOffsetRef.current = list.length;
          setMeetingList(list);
        }
      })
      .catch((error: unknown) => {
        const e = error as NECommonError;

        Toast.fail(e.message || e.msg || 'failed');

        // 用户被注销或者删除
        if (e.code === 404 || e.code === 401) {
          Toast.warning(i18n.tokenExpired);
          setTimeout(() => {
            logout();
          }, 1000);
        }
      })
      .finally(() => {
        getMeetingListLoadingRef.current = false;
      });
  }

  function formatScheduleMeetingDateTitle(time: number) {
    const weekdays = i18n.weekdays;
    const weekday =
      dayjs(time) < dayjs().endOf('day')
        ? i18n.today
        : dayjs(time) < dayjs().add(1, 'day').endOf('day')
        ? i18n.tomorrow
        : weekdays[dayjs(time).day()];

    const date = formatTimeWithLanguage(time, i18next.language);

    return (
      <div className="schedule-meeting-group-date">
        <div className="schedule-meeting-group-date-line">
          <span className="weekday">{weekday}</span>
          <span className="date">{date}</span>
        </div>
      </div>
    );
  }

  function onSettingChange(setting: MeetingSetting) {
    setSetting(setting);
    setLocalStorageSetting(JSON.stringify(setting));
  }

  //打开当前下载路径
  function openFile() {
    //获取localStorage的临时代码
    console.log('打开当前下载路径');
    let localRecordDefaultPath = ''; //setting.recordSetting.localRecordDefaultPath
    const str =
      window.localStorage.getItem(LOCALSTORAGE_LOCAL_RECORD_INFO) || '{}';
    const list = JSON.parse(str);

    console.log('accountInfoRef.current: ', accountInfoRef.current);
    console.log(
      'currentMeetingInfoRef.current: ',
      currentMeetingInfoRef.current,
    );
    list[accountInfoRef.current.userUuid]
      ? list[accountInfoRef.current.userUuid].forEach((item) => {
          if (item.meetingId == currentMeetingInfoRef.current.meetingId) {
            localRecordDefaultPath = item.localRecordDefaultPath;
          }
        })
      : null;
    console.log(
      'getLocalRecordPath() localRecordDefaultPath: ',
      localRecordDefaultPath,
    );
    window.ipcRenderer?.send('nemeeting-open-file', {
      isDir: true,
      filePath: localRecordDefaultPath,
    });

    window.ipcRenderer?.removeAllListeners('nemeeting-open-file-reply');
    window.ipcRenderer?.once('nemeeting-open-file-reply', (_, exist) => {
      if (!exist) {
        Toast.info(t('fileNotExist'));
        Modal.warning({
          title: t('fileNotExist'),
          content: t('localRecordOpenFileContent'),
          zIndex: 20000,
        });
      }
    });
  }

  function localRecordStopRemux() {
    if (localReocrdState == 6 || localReocrdState == 7) {
      Toast.info(t('localRecordStopRemuxCompleted'));
      //return
    }

    Modal.confirm({
      title: i18n.localRecordStopRemuxTitle,
      content: i18n.localRecordStopRemuxContent,
      cancelText: i18n.cancel,
      okText: i18n.confirm,
      closable: true,
      zIndex: 20000,
      onOk: () => {
        console.log('localRecordStopRemux');
        recordTimerRef.current && clearInterval(recordTimerRef.current);
        setLocalReocrdState(-1);
        setMeetingEndFlag(false);
        setProgress(0);
        try {
          console.log('stopLocalRecorderRemux() 停止转码');
          preMeetingService?.stopLocalRecorderRemux();
        } catch (e) {
          console.log('stopLocalRecorderRemux() error: ', e);
        }
      },
    });
  }

  const [localReocrdState, setLocalReocrdState] = useState<number>(-1);
  const [meetingEndFlag, setMeetingEndFlag] = useState<boolean>(false);
  const [progress, setProgress] = useState<number>(0);

  useEffect(() => {
    if (localReocrdState !== -1 && meetingEndFlag) {
      getProgress();
    }
  }, [meetingEndFlag, localReocrdState]);
  const recordTimerRef = useRef<number | NodeJS.Timeout | null>(null);

  function getProgress() {
    let interval = 10;
    let times = 0;

    console.log('getProgress');
    recordTimerRef.current && clearInterval(recordTimerRef.current);
    recordTimerRef.current = setInterval(() => {
      setProgress((prevProgress) => {
        console.log('prevProgress: ', prevProgress);
        console.log('times: ', times);
        //进度条展示，最少持续1秒
        if (times == 8) {
          console.log('localReocrdState: ', localReocrdState);
          //判断此时转码的状态（后面改成枚举）
          if (localReocrdState == 6 || localReocrdState == 7) {
            //此时转码完成了，不用处理
          } else {
            //学习拼多多
            interval = interval / 5;
            console.log('需要缩小 interval: ', interval);
            // time重新计数
            times = 0;
          }
        }

        if (prevProgress >= 100) {
          recordTimerRef.current && clearInterval(recordTimerRef.current);
          console.log(
            '虚假的进度条完成了，此时需要打开录制文件，并且关闭转换的进度条',
          );
          openFile();
          setLocalReocrdState(-1);
          setMeetingEndFlag(false);
          setProgress(0);
          return 100;
        }

        const newProgress = prevProgress + interval; // 每次增加interval

        console.log('newProgress: ', newProgress);
        times++;
        return newProgress > 100 ? 100 : newProgress;
      });
    }, 100); // 每100毫秒更新一次
  }

  function updateLocalStorageUserInfo(userInfo) {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);

    if (userString) {
      const user = JSON.parse(userString);

      localStorage.setItem(
        LOCALSTORAGE_USER_INFO,
        JSON.stringify({
          ...user,
          ...userInfo,
        }),
      );
    }
  }

  useEffect(() => {
    preMeetingService?.addListener({
      onLocalRecorderStatus: (state) => {
        console.log('会前主页面收到录制状态通知: ', state);
        setLocalReocrdState(state);
      },
      onLocalRecorderError: (error) => {
        console.log('会前主页面收到录制错误通知: ', error);
        Toast.info('local Record error: ' + error);
      },
    });
  }, [preMeetingService]);

  useEffect(() => {
    if (inMeeting) return;
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);

    if (userString) {
      const user = JSON.parse(userString);

      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId;
        init();
      } else {
        logout();
      }
    } else {
      logout();
    }

    const setting = getLocalStorageSetting();

    if (setting) {
      setSetting(setting);
    }
  }, [inMeeting]);

  // 会议状态监听
  useEffect(() => {
    meetingService?.setOnInjectedMenuItemClickListener({
      onInjectedMenuItemClick: (item) => {
        if (item.itemId === 1000) {
          setMeetingId(String(currentMeetingInfoRef.current.meetingId));
          onOpenFeedback();
        }
      },
    });

    meetingService?.addMeetingStatusListener({
      onMeetingStatusChanged: ({ status, arg }) => {
        if (status === NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM) {
          // 到等候室
          console.log('MEETING_STATUS_IN_WAITING_ROOM', arg);
        } else if (
          status === NEMeetingStatus.MEETING_STATUS_FAILED ||
          status === NEMeetingStatus.MEETING_STATUS_IDLE
        ) {
          setInMeeting(false);
          // 修复断网重连加入已结束的会议，无法回到首页问题
          if (window.isElectronNative) {
            window.ipcRenderer?.send(IPCEvent.beforeEnterRoom);
          }

          currentMeetingInfoRef.current = {
            meetingId: 0,
            meetingNum: '',
            sipId: '',
            sessionId: currentMeetingInfoRef.current.sessionId,
            time: 0,
          };
          localStorage.setItem(
            'ne-meeting-current-info',
            JSON.stringify(currentMeetingInfoRef.current),
          );
          window.ipcRenderer?.send('flushStorageData');
        } else if (status === NEMeetingStatus.MEETING_STATUS_DISCONNECTING) {
          console.log('MEETING_STATUS_DISCONNECTING', arg);
          setMeetingEndFlag(true);
          const reasonMap = {
            [NEMeetingCode.MEETING_DISCONNECTING_CLOSED_BY_HOST]:
              t('meetingEnded'),
            [NEMeetingCode.MEETING_DISCONNECTING_END_OF_LIFE]: t('END_OF_LIFE'),
            [NEMeetingCode.MEETING_DISCONNECTING_REMOVED_BY_HOST]:
              t('KICK_OUT'),
            [NEMeetingCode.MEETING_DISCONNECTING_SYNC_DATA_ERROR]:
              t('SYNC_DATA_ERROR'),
            [NEMeetingCode.MEETING_DISCONNECTING_JOIN_TIMEOUT]: 'JOIN_TIMEOUT',
          };

          if (window.isElectronNative) {
            reasonMap[
              NEMeetingCode.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE
            ] = t('meetingSwitchOtherDevice');
            (arg || arg === 0) && reasonMap[arg] && Toast.info(reasonMap[arg]);
          }

          window.ipcRenderer?.send(IPCEvent.quiteFullscreen);
          setTimeout(() => {
            setInMeeting(false);
            if (window.isElectronNative) {
              window.ipcRenderer?.send(IPCEvent.beforeEnterRoom);
            } else {
              window.location.reload();
            }
          }, 0);
          localStorage.removeItem('ne-meeting-current-info');
          window.ipcRenderer?.send('flushStorageData');
        }
      },
    });

    window.ipcRenderer?.on(IPCEvent.NEMeetingKitCrash, () => {
      setInMeeting(false);
      window.ipcRenderer?.send(IPCEvent.beforeEnterRoom, !isLoginRef.current);
    });
  }, [meetingService]);

  //
  useUpdateEffect(() => {
    if (accountService && !accountInfo && !isOffLine && !isLoginRef.current) {
      const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);

      if (userString) {
        const user = JSON.parse(userString);

        if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
          appKey = user.appKey || user.appId;
          userUuid = user.userUuid;
          userToken = user.userToken;

          accountService
            ?.loginByToken(userUuid, userToken)
            .then(async (res) => {
              setIsLogin(true);
              setLoginLoading(false);
              setAccountInfo(res.data);
              getMeetingList({
                size: pageSize,
                offset: 0,
              });

              accountService?.addListener({
                onKickOut: () => {
                  //
                },
                onAuthInfoExpired: () => {
                  //
                },
                onReconnected: () => {
                  //
                },
                onAccountInfoUpdated: (info) => {
                  setAccountInfo({ ...info });
                  updateLocalStorageUserInfo(info);
                },
              });
              console.warn('preMeetingService注册事件');
              preMeetingService?.addListener({
                onMeetingItemInfoChanged: (data) => {
                  //
                  data.forEach((item) => {
                    if (
                      item.status === 4 &&
                      openMeetingDetailMeetingNumRef.current == item.meetingNum
                    ) {
                      if (window.isElectronNative) {
                        closeWindow('scheduleMeetingWindow');
                      } else {
                        setScheduleMeetingModalOpen(false);
                      }

                      openMeetingDetailMeetingNumRef.current = '';
                    }
                  });

                  getMeetingList({
                    size: currentOffsetRef.current,
                    offset: 0,
                  });
                },
              });

              if (settingsService) {
                const settings = getLocalStorageSetting();

                const language = settings?.normalSetting?.language;

                if (language) {
                  MeetingKitInstance.switchLanguage(
                    {
                      'zh-CN': NEMeetingLanguage.CHINESE,
                      'en-US': NEMeetingLanguage.ENGLISH,
                      'ja-JP': NEMeetingLanguage.JAPANESE,
                    }[language] ?? NEMeetingLanguage.AUTOMATIC,
                  );
                  i18next.changeLanguage(language);
                }

                const sessionIdRes =
                  await settingsService.getAppNotifySessionId();
                const isAvatarUpdateSupportedRes =
                  await settingsService?.isAvatarUpdateSupported();

                isAvatarUpdateSupportedRes &&
                  setIsAvatarUpdateSupported(isAvatarUpdateSupportedRes.data);

                const isNicknameUpdateSupportedRes =
                  await settingsService?.isNicknameUpdateSupported();

                isNicknameUpdateSupportedRes &&
                  setIsNicknameUpdateSupported(
                    isNicknameUpdateSupportedRes.data,
                  );

                const isMeetingLiveSupportedRes =
                  await settingsService?.isMeetingLiveSupported();

                isMeetingLiveSupportedRes &&
                  setAppLiveAvailable(isMeetingLiveSupportedRes.data);
                currentMeetingInfoRef.current = {
                  ...currentMeetingInfoRef.current,
                  sessionId: sessionIdRes?.data || '',
                };

                const { data: interpreterConfig } =
                  await settingsService.getInterpretationConfig();
                const { data: scheduleConfig } =
                  await settingsService.getScheduledMemberConfig();

                const { data: whiteboard } =
                  await settingsService.isMeetingWhiteboardSupported();

                const { data: live } =
                  await settingsService.isMeetingLiveSupported();

                const { data: record } =
                  await settingsService.isMeetingCloudRecordSupported();

                const { data: guest } =
                  await settingsService.isGuestJoinSupported();

                const { data: waitingRoom } =
                  await settingsService.isWaitingRoomSupported();
                const { data: maxThirdPartyNum } =
                  await settingsService.getLiveMaxThirdPartyCount();

                const { data: isMeetingLiveOfficialPushSupported } =
                  await settingsService.isMeetingLiveOfficialPushSupported();

                const { data: isMeetingLiveThirdPartyPushSupported } =
                  await settingsService.isMeetingLiveThirdPartyPushSupported();

                setGlobalConfig({
                  appConfig: {
                    APP_LIVE: {
                      officialPushEnabled: isMeetingLiveOfficialPushSupported,
                      thirdPartyPushEnabled:
                        isMeetingLiveThirdPartyPushSupported,
                    },
                    APP_ROOM_RESOURCE: {
                      whiteboard,
                      live,
                      record,
                      guest,
                      waitingRoom,
                      interpretation: interpreterConfig
                        ? {
                            enable: interpreterConfig.enable,
                            maxInterpreters: interpreterConfig.maxInterpreters,
                            enableCustomLang:
                              interpreterConfig.enableCustomLang,
                            maxCustomLanguageLength:
                              interpreterConfig.maxCustomLangNameLen,
                            maxLanguagesPerInterpreter:
                              interpreterConfig.maxInterpreters,
                          }
                        : undefined,
                    },
                    MEETING_SCHEDULED_MEMBER_CONFIG: scheduleConfig
                      ? {
                          enable: scheduleConfig.enable,
                          coHostLimit: scheduleConfig.coHostLimit,
                          max: scheduleConfig.scheduleMemberMax,
                        }
                      : undefined,
                    MEETING_LIVE: {
                      maxThirdPartyNum: maxThirdPartyNum || 5,
                    },
                  },
                });
              }

              MeetingKitInstance.getAppNoticeTips().then((res) => {
                res.data && setTipInfo(res.data.tips[0]);
              });

              const notFirstLogin = sessionStorage.getItem(NOT_FIRST_LOGIN);

              if (!notFirstLogin) {
                window.ipcRenderer?.send(IPCEvent.isStartByUrl);
                sessionStorage.setItem(NOT_FIRST_LOGIN, 'true');
              }

              const currentMeetingStr = localStorage.getItem(
                'ne-meeting-current-info',
              );

              // 异常退出恢复会议
              if (currentMeetingStr && window.isElectronNative) {
                const currentMeeting = JSON.parse(currentMeetingStr);

                // 15分钟内恢复会议
                if (currentMeeting.time > Date.now() - 1000 * 60 * 15) {
                  Modal.confirm({
                    title: i18n.hint,
                    content: i18n.restoreMeetingTips,
                    okText: i18n.restore,
                    onCancel: () => {
                      localStorage.removeItem('ne-meeting-current-info');
                      window.ipcRenderer?.send('flushStorageData');
                    },
                    onOk: () => {
                      try {
                        joinMeeting({
                          meetingNum: currentMeeting.meetingNum,
                        });
                      } catch (error) {
                        console.error('restore meeting error', error);
                      }

                      localStorage.removeItem('ne-meeting-current-info');
                      window.ipcRenderer?.send('flushStorageData');
                    },
                  });
                } else {
                  localStorage.removeItem('ne-meeting-current-info');
                  window.ipcRenderer?.send('flushStorageData');
                }
              }
            })
            .catch((e) => {
              console.log('loginByToken error', e);
              Toast.fail(e.message || e.msg || 'failed');

              setLoginLoading(false);

              setIsLogin(false);
              // 非网络错误才离开
              if (e.code !== 'ERR_NETWORK') {
                logout();
              }
            });
        } else {
          logout();
        }
      } else {
        logout();
      }
    }
  }, [accountService, isOffLine]);

  document.title = i18n.appTitle;

  function onSettingClick(type?: SettingTabType) {
    type = type || 'normal';

    MeetingKitInstance.getSettingsService()?.openSettingsWindow(type);
  }

  function openBeforeMeetingWindow(payload: {
    name: string;
    url?: string;
    postMessageData?: { event: string; payload };
  }) {
    const newWindow = openWindow(payload.name, payload.url);
    const postMessage = () => {
      payload.postMessageData &&
        newWindow?.postMessage(payload.postMessageData, newWindow.origin);
    };

    console.warn('firstOpen', newWindow?.firstOpen);
    // 不是第一次打开
    if (newWindow?.firstOpen === false) {
      postMessage();
    } else {
      windowLoadListener(newWindow);
      newWindow?.addEventListener('load', () => {
        postMessage();
      });
    }
  }

  // 监听子窗口消息
  function windowLoadListener(childWindow) {
    function messageListener(e) {
      const { event, payload } = e.data;

      const messageChannelService =
        MeetingKitInstance.getMeetingMessageChannelService();

      if (event === 'neMeetingKit') {
        const { replyKey, fnKey, args } = payload;
        const result = MeetingKitInstance[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (event === 'getMeetingService' && meetingService) {
        const { replyKey, fnKey, args } = payload;
        const result = meetingService[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (event === 'getPreMeetingService' && preMeetingService) {
        const { replyKey, fnKey, args } = payload;
        const result = preMeetingService[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (event === 'getAccountService' && accountService) {
        const { replyKey, fnKey, args } = payload;
        const result = accountService[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (event === 'getContactsService' && contactsService) {
        const { replyKey, fnKey, args } = payload;
        const result = contactsService[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (
        event === 'getMeetingMessageChannelService' &&
        messageChannelService
      ) {
        const { replyKey, fnKey, args } = payload;
        const result = messageChannelService[fnKey]?.(...args);

        handlePostMessage(childWindow, result, replyKey);
      } else if (event === 'updateUserAvatar') {
        Toast.success(t('settingAvatarUpdateSuccess'));
      } else if (event === 'openWindow') {
        openBeforeMeetingWindow(payload);
      } else if (event === 'updateWindowData') {
        const win = getWindow(payload.name);

        win?.postMessage(payload.postMessageData, win.origin);
      } else if (event === 'notificationClick') {
        handleNotificationClick(payload.action, payload.message);
      } else if (event === 'createMeeting') {
        const { value } = payload;

        createMeeting({
          meetingNum: value.meetingId,
          password: value.password,
          video: value.openCamera ? 1 : 2,
          audio: value.openMic ? 1 : 2,
        });
      } else if (event === 'onFeedbackSuccess') {
        Toast.success(t('thankYourFeedback'));
      } else if (event === 'onFeedbackUpload') {
        setShowLoading(payload.value);
      } else if (event === 'joinMeeting') {
        const { value } = payload;

        if (isJoiningRef.current) {
          return;
        }

        isJoiningRef.current = true;
        joinMeeting({
          meetingNum: value.meetingId,
          video: value.openCamera ? 1 : 2,
          audio: value.openMic ? 1 : 2,
          password: value.password,
        }).finally(() => {
          isJoiningRef.current = false;
        });
      } else if (event === 'joinScheduleMeeting') {
        const { meetingId } = payload;

        joinMeeting({
          meetingNum: meetingId,
        });
      } else if (event === 'createOrEditScheduleMeeting') {
        const { value } = payload;

        createOrEditScheduleMeeting(value);
      } else if (event === 'cancelScheduleMeeting') {
        const { meetingId, cancelRecurringMeeting } = payload;

        cancelScheduleMeeting(meetingId, cancelRecurringMeeting);
      } else if (
        event === 'onMembersChangeHandler' ||
        event === 'onRoleChange' ||
        event === 'onAddressBookConfirmHandler' ||
        event === 'onAddressBookCancelHandler'
      ) {
        if (e.target === getWindow('addressBook')) {
          const scheduleMeetingWindow = getWindow('scheduleMeetingWindow');

          scheduleMeetingWindow?.postMessage({
            event,
            payload,
          });
        }
      } else if (
        event === 'onSaveInterpreters' ||
        event === 'onDeleteScheduleMember' ||
        event === 'onDeleteInterpreterAndAddressBookMember'
      ) {
        const scheduleMeetingWindow = getWindow('scheduleMeetingWindow');

        scheduleMeetingWindow?.postMessage({
          event,
          payload,
        });
      } else if (event === 'confirmDeleteInterpreter') {
        const addressBookWindow = getWindow('addressBook');

        addressBookWindow?.postMessage({
          event: 'showConfirmDeleteInterpreter',
          payload,
        });
      }
    }

    childWindow?.addEventListener('message', messageListener);
  }

  function openImageCrop() {
    const fileInput = document.createElement('input');

    fileInput.type = 'file';
    fileInput.accept = 'image/*';
    fileInput.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];

      if (file) {
        const maxAllowedSize = 5 * 1024 * 1024;

        if (file?.size > maxAllowedSize) {
          Toast.fail('图片大小不能超过5MB');
          return;
        }

        const reader = new FileReader();

        reader.onload = (e) => {
          imageCropValueRef.current = e.target?.result as string;
          if (window.isElectronNative) {
            openBeforeMeetingWindow({
              name: 'imageCropWindow',
              postMessageData: {
                event: 'setAvatarImage',
                payload: {
                  image: imageCropValueRef.current,
                },
              },
            });
          } else {
            setImageCropModalOpen(true);
          }
        };

        reader.readAsDataURL(file);
      }
    };

    fileInput.click();
  }

  async function openNotificationList() {
    const sessionId = currentMeetingInfoRef.current.sessionId;

    if (sessionId) {
      MeetingKitInstance.getMeetingMessageChannelService()
        ?.clearUnreadCount(sessionId)
        .then(() => {
          setNotificationMessages([]);
        });
    }

    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'notificationListWindow',
        postMessageData: {
          event: 'windowOpen',
          payload: {
            sessionId,
            isInMeeting: false,
          },
        },
      });
    } else {
      setNotificationListModalOpen(true);
    }
  }

  // 通知点击事件
  function handleNotificationClick(action?: string, message?) {
    console.log('handleNotificationClick', action, message);
    if (
      action?.startsWith('meeting://meeting_history') ||
      action?.startsWith('meeting://meeting_info')
    ) {
      const urlObj = new URL(action);
      const searchParams = new URLSearchParams(urlObj.search);
      const meetingId = searchParams.get('meetingId');

      if (meetingId) {
        if (action?.startsWith('meeting://meeting_history')) {
          setHistoryMeetingId(Number(meetingId));
          if (window.isElectronNative) {
            openBeforeMeetingWindow({
              name: 'historyWindow',
              postMessageData: {
                event: 'windowOpen',
                payload: {
                  meetingId,
                },
              },
            });
          } else {
            setHistoryMeetingModalOpen(true);
          }
        } else {
          openMeetingDetailInfo(Number(meetingId));
        }
      }
    } else {
      action && onNotificationClickHandler(action, message);
    }
  }

  const onNotificationCardWinOpen = (message) => {
    console.log('onNotificationCardWinOpen', message);
    openBeforeMeetingWindow({
      name: 'notificationCardWindow',
      postMessageData: {
        event: 'updateNotifyCard',
        payload: {
          message,
        },
      },
    });
  };

  function openNPS() {
    const npsString = localStorage.getItem('ne-meeting-nps');

    if (npsString) {
      const nps = JSON.parse(npsString);

      setMeetingId(nps.meetingId);
      if (
        (!nps.time || nps.time < Date.now() - 24 * 60 * 60 * 1000) &&
        nps.need
      ) {
        nps.time = Date.now();
        if (window.isElectronNative) {
          openBeforeMeetingWindow({
            name: 'npsWindow',
            postMessageData: {
              event: 'setNpsInfo',
              payload: {
                meetingId: nps.meetingId,
                nickname: accountInfoRef.current?.nickname,
                appKey,
              },
            },
          });
        } else {
          setNpsModalOpen(true);
        }
      }

      nps.need = false;
      localStorage.setItem('ne-meeting-nps', JSON.stringify(nps));
    }
  }

  const expireTip = useMemo(() => {
    if (
      showExpireTip &&
      accountInfo?.serviceBundle?.expireTimeStamp &&
      accountInfo.serviceBundle.expireTimeStamp !== -1 &&
      accountInfo?.serviceBundle.expireTimeStamp < Date.now()
    ) {
      return (
        <div className="before-meeting-home-alter">
          <ExclamationCircleFilled />
          <div className="before-meeting-home-alter-content">
            {t('settingServiceBundleExpirationDateTip')}
          </div>
          <CloseOutlined onClick={() => setShowExpireTip(false)} />
        </div>
      );
    }

    return null;
  }, [accountInfo?.serviceBundle?.expireTimeStamp, showExpireTip, t]);

  const tipStrs = useMemo(() => {
    return tipInfo && showTipInfo && !isOffLine ? (
      <div className="before-meeting-home-alter">
        <ExclamationCircleFilled />
        <MeetingPopover
          placement="bottom"
          rootClassName="before-meeting-home-alter-popover"
          content={
            (tipInfo?.title ? `【${tipInfo.title}】` : '') + tipInfo?.content
          }
        >
          <div
            className="before-meeting-home-alter-content"
            style={{
              cursor: tipInfo?.url ? 'pointer' : 'default',
            }}
            onClick={() => {
              if (tipInfo?.url) {
                if (window.isElectronNative) {
                  window.ipcRenderer?.send(
                    IPCEvent.openBrowserWindow,
                    tipInfo.url,
                  );
                } else {
                  window.open(tipInfo.url, '_blank');
                }
              }
            }}
          >
            {tipInfo?.title ? `【${tipInfo.title}】` : ''}
            {tipInfo?.content || ''}
          </div>
        </MeetingPopover>
        <CloseOutlined onClick={() => setShowTipInfo(false)} />
      </div>
    ) : null;
  }, [tipInfo, showTipInfo, isOffLine]);

  useEffect(() => {
    if (inMeetingRef.current) {
      return;
    }

    if (!window.isElectronNative) {
      openNPS();
    }

    window.ipcRenderer?.on(IPCEvent.openMeetingFeedback, () => {
      onOpenFeedback();
    });
    window.ipcRenderer?.on(IPCEvent.openMeetingAbout, () => {
      openBeforeMeetingWindow({ name: 'aboutWindow' });
    });
    window.ipcRenderer?.on(IPCEvent.changeSetting, (_, setting) => {
      onSettingChange(setting);
    });
    window.ipcRenderer?.on(IPCEvent.needOpenNPS, () => {
      openNPS();
    });
    window.ipcRenderer?.on(IPCEvent.setNPS, (_, meetingId) => {
      setNPS(meetingId);
    });
  }, []);

  useEffect(() => {
    window.addEventListener('online', () => {
      setIsOffLine(false);
      isLoginRef.current &&
        getMeetingList({
          size: currentOffsetRef.current,
          offset: 0,
        });
    });
    window.addEventListener('offline', () => {
      setIsOffLine(true);
    });
    if (!navigator.onLine) {
      setIsOffLine(true);
    }

    window.ipcRenderer?.on(IPCEvent.joinMeetingLoading, (_, loading) => {
      setSubmitLoading(loading);
    });
  }, [preMeetingService]);

  // 查询通知消息
  useEffect(() => {
    // 如果没有登录则不查询
    if (!accountInfo) {
      return;
    }

    const listener = {
      onSessionMessageReceived: onReceiveMessage,
      onSessionMessageRecentChanged: onSessionMessageRecentChanged,
      onSessionMessageAllDeleted: onDeleteAllSessionMessage,
    };
    const messageChannelService =
      MeetingKitInstance.getMeetingMessageChannelService();

    async function onReceiveMessage(message?: NEMeetingSessionMessage) {
      const sessionId = currentMeetingInfoRef.current.sessionId;

      if (sessionId && (message?.sessionId === sessionId || !message)) {
        if (message?.data) {
          const data =
            Object.prototype.toString.call(message.data) === '[object Object]'
              ? message?.data
              : JSON.parse(message.data);

          message.data = data;
        }

        const messageChannelService =
          MeetingKitInstance.getMeetingMessageChannelService();

        if (notificationListModalOpen || getWindow('notificationListWindow')) {
          messageChannelService?.clearUnreadCount(sessionId);
        } else {
          // 这里需要延迟查询，否则会出现消息获取不了的问题
          setTimeout(
            () => {
              messageChannelService
                ?.queryUnreadMessageList(sessionId)
                .then((res) => {
                  setNotificationMessages(res.data);
                });
            },
            message?.messageId ? 1000 : 100,
          );
        }
      }
    }

    onReceiveMessage();

    messageChannelService?.addMeetingMessageChannelListener(listener);
    function onSessionMessageRecentChanged(sessions: NEMeetingRecentSession[]) {
      const sessionId = currentMeetingInfoRef.current.sessionId;

      if (sessionId) {
        const session = sessions.find((s) => s.sessionId === sessionId);

        if (session?.unreadCount === 0) {
          setNotificationMessages([]);
        }
      }
    }

    function onDeleteAllSessionMessage(
      sessionId: string,
      sessionType: NEMeetingSessionTypeEnum,
    ) {
      const notificationListWindow = getWindow('notificationListWindow');

      notificationListWindow?.postMessage(
        {
          event: 'eventEmitter',
          payload: {
            key: EventType.OnDeleteAllSessionMessage,
            args: [sessionId, sessionType],
          },
        },
        notificationListWindow.origin,
      );
    }

    function onMeetingInviteStatusChange(
      status: NEMeetingInviteStatus,
      inviteInfo: NEMeetingInviteInfo,
      meetingId: number,
      message: NECustomSessionMessage,
    ) {
      if (inMeetingRef.current && window.isElectronNative) {
        return;
      }

      if (status === NEMeetingInviteStatus.calling) {
        let data = message.data;

        // 如果是字符串需要解析成对象
        if (
          data &&
          Object.prototype.toString.call(data) === '[object String]'
        ) {
          try {
            data = JSON.parse(data);
            data = data.data;
            message.data = { data };
          } catch (error) {
            console.log('Json parse invite msg error', error);
          }
        }

        // 如果当前时间大于接收到的消息时间60s则不处理
        if (!data || Date.now() - data.timestamp > 60000) {
          return;
        }

        if (window.isElectronNative) {
          console.warn(
            'electronInMeetingRef',
            electronInMeetingRef.current,
            message,
          );
          if (!electronInMeetingRef.current) {
            setCustomMessage(message);
          }
        } else {
          setCustomMessage(message);
        }
      } else if (
        status === NEMeetingInviteStatus.rejected ||
        status === NEMeetingInviteStatus.canceled ||
        status === NEMeetingInviteStatus.removed
      ) {
        // 如果多端登录 邀请被拒绝需要同步关闭本端的
        notificationApi.destroy(meetingId);
        // electron 需要关闭多窗口
        if (window.isElectronNative) {
          const notificationCardWindow = getWindow('notificationCardWindow');

          notificationCardWindow?.postMessage(
            {
              event: 'inviteStateChange',
              payload: {
                status,
                meetingId,
              },
            },
            notificationCardWindow.origin,
          );
        }
      }
    }

    const inviteListener = {
      onMeetingInviteStatusChanged: onMeetingInviteStatusChange,
    };

    meetingInviteService?.addMeetingInviteStatusListener(inviteListener);
    return () => {
      meetingInviteService?.removeMeetingInviteStatusListener(inviteListener);
      messageChannelService?.removeMeetingMessageChannelListener(listener);
    };
  }, [
    accountInfo,
    notificationListModalOpen,
    // 这里需要监听当前会议的 sessionId，因为 sessionId 获取是异步的。
    currentMeetingInfoRef.current.sessionId,
  ]);

  function openMeetingDetailInfo(meetingId: number) {
    preMeetingService
      ?.getMeetingItemById(meetingId)
      .then((res) => {
        preMeetingService
          ?.getMeetingItemByNum(res.data.meetingNum)
          .then((res) => {
            setEditMeeting(res.data);
            if (window.isElectronNative) {
              openBeforeMeetingWindow({
                name: 'scheduleMeetingWindow',
                postMessageData: {
                  event: 'windowOpen',
                  payload: {
                    nickname: accountInfoRef.current?.nickname,
                    appLiveAvailable,
                    globalConfig,
                    editMeeting: res.data,
                  },
                },
              });
            } else {
              setScheduleMeetingModalOpen(true);
            }
          });
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg);
      });
  }

  const [time, setTime] = useState(getCurrentDateTime().time);
  const [date, setDate] = useState(getCurrentDateTime().date);

  useEffect(() => {
    const now = dayjs(); // 获取当前时间的dayjs对象
    const currentSecond = now.second(); // 获取当前秒数

    const timeout = setTimeout(() => {
      setTime(getCurrentDateTime().time);
      setInterval(() => {
        setTime(getCurrentDateTime().time);
        setDate(getCurrentDateTime().date);
      }, 1000 * 60);
    }, 1000 * (60 - currentSecond));

    const dateInterval = setInterval(() => {
      setDate(getCurrentDateTime().date);
    }, 1000 * 60 * 60 * 24);

    return () => {
      clearTimeout(timeout);
      clearInterval(dateInterval);
    };
  }, []);

  const onOpenImmediateMeeting = () => {
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'immediateMeetingWindow',
        postMessageData: {
          event: 'setImmediateMeetingData',
          payload: {
            nickname: accountInfoRef.current?.nickname,
            avatar: accountInfoRef.current?.avatar,
            setting,
            meetingNum: accountInfoRef.current?.privateMeetingNum,
            shortMeetingNum: accountInfoRef.current?.privateShortMeetingNum,
          },
        },
      });
    } else {
      setImmediateMeetingModalOpen(true);
    }
  };

  const onOpenScheduleMeeting = () => {
    setEditMeeting(undefined);
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'scheduleMeetingWindow',
        postMessageData: {
          event: 'windowOpen',
          payload: {
            nickname: accountInfoRef.current?.nickname,
            appLiveAvailable,
            globalConfig,
          },
        },
      });
    } else {
      setScheduleMeetingModalOpen(true);
    }
  };

  const onOpenJoinMeeting = (meetingNum?: string) => {
    if (!accountInfoRef.current) {
      return;
    }

    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'joinMeetingWindow',
        postMessageData: {
          event: 'setJoinMeetingData',
          payload: {
            nickname: accountInfoRef.current.nickname,
            avatar: accountInfoRef.current.avatar,
            setting: settingRef.current,
            settingOpen,
            invitationMeetingNum: meetingNum || invitationMeetingNum,
            accountId: accountInfoRef.current.account,
          },
        },
      });
      setInvitationMeetingNum('');
    } else {
      setJoinMeetingModalOpen(true);
      meetingService?.getLocalHistoryMeetingList().then((res) => {
        setLocalHistoryMeetingList(res.data);
      });
    }
  };

  useEffect(() => {
    const joinMeetingWindow = getWindow('joinMeetingWindow');

    joinMeetingWindow?.postMessage(
      {
        event: 'setJoinMeetingData',
        payload: {
          setting,
        },
      },
      joinMeetingWindow.origin,
    );

    const immediateMeetingWindow = getWindow('immediateMeetingWindow');

    immediateMeetingWindow?.postMessage(
      {
        event: 'setImmediateMeetingData',
        payload: {
          setting,
        },
      },
      immediateMeetingWindow.origin,
    );
  }, [setting]);

  useUpdateEffect(() => {
    // 语言切换
    const language = i18next.language;

    MeetingKitInstance.switchLanguage(
      {
        'zh-CN': NEMeetingLanguage.CHINESE,
        'en-US': NEMeetingLanguage.ENGLISH,
        'ja-JP': NEMeetingLanguage.JAPANESE,
      }[language] ?? NEMeetingLanguage.AUTOMATIC,
    );
  }, [i18next.language]);

  return (
    <>
      <Modal
        title={i18n.localRecordRemuxTitle}
        zIndex={20000}
        closable={true}
        footer={null}
        open={localReocrdState != -1 && meetingEndFlag}
        width={416}
        onCancel={() => {
          console.log('取消');
          //recordTimerRef.current && clearInterval(recordTimerRef.current)
          localRecordStopRemux();
          // setMeetingEndFlag(false)
          // setLocalReocrdState(-1)
          // setProgress(0)
        }}
      >
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
          }}
        >
          <div
            style={{
              textAlign: 'center',
              lineHeight: '25px',
              margin: '24px 0 6px 0',
            }}
          >
            {t('localRecordRemuxContent')}
          </div>
          <Progress percent={progress} showInfo={false} />
          <div
            key="footer-container"
            style={{
              textAlign: 'center',
              marginBottom: 20,
              marginTop: 30,
            }}
          >
            <Button
              danger
              onClick={() => {
                console.log('执行localRecordStopRemux()');
                localRecordStopRemux();
              }}
            >
              {i18n.localRecordStopRemuxTitle}
            </Button>
          </div>
        </div>
      </Modal>
      {!inMeeting && (
        <Spin
          spinning={loginLoading || submitLoading}
          wrapperClassName="before-meeting-home-spin"
        >
          <div
            className="before-meeting-home-container"
            id="before-meeting-home"
          >
            <div
              className={classNames('before-meeting-home-container-header', {
                drag: !userMenuOpen,
              })}
            ></div>
            {isOffLine ? (
              <div className="before-meeting-home-network-error">
                <ExclamationCircleFilled />
                <div className="before-meeting-home-alter-content">
                  {i18n.networkError}
                </div>
              </div>
            ) : null}
            {expireTip ? expireTip : tipStrs}
            <div className="before-meeting-home-content-wrap">
              <div className="before-meeting-home-top-buttons">
                <PCTopButtons size="small" maximizable={false} />
              </div>
              <div
                style={{
                  borderRadius:
                    window.systemPlatform === 'win32' ? '0' : '10px 0 0 10px',
                }}
                className={classNames('before-meeting-home-left-side', {
                  drag: !userMenuOpen,
                })}
              >
                <div className="before-meeting-home-user-avatar">
                  <Dropdown
                    menu={{ items }}
                    //@ts-expect-error antd 组件支持传right，其类型定义有误
                    placement="right"
                    trigger={['click']}
                    open={userMenuOpen}
                    onOpenChange={(open) => setUserMenuOpen(open)}
                    overlayClassName="before-meeting-home-user-menu"
                    getPopupContainer={() =>
                      document.getElementById(
                        'before-meeting-home',
                      ) as HTMLElement
                    }
                  >
                    <UserAvatar
                      nickname={accountInfo?.nickname}
                      avatar={accountInfo?.avatar}
                      size={36}
                    ></UserAvatar>
                  </Dropdown>
                </div>
                <div className="before-meeting-home-bottom-buttons">
                  <div
                    className="notification-icon"
                    onClick={() => {
                      openNotificationList();
                    }}
                  >
                    <Badge
                      count={
                        notificationMessages.length > 99
                          ? '99+'
                          : notificationMessages.length
                      }
                    >
                      <svg
                        className="icon iconfont iconxiaoxi"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#icontongzhi"></use>
                      </svg>
                    </Badge>
                  </div>
                  <div
                    className="setting-button"
                    onClick={() => {
                      onSettingClick();
                    }}
                  >
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconshezhi1"></use>
                    </svg>
                  </div>
                </div>
              </div>
              <div className="before-meeting-home-middle">
                <div className="before-meeting-home-middle-content">
                  <div className="before-meeting-home-buttons">
                    <div>
                      <div
                        className="meeting-button-img"
                        onClick={onOpenImmediateMeeting}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconfaqihuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.immediateMeeting}</span>
                      </div>
                      <div
                        className="meeting-button-img"
                        onClick={onOpenScheduleMeeting}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconyuyuehuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.scheduleMeeting}</span>
                      </div>
                    </div>
                    <div>
                      <div
                        className="meeting-button-img"
                        onClick={() => {
                          onOpenJoinMeeting();
                        }}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconjiaruhuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.joinMeeting}</span>
                      </div>
                      <div className="meeting-button-img">
                        <div
                          className="icon-wrap"
                          onClick={() => Toast.success(i18n.comingSoon)}
                        >
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconhuiyishitouping"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">
                          {i18n.meetingRoomScreenCasting}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div className="before-meeting-home-right">
                <div className="before-meeting-home-right-content">
                  <div
                    className="before-meeting-home-right-header"
                    style={{
                      backgroundImage: `url(${BeforeMeetingHomeHeader})`,
                    }}
                  >
                    <div className="time">{time}</div>
                    <div className="date">
                      <span className="today">{i18n.today}</span>
                      <span>{date}</span>
                    </div>
                  </div>
                  <div
                    className="before-meeting-home-history-button"
                    onClick={() => {
                      if (isOffLine) {
                        Toast.fail(i18n.networkError);
                        return;
                      }

                      if (window.isElectronNative) {
                        openBeforeMeetingWindow({
                          name: 'historyWindow',
                          postMessageData: {
                            event: 'windowOpen',
                            payload: {
                              meetingId: '',
                            },
                          },
                        });
                      } else {
                        setHistoryMeetingId(undefined);
                        setHistoryMeetingModalOpen(true);
                      }
                    }}
                  >
                    <span className="history-meeting-title">
                      {i18n.historyMeeting}
                    </span>
                    <span className="icon-jiantou">
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconyoujiantou-16px-2"></use>
                      </svg>
                    </span>
                  </div>
                  <div
                    ref={scrollRef}
                    className="schedule-meeting-list-container-wrap"
                  >
                    <div className="schedule-meeting-list-container">
                      {meetingListGroupByDate.length > 0 ? (
                        meetingListGroupByDate.map((item) => (
                          <div
                            className="schedule-meeting-group-item"
                            key={item.date}
                          >
                            {formatScheduleMeetingDateTitle(Number(item.date))}
                            {item.list.map((meeting) => (
                              <div
                                className="schedule-meeting-item"
                                key={meeting.meetingId}
                              >
                                <div className="schedule-meeting-item-content">
                                  <div className="top">
                                    <div className="schedule-meeting-item-subject">
                                      <span
                                        className="schedule-meeting-item-subject-text"
                                        style={{
                                          fontWeight:
                                            window.systemPlatform === 'win32'
                                              ? 'bold'
                                              : '500',
                                        }}
                                      >
                                        {meeting.subject}
                                      </span>
                                      {meeting.recurringRule &&
                                        meeting.recurringRule.type !==
                                          MeetingRepeatType.NoRepeat && (
                                          <Tag
                                            color="#EBF2FF"
                                            className="periodic-tag"
                                            style={{
                                              lineHeight:
                                                window.systemPlatform == 'win32'
                                                  ? '20px'
                                                  : '19px',
                                            }}
                                          >
                                            {t('meetingRepeat')}
                                          </Tag>
                                        )}
                                    </div>

                                    <div className="schedule-meeting-item-buttons">
                                      <Button
                                        className="schedule-meeting-item-button-join"
                                        type="primary"
                                        onClick={() => {
                                          setSubmitLoading(true);
                                          joinMeeting({
                                            meetingNum: meeting.meetingNum,
                                          });
                                        }}
                                      >
                                        {i18n.join}
                                      </Button>
                                      <div className="more">
                                        <svg
                                          onClick={() => {
                                            preMeetingService
                                              ?.getMeetingItemByNum(
                                                meeting.meetingNum,
                                              )
                                              .then((res) => {
                                                eventEmitter.emit(
                                                  EventType.OnScheduledMeetingPageModeChanged,
                                                  'detail',
                                                );
                                                setEditMeeting(res.data);
                                                openMeetingDetailMeetingNumRef.current =
                                                  meeting.meetingNum;
                                                if (window.isElectronNative) {
                                                  openBeforeMeetingWindow({
                                                    name: 'scheduleMeetingWindow',
                                                    postMessageData: {
                                                      event: 'windowOpen',
                                                      payload: {
                                                        nickname:
                                                          accountInfoRef.current
                                                            ?.nickname,
                                                        appLiveAvailable,
                                                        globalConfig,
                                                        editMeeting: res.data,
                                                      },
                                                    },
                                                  });
                                                } else {
                                                  setScheduleMeetingModalOpen(
                                                    true,
                                                  );
                                                }
                                              })
                                              .catch((e) => {
                                                Toast.fail(e.message || e.msg);
                                              });
                                          }}
                                          className="icon iconfont iconyx-tv-more1x"
                                          aria-hidden="true"
                                        >
                                          <use xlinkHref="#iconyx-tv-more1x"></use>
                                        </svg>
                                      </div>
                                    </div>
                                  </div>
                                  <div className="bottom">
                                    <span className="dur-time">
                                      {dayjs(Number(meeting.startTime)).format(
                                        'HH:mm',
                                      )}
                                      {'-'}
                                      {dayjs(Number(meeting.endTime)).format(
                                        'HH:mm',
                                      )}
                                    </span>
                                    <div className="line"></div>
                                    <MeetingPopover
                                      content={i18n.copyMeetingIdTip}
                                      trigger="hover"
                                    >
                                      <div
                                        className="meeting-id"
                                        onClick={() =>
                                          copyElementValue(
                                            meeting.meetingNum,
                                            () => {
                                              Toast.success(i18n.copySuccess);
                                            },
                                          )
                                        }
                                      >
                                        <span>
                                          {getMeetingDisplayId(
                                            meeting.meetingNum,
                                          )}
                                        </span>
                                      </div>
                                    </MeetingPopover>

                                    <div className="line"></div>
                                    <span
                                      className={
                                        meeting.status === 1
                                          ? 'in-ready-state'
                                          : meeting.status === 2
                                          ? `in-progress-state`
                                          : 'in-end-state'
                                      }
                                    >
                                      {
                                        [
                                          i18n.notStarted,
                                          i18n.inProgress,
                                          i18n.ended,
                                        ][meeting.status - 1]
                                      }
                                    </span>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        ))
                      ) : (
                        <div className="before-meeting-home-empty-schedule-meeting">
                          <img
                            className="empty-schedule-meeting-img"
                            src={EmptyScheduleMeetingImg}
                            alt=""
                          />
                          <span className="text">
                            {i18n.emptyScheduleMeeting}
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <ImmediateMeetingModal
              setting={setting}
              nickname={accountInfo?.nickname}
              avatar={accountInfo?.avatar}
              onSettingChange={onSettingChange}
              meetingNum={accountInfo?.privateMeetingNum}
              shortMeetingNum={accountInfo?.privateShortMeetingNum}
              open={immediateMeetingModalOpen}
              onCancel={() => setImmediateMeetingModalOpen(false)}
              settingsService={settingsService}
              submitLoading={submitLoading}
              onOpenSetting={(tab) => {
                onSettingClick(tab);
              }}
              onSummit={(value) => {
                return createMeeting({
                  meetingNum: value.meetingId,
                  password: value.password,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                });
              }}
            />

            <JoinMeetingModal
              wrapClassName="join-meeting-modal-wrap"
              setting={setting}
              nickname={accountInfo?.nickname}
              avatar={accountInfo?.avatar}
              settingOpen={settingOpen}
              settingsService={settingsService}
              onSettingChange={onSettingChange}
              open={joinMeetingModalOpen}
              getContainer={false}
              onCancel={() => setJoinMeetingModalOpen(false)}
              afterClose={() => setInvitationMeetingNum('')}
              meetingNum={invitationMeetingNum}
              submitLoading={submitLoading}
              recentMeetingList={localHistoryMeetingList}
              onClearRecentMeetingList={() => {
                meetingService?.clearLocalHistoryMeetingList();
                setLocalHistoryMeetingList([]);
              }}
              onOpenSetting={(tab) => {
                onSettingClick(tab);
              }}
              onSummit={async (value) => {
                const options = {
                  meetingNum: value.meetingId,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                };

                setSubmitLoading(true);
                joinMeeting(options);
              }}
            />
            <ScheduleMeetingModal
              nickname={accountInfo?.nickname}
              open={scheduleMeetingModalOpen}
              submitLoading={submitLoading}
              appLiveAvailable={appLiveAvailable}
              globalConfig={globalConfig}
              eventEmitter={eventEmitter}
              meeting={editMeeting}
              preMeetingService={preMeetingService}
              meetingContactsService={contactsService}
              onCancel={() => setScheduleMeetingModalOpen(false)}
              onJoinMeeting={(meetingId) => {
                joinMeeting({
                  meetingNum: meetingId,
                });
              }}
              onCancelMeeting={(cancelRecurringMeeting) => {
                editMeeting &&
                  cancelScheduleMeeting(
                    editMeeting.meetingId,
                    cancelRecurringMeeting,
                  );
              }}
              onSummit={(value) => {
                setSubmitLoading(true);
                createOrEditScheduleMeeting(value);
              }}
            />
            <HistoryMeetingModal
              open={historyMeetingModalOpen}
              onCancel={() => {
                setHistoryMeetingModalOpen(false);
              }}
              meetingContactsService={contactsService}
              preMeetingService={preMeetingService}
              accountId={accountInfo?.userUuid}
              meetingId={historyMeetingId}
              eventEmitter={eventEmitter}
            />
            <UpdateUserNicknameModal
              nickname={accountInfo?.nickname}
              open={updateUserNicknameModalOpen}
              onCancel={() => setUpdateUserNicknameModalOpen(false)}
              onSummit={(value) => {
                setUpdateUserNicknameModalOpen(false);
                accountService
                  ?.updateNickname(value.nickname)
                  .then(() => {
                    Toast.success(i18n.updateUserNicknameSuccess);
                    updateLocalStorageUserInfo({ nickname: value.nickname });
                  })
                  .catch(() => {
                    Toast.fail(i18n.updateUserNicknameFail);
                  });
              }}
            />
            <AboutModal
              open={aboutModalOpen}
              onCancel={() => setAboutModalOpen(false)}
            />
          </div>
        </Spin>
      )}
      {inMeeting && window.isElectronNative && (
        <div className="meeting-electron-header-drag-bar">
          <div className="drag-region" />
          {document.title}
          <PCTopButtons />
        </div>
      )}
      {contextHolder}
      <div
        id="ne-web-meeting"
        style={
          window.isElectronNative
            ? {
                position: 'absolute',
                top: 28,
                left: 0,
                right: 0,
                width: '100%',
                height: 'calc(100% - 28px)',
                display: inMeeting ? 'block' : 'none',
              }
            : {
                width: '100%',
                height: '100%',
                display: inMeeting ? 'block' : 'none',
              }
        }
      />
      {privateConfig?.module?.nps.enabled !== false && (
        <NPSModal
          visible={npsModalOpen}
          meetingId={meetingId}
          nickname={accountInfo?.nickname || ''}
          appKey={appKey}
          onClose={() => setNpsModalOpen(false)}
        />
      )}

      <NotificationListModal
        sessionId={currentMeetingInfoRef.current.sessionId}
        open={notificationListModalOpen}
        onCancel={() => setNotificationListModalOpen(false)}
        meetingMessageChannelService={MeetingKitInstance.getMeetingMessageChannelService()}
        onClick={handleNotificationClick}
      />
      <MeetingNotification
        onClick={onNotificationClickHandler}
        beforeMeeting={true}
        beforeMeetingJoin={joinRoomByInvite}
        notification={notificationApi}
        customMessage={customMessage || undefined}
        meetingInviteService={meetingInviteService}
        onNotificationCardWinOpen={onNotificationCardWinOpen}
      />
      <ImageCropModal
        image={imageCropValueRef.current}
        open={imageCropModalOpen}
        accountService={accountService}
        onCancel={() => setImageCropModalOpen(false)}
        onUpdate={() => {
          setImageCropModalOpen(false);
          Toast.success(t('settingAvatarUpdateSuccess'));
        }}
      />
      <InviteScheduleMeetingModal
        visible={inviteScheduleMeetingModalOpen}
        onClose={() => {
          setInviteScheduleMeetingModalOpen(false);
          setCurrentScheduleMeetingInfo(undefined);
        }}
        meetingInfo={currentScheduleMeetingInfo}
      />

      {!window.isElectronNative && (
        <UnSupportBrowserModal
          visible={unSupportBrowserModalOpen}
          onClose={() => setUnSupportBrowserModalOpen(false)}
        />
      )}

      {showLoading && (
        <p className="nemeeting-feedback-loading-text">
          {i18n.uploadLoadingText}
        </p>
      )}
    </>
  );
};

export default BeforeMeetingHome;
