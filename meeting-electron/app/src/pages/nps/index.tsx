import { useEffect, useState } from 'react';
import { NPS } from '../../../../src/components/web/NPS';
import './index.less';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { history, useLocation } from 'umi';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
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
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="nps-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {t('npsTitle')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <div className="nps-meeting-content">
        <NPS {...npsProps} />
      </div>
    </div>
  );
}
