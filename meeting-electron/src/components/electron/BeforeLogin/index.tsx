import { Button, Checkbox } from 'antd'
import React, { useState } from 'react'
import AppAboutLogoImage from '../../../assets/app-about-logo.png'
import MobLogo from '../../../assets/mob-logo@2x.png'
import Toast from '../../common/toast'
import './index.less'

interface BeforeLoginProps {
  onLogin: (type: number) => void
}

const i18n = {
  loginAndRegister: '注册登录',
  ssoLogin: 'SSO登录',
  loginAgreement: '已阅读并同意网易会议',
  and: '和',
  privacyPolicy: '隐私政策',
  userAgreement: '用户服务协议',
  beforeLoginCheck: '请先勾选同意',
}

const BeforeLogin: React.FC<BeforeLoginProps> = ({ onLogin }) => {
  const [isAgree, setIsAgree] = useState<boolean>(false)

  const onClickLogin = (type: number) => {
    if (!isAgree) {
      Toast.info(
        `${i18n.beforeLoginCheck}《${i18n.privacyPolicy}》${i18n.and}《${i18n.userAgreement}》`
      )
      return
    }

    onLogin(type)
  }

  return (
    <div className="before-login">
      <img className="logo" src={AppAboutLogoImage} />
      <Button
        type="primary"
        className="login-button"
        onClick={() => {
          onClickLogin(1)
        }}
      >
        {i18n.loginAndRegister}
      </Button>
      <Button
        className="login-button"
        onClick={() => {
          onClickLogin(2)
        }}
      >
        {i18n.ssoLogin}
      </Button>
      <div className="footer">
        <div className="footer-agreement">
          <Checkbox
            onChange={(e) => {
              console.log('onchange  ', e.target.checked)
              setIsAgree(e.target.checked)
            }}
            checked={isAgree}
          ></Checkbox>
          <span className="text">
            {i18n.loginAgreement}
            <a
              href="https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml"
              target="_blank"
              title="用户服务协议"
              rel="noreferrer"
            >
              {i18n.privacyPolicy}
            </a>
            {i18n.and}
            <a
              href="https://netease.im/meeting/clauses?serviceType=0"
              target="_blank"
              title="隐私政策"
              rel="noreferrer"
            >
              {i18n.userAgreement}
            </a>
          </span>
        </div>
        <img className="footer-logo" src={MobLogo} />
      </div>
    </div>
  )
}

export default BeforeLogin
