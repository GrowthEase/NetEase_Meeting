import React, { useState, useMemo, useRef } from 'react';
import classnames from 'classnames';
import './index.less';
import BaseInput, { PwdInput } from '../../../components/input';
import { Button } from 'antd';
import { loginApi, modifyPasswordApi } from '../../../api';
import { LOCALSTORAGE_USER_INFO } from '../../../config';
import { useTranslation } from 'react-i18next';
import LoginHeader from '../header';
import Toast from '../../../../../src/components/common/toast';
import { EnterPriseInfo, LoginUserInfo } from '@/types';
import Modal from '../../../../../src/components/common/Modal';
import { md5Password } from '../../../../../src/utils';
interface EnterpriseLoginProps {
  goBack?: () => void;
  onSSOLogin: () => void;
  checkIsAgree: () => boolean;
  enterpriseInfo?: EnterPriseInfo;
  onLogged: () => void;
}

type ShowType = 'enterpriseLogin' | 'newPassword';

const EnterpriseLogin: React.FC<EnterpriseLoginProps> = ({
  goBack,
  checkIsAgree,
  enterpriseInfo,
  onSSOLogin,
  onLogged,
}) => {
  const { t } = useTranslation();
  const [pwd, setPwd] = useState({ value: '', valid: false });
  const [newPwd, setNewPwd] = useState({ value: '', valid: false });
  const [newSecondPwd, setNewSecondPwd] = useState({ value: '', valid: false });
  const [account, setAccount] = useState({ value: '', valid: false });
  const [loading, setLoading] = useState(false);
  const [errorTip, setErrorTip] = useState('');
  const userInfoRef = useRef<LoginUserInfo | null>(null);
  const [currentType, setCurrentType] = useState<ShowType>('enterpriseLogin');
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
      username: account.value,
      password: md5Password(pwd.value),
      appKey: enterpriseInfo?.appKey,
    };
    loginApi(payload)
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
  }, [enterpriseInfo?.appName, currentType]);

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
        <LoginHeader title={title} goBack={() => handleGoBack()} />
        {currentType === 'enterpriseLogin' ? (
          <>
            <div className="input-container">
              <BaseInput
                style={{ paddingLeft: 0, marginBottom: '20px' }}
                placeholder={t('authEnterAccount')}
                value={account.value}
                hasClear={true}
                set={setAccount}
                errorTip=""
              />
              <PwdInput
                style={{ paddingLeft: 0 }}
                value={pwd.value}
                set={setPwd}
                hasClear={true}
                errorTip=""
              />
            </div>
            <div className="enterprise-sso-login">
              <Button
                className="enterprise-sso-login-btn"
                type="link"
                onClick={() => {
                  onSSOLogin();
                }}
              >
                {t('authLoginBySSO')}
              </Button>
            </div>
            <Button
              type="primary"
              shape="round"
              disabled={!account.valid || pwd.value.length < 6}
              className={`login-btn login-button ${
                loginValid ? '' : 'inactive'
              }`}
              onClick={login}
              loading={loading}
            >
              {t('authLogin')}
            </Button>
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
