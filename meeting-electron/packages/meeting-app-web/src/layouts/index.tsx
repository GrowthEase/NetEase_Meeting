import React, { useEffect } from 'react';
import { useTranslation } from 'react-i18next';

import { ConfigProvider } from 'antd';

import enUs from 'antd/locale/en_US';
import jaJP from 'antd/locale/ja_JP';
import zhCN from 'antd/locale/zh_CN';

import 'dayjs/locale/en';
import 'dayjs/locale/ja';
import 'dayjs/locale/zh-cn';

import {
  GlobalContext,
  MeetingInfoContext,
  WaitingRoomContext,
} from '@meeting-module/store';

import useGlobalContextPageContext from '../hooks/useGlobalContextPageContext';
import useMeetingInfoPageContext from '../hooks/useMeetingInfoPageContext';
import useWaitingRoomPageContext from '../hooks/useWaitingRoomPageContext';

import '@meeting-module/locales/i18n';
import globalErrorCatch from '@meeting-module/utils/globalErrorCatch';
import { getLocalStorageSetting } from 'nemeeting-web-sdk';
import { MeetingSetting } from '@meeting-module/kit';

const Layout: React.FC = (props) => {
  const { i18n } = useTranslation();
  const [windowOpen, setWindowOpen] = React.useState(true);
  const {
    meetingInfo,
    memberList,
    inInvitingMemberList,
    dispatch: meetingInfoDispatch,
  } = useMeetingInfoPageContext();
  const {
    waitingRoomInfo,
    memberList: waitingRoomMemberList,
    dispatch: waitingRoomInfoDispatch,
  } = useWaitingRoomPageContext();
  const {
    neMeeting,
    eventEmitter,
    globalConfig,
    interpretationSetting,
    dispatch: globalDispatch,
  } = useGlobalContextPageContext();

  useEffect(() => {
    function changeLanguage(event?: string | null, data?: MeetingSetting) {
      const defaultLanguage =
        {
          zh: 'zh-CN',
          en: 'en-US',
          ja: 'ja-JP',
        }[navigator.language.split('-')[0]] || 'en-US';
      const appLanguage = data?.normalSetting?.language || defaultLanguage;

      // 如果当前语言和应用语言一致，则不需要切换
      if (i18n.language === appLanguage) return;
      i18n.changeLanguage(appLanguage);
    }

    const setting = getLocalStorageSetting();

    if (setting) {
      changeLanguage(null, setting);
    } else {
      changeLanguage();
    }

    window.ipcRenderer?.on('changeSetting', changeLanguage);

    return () => {
      window.ipcRenderer?.removeListener('changeSetting', changeLanguage);
    };
  }, [i18n.language]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event } = e.data;

      // 关闭统一处理页面重置逻辑
      switch (event) {
        case 'windowClosed':
          setWindowOpen(false);
          break;
        default:
          break;
      }
    }

    window.addEventListener('message', handleMessage);

    globalErrorCatch();

    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  // 重置页面处理
  useEffect(() => {
    if (!windowOpen) {
      setWindowOpen(true);
    }
  }, [windowOpen]);

  return (
    <ConfigProvider
      prefixCls="nemeeting"
      locale={
        {
          'zh-CN': zhCN,
          'en-US': enUs,
          'ja-JP': jaJP,
        }[i18n.language]
      }
      theme={{ hashed: false }}
    >
      {windowOpen && (
        <GlobalContext.Provider
          value={{
            neMeeting,
            eventEmitter,
            globalConfig,
            interpretationSetting,
            dispatch: globalDispatch,
          }}
        >
          <MeetingInfoContext.Provider
            value={{
              meetingInfo,
              memberList,
              inInvitingMemberList,
              dispatch: meetingInfoDispatch,
            }}
          >
            <WaitingRoomContext.Provider
              value={{
                waitingRoomInfo,
                memberList: waitingRoomMemberList,
                dispatch: waitingRoomInfoDispatch,
              }}
            >
              <>{props.children}</>
            </WaitingRoomContext.Provider>
          </MeetingInfoContext.Provider>
        </GlobalContext.Provider>
      )}
    </ConfigProvider>
  );
};

export default Layout;
