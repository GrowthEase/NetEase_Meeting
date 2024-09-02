import React, { useState, useMemo, useRef, useCallback } from 'react';
import classnames from 'classnames';
import './index.less';
import BaseInput, { PhoneInput, PwdInput } from '../../Input';
import { Button, Checkbox, Divider } from 'antd';
import { modifyPasswordApi, loginApiNew } from '../../../api';
import { LOCALSTORAGE_USER_INFO } from '../../../config';
import { useTranslation } from 'react-i18next';
import LoginHeader from '../header';
import Toast from '@meeting-module/components/common/toast';
import { EnterPriseInfo, LoginUserInfo } from '@/types';
import Modal from '@meeting-module/components/common/Modal';
import { md5Password } from '@meeting-module/utils';
import LoginTypeIcon from '../loginTypeIcon';

interface EnterpriseLoginProps {
  goBack?: () => void;
  onSSOLogin: () => void;
  enterpriseInfo?: EnterPriseInfo;
  onLogged: () => void;
}

type ShowType = 'enterpriseLogin' | 'newPassword';

type EnterpriseLoginType = 'account' | 'phone' | 'email';

const EnterpriseLogin: React.FC<EnterpriseLoginProps> = ({
  goBack,
  enterpriseInfo,
  onSSOLogin,
  onLogged,
}) => {
  const { t } = useTranslation();
  const [isAgree, setIsAgree] = useState<boolean>(true);
  const [pwd, setPwd] = useState({ value: '', valid: false });
  const [newPwd, setNewPwd] = useState({ value: '', valid: false });
  const [newSecondPwd, setNewSecondPwd] = useState({ value: '', valid: false });
  const [account, setAccount] = useState({ value: '', valid: false });
  const [phone, setPhone] = useState({ value: '', valid: false });
  const [email, setEmail] = useState({ value: '', valid: false });
  const [loading, setLoading] = useState(false);
  const [errorTip, setErrorTip] = useState('');
  const userInfoRef = useRef<LoginUserInfo | null>(null);
  const [currentType, setCurrentType] = useState<ShowType>('enterpriseLogin');
  const [enterpriseLoginType, setEnterpriseLoginType] =
    useState<EnterpriseLoginType>('account');

  const pageTitle = useMemo(() => {
    switch (enterpriseLoginType) {
      case 'account':
        return t('authLoginByAccountPwd');
      case 'phone':
        return t('authLoginByMobilePwd');
      case 'email':
        return t('authLoginByEmailPwd');
    }
  }, [enterpriseLoginType, t]);

  const loginButtonDisabled = useMemo(() => {
    if (enterpriseLoginType === 'account') {
      return !account.valid || pwd.value.length < 6;
    } else if (enterpriseLoginType === 'phone') {
      return !phone.valid || pwd.value.length < 6;
    } else {
      return !email.valid || pwd.value.length < 6;
    }
  }, [account.valid, email.valid, enterpriseLoginType, phone.valid, pwd.value]);

  const checkIsAgree = useCallback(() => {
    if (!isAgree) {
      Toast.info(t('authPrivacyCheckedTips'));
      return false;
    }

    return true;
  }, [isAgree, t]);

  const handleGoBack = () => {
    if (currentType === 'enterpriseLogin') {
      goBack?.();
    } else {
      setCurrentType('enterpriseLogin');
    }
  };

  const login = () => {
    if (!checkIsAgree()) {
      return;
    }

    setLoading(true);
    const payload = {
      username: enterpriseLoginType === 'account' ? account.value : undefined,
      email: enterpriseLoginType === 'email' ? email.value : undefined,
      phone: enterpriseLoginType === 'phone' ? phone.value : undefined,
      password: md5Password(pwd.value),
      appKey: enterpriseInfo?.appKey,
    };

    loginApiNew(payload)
      .then((data) => {
        userInfoRef.current = data;
        setLoading(false);
        if (data.initialPassword) {
          showPwdModal();
          return;
        }

        loginHandle(data);
      })
      .catch((e) => {
        // 需要设置新密码
        if (e.code === 3426) {
          setCurrentType('newPassword');
        } else {
          Toast.fail(e.message || e.msg);
        }

        setLoading(false);
      });
  };

  const loginHandle = (data: LoginUserInfo) => {
    let userInfo = data;

    userInfo = Object.assign(
      {
        appKey: enterpriseInfo?.appKey,
      },
      userInfo,
    );
    localStorage.setItem(LOCALSTORAGE_USER_INFO, JSON.stringify(userInfo));
    window.ipcRenderer?.send('flushStorageData');
    onLogged?.();
    setTimeout(() => {
      setLoading(false);
    }, 500);
  };

  const showPwdModal = () => {
    Modal.confirm({
      width: 320,
      title: t('authResetInitialPasswordDialogTitle'),
      content: t('authResetInitialPasswordDialogMessage'),
      okText: t('authResetInitialPasswordDialogOKLabel'),
      cancelText: t('authResetInitialPasswordDialogCancelLabel'),
      onOk: () => {
        setCurrentType('newPassword');
      },
      onCancel: () => {
        userInfoRef.current && loginHandle(userInfoRef.current);
      },
    });
  };

  const title = useMemo(() => {
    if (currentType === 'enterpriseLogin') {
      return enterpriseInfo?.appName || '';
    } else {
      return t('authResetInitialPasswordTitle');
    }
  }, [enterpriseInfo?.appName, currentType, t]);

  const saveNewPassword = () => {
    if (newPwd.value !== newSecondPwd.value) {
      setErrorTip(t('settingPasswordDifferent'));
      return;
    }

    modifyPasswordApi({
      password: md5Password(pwd.value),
      newPassword: md5Password(newPwd.value),
      username: account.value,
      appKey: enterpriseInfo?.appKey,
    })
      .then((data) => {
        Toast.success(t('authModifyPasswordSuccess'));
        loginHandle(data);
      })
      .catch((e) => {
        setErrorTip(e.msg);
        // Toast.fail(e.message || e.msg);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const handleConfirmPwdChange = (value: string): string => {
    setErrorTip('');
    return value;
  };

  const loginValid = useMemo(() => {
    return account.value && pwd.value;
  }, [pwd.value, account.value]);

  const passwordValid = useMemo(() => {
    return newPwd.value && newSecondPwd.valid;
  }, [newPwd.value, newSecondPwd.value]);

  return (
    <div className="enterprise-login">
      <section className={classnames('content', 'login-content')}>
        <LoginHeader
          subTitle={title}
          title={pageTitle}
          goBack={() => handleGoBack()}
        />
        {currentType === 'enterpriseLogin' ? (
          <>
            <div className="input-container">
              {enterpriseLoginType === 'account' && (
                <BaseInput
                  prefix={
                    <svg
                      className="icon iconfont input-prefix-icon"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconzhanghao"></use>
                    </svg>
                  }
                  style={{ paddingLeft: 0, marginBottom: '20px' }}
                  placeholder={t('authEnterAccount')}
                  value={account.value}
                  hasClear={true}
                  set={setAccount}
                  errorTip=""
                />
              )}
              {enterpriseLoginType === 'phone' && (
                <PhoneInput
                  prefix={
                    <svg
                      className="icon iconfont input-prefix-icon"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconshouji"></use>
                    </svg>
                  }
                  style={{ paddingLeft: 0, marginBottom: '20px' }}
                  value={phone.value}
                  set={setPhone}
                  errorTip=""
                />
              )}
              {enterpriseLoginType === 'email' && (
                <BaseInput
                  prefix={
                    <svg
                      className="icon iconfont input-prefix-icon"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconqiyeyouxiang"></use>
                    </svg>
                  }
                  style={{ paddingLeft: 0, marginBottom: '20px' }}
                  placeholder={t('authEnterCorpMail')}
                  value={email.value}
                  hasClear={true}
                  set={setEmail}
                  errorTip=""
                />
              )}
              <PwdInput
                prefix={
                  <svg
                    className="icon iconfont input-prefix-icon"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconmima"></use>
                  </svg>
                }
                style={{ paddingLeft: 0 }}
                value={pwd.value}
                set={setPwd}
                hasClear={true}
                errorTip=""
              />
            </div>
            <Button
              type="primary"
              disabled={loginButtonDisabled}
              className={`login-btn login-button ${
                loginValid ? '' : 'inactive'
              }`}
              onClick={login}
              loading={loading}
            >
              {t('authLogin')}
            </Button>
            <div className="agreement">
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
                  rel="noreferrer"
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
                  rel="noreferrer"
                >
                  {t('authUserProtocol')}
                </a>
              </span>
            </div>
            <div className="enterprise-login-type">
              <Divider plain className="other-login-type-divider">
                <span className="line"></span>
                <span className="other-login-type-divider-text">
                  {t('authOtherLoginTypes')}
                </span>
                <span className="line"></span>
              </Divider>
              <div className="enterprise-login-type-group">
                {enterpriseLoginType === 'phone' ? (
                  <LoginTypeIcon
                    title={t('authTypeAccountPwd')}
                    icon="iconzhanghao"
                    onClick={() => {
                      setEnterpriseLoginType('account');
                    }}
                  />
                ) : (
                  <LoginTypeIcon
                    title={t('authMobileNum')}
                    icon="iconshouji"
                    onClick={() => {
                      setEnterpriseLoginType('phone');
                    }}
                  />
                )}
                {enterpriseLoginType === 'email' ? (
                  <LoginTypeIcon
                    title={t('authTypeAccountPwd')}
                    icon="iconzhanghao"
                    onClick={() => {
                      setEnterpriseLoginType('account');
                    }}
                  />
                ) : (
                  <LoginTypeIcon
                    title={t('settingEmail')}
                    icon="iconqiyeyouxiang"
                    onClick={() => {
                      setEnterpriseLoginType('email');
                    }}
                  />
                )}
                <LoginTypeIcon
                  title={t('authLoginBySSO')}
                  icon="iconSSO1"
                  onClick={() => {
                    onSSOLogin();
                  }}
                />
              </div>
            </div>
          </>
        ) : (
          <>
            <div className="input-container">
              <PwdInput
                style={{ paddingLeft: 0 }}
                value={newPwd.value}
                set={setNewPwd}
                needCheck={true}
                hasClear={true}
                onValueChange={handleConfirmPwdChange}
                placeholder={t('settingEnterNewPasswordTips')}
                errorTip=""
              />
              <div
                style={{
                  visibility: !newPwd.valid || errorTip ? 'visible' : 'hidden',
                }}
                className="nemeeting-accoutn-pwd-err-tip"
              >
                {!newPwd.valid && newPwd.value
                  ? t('settingValidatorPwdTip')
                  : errorTip}
              </div>
              <PwdInput
                style={{ paddingLeft: 0 }}
                value={newSecondPwd.value}
                onValueChange={handleConfirmPwdChange}
                set={setNewSecondPwd}
                hasClear={true}
                placeholder={t('settingEnterPasswordConfirm')}
                errorTip=""
              />
            </div>
            <Button
              type="primary"
              shape="round"
              disabled={!newPwd.valid || !newSecondPwd.value || !newPwd.value}
              className={`login-btn login-button ${
                passwordValid ? '' : 'inactive'
              }`}
              onClick={saveNewPassword}
              loading={loading}
            >
              {t('save')}
            </Button>
          </>
        )}
      </section>
    </div>
  );
};

export default EnterpriseLogin;
