import './index.less';
import MeetingNotificationGlobalCard from '@meeting-module/components/web/MeetingNotification/GlobalCard';
import React, { useCallback, useEffect, useState } from 'react';
import { NEMeetingInviteStatus } from '@meeting-module/types/type';
import { NECustomSessionMessage } from 'neroom-types';

const MeetingNotificationCard: React.FC = () => {
  const [messageList, setMessageList] = useState<NECustomSessionMessage[]>([]);
  const [pluginNotifyDuration, setPluginNotifyDuration] = useState<number>();

  function handleClick(action?: string, message?: NECustomSessionMessage) {
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
      const type = payload?.message?.data?.data?.type;

      if (event === 'updateNotifyCard') {
        const { message } = payload;
        const tmpNotifyCards = [...messageList];

        setMessageList([message, ...tmpNotifyCards]);

        if (type === 'PLUGIN.CUSTOM') {
          setPluginNotifyDuration(payload?.pluginNotifyDuration);
        }
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
      pluginNotifyDuration={pluginNotifyDuration}
    />
  ) : null;
};

export default MeetingNotificationCard;
