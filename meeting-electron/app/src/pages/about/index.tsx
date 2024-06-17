import './index.less';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import About from '../../../../src/components/web/BeforeMeetingModal/About';
import { useTranslation } from 'react-i18next';
import React from 'react';

export default function AboutPage() {
  const { t } = useTranslation();

  return (
    <div className="nps-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        <span
          style={{
            fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
          }}
        >
          {t('about')}
        </span>
        <PCTopButtons size="normal" minimizable={false} maximizable={false} />
      </div>
      <div className="about-meeting-content">
        <About />
      </div>
    </div>
  );
}
