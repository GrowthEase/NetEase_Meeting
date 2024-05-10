import React, { useEffect, useMemo } from 'react';
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
} from '../../../src/store';

import useGlobalContextPageContext from '../hooks/useGlobalContextPageContext';
import useMeetingInfoPageContext from '../hooks/useMeetingInfoPageContext';
import useWaitingRoomPageContext from '../hooks/useWaitingRoomPageContext';

import '../../../src/locales/i18n';

const Layout: React.FC = (props) => {
  const hash = window.location.hash;
  const { i18n, t } = useTranslation();
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
  } = useGlobalContextPageContext();

  useEffect(() => {
    function changeLanguage(event?: any, data?: any) {
      const defaultLanguage =
        {
          zh: 'zh-CN',
          en: 'en-US',
          ja: 'ja-JP',
        }[navigator.language.split('-')[0]] || 'en-US';
      const appLanguage = data?.normalSetting.language || defaultLanguage;
      // 如果当前语言和应用语言一致，则不需要切换
      if (i18n.language === appLanguage) return;
      i18n.changeLanguage(appLanguage);
    }

    const settingStr = localStorage.getItem('ne-meeting-setting');
    if (settingStr) {
      try {
        const setting = JSON.parse(settingStr);
        changeLanguage(null, setting);
      } catch {}
    } else {
      changeLanguage();
    }

    window.ipcRenderer?.on('changeSetting', changeLanguage);

    return () => {
      window.ipcRenderer?.removeListener('changeSetting', changeLanguage);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [i18n.language]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event } = e.data;
      // 关闭统一处理页面重置逻辑
      switch (event) {
        case 'windowClosed':
          setWindowOpen(false);
          setTimeout(() => {
            setWindowOpen(true);
          });
          break;
        default:
          break;
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

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
          value={{ neMeeting, eventEmitter, globalConfig }}
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
