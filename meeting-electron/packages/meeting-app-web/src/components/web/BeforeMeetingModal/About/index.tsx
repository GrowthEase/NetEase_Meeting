import React from 'react';
import { useTranslation } from 'react-i18next';

import AppAboutLogoImage from '../../../../assets/app-about-logo.png';
import { IPCEvent } from '../../../../types';
import pkg from '../../../../../package.json';

import './index.less';

const AboutContent: React.FC = () => {
  const { t } = useTranslation();

  const i18n = {
    privacyAgreement: t('privacyAgreement'),
    userAgreement: t('userAgreement'),
    copyRight: t('copyRight', { year: new Date().getFullYear() }),
    version: t('currentVersion'),
  };

  const privacyAgreement =
    'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml';
  const userAgreement = 'https://netease.im/meeting/clauses?serviceType=0';

  function openUrl(url: string) {
    if (window.ipcRenderer) {
      window.ipcRenderer?.send(IPCEvent.openBrowserWindow, url);
      return;
    }

    const a = document.createElement('a');

    a.setAttribute('target', '_blank');
    a.style.display = 'none';
    a.href = url;
    // the filename you want
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  return (
    <div className="about-content">
      <div className="app-about-logo-wrap">
        <img className="app-about-logo-image" src={AppAboutLogoImage} />
        <div className="app-about-version">
          {i18n.version} {pkg.version}
          {!!window.ipcRenderer}
        </div>
      </div>
      <div className="app-about-item-wrap">
        <div className="app-about-item" onClick={() => openUrl(userAgreement)}>
          <div className="app-about-item-title">{i18n.userAgreement}</div>
          <span className="iconyoujiantou">
            <svg
              className="icon iconfont iconyoujiantou-16px-2"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </span>
        </div>
        <div
          className="app-about-item"
          onClick={() => openUrl(privacyAgreement)}
        >
          <div className="app-about-item-title">{i18n.privacyAgreement}</div>
          <span className="iconyoujiantou">
            <svg
              className="icon iconfont iconyoujiantou-16px-2"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </span>
        </div>
      </div>
      <div className="copy-right-content">{i18n.copyRight}</div>
    </div>
  );
};

export default AboutContent;
