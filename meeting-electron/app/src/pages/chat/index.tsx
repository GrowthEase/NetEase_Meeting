import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import ChatRoom from '../../../../src/components/web/Chatroom/Chatroom';
import { useMeetingInfoContext } from '../../../../src/store';
import useWatermark from '../../../../src/hooks/useWatermark';

import './index.less';

const ChatPage: React.FC = () => {
  useWatermark();
  const { t } = useTranslation();
  const { meetingInfo } = useMeetingInfoContext();
  const [initMsgs, setInitMsgs] = useState<any[]>([]);

  const [chatInfo, setChatInfo] = useState<{
    roomArchiveId: string;
    startTime: number;
    subject: string;
  }>();

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'updateData') {
        const { cacheMsgs, roomArchiveId, startTime, subject } = payload;
        setInitMsgs(cacheMsgs);
        roomArchiveId && setChatInfo({ roomArchiveId, startTime, subject });
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
      {chatInfo && chatInfo?.roomArchiveId ? (
        <div className="history-chat-wrapper">
          <div className="electron-drag-bar">
            <div className="drag-region" />
            {t('chatHistory')}
            <PCTopButtons minimizable={false} maximizable={false} />
          </div>
          <ChatRoom
            startTime={chatInfo.startTime}
            subject={chatInfo.subject}
            roomArchiveId={chatInfo.roomArchiveId}
            isViewHistory={true}
            visible
          />
        </div>
      ) : !!meetingInfo?.ownerUserUuid && !!meetingInfo?.localMember.uuid ? (
        <ChatRoom visible initMsgs={initMsgs} />
      ) : null}
    </>
  );
};

export default ChatPage;
