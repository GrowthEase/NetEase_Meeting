import './index.less';
import MeetingNotificationGlobalCard from '../../../../src/components/web/MeetingNotification/GlobalCard';
import React, { useCallback, useEffect, useState } from 'react';
import { NEMeetingInviteStatus } from '../../../../src/types/type';

const MeetingNotificationCard: React.FC = () => {
  const [messageList, setMessageList] = useState<any[]>([]);

  function handleClick(action?: string, message?: any) {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'notificationClick',
        payload: {
          action,
          message,
        },
      },
      parentWindow.origin,
    );
    if (action === 'join') {
      window.close();
    } else {
      onClose();
    }
  }

  function onClose() {
    if (messageList.length <= 1) {
      window.close();
    } else {
      // 删除最后一个
      const tmpNotifyCards = [...messageList];

      tmpNotifyCards.pop();
      setMessageList(tmpNotifyCards);
    }
  }

  const handleMessage = useCallback(
    (e: MessageEvent) => {
      const { event, payload } = e.data;

      if (event === 'updateNotifyCard') {
        const { message } = payload;
        const tmpNotifyCards = [...messageList];

        setMessageList([message, ...tmpNotifyCards]);
      } else if (event === 'inviteStateChange') {
        const { meetingId, status } = payload;

        // 如果是拒绝、取消、移除。则直接关闭卡片
        if (
          status === NEMeetingInviteStatus.rejected ||
          status === NEMeetingInviteStatus.canceled ||
          status === NEMeetingInviteStatus.removed
        ) {
          const tmpList = [...messageList];
          const index = tmpList.findIndex(
            (item) => item.data?.data?.meetingId === meetingId,
          );

          if (index > -1) {
            tmpList.splice(index, 1);
          }

          setMessageList(tmpList);
          if (tmpList.length === 0) {
            window.close();
          }
        }
      }
    },
    [messageList],
  );

  useEffect(() => {
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [handleMessage]);

  return messageList.length > 0 ? (
    <MeetingNotificationGlobalCard
      messageList={messageList}
      onClick={handleClick}
      onClose={onClose}
    />
  ) : null;
};

export default MeetingNotificationCard;
