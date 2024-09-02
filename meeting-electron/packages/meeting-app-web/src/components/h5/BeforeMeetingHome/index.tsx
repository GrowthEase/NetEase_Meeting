import React, { useCallback, useEffect, useRef, useState } from 'react';
import { Button, Input, Switch } from 'antd';
import { useTranslation } from 'react-i18next';

import NEMeetingKit from '@meeting-module/index';
import { setLocalStorageSetting } from '@meeting-module/utils';
import './index.less';

import { LOCALSTORAGE_USER_INFO, NOT_FIRST_LOGIN } from '../../../config';

import { NECommonError, NEPreviewController } from 'neroom-types';
import qs from 'qs';
import { IPCEvent } from '../../../types';
import {
  CreateMeetingResponse,
  EventType,
  JoinOptions,
  MeetingSetting,
} from '@meeting-module/types';
import { NEMeetingStatus } from '@meeting-module/types/type';
import UserAvatar from '@meeting-module/components/common/Avatar';
import Modal from '@meeting-module/components/common/Modal';
import Toast from '@meeting-module/components/common/toast';
import { ActionSheet } from 'antd-mobile/es';
import { Action } from 'antd-mobile/es/components/action-sheet';
import Dialog from '@meeting-module/components/h5/ui/dialog';
import { errorCodeMap } from '@meeting-module/config';
import { AccountInfo, getLocalStorageSetting } from 'nemeeting-web-sdk';
import browserPng from '../../../assets/browser.png';
import { checkSystemRequirements } from '@/components/web/BeforeMeetingHome/neMeetingKit';

const domain = process.env.MEETING_DOMAIN;

interface BeforeMeetingHomeProps {
  onLogout: () => void;
}

let appKey = '';

