import React from 'react'
import { ModalProps } from 'antd'
import RightOutlined from '@ant-design/icons/RightOutlined'
import { useTranslation } from 'react-i18next'

import Modal from '../../common/Modal'
import AppAboutLogoImage from '../../../assets/app-about-logo.png'
import pkg from '../../../../package.json'

import './index.less'

const AboutModal: React.FC<ModalProps> = ({ ...restProps }) => {
  const { t } = useTranslation()

  return (
    <Modal
      title={t('about')}
      width={375}
      maskClosable={false}
      footer={null}
      {...restProps}
    >
      <About />
    </Modal>
  )
}

function About() {
  const { t } = useTranslation()

  const i18n = {
    privacyAgreement: t('privacyAgreement'),
    userAgreement: t('userAgreement'),
    copyRight: t('copyRight', { year: new Date().getFullYear() }),
    version: t('currentVersion'),
  }

  const privacyAgreement =
    'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml'
  const userAgreement = 'https://netease.im/meeting/clauses?serviceType=0'

  function openUrl(url: string) {
    if (window.ipcRenderer) {
      window.ipcRenderer?.send('open-browser-window', url)
      return
    }
    const a = document.createElement('a')
    a.setAttribute('target', '_blank')
    a.style.display = 'none'
    a.href = url
    // the filename you want
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
  return (
    <div className="before-meeting-modal-content">
      <img className="app-about-logo-image" src={AppAboutLogoImage} />
      <div className="app-about-version">
        {i18n.version} {pkg.version}
        {!!window.ipcRenderer}
      </div>
      <div>
        <div className="app-about-item" onClick={() => openUrl(userAgreement)}>
          <div className="app-about-item-title">{i18n.userAgreement}</div>
          <RightOutlined />
        </div>
        <div
          className="app-about-item"
          onClick={() => openUrl(privacyAgreement)}
        >
          <div className="app-about-item-title">{i18n.privacyAgreement}</div>
          <RightOutlined />
        </div>
      </div>
      <div className="copy-right-content">{i18n.copyRight}</div>
    </div>
  )
}

export { About }

export default AboutModal
