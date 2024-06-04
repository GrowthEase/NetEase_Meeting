import { Button, Checkbox } from 'antd';
import React, { useCallback, useEffect, useState } from 'react';
import AppAboutLogoImage from '../../assets/app-about-logo.png';
import MobLogo from '../../assets/mob-logo@2x.png';
import Toast from '../../../../src/components/common/toast';
import './index.less';
import LoginBySSO from './bySSO';
import NormalLogin from './normalLogin';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import BaseInput from '../../../src/components/input';
import EnterpriseLogin from './enterpriseLogin';
import { getEnterPriseInfoApi } from '../../api';
import { EnterPriseInfo } from '../../types';
import { useTranslation } from 'react-i18next';

export const CREATE_ACCOUNT_URL = process.env.CREATE_ACCOUNT_URL;

type ShowType =
  | 'home'
  | 'sso'
  | 'login'
  | 'register'
  | 'enterprise'
  | 'enterpriseLogin';
interface BeforeLoginProps {
  onLogged: () => void;
}

const BeforeLogin: React.FC<BeforeLoginProps> = ({ onLogged }) => {
  const { t } = useTranslation();
  const [isAgree, setIsAgree] = useState<boolean>(false);
  const [type, setType] = useState<ShowType>('home');
  const [enterpriseCode, setEnterpriseCode] = useState({
    value: '',
    valid: false,
  });
  const [enterpriseLoading, setEnterpriseLoading] = useState(false);
  const [enterpriseInfo, setEnterpriseInfo] = useState<EnterPriseInfo>();

  function login(type: ShowType) {
    setType(type);
  }

  const goType = (type: ShowType) => {
    setType(type);
  };

  const goEnterprise = () => {
    if (checkIsAgree()) {
      setEnterpriseLoading(true);
      getEnterPriseInfoApi({ code: enterpriseCode.value })
        .then((data) => {
          setType('enterpriseLogin');
          setEnterpriseInfo(data);
          // setEnterpriseCode({ value: '', valid: false });
        })
        .catch((err) => {
          Toast.fail(err.msg || err.message);
        })
        .finally(() => {
          setEnterpriseLoading(false);
        });
    }
  };

  function onCreateAccount() {
    if (window.isElectronNative) {
      window.ipcRenderer?.send('open-browser-window', CREATE_ACCOUNT_URL);
    } else {
      window.open(CREATE_ACCOUNT_URL, '_blank');
    }
  }

  const checkIsAgree = useCallback(() => {
    if (!isAgree) {
      Toast.info(t('authPrivacyCheckedTips'));
      return false;
    }
    return true;
  }, [isAgree]);

  const onClickLogin = (type: ShowType) => {
    if (checkIsAgree()) {
      login(type);
    }
  };
  function goBack() {
    setType('home');
  }

  return (
    <div className={'before-login-wrap'}>
      {window.isElectronNative && (
        <div className="electron-drag-bar">
          <div className="drag-region" />
          {t('appTitle')}
          <PCTopButtons maximizable={false} />
        </div>
      )}
      <div className="before-login">
        <div className="before-login-content">
          {type === 'home' && (
            <>
              <img
                className={`${
                  window.isElectronNative ? 'logo-electron' : ''
                } ${'logo'}`}
                src={AppAboutLogoImage}
              />
              <BaseInput
                style={{ width: '100%', paddingLeft: 0 }}
                size="middle"
                value={enterpriseCode.value}
                placeholder={t('authEnterCorpCode')}
                set={setEnterpriseCode}
              />
              <div className="no-enterprise-tip">
                <div>
                  {t('authNoCorpCode')}
                  <Button
                    className="create-count"
                    type="link"
                    onClick={onCreateAccount}
                  >
                    {t('authCreateNow')}
                  </Button>
                </div>
                <Button
                  type="link"
                  className="to-demo"
                  onClick={() => {
                    goType('register');
                  }}
                >
                  {t('authLoginToTrialEdition')}
                </Button>
              </div>
              <Button
                type="primary"
                disabled={!enterpriseCode.value}
                loading={enterpriseLoading}
                className="login-button"
                onClick={() => {
                  goEnterprise();
                }}
              >
                {t('authNextStep')}
              </Button>
              <Button
                type="link"
                onClick={() => {
                  onClickLogin('sso');
                }}
              >
                {t('authLoginBySSO')}
              </Button>
            </>
          )}
          {type === 'enterpriseLogin' && (
            <EnterpriseLogin
              enterpriseInfo={enterpriseInfo}
              checkIsAgree={checkIsAgree}
              onLogged={onLogged}
              goBack={goBack}
              onSSOLogin={() => login('sso')}
            />
          )}
          {type === 'register' && (
            <>
              <img
                className={`${
                  window.isElectronNative ? 'logo-electron' : ''
                } ${'logo'}`}
                src={AppAboutLogoImage}
              />
              <Button
                type="primary"
                className={`login-button  ${'login-and-register-btn'}`}
                onClick={() => {
                  onClickLogin('login');
                }}
              >
                {t('authRegisterAndLogin')}
              </Button>
              <div className="no-enterprise-tip">
                <div>
                  {t('authHasCorpCode')}
                  <Button
                    onClick={() => goType('home')}
                    className="create-count"
                    type="link"
                  >
                    {t('authLoginToCorpEdition')}
                  </Button>
                </div>
                <Button
                  className="create-count"
                  type="link"
                  onClick={() => {
                    onClickLogin('sso');
                  }}
                >
                  {t('authLoginBySSO')}
                </Button>
              </div>
            </>
          )}
          {type === 'sso' && (
            <LoginBySSO
              checkIsAgree={checkIsAgree}
              goBack={goBack}
              code={enterpriseCode.value}
            />
          )}
          {type === 'login' && (
            <NormalLogin
              checkIsAgree={checkIsAgree}
              onSSOLogin={() => login('sso')}
              goBack={goBack}
              onLogged={onLogged}
            />
          )}
        </div>
        <div className={'footer'}>
          <div className="footer-agreement">
            <Checkbox
              onChange={(e) => {
                setIsAgree(e.target.checked);
              }}
              checked={isAgree}
            />
            <span className="text">
              {t('authHasReadAndAgreeMeeting')}
              <a
                href="https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml"
                target="_blank"
                title={t('authPrivacy')}
                onClick={(e) => {
                  if (window.ipcRenderer) {
                    window.ipcRenderer.send(
                      'open-browser-window',
                      'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml',
                    );
                    e.preventDefault();
                  }
                }}
              >
                {t('authPrivacy')}
              </a>
              {t('authAnd')}
              <a
                href="https://netease.im/meeting/clauses?serviceType=0"
                target="_blank"
                title={t('authUserProtocol')}
                onClick={(e) => {
                  if (window.ipcRenderer) {
                    window.ipcRenderer.send(
                      'open-browser-window',
                      'https://netease.im/meeting/clauses?serviceType=0',
                    );
                    e.preventDefault();
                  }
                }}
              >
                {t('authUserProtocol')}
              </a>
            </span>
          </div>
          <img className="footer-logo" src={MobLogo} />
        </div>
      </div>
    </div>
  );
};

export default BeforeLogin;
