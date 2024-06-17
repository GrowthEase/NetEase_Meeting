import React, { useEffect, useMemo, useRef, useState } from 'react';
import NEMeetingKit from '../../../../src/index';
import { DOMAIN_SERVER } from '../../config';
import { MeetingSetting } from '../../../../src/types';
import FeedbackImg from '../../../../src/assets/feedback.png';
import LightFeedbackImg from '../../../../src/assets/light-feedback.png';
import Feedback from '../../../../src/components/web/Feedback';
import eleIpc from '../../../../src/services/electron/index';
import '../index.less';
import { IPCEvent } from '../../types';
import { history } from 'umi';
import { useTranslation } from 'react-i18next';
import Toast from '../../../../src/components/common/toast';
import { LOCAL_STORAGE_KEY } from '../../../../src/config';
import { css } from '@emotion/css';
import { parsePrivateConfig } from '../../../../src/utils';
import { NEAccountInfo } from '../../../../src/types/type';
import { openWindow } from '../../../../src/utils/windowsProxy';

let appKey = '';
const platform = window.isElectronNative ? 'electron' : 'web';

export default function MeetingPage() {
  const { t, i18n: i18next } = useTranslation();

  const i18n = {
    feedback: t('feedback'),
    password: t('meetingPassword'),
    uploadLogLoading: t('uploadLoadingText'),
  };

  const accountInfoRef = useRef<NEAccountInfo>();
  const [feedbackModalOpen, setFeedbackModalOpen] = useState(false);
  const [meetingId, setMeetingId] = useState<string>('');
  const joinTypeRef = useRef<string>('create');
  const settingRef = useRef<MeetingSetting | null>(null);
  const queryRef = useRef({
    meetingServerDomain: '',
    appKey: '',
    userUuid: '',
    userToken: '',
    userName: '',
    userPassword: '',
    joinType: 'create',
    meetingNum: '',
    password: '',
    openCamera: 1 | 2,
    openMic: 1 | 2,
    nickName: '',
    avatar: '',
  });
  const eleIpcIns = useMemo(() => eleIpc.getInstance(), []);
  const [systemAndManufacturer, setSystemAndManufacturer] = useState<{
    manufacturer: string;
    version: string;
    model: string;
  }>();

  useEffect(() => {
    window.ipcRenderer?.on(IPCEvent.openMeeting, (_, data) => {
      queryRef.current = data;
      joinTypeRef.current = data.joinType;
      console.log('open-meeting', data);
      init();
    });
  }, []);

  useEffect(() => {
    window.ipcRenderer?.invoke(IPCEvent.getSystemManufacturer).then((res) => {
      setSystemAndManufacturer(res);
    });
  }, []);

  async function init() {
    const user = queryRef.current;

    if (user.appKey) {
      appKey = user.appKey;
      const setting = localStorage.getItem('ne-meeting-setting');

      if (setting) {
        try {
          settingRef.current = JSON.parse(setting) as MeetingSetting;
        } catch (error) {
          console.error('parse setting error', error);
        }
      }

      let config = {
        appKey, //云信服务appkey
        meetingServerDomain: user.meetingServerDomain || DOMAIN_SERVER, //会议服务器地址，支持私有化部署
        locale: settingRef.current?.normalSetting.language, //语言
      };

      console.log('init config ', config);
      if (NEMeetingKit.actions.isInitialized) {
        if (user.joinType === 'anonymousJoin') {
          joinMeeting('anonymousJoin');
        } else {
          if (user.userUuid && user.userToken) {
            login(user.userUuid, user.userToken);
          }

          if (user.userName && user.userPassword) {
            loginWithPassword(user.userName, user.userPassword);
          }
        }

        return;
      }

      let privateConfig: any = null;

      if (window.isElectronNative) {
        try {
          privateConfig = await window.ipcRenderer?.invoke(
            IPCEvent.getPrivateConfig,
          );
          privateConfig = parsePrivateConfig(privateConfig);
        } catch (error) {
          console.log('getPrivateConfig failed: ', error);
        }
      }

      if (privateConfig) {
        privateConfig.meetingServerDomain &&
          (config.meetingServerDomain = privateConfig.meetingServerDomain);
        privateConfig.appKey && (config.appKey = privateConfig.appKey);
        config = { ...config, ...privateConfig };
      }

      NEMeetingKit.actions.init(0, 0, config, () => {
        if (user.joinType === 'anonymousJoin') {
          joinMeeting('anonymousJoin');
        } else {
          if (user.userUuid && user.userToken) {
            login(user.userUuid, user.userToken);
          }

          if (user.userName && user.userPassword) {
            loginWithPassword(user.userName, user.userPassword);
          }
        }
      }); // （width，height）单位px 建议比例4:3
      //@ts-ignore
      NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
        // 密码输入框点击取消
        if (status === 3 || status === 2) {
          setTimeout(() => {
            eleIpcIns?.sendMessage('beforeEnterRoom');
          }, 1000);
        } else if (status === 8) {
          // 到等候室
          setFeedbackModalOpen(false);
        }
      });
      NEMeetingKit.actions.on('roomEnded', (reason: any) => {
        localStorage.removeItem('ne-meeting-current-info');
        eleIpcIns?.sendMessage(IPCEvent.quiteFullscreen);
        setTimeout(() => {
          if (eleIpcIns) {
            setTimeout(() => {
              eleIpcIns.sendMessage('beforeEnterRoom');
              window.ipcRenderer?.send(IPCEvent.needOpenNPS);
            }, 1000);
          } else {
            history.push('/');
          }

          console.log('房间被关闭', reason);
        }, 1000);
      });
    } else {
      logout();
      return;
    }
  }

  function logout() {
    // todo 关闭页面
    eleIpcIns?.sendMessage('beforeEnterRoom');
  }

  function loginWithPassword(username: string, password: string) {
    console.log('loginWithPassword', username, password);
    NEMeetingKit.actions.loginWithPassword(
      {
        // 登陆
        username,
        password,
      },
      function (e: any) {
        if (!e) {
          accountInfoRef.current = {
            //@ts-ignore
            ...NEMeetingKit.actions.accountInfo,
          };
          switch (joinTypeRef.current) {
            case 'create':
              createMeeting();
              break;
            case 'join':
              joinMeeting('join');
              break;
            case 'joinByInvite':
              joinMeeting('joinByInvite');
              break;
            case 'anonymousJoin':
              joinMeeting('anonymousJoin');
              break;
          }
        } else {
          Toast.fail(e.msg || e.message || e.code);
          setTimeout(() => {
            logout();
          }, 1000);
        }
      },
    );
  }

  function login(accountId: string, token: string) {
    NEMeetingKit.actions.login(
      {
        // 登陆
        accountId: accountId,
        accountToken: token,
      },
      function (e: any) {
        if (!e) {
          accountInfoRef.current = {
            //@ts-ignore
            ...NEMeetingKit.actions.accountInfo,
            userUuid: accountId,
          };
          switch (joinTypeRef.current) {
            case 'create':
              createMeeting();
              break;
            case 'join':
              joinMeeting('join');
              break;
            case 'joinByInvite':
              joinMeeting('joinByInvite');
              break;
          }
        } else {
          Toast.fail(e.msg || e.message || e.code);
          setTimeout(() => {
            logout();
          }, 1000);
          // 非网络错误才离开
          // if (e.code !== 'ERR_NETWORK') {
          //   logout();
          // }
        }
      },
    );
  }

  function openFeedback(id?: string) {
    if (window.isElectronNative) {
      const feedbackWindow = openWindow('feedbackWindow');
      const feedbackWindowOpenData = {
        event: 'setFeedbackData',
        payload: {
          meetingId: id,
          nickname: accountInfoRef.current?.nickname,
          appKey: appKey,
          systemAndManufacturer: systemAndManufacturer,
        },
      };

      if (feedbackWindow?.firstOpen === false) {
        feedbackWindow.postMessage(
          feedbackWindowOpenData,
          feedbackWindow.origin,
        );
      } else {
        feedbackWindow?.addEventListener('load', () => {
          feedbackWindow?.postMessage(
            feedbackWindowOpenData,
            feedbackWindow.origin,
          );
        });
      }

      const messageListener = (e) => {
        const { event, payload } = e.data;
        const neMeeting = NEMeetingKit.actions.neMeeting;

        if (event === 'neMeeting' && neMeeting) {
          const { replyKey, fnKey, args } = payload;

          // @ts-ignore
          neMeeting[fnKey]?.(...args)
            .then((res: unknown) => {
              feedbackWindow?.postMessage(
                {
                  event: replyKey,
                  payload: {
                    result: res,
                    error: null,
                  },
                },
                feedbackWindow.origin,
              );
            })
            .catch((error: unknown) => {
              feedbackWindow?.postMessage(
                {
                  event: replyKey,
                  payload: {
                    error,
                  },
                },
                feedbackWindow.origin,
              );
            });
        } else if (event === 'onFeedbackSuccess') {
          Toast.success(t('thankYourFeedback'));
        } else if (event === 'onFeedbackUpload') {
          handleFeedback(payload.value);
        }
      };

      feedbackWindow?.removeEventListener('message', messageListener);
      feedbackWindow?.addEventListener('message', messageListener);
    } else {
      setFeedbackModalOpen(true);
    }
  }

  function createMeeting() {
    NEMeetingKit.actions.create(
      {
        video: queryRef.current?.openCamera,
        audio: queryRef.current?.openMic,
        showSpeaker: settingRef.current?.normalSetting.showSpeakerList,
        enableUnmuteBySpace:
          settingRef.current?.audioSetting.enableUnmuteBySpace,
        meetingIdDisplayOption: 0,
        enableFixedToolbar: settingRef.current?.normalSetting.showToolbar,
        enableVideoMirror:
          settingRef.current?.videoSetting.enableVideoMirroring,
        showDurationTime: settingRef.current?.normalSetting.showDurationTime,
        showMeetingRemainingTip: true,
        showCloudRecordingUI: true,
        watermarkConfig: {
          name: accountInfoRef.current?.nickname || '',
        },
        noSip: false,
        moreBarList: [
          { id: 29 },
          { id: 30 },
          { id: 25 },
          {
            id: 1000,
            btnConfig: {
              icon: FeedbackImg,
              lightIcon: LightFeedbackImg,
              text: t('feedback'),
            },
            type: 'single',
            injectItemClick: () => {
              setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId);
              openFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId);
            },
          },
          { id: 31 },
        ],
        env: platform,
        ...queryRef.current,
      },
      function (e: any) {
        if (!e) {
          setLocalRecentMeetingList(
            NEMeetingKit.actions.NEMeetingInfo.meetingNum,
          );
        }

        joinHandler(e);
      },
    );
  }

  async function setLocalRecentMeetingList(meetingNum: string) {
    const res = await NEMeetingKit.actions.neMeeting?.getMeetingInfoByFetch(
      meetingNum,
    );
    const store = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) || '{}');
    const accountInfo = accountInfoRef.current;
    const key = accountInfo?.account || accountInfo?.userUuid;

    if (key) {
      if (!store[key]) {
        store[key] = [res];
      } else {
        store[key] = [
          res,
          ...store[key].filter((item: any) => item.meetingNum !== meetingNum),
        ].slice(0, 10);
      }

      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(store));
    }
  }

  function joinHandler(e: any) {
    const storeMeetingInfo = () => {
      queryRef.current.meetingNum =
        NEMeetingKit.actions.NEMeetingInfo.meetingNum;
      const currentInfo = {
        ...queryRef.current,
        time: new Date().getTime(),
      };

      localStorage.setItem(
        'ne-meeting-current-info',
        JSON.stringify(currentInfo),
      );
    };

    if (!e) {
      //  缓存会议信息，用与解决异常退出重新进入
      window.ipcRenderer?.send(IPCEvent.setNPS, queryRef.current.meetingNum);
      setInterval(() => {
        // 1分钟存储一次
        storeMeetingInfo();
      }, 1000 * 60);
      storeMeetingInfo();
      eleIpcIns?.sendMessage('inMeeting');
    } else {
      console.log('>>>>', e);
      if (e.code === 1020 || e.code === 3100) {
        return;
      }

      console.error(e.msg);
      // 去掉重复“房间已锁定”弹窗
      if (!(e.code === 1019 && window.isElectronNative)) {
        // Toast.fail(e.msg || e.message || e.code);
      }

      setTimeout(() => {
        eleIpcIns?.sendMessage('beforeEnterRoom');
      }, 1500);
    }
  }

  function handleFeedback(isLoading: boolean) {
    if (isLoading) {
      Toast.info(i18n.uploadLogLoading, 2000);
    }
  }

  function joinMeeting(type: string) {
    return new Promise((resolve, reject) => {
      const data: any = {
        video: queryRef.current?.openCamera,
        audio: queryRef.current?.openMic,
        showCloudRecordingUI: true,
        enableVideoMirror:
          settingRef.current?.videoSetting.enableVideoMirroring,
        showSpeaker: settingRef.current?.normalSetting.showSpeakerList,
        enableUnmuteBySpace:
          settingRef.current?.audioSetting.enableUnmuteBySpace,
        showDurationTime: settingRef.current?.normalSetting.showDurationTime,
        env: platform,
        showMeetingRemainingTip: true,
        watermarkConfig: {
          name: accountInfoRef.current?.nickname,
        },
        moreBarList: [
          { id: 29 },
          { id: 30 },
          { id: 25 },
          {
            id: 1000,
            btnConfig: {
              icon: FeedbackImg,
              lightIcon: LightFeedbackImg,
              text: t('feedback'),
            },
            type: 'single',
            injectItemClick: () => {
              setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId);
              openFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId);
            },
          },
          { id: 31 },
        ],
        ...queryRef.current,
      };

      if (type === 'anonymousJoin') {
        NEMeetingKit.actions.anonymousJoinMeeting(data, function (e: any) {
          joinHandler(e);
          if (!e) {
            setLocalRecentMeetingList(queryRef.current.meetingNum);
            resolve(null);
          } else {
            reject(e);
          }
        });
      } else if (type === 'joinByInvite') {
        NEMeetingKit.actions.inviteService
          ?.acceptInvite(data)
          .then(() => {
            setLocalRecentMeetingList(queryRef.current.meetingNum);
            joinHandler(null);
            resolve(null);
          })
          .catch((e) => {
            joinHandler(e);
            reject(e);
          });
      } else {
        NEMeetingKit.actions.join(data, function (e: any) {
          joinHandler(e);
          if (!e) {
            setLocalRecentMeetingList(queryRef.current.meetingNum);
            resolve(null);
          } else {
            reject(e);
          }
        });
      }
    });
  }

  useEffect(() => {
    NEMeetingKit.actions.neMeeting?.updateMeetingInfo({
      moreBarList: [
        { id: 29 },
        { id: 30 },
        { id: 25 },
        {
          id: 1000,
          btnConfig: {
            icon: FeedbackImg,
            lightIcon: LightFeedbackImg,
            text: i18n.feedback,
          },
          type: 'single',
          injectItemClick: () => {
            setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId);
            openFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId);
          },
        },
        { id: 31 },
      ],
    });
    NEMeetingKit.actions.neMeeting?.switchLanguage(
      // @ts-ignore
      i18next.language || navigator.language,
    );
  }, [t]);

  // win32 边框样式问题
  const [isMaximized, setIsMaximized] = useState(false);
  const [isSharingScreen, setIsSharingScreen] = useState(false);

  useEffect(() => {
    function handleMaximizeWindow(_: any, value: boolean) {
      setIsMaximized(value);
    }

    NEMeetingKit.actions.on('onScreenSharingStatusChange', setIsSharingScreen);
    window.ipcRenderer?.on(IPCEvent.maximizeWindow, handleMaximizeWindow);
    window.ipcRenderer?.on(IPCEvent.openMeetingFeedback, () => {
      openFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId);
    });
    return () => {
      window.ipcRenderer?.off(IPCEvent.maximizeWindow, handleMaximizeWindow);
    };
  }, []);

  const winCls =
    window.isElectronNative &&
    window.isWins32 &&
    !isMaximized &&
    !isSharingScreen
      ? css`
          width: calc(100% - 4px);
          height: calc(100% - 4px);
          margin: 2px;
          #ne-web-meeting {
            box-shadow: 0px 0px 3px rgba(0, 0, 0, 0.5);
          }
        `
      : css`
          width: 100%;
          height: 100%;
        `;

  return (
    <>
      <div className={winCls}>
        <div
          id="ne-web-meeting"
          style={
            !!eleIpcIns && !window.isElectronNative
              ? {
                  position: 'absolute',
                  top: 28,
                  left: 0,
                  right: 0,
                  width: '100%',
                  height: 'calc(100% - 28px)',
                }
              : {
                  width: '100%',
                  height: '100%',
                }
          }
        ></div>
      </div>
      <Feedback
        visible={feedbackModalOpen}
        meetingId={meetingId}
        nickname={accountInfoRef.current?.nickname || ''}
        appKey={appKey}
        inMeeting={true}
        onClose={() => setFeedbackModalOpen(false)}
        neMeeting={NEMeetingKit.actions.neMeeting}
        loadingChange={handleFeedback}
        systemAndManufacturer={systemAndManufacturer}
      />
    </>
  );
}
