import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import MeetingNotificationList from '../../../../src/components/common/Notification/List';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import useWatermark from '../../../../src/hooks/useWatermark';

import './index.less';

const MeetingNotification: React.FC = () => {
  useWatermark();

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
          {t('notifyCenter')}
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
        />
      </div>
    </>
  );
};

export default MeetingNotification;
