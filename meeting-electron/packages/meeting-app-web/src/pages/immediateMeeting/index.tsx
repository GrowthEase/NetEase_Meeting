import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import ImmediateMeeting from '../../components/web/BeforeMeetingModal/ImmediateMeeting';
import './index.less';
import { useGlobalContext } from '@meeting-module/store';
import { MeetingSetting } from '@meeting-module/types';
import { IPCEvent } from '@/types';
import Toast from '@meeting-module/components/common/toast';
import { setLocalStorageSetting } from 'nemeeting-web-sdk';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';

const JoinMeetingPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const [submitLoading, setSubmitLoading] = useState(false);
  const [setting, setSetting] = useState<MeetingSetting | null>(null);
  const [nickname, setNickname] = useState('');
  const [avatar, setAvatar] = useState('');
  const [meetingNum, setMeetingNum] = useState('');
  const [shortMeetingNum, setShortMeetingNum] = useState('');

  const [open, setOpen] = useState(false);

  const settingsService = useMemo(() => {
    return neMeetingKit.getSettingsService();
  }, [neMeetingKit]);

  const onSettingChange = useCallback((setting: MeetingSetting): void => {
    setSetting(setting);
    setLocalStorageSetting(JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }, []);

  const previewController = useMemo(
    () => neMeeting?.previewController,
    [neMeeting],
  );

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'setImmediateMeetingData') {
        payload.nickname && setNickname(payload.nickname);
        payload.avatar && setAvatar(payload.avatar);
        payload.setting && setSetting(payload.setting);
        payload.meetingNum && setMeetingNum(payload.meetingNum);
        payload.shortMeetingNum && setShortMeetingNum(payload.shortMeetingNum);
        setOpen(true);
      } else if (event === 'createMeetingFail') {
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
      document.title = t('immediateMeeting');
    });
  }, [t]);

  return (
    <>
      <div className={'immediate-meeting-page'}>
        <div className="electron-drag-bar">
          <div className="drag-region"></div>
          <span
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('immediateMeeting')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="immediate-meeting-page-content">
          <ImmediateMeeting
            previewController={previewController}
            settingsService={settingsService}
            setting={setting}
            nickname={nickname}
            avatar={avatar}
            onSettingChange={onSettingChange}
            meetingNum={meetingNum}
            shortMeetingNum={shortMeetingNum}
            open={open}
            submitLoading={submitLoading}
            onSummit={(value) => {
              setSubmitLoading(true);
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'createMeeting',
                  payload: {
                    value,
                  },
                },
                parentWindow.origin,
              );
            }}
          ></ImmediateMeeting>
        </div>
      </div>
    </>
  );
};

export default JoinMeetingPage;
