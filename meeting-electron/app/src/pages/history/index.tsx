import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { HistoryMeeting } from '../../../../src/components/web/BeforeMeetingModal/HistoryMeetingModal';
import NEMeetingKit from '../../../../src/index';
import './index.less';
import { LOCALSTORAGE_USER_INFO } from '../../config';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';

let appKey = '';
const domain = process.env.MEETING_DOMAIN;

export default function HistoryPage() {
  const { t } = useTranslation();

  const [open, setOpen] = useState(false);
  const [isLogined, setIsLogined] = useState(false);
  function init(cb: any) {
    const config = {
      appKey: appKey, //云信服务appkey
      meetingServerDomain: domain, //会议服务器地址，支持私有化部署
    };
    if (NEMeetingKit.actions.isInitialized) {
      cb();
      return;
    }
    // @ts-ignore
    NEMeetingKit.actions.init(0, 0, config, cb); // （width，height）单位px 建议比例4:3
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
          setIsLogined(true);
          setOpen(true);
        } else {
          setIsLogined(false);
        }
      },
    );
  }

  function loginAfterInit(account: string, token: string) {
    init((e: any) => {
      if (!e) {
        login(account, token);
      }
    });
  }

  const getAccountInfo = () => {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);
    if (userString) {
      const user = JSON.parse(userString);
      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId;
        return {
          userUuid: user.userUuid,
          userToken: user.userToken,
        };
      }
    }
    return null;
  };

  useEffect(() => {
    const accountInfo = getAccountInfo();
    if (accountInfo) {
      loginAfterInit(accountInfo.userUuid, accountInfo.userToken);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    // @ts-ignore
    if (window.ipcRenderer) {
      // @ts-ignore
      window.ipcRenderer.on('open-meeting-history', () => {
        const isInitialized = NEMeetingKit.actions.isInitialized;
        const accountInfo = getAccountInfo();
        if (isInitialized && isLogined) {
          setOpen(true);
        } else if (isInitialized && !isLogined) {
          if (accountInfo) {
            login(accountInfo.userUuid, accountInfo.userToken);
          }
        } else {
          if (accountInfo) {
            loginAfterInit(accountInfo.userUuid, accountInfo.userToken);
          }
        }
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="history-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {t('historyMeeting')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <div id="ne-web-meeting" style={{ display: 'none' }} />
      <HistoryMeeting open={open} />
    </div>
  );
}
