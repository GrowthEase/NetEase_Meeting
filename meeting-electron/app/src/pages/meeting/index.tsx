import { useEffect, useMemo, useRef, useState } from 'react';
import NEMeetingKit from '../../../../src/index';
import {
  DOMAIN_SERVER,
  LOCALSTORAGE_USER_INFO,
  MEETING_ENV,
} from '../../config';
import { MeetingSetting } from '../../../../src/types';
import FeedbackImg from '../../../../src/assets/feedback.png';
import LightFeedbackImg from '../../../../src/assets/light-feedback.png';
import Feedback from '../../../../src/components/web/Feedback';
import eleIpc from '../../../../src/services/electron/index';
import '../index.less';
import { IPCEvent } from '../../types';
import { history, useLocation } from 'umi';
import { useTranslation } from 'react-i18next';
import Toast from '../../../../src/components/common/toast';
import { LOCAL_STORAGE_KEY } from '../../../../src/config';

let appKey = '';
const platform = window.isElectronNative ? 'electron' : 'web';

export default function MeetingPage() {
  const { t, i18n: i18next } = useTranslation();

  const i18n = {
    feedback: t('feedback'),
    password: t('meetingPassword'),
    passwordPlaceholder: t('inputMeetingPassword'),
    passwordError: t('wrongPassword'),
    uploadLogLoading: t('uploadLoadingText'),
  };

  const [inMeeting, setInMeeting] = useState(false);
  const [loginLoading, setLoginLoading] = useState(true);
  const [appName, setAppName] = useState<string>('');
  const accountInfoRef = useRef<any>();
  const [feedbackModalOpen, setFeedbackModalOpen] = useState(false);
  const [meetingId, setMeetingId] = useState<string>('');
  const joinTypeRef = useRef<'create' | 'join'>('create');
  const passwordRef = useRef<string>('');
  const settingRef = useRef<MeetingSetting | null>(null);
  const queryRef = useRef({
    joinType: 'create',
    meetingNum: '',
    password: '',
    openCamera: false,
    openMic: false,
    nickName: '',
    avatar: '',
  });
  const eleIpcIns = useMemo(() => eleIpc.getInstance(), []);
  const { search } = useLocation();
  const [showUploadLogLoading, setShowUploadLogLoading] = useState(false);
  const [systemAndManufacturer, setSystemAndManufacturer] = useState<{
    manufacturer: string;
    version: string;
    model: string;
  }>();
  useEffect(() => {
    // function mouseLeaveHandler(e: any) {
    //   // 表示从顶部离开
    //   if (e.clientY < 5) {
    //     eleIpcIns?.sendMessage(IPCEvent.mouseLeave);
    //   }
    // }
    // function mouseEnterHandler() {
    //   eleIpcIns?.sendMessage(IPCEvent.mouseEnter);
    // }
    // document.addEventListener('mouseleave', mouseLeaveHandler);
    // // 监听鼠标移入
    // document.addEventListener('mouseenter', mouseEnterHandler);
    const params = new URLSearchParams(window.location.search || search);
    const meetingNum = params.get('meetingNum');
    const joinType = params.get('joinType');
    const password = params.get('password');
    // const query = qs.parse(location.hash)
    queryRef.current = {
      joinType: (joinType as 'create' | 'join') || 'create',
      meetingNum: meetingNum || '',
      password: password || '',
      openCamera: params.get('openCamera') == '1',
      openMic: params.get('openMic') == '1',
      nickName: params.get('nickName') || '',
      avatar: params.get('avatar') || '',
    };
    console.log('query>>>>', queryRef.current, params.get('nickName'));
    // const {joinType, meetingNum} = query
    if (!meetingNum) {
      joinTypeRef.current = 'create';
    } else {
      joinTypeRef.current = (joinType as 'create' | 'join') || 'create';
    }
    init();
    return () => {
      // document.removeEventListener('mouseleave', mouseLeaveHandler);
    };
  }, []);

  useEffect(() => {
    window.ipcRenderer?.invoke('get-system-manufacturer').then((res) => {
      setSystemAndManufacturer(res);
    });
  }, []);

  function init() {
    setLoginLoading(true);

    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);
    if (userString) {
      const user = JSON.parse(userString);
      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId;
        const setting = localStorage.getItem('ne-meeting-setting');
        if (setting) {
          try {
            settingRef.current = JSON.parse(setting) as MeetingSetting;
          } catch (error) {}
        }
        const config = {
          appKey, //云信服务appkey
          meetingServerDomain: DOMAIN_SERVER, //会议服务器地址，支持私有化部署
        };
        console.log('init config ', config);
        if (NEMeetingKit.actions.isInitialized) {
          login(user.userUuid, user.userToken);
          return;
        }
        NEMeetingKit.actions.init(0, 0, config, () => {
          login(user.userUuid, user.userToken);
        }); // （width，height）单位px 建议比例4:3
        //@ts-ignore
        NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
          // 密码输入框点击取消
          if (status === 3 || status === 2) {
            eleIpcIns?.sendMessage('beforeEnterRoom');
          } else if (status === 8) {
            // 到等候室
            setFeedbackModalOpen(false);
          }
        });
        NEMeetingKit.actions.on('roomEnded', (reason: any) => {
          localStorage.removeItem('ne-meeting-current-info');
          eleIpcIns?.sendMessage(IPCEvent.quiteFullscreen);
          setTimeout(() => {
            setInMeeting(false);
            if (eleIpcIns) {
              eleIpcIns.sendMessage('beforeEnterRoom');
              window.ipcRenderer?.send(IPCEvent.needOpenNPS);
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
    } else {
      logout();
      return;
    }
  }
  function logout() {
    // todo 关闭页面
    eleIpcIns?.sendMessage('beforeEnterRoom');
  }

  function login(account: string, token: string) {
    NEMeetingKit.actions.login(
      {
        // 登陆
        accountId: account,
        accountToken: token,
      },
      function (e: any) {
        if (!e) {
          console.log(
            'login success',
            //@ts-ignore
            NEMeetingKit.actions.accountInfo.meetingNum,
          );
          setLoginLoading(false);
          accountInfoRef.current = {
            //@ts-ignore
            ...NEMeetingKit.actions.accountInfo,
            account: account,
          };
          switch (joinTypeRef.current) {
            case 'create':
              createMeeting();
              break;
            case 'join':
              joinMeeting();
              break;
          }
        } else {
          Toast.fail(e.msg || e.message || e.code);
          console.error('login fail appKey ', e, {
            // 登陆
            accountId: account,
            accountToken: token,
          });
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

  function createMeeting() {
    console.log('inMeeting', i18n);
    const video =
      queryRef.current.openCamera || settingRef.current?.normalSetting.openVideo
        ? 1
        : 2;
    const audio =
      queryRef.current.openMic || settingRef.current?.normalSetting.openAudio
        ? 1
        : 2;
    NEMeetingKit.actions.create(
      {
        meetingNum: queryRef.current.meetingNum || '',
        password: queryRef.current.password,
        nickName: queryRef.current.nickName || accountInfoRef.current.nickname,
        avatar: queryRef.current.avatar || '',
        video,
        audio,
        showSpeaker: settingRef.current?.normalSetting.showSpeakerList,
        enableUnmuteBySpace:
          settingRef.current?.audioSetting.enableUnmuteBySpace,
        meetingIdDisplayOption: 0,
        enableFixedToolbar: settingRef.current?.normalSetting.showToolbar,
        enableVideoMirror:
          settingRef.current?.videoSetting.enableVideoMirroring,
        showDurationTime: settingRef.current?.normalSetting.showDurationTime,
        showMeetingRemainingTip: true,
        showCloudRecordingUI: MEETING_ENV !== 'production',
        watermarkConfig: {
          name: accountInfoRef.current.nickname,
        },
        moreBarList: [
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
              setFeedbackModalOpen(true);
            },
          },
        ],
        env: platform,
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
    // @ts-ignore
    const accountInfo = accountInfoRef.current;
    if (!store[accountInfo?.account]) {
      store[accountInfo?.account] = [res];
    } else {
      store[accountInfo?.account] = [
        res,
        ...store[accountInfo?.account].filter(
          (item: any) => item.meetingNum !== meetingNum,
        ),
      ].slice(0, 10);
    }
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(store));
  }
  function joinHandler(e: any) {
    if (!e) {
      //  缓存会议信息，用与解决异常退出重新进入
      function storeMeetingInfo() {
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
      }
      window.ipcRenderer?.send(IPCEvent.setNPS, queryRef.current.meetingNum);
      setInterval(() => {
        // 1分钟存储一次
        storeMeetingInfo();
      }, 1000 * 60);
      storeMeetingInfo();
      // eleIpcIns?.sendMessage('enterRoom')
      setInMeeting(true);
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
    setShowUploadLogLoading(isLoading);
    if (isLoading) {
      Toast.info(i18n.uploadLogLoading, 2000);
    }
  }

  function joinMeeting() {
    const video =
      queryRef.current.openCamera || settingRef.current?.normalSetting.openVideo
        ? 1
        : 2;
    const audio =
      queryRef.current.openMic || settingRef.current?.normalSetting.openAudio
        ? 1
        : 2;
    return new Promise((resolve, reject) => {
      NEMeetingKit.actions.join(
        {
          meetingNum: queryRef.current.meetingNum,
          showCloudRecordingUI: MEETING_ENV !== 'production',
          password: queryRef.current.password,
          avatar: queryRef.current.avatar || '',
          nickName:
            queryRef.current.nickName || accountInfoRef.current.nickname,
          enableVideoMirror:
            settingRef.current?.videoSetting.enableVideoMirroring,
          video,
          audio,
          showSpeaker: settingRef.current?.normalSetting.showSpeakerList,
          enableUnmuteBySpace:
            settingRef.current?.audioSetting.enableUnmuteBySpace,
          showDurationTime: settingRef.current?.normalSetting.showDurationTime,
          env: platform,
          showMeetingRemainingTip: true,
          watermarkConfig: {
            name: accountInfoRef.current.nickname,
          },
          moreBarList: [
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
                setFeedbackModalOpen(true);
              },
            },
          ],
        },
        function (e: any) {
          if (!e) {
            setLocalRecentMeetingList(queryRef.current.meetingNum);
          }
          joinHandler(e);
        },
      );
    });
  }

  useEffect(() => {
    NEMeetingKit.actions.neMeeting?.updateMeetingInfo({
      moreBarList: [
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
            setFeedbackModalOpen(true);
          },
        },
      ],
    });
    NEMeetingKit.actions.neMeeting?.switchLanguage(
      // @ts-ignore
      i18next.language || navigator.language,
    );
  }, [t]);

  return (
    <>
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
      <Feedback
        visible={feedbackModalOpen}
        meetingId={meetingId}
        nickname={accountInfoRef.current?.nickname}
        appKey={appKey}
        inMeeting={true}
        onClose={() => setFeedbackModalOpen(false)}
        neMeeting={NEMeetingKit}
        loadingChange={handleFeedback}
        systemAndManufacturer={systemAndManufacturer}
      />
      {/* {showUploadLogLoading && (
        <p className="nemeeting-feedback-loading-text">
          {i18n.uploadLogLoading}
        </p>
      )} */}
    </>
  );
}
