import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '../../../../src/components/common/PCTopButtons';

import JoinMeeting from '../../../../src/components/web/BeforeMeetingModal/JoinMeeting';
import './index.less';
import { MeetingSetting } from '../../../../src/types';
import { useGlobalContext } from '../../../../src/store';
import { IPCEvent } from '@/types';
import Toast from '../../../../src/components/common/toast';

const LOCAL_STORAGE_KEY = 'ne-meeting-recent-meeting-list';

const JoinMeetingPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const [submitLoading, setSubmitLoading] = useState(false);
  const [setting, setSetting] = useState<MeetingSetting | null>(null);
  const [accountId, setAccountId] = useState<string>('');
  const [settingOpen, setSettingOpen] = useState(false);
  const [invitationMeetingNum, setInvitationMeetingNum] = useState('');
  const [nickname, setNickname] = useState('');
  const [avatar, setAvatar] = useState('');

  const [open, setOpen] = useState(false);

  const onSettingChange = useCallback((setting: MeetingSetting): void => {
    setSetting(setting);
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }, []);

  const previewController = useMemo(
    () => neMeeting?.previewController,
    [neMeeting],
  );

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'setJoinMeetingData') {
        payload.nickname && setNickname(payload.nickname);
        payload.avatar && setAvatar(payload.avatar);
        payload.setting && setSetting(payload.setting);
        payload.settingOpen && setSettingOpen(payload.settingOpen);
        payload.accountId && setAccountId(payload.accountId);
        payload.invitationMeetingNum &&
          setInvitationMeetingNum(payload.invitationMeetingNum);
        setOpen(true);
      } else if (event === 'joinMeetingFail') {
        Toast.fail(payload.errorMsg);
        setSubmitLoading(false);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('meetingJoin');
    });
  }, [t]);

  return (
    <>
      <div className={'join-meeting-page'}>
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {t('meetingJoin')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="join-meeting-page-content">
          <JoinMeeting
            previewController={previewController}
            setting={setting}
            nickname={nickname}
            avatar={avatar}
            settingOpen={settingOpen}
            onSettingChange={onSettingChange}
            open={open}
            meetingNum={invitationMeetingNum}
            submitLoading={submitLoading}
            recentMeetingList={
              JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) || '{}')[
                accountId
              ] || []
            }
            onClearRecentMeetingList={() => {
              const localStorageData = JSON.parse(
                localStorage.getItem(LOCAL_STORAGE_KEY) || '{}',
              );

              delete localStorageData[accountId];
              localStorage.setItem(
                LOCAL_STORAGE_KEY,
                JSON.stringify(localStorageData),
              );
            }}
            onSummit={(value) => {
              setSubmitLoading(true);
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'joinMeeting',
                  payload: {
                    value,
                  },
                },
                parentWindow.origin,
              );
            }}
          />
        </div>
      </div>
    </>
  );
};

export default JoinMeetingPage;
