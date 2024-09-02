import React, { useEffect } from 'react';
import { useTranslation } from 'react-i18next';

import { ChatRoomContextProvider } from '@meeting-module/hooks/useChatRoom';
import BulletScreenMessage from '@meeting-module/components/common/BulletScreenMessage';
import './index.less';

const BulletScreenMessagePage: React.FC = () => {
  const { t } = useTranslation();

  useEffect(() => {
    setTimeout(() => {
      document.title = t('chat');
    });
  }, [t]);

  return (
    <>
      <ChatRoomContextProvider>
        <BulletScreenMessage className="nemeeting-bullet-screen-message-page" />
      </ChatRoomContextProvider>
    </>
  );
};

export default BulletScreenMessagePage;