const BeforeMeetingHome: React.FC<BeforeMeetingHomeProps> = ({ onLogout }) => {
  const [accountInfo, setAccountInfo] = useState<
    AccountInfo & {
      account: string;
      phoneNumber: string;
      email: string;
    }
  >();
  const [inMeeting, setInMeeting] = useState(false);
  const isLogin = useRef<boolean>(false);
  const [previewController, setPreviewController] =
    useState<NEPreviewController>();
  const videoPreviewRef = useRef<HTMLDivElement>(null);
  const [setting, setSetting] = useState<MeetingSetting | null>(null);
  const [openVideo, setOpenVideo] = useState<boolean>(false);
  const [openAudio, setOpenAudio] = useState<boolean>(false);
  const cameraId = '';
  const micId = '';
  const speakerId = '';
  const [submitLoading, setSubmitLoading] = useState(false);
  const [meetingNum, setMeetingNum] = useState<string>('');
  const passwordRef = React.useRef<string>('');
  const [logoutSheetVisible, setLogoutSheetVisible] = useState(false);
  const [logoutDialogVisible, setLogoutDialogVisible] = useState(false);
  const [showCrossAppForbiddenDialog, setShowCrossAppForbiddenDialog] =
    useState(false);
  const [showCrossAppDialog, setShowCrossAppDialog] = useState(false);

  const guestInfoRef = useRef({
    meetingUserUuid: '',
    meetingUserToken: '',
    meetingAuthType: '',
    guestJoinType: '',
    meetingAppKey: '',
  });

  const isGuestJoinRef = useRef(false);

  const { t, i18n: i18next } = useTranslation();

  const i18n = {
    appTitle: t('appTitle'),
    immediateMeeting: t('immediateMeeting'),
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
    openMicInMeeting: t('openMicInMeeting'),
    openCameraInMeeting: t('openCameraInMeeting'),
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
    mic: t('microphone'),
    camera: t('camera'),
    inputPlaceholder: t('meetingIDInputPlaceholder'),
  };

  const logoutActions: Action[] = [
    {
      text: t('logout'),
      danger: true,
      key: 'logout',
      onClick: async () => {
        setLogoutDialogVisible(true);
      },
    },
    {
      text: <div style={{ color: '#007AFF' }}>{i18n.cancel}</div>,
      key: 'cancel',
      onClick: () => {
        setLogoutSheetVisible(false);
      },
    },
  ];

  function init(cb, crossAppKey?: string) {
    const config = {
      appKey: crossAppKey || appKey, //云信服务appkey
      meetingServerDomain: domain, //会议服务器地址，支持私有化部署
      locale: i18next.language, //语言
    };

    console.log('init config ', config);
    if (NEMeetingKit.actions.isInitialized) {
      cb();
      return;
    }

    NEMeetingKit.actions.init(0, 0, config, cb); // （width，height）单位px 建议比例4:3
    NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
      if (status === NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM) {
        // 到等候室
        // setFeedbackModalOpen(false)
      } else if (status === NEMeetingStatus.MEETING_STATUS_FAILED) {
        setInMeeting(false);
      }
    });
    NEMeetingKit.actions.on('roomEnded', () => {
      setInMeeting(false);
      setTimeout(() => {
        window.location.reload();
      });
    });
  }

  // 登录
  function login(account, token) {
    init((e) => {
      if (!e) {
        const previewController = NEMeetingKit.actions.neMeeting
          ?.previewController as NEPreviewController;

        setPreviewController(previewController);
        NEMeetingKit.actions.login(
          {
            // 登陆
            accountId: account,
            accountToken: token,
          },
          function (e) {
            const error = e as unknown as {
              code: string;
            };

            if (!error) {
              isLogin.current = true;

              setAccountInfo({
                ...NEMeetingKit.actions.accountInfo,
                account: account,
              });

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveScheduledMeetingUpdate,
                (res) => {
                  console.log('收到房间状态变更', res);
                  // 账号受到限制
                  if (res.data?.type === 200) {
                    Toast.warning('tokenExpired', 3000);
                    setTimeout(() => {
                      logout();
                    }, 1000);
                  }
                },
              );

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveAccountInfoUpdate,
                (res) => {
                  console.log('收到账号信息变更', res);
                  setAccountInfo((prev) => {
                    return {
                      ...prev,
                      ...res.meetingAccountInfo,
                    };
                  });
                },
              );

              NEMeetingKit.actions.neMeeting?.getAppInfo().then((res) => {
                console.log('getAppInfo', res);
              });
              NEMeetingKit.actions.neMeeting?.getAppTips();
              NEMeetingKit.actions.neMeeting?.getAppConfig().then((res) => {
                console.log('getAppConfig', res);
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
              if (currentMeetingStr) {
                const currentMeeting = JSON.parse(currentMeetingStr);

                // 15分钟内恢复会议
                if (currentMeeting.time > Date.now() - 1000 * 60 * 15) {
                  Modal.confirm({
                    title: 'hint',
                    content: 'restoreMeetingTips',
                    okText: 'restore',
                    onCancel: () => {
                      localStorage.removeItem('ne-meeting-current-info');
                    },
                    onOk: () => {
                      try {
                        const currentMeeting = JSON.parse(currentMeetingStr);

                        currentMeeting.joinType = 'join';
                        window.ipcRenderer?.send(
                          IPCEvent.enterRoom,
                          currentMeeting,
                        );
                      } catch (error) {
                        console.error('restore meeting error', error);
                      }

                      localStorage.removeItem('ne-meeting-current-info');
                    },
                  });
                } else {
                  localStorage.removeItem('ne-meeting-current-info');
                }
              }

              NEMeetingKit.actions.neMeeting?.getGlobalConfig();
            } else {
              console.error('login fail appKey ', e, {
                // 登陆
                accountId: account,
                accountToken: token,
              });
              isLogin.current = false;
              // 非网络错误才离开
              if (error.code !== 'ERR_NETWORK') {
                logout();
              }
            }
          },
        );
      }
    });
  }

  //退出登录
  function logout() {
    onLogout();
    isLogin.current = false;
    NEMeetingKit?.actions?.destroy();
  }

  function onSettingChange(setting: MeetingSetting) {
    setSetting(setting);
    setLocalStorageSetting(JSON.stringify(setting));
  }

  function onHandleSettingChange({
    openAudio,
    openVideo,
    speakerId,
    micId,
    cameraId,
  }: {
    openAudio: boolean;
    openVideo: boolean;
    speakerId: string;
    micId: string;
    cameraId: string;
  }) {
    setting &&
      onSettingChange &&
      onSettingChange({
        ...setting,
        normalSetting: {
          ...setting.normalSetting,
          openAudio,
          openVideo,
        },
        audioSetting: {
          ...setting.audioSetting,
          playoutDeviceId: speakerId,
          recordDeviceId: micId,
        },
        videoSetting: {
          ...setting.videoSetting,
          deviceId: cameraId,
        },
      });
  }

  async function joinMeeting(options: JoinOptions, type: 'guestJoin' | 'join') {
    setSubmitLoading(true);
    await NEMeetingKit.actions.neMeeting
      ?.getMeetingInfoByFetch(options.meetingNum)
      .catch((e) => {
        console.error('join failed', options.meetingNum, e);
        // 非密码错误
        if (e?.code != 1020) {
          setSubmitLoading(false);
          Toast.fail(e.message || e.msg || e.code);
          throw e;
        }
      });
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
        NEMeetingKit.actions.join(
          {
            ...options,
            showCloudRecordingUI: true,
            showMeetingRemainingTip: true,
            env: 'web',
            watermarkConfig: {
              name: accountInfo?.nickname,
              phone: accountInfo?.phoneNumber || '',
              email: accountInfo?.email || '',
            },
          },
          function (e) {
            if (e) {
              reject(e);
            }

            resolve();
          },
        );
      });
    }

    let modal;

    return fetchJoin(options)
      .then(() => {
        setInMeeting(true);
        setMeetingNum('');
        isGuestJoinRef.current = type === 'guestJoin';
      })
      .catch((e) => {
        console.log('join failed', e);
        if (e?.code === 1019) {
          Toast.info(t('meetingLocked'));
          throw e;
        }

        const InputComponent = (inputValue) => {
          return (
            <Input
              placeholder={i18n.passwordPlaceholder}
              value={inputValue}
              maxLength={6}
              allowClear
              onChange={(event) => {
                passwordRef.current = event.target.value.replace(/[^0-9]/g, '');
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
                } else if (e.code === 3102) {
                  modal.destroy();
                }

                throw e;
              }
            },
          });
        } else {
          throw e;
        }
      })
      .finally(() => {
        setSubmitLoading(false);
      });
  }

  const handleGuestJoin = useCallback(async () => {
    const meetingNumByFormat = meetingNum.replace(/-/g, '').replace(/\s/g, '');

    const {
      meetingAppKey,
      meetingAuthType,
      meetingUserToken,
      meetingUserUuid,
    } = guestInfoRef.current;

    setShowCrossAppDialog(false);
    await NEMeetingKit.actions.neMeeting?.logout();
    NEMeetingKit.actions.destroy();
    init((e) => {
      if (!e) {
        NEMeetingKit.actions.login(
          {
            accountId: meetingUserUuid,
            accountToken: meetingUserToken,
            isTemporary: true,
            authType: meetingAuthType,
          },
          (e) => {
            if (!e) {
              console.log('登录完成, 开始加入');
              joinMeeting(
                {
                  meetingNum: meetingNumByFormat,
                  nickName: accountInfo?.nickname as string,
                  video: openVideo ? 1 : 2,
                  audio: openAudio ? 1 : 2,
                  avatar: accountInfo?.avatar,
                },
                'guestJoin',
              );
            }
          },
        );
      }
    }, meetingAppKey);
  }, [
    openAudio,
    openVideo,
    accountInfo?.nickname,
    accountInfo?.avatar,
    meetingNum,
  ]);

  // 加入会议
  async function onJoinMeeting() {
    if (!checkSystemRequirements()) {
      showUnSupportedBrowserModal();
      return;
    }

    const meetingNumByFormat = meetingNum.replace(/-/g, '').replace(/\s/g, '');

    let info: CreateMeetingResponse | undefined = undefined;
    let isGuestJoin = false;

    try {
      info = await NEMeetingKit.actions.neMeeting?.getMeetingInfoByFetch(
        meetingNumByFormat,
      );
    } catch (error) {
      const e = error as NECommonError;

      if (e.code === 3432) {
        isGuestJoin = true;
        setShowCrossAppForbiddenDialog(true);
      }
    }

    if (info) {
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
        isGuestJoin = true;
        guestInfoRef.current = {
          meetingAppKey,
          meetingAuthType,
          meetingUserToken,
          meetingUserUuid,
          guestJoinType,
        };
        // 不允许访客入会
        if (guestJoinType == '0') {
          setShowCrossAppForbiddenDialog(true);
        } else {
          setShowCrossAppDialog(true);
        }
      }
    }

    if (!isGuestJoin) {
      joinMeeting(
        {
          meetingNum: meetingNumByFormat,
          nickName: accountInfo?.nickname as string,
          video: openVideo ? 1 : 2,
          audio: openAudio ? 1 : 2,
          avatar: accountInfo?.avatar,
        },
        'guestJoin',
      );
    }
  }

  // 处理邀请链接url
  function handleInvitationUrl(url: string) {
    let meetingNum = '';
    const query = qs.parse(url.split('?')[1]?.split('#/')[0]);

    meetingNum = query.meetingId as string;
    if (meetingNum) {
      setMeetingNum(meetingNum);
      delete query.meetingId;
      history.replaceState(
        {},
        '',
        qs.stringify(query, { addQueryPrefix: true }),
      );
    }
  }

  // 浏览器不支持提示
  function showUnSupportedBrowserModal() {
    Modal.warning({
      title: t('unSupportBrowserTitle'),
      content: (
        <div className="h5-un-support-browser-content">
          <div className="h5-un-support-browser-tip">
            {t('unSupportBrowserTip')}
          </div>
          <img className="h5-browser-png" src={browserPng}></img>
        </div>
      ),
      okText: t('gotIt'),
    });
  }

  useEffect(() => {
    if (!checkSystemRequirements()) {
      showUnSupportedBrowserModal();
    }
  }, []);

  useEffect(() => {
    if (isGuestJoinRef.current) {
      return;
    }

    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);

    if (userString) {
      const user = JSON.parse(userString);

      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId;
        setTimeout(() => {
          login(user.userUuid, user.userToken);
        }, 100);
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
  }, [isLogin]);

  useEffect(() => {
    if (previewController && videoPreviewRef.current && openVideo) {
      previewController.setupLocalVideoCanvas(videoPreviewRef.current);
      const timer = setTimeout(() => {
        videoPreviewRef.current &&
          previewController
            .startPreview(videoPreviewRef.current)

            .catch((error: unknown) => {
              const e = error as NECommonError & {
                data: {
                  message: string;
                  name: string;
                };
              };

              setOpenVideo(false);
              if (e?.msg || errorCodeMap[e?.code]) {
                Toast.fail(e?.msg || t(errorCodeMap[e?.code]));
              } else if (
                e.data?.message &&
                (e.data?.message?.includes('Permission denied') ||
                  e.data?.name?.includes('NotAllowedError'))
              ) {
                //@ts-expect-error    权限不足
                Toast.fail(t(errorCodeMap['10212']));
              }
            });
      }, 500);

      return () => {
        clearTimeout(timer);
        previewController.stopPreview();
      };
    }
  }, [openVideo, previewController, t]);

  useEffect(() => {
    if (setting) {
      setOpenAudio(setting.normalSetting.openAudio);
      setOpenVideo(setting.normalSetting.openVideo);
    }
  }, [
    setting?.normalSetting.openVideo,
    setting?.normalSetting.openAudio,
    setting,
  ]);

  useEffect(() => {
    if (location.href) {
      handleInvitationUrl(location.href);
    }
  }, []);

  return (
    <>
      <div
        id="ne-web-meeting"
        style={{
          width: '100%',
          height: '100%',
          display: inMeeting ? 'block' : 'none',
        }}
      ></div>
      {!inMeeting && (
        <div className="ne-meeting-app-h5 before-meeting-home-container">
          <div className="before-meeting-home-header">
            <div
              className="nemeeting-header-avatar"
              onClick={() => {
                setLogoutSheetVisible(true);
              }}
            >
              <UserAvatar
                nickname={accountInfo?.nickname}
                avatar={accountInfo?.avatar}
                size={36}
              ></UserAvatar>
            </div>
            <div className="nemeeting-header-item-title">
              {i18n.joinMeeting}
            </div>
          </div>

          <div className="before-meeting-home-content">
            <div className="before-meeting-home-content-top">
              <div className="before-meeting-home-input">
                <div className="before-meeting-home-input-title">
                  {i18n.meetingId}
                </div>
                <Input
                  placeholder={i18n.inputPlaceholder}
                  value={meetingNum}
                  allowClear
                  onChange={(e) => {
                    if (/^[0-9-]*$/.test(e.target.value)) {
                      setMeetingNum(e.target.value);
                    }
                  }}
                  style={{
                    backgroundColor: '#fff',
                    border: 'none',
                    fontSize: 16,
                  }}
                />
              </div>
              <div className="before-meeting-home-lines">
                <div className="audio-line">
                  <div className="audio-line-title">
                    {i18n.openMicInMeeting}
                  </div>
                  <div className="audio-line-switch">
                    <Switch
                      value={openAudio}
                      onChange={(value) => {
                        onHandleSettingChange({
                          openAudio: value,
                          openVideo,
                          speakerId,
                          micId,
                          cameraId,
                        });
                        setOpenAudio(value);
                      }}
                    />
                  </div>
                </div>
                <div className="video-line">
                  <div className="video-line-title">
                    {i18n.openCameraInMeeting}
                  </div>
                  <div className="video-line-switch">
                    <Switch
                      value={openVideo}
                      onChange={(value) => {
                        onHandleSettingChange({
                          openAudio,
                          openVideo: value,
                          speakerId,
                          micId,
                          cameraId,
                        });
                        setOpenVideo(value);
                      }}
                    />
                  </div>
                </div>
              </div>
            </div>
            <div className="before-meeting-home-foot">
              <Button
                type="primary"
                className="join-meeting-button"
                onClick={onJoinMeeting}
                disabled={!meetingNum}
                loading={submitLoading}
              >
                {i18n.joinMeeting}
              </Button>
            </div>
          </div>

          <ActionSheet
            visible={logoutSheetVisible}
            actions={logoutActions}
            onClose={() => setLogoutSheetVisible(false)}
          />
          <Dialog
            visible={showCrossAppForbiddenDialog}
            width={305}
            confirmText={t('IkonwIt')}
            ifShowCancel={false}
            onConfirm={() => {
              setShowCrossAppForbiddenDialog(false);
            }}
          >
            <div className="nemeting-cross-app-title">
              {t('meetingCrossAppNoPermission')}
            </div>
          </Dialog>
          <Dialog
            visible={showCrossAppDialog}
            width={305}
            confirmText={t('meetingJoin')}
            cancelText={i18n.cancel}
            onConfirm={() => {
              handleGuestJoin();
            }}
            onCancel={() => {
              setShowCrossAppDialog(false);
            }}
          >
            <div className="nemeting-cross-app-title">
              {t('meetingCrossAppJoinTip')}
            </div>
          </Dialog>
          <Dialog
            visible={logoutDialogVisible}
            width={305}
            confirmText={i18n.confirm}
            cancelText={i18n.cancel}
            onConfirm={() => {
              logout();
            }}
            onCancel={() => {
              setLogoutDialogVisible(false);
            }}
          >
            <div className="logout-text">{i18n.logoutConfirm}</div>
          </Dialog>
        </div>
      )}
    </>
  );
};

export default BeforeMeetingHome;
