import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { HistoryMeeting } from '../../../../src/components/web/BeforeMeetingModal/HistoryMeetingModal';
import './index.less';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import NEMeetingService from '../../../../src/services/NEMeeting';

export default function HistoryPage() {
  const { t } = useTranslation();
  const [meetingId, setMeetingId] = useState<string>();

  const replyCount = useRef(0);

  const neMeeting = new Proxy(
    {},
    {
      get: function (_, propKey) {
        return function (...args: any) {
          return new Promise((resolve, reject) => {
            const parentWindow = window.parent;
            const replyKey = `neMeetingReply_${replyCount.current++}`;
            parentWindow?.postMessage(
              {
                event: 'neMeeting',
                payload: {
                  replyKey,
                  fnKey: propKey,
                  args: args,
                },
              },
              '*',
            );
            const handleMessage = (e: MessageEvent) => {
              const { event, payload } = e.data;
              if (event === replyKey) {
                const { result, error } = payload;
                if (error) {
                  reject(error);
                } else {
                  resolve(result);
                }
                window.removeEventListener('message', handleMessage);
              }
            };
            window.addEventListener('message', handleMessage);
          });
        };
      },
    },
  ) as NEMeetingService;

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

  return (
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
  );
}
