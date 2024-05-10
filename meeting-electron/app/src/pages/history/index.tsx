import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { HistoryMeeting } from '../../../../src/components/web/BeforeMeetingModal/HistoryMeetingModal';
import { useGlobalContext } from '../../../../src/store';

import './index.less';

const HistoryPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const [meetingId, setMeetingId] = useState<string>();

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      console.log('event', event, payload);
      if (event === 'windowOpen') {
        console.log('windowOpen', payload);
        const { meetingId } = payload;
        setMeetingId(meetingId);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('historyMeeting');
    });
  }, [t]);

  return (
    <>
      <div className="history-meeting-page">
        <div className="electron-drag-bar">
          <div className="drag-region" />
          {t('historyMeeting')}
          <PCTopButtons minimizable={false} maximizable={false} />
        </div>
        <HistoryMeeting
          open
          neMeeting={neMeeting}
          meetingId={meetingId}
          onBack={() => setMeetingId(undefined)}
        />
      </div>
    </>
  );
};

export default HistoryPage;
