import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import ChatRoom from '@meeting-module/components/web/NEChatRoom';
import { useMeetingInfoContext } from '@meeting-module/store';
import useWatermark from '@meeting-module/hooks/useWatermark';

import './index.less';

const ChatPage: React.FC = () => {
  useWatermark();
  const { t } = useTranslation();
  const { meetingInfo } = useMeetingInfoContext();
  const [meetingId, setMeetingId] = useState<number>();

  // 会前
  const preMeeting = !meetingInfo.meetingNum;

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { meetingId } = payload;

        meetingId && setMeetingId(Number(meetingId));
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('chat');
    });
  }, [t]);

  return (
    <>
      <div className="history-chat-wrapper">
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
            className="chat-history-title"
          >
            {preMeeting ? t('chatHistory') : t('chat')}
          </span>
          <PCTopButtons minimizable={false} maximizable={false} />
        </div>
        {preMeeting ? (
          meetingId ? (
            <ChatRoom meetingId={meetingId} />
          ) : null
        ) : (
          <ChatRoom />
        )}
      </div>
    </>
  );
};

export default ChatPage;
