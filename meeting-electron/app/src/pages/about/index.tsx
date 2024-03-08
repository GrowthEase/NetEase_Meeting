import './index.less';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { About } from '../../../../src/components/web/BeforeMeetingModal/AboutModal';
import { useTranslation } from 'react-i18next';

export default function AboutPage() {
  const { t } = useTranslation();

  return (
    <div className="nps-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {t('about')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <div className="about-meeting-content">
        <About />
      </div>
    </div>
  );
}
