import './index.less';
import MeetingNotificationGlobalCard from '../../../../src/components/web/MeetingNotification/GlobalCard';
import { useEffect, useState } from 'react';

const MeetingNotificationCard: React.FC = () => {
  const [notifyCard, setNotifyCard] = useState(null);

  function handleClick(action?: string) {
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'notificationClick',
        payload: {
          action,
        },
      },
      '*',
    );
  }

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'updateNotifyCard') {
        const { notifyCard } = payload;
        setNotifyCard(notifyCard);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return notifyCard ? (
    <MeetingNotificationGlobalCard
      notifyCard={notifyCard}
      onClick={handleClick}
    />
  ) : null;
};

export default MeetingNotificationCard;
