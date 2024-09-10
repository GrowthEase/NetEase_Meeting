import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import FeedbackContent from '@meeting-module/components/common/Feedback/index';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import './index.less';

const FeedbackPage: React.FC = () => {
  const { t } = useTranslation();
  const [visible, setVisible] = useState<boolean>(false);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event } = e.data;

      if (event === 'updateData') {
        setVisible(true);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <>
      <div className={'feedback-page'}>
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('feedback')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="feedback-meeting-content">
          <FeedbackContent
            visible={visible}
            onClose={() => {
              window.close();
            }}
          />
        </div>
      </div>
    </>
  );
};

export default FeedbackPage;
