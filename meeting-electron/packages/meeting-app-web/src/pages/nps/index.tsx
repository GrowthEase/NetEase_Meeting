import React, { useEffect, useState } from 'react';
import NPS from '../../components/NPS/NPS';
import './index.less';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import { useTranslation } from 'react-i18next';

export default function NPSPage() {
  const { t } = useTranslation();
  const [npsProps, setNpsProps] = useState({
    meetingId: '',
    appKey: '',
    nickname: '',
  });

  useEffect(() => {
    // 设置页面标题
    setTimeout(() => {
      document.title = 'NPS';
    });

    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'setNpsInfo') {
        setNpsProps(payload);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <div className="nps-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        <div
          className="title"
          style={{
            fontWeight: 'bold',
          }}
        >
          {t('npsTitle')}
        </div>
        <PCTopButtons size="normal" minimizable={false} maximizable={false} />
      </div>
      <div className="nps-meeting-content">
        <NPS {...npsProps} />
      </div>
    </div>
  );
}
