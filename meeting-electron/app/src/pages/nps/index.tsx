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
  const { search } = useLocation();
  useEffect(() => {
    const paramsIter = new URLSearchParams(window.location.search || search);
    const paramsObject: any = {};
    for (const [key, value] of paramsIter.entries()) {
      paramsObject[key] = value;
    }
    console.log('paramsObject>>>', paramsObject);
    setNpsProps(paramsObject);
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
