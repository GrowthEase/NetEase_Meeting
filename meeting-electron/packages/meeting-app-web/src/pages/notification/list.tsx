import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import MeetingNotificationList from '@meeting-module/components/common/Notification/List';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import useWatermark from '@meeting-module/hooks/useWatermark';

import './index.less';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';

const MeetingNotification: React.FC = () => {
  useWatermark();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const { t } = useTranslation();

  const [sessionId, setSessionId] = useState<string>('');
  const [isInMeeting, setIsInMeeting] = useState<boolean>(true);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'windowOpen') {
        const { sessionId, isInMeeting } = payload;

        setSessionId(sessionId);
        setIsInMeeting(isInMeeting);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  function handleClick(action?: string) {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'notificationClick',
        payload: {
          action,
        },
      },
      parentWindow.origin,
    );
  }

  useEffect(() => {
    setTimeout(() => {
      document.title = t('notifyCenter');
    });
  }, [t]);

  return (
    <>
      {isInMeeting ? null : (
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('notifyCenter')}
          </span>
          <PCTopButtons minimizable={false} maximizable={false} />
        </div>
      )}
      <div
        style={{
          height: isInMeeting ? '100%' : 'calc(100% - 40px)',
        }}
      >
        <MeetingNotificationList
          sessionIds={sessionId ? [sessionId] : []}
          onClick={handleClick}
          meetingMessageChannelService={neMeetingKit?.getMeetingMessageChannelService()}
        />
      </div>
    </>
  );
};

export default MeetingNotification;
