import React, { FC, useState, useEffect, useMemo } from 'react';
import { Button, Checkbox } from 'antd';
import { BaseInput } from '../../../components/input';
import styles from './index.less';
import { useLocation } from 'umi';
// import { matchURL } from '@/utils/index';
import classnames from 'classnames';
import Toast from '../../../../../src/components/common/toast';
import eleIpc from '../../../../../src/services/electron';
import {
  DOMAIN_SERVER,
  LOCALSTORAGE_LOGIN_BACK,
  SSO_APP_KEY,
  PROTOCOL,
  LOCALSTORAGE_SSO_APP_KEY,
} from '../../../config';
import LoginHeader from '../header';
import { getEnterPriseInfoApi } from '../../../api';
import { EnterPriseInfo } from '../../../types';
import { getDeviceKey } from '../../../../../src/utils';
import { NEClientType } from '../../../../../src/types';
import { useTranslation } from 'react-i18next';

// 一个简陋的方法，url拼接
export const matchURL = (url: string | any, paramStr: string) => {
  const hasParam = url.includes('?');
  return `${url}${hasParam ? '&' : '?'}${paramStr}`;
};

interface LoginBySSOComProps {
  checkIsAgree: () => boolean;
  style?: Record<string, string>;
  goBack?: () => void;
  code?: string;
}
export const LoginBySSOCom: FC<LoginBySSOComProps> = ({
  style = {},
  goBack,
  code,
  checkIsAgree,
}) => {
  const { t } = useTranslation();
  const [enterpriseCode, setEnterpriseCode] = useState({
    value: '',
    valid: false,
  });
  const [enterpriseEmail, setEnterpriseEmail] = useState({
    value: '',
    valid: false,
  });
  const [disableButton, setDisableButton] = useState(false);
  // const [ssoToken] = useState(history.location.query?.ssoToken);
  // const [userToken] = useState(history.location.query?.userToken);
  const [rememberCode, setRememberCode] = useState<boolean>(true);
  const [isEmail, setIsEmail] = useState<boolean>(false);
  const [loading, setLoading] = useState(false);
  const location = useLocation();

  const eleIpcIns = useMemo(() => eleIpc.getInstance(), []);

  const ssoAuthorize = async () => {
    if (!checkIsAgree()) {
      return;
    }
    const ssoCode = isEmail ? enterpriseEmail.value : enterpriseCode.value;
    const _enterpriseCode = ssoCode?.toLowerCase()?.trim();
    let params: { email?: string; code?: string } = {};
    if (isEmail) {
      params.email = enterpriseEmail.value;
    } else {
      params.code = enterpriseCode.value;
    }
    setLoading(true);
    getEnterPriseInfoApi(params)
      .then((data) => {
        if (data.idpList.length > 0) {
          const ipdInfo = data.idpList.find((item) => {
            return item.type === 1;
          });
          console.log('ipdInfo', ipdInfo);
          if (ipdInfo) {
            toSSOUrl(_enterpriseCode, ipdInfo.id, data.appKey);
          } else {
            Toast.fail(t('authSSOTip'));
          }
        } else {
          Toast.fail(t('authSSOTip'));
        }
      })
      .catch((err) => {
        Toast.fail(err.msg || err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const toSSOUrl = (_enterpriseCode: string, ipdId: number, appKey: string) => {
    // @ts-ignore
    const { query } = location;
    const [loginAppNameSpace] = [query?.loginAppNameSpace];
    const { origin, pathname } = window.location;
    const backUrl = window.localStorage.getItem(LOCALSTORAGE_LOGIN_BACK);
    const returnURL = query?.returnURL
      ? matchURL(
          `${origin}${pathname}`,
          `returnURL=${query?.returnURL}&loginAppNameSpace=${
            loginAppNameSpace || _enterpriseCode
          }&backUrl=${window.encodeURIComponent(
            (query?.backUrl as string) || '',
          )}&from=${query?.from || 'web'}`,
        )
      : `${origin}${pathname}?loginAppNameSpace=${
          loginAppNameSpace || _enterpriseCode
        }&backUrl=${window.encodeURIComponent(backUrl || '')}&from=${
          query?.from || 'web'
        }`;

    const ssoUrl = `${DOMAIN_SERVER}/scene/meeting/v2/sso-authorize`;
    const key = getDeviceKey();
    const clientCallbackUrl = window.isElectronNative
      ? `${PROTOCOL}://loginSuccess?` // 自定义协议唤起应用
      : `${window.encodeURIComponent(returnURL)}`;
    const clientType = window.isElectronNative
      ? window.isWins32
        ? NEClientType.PC
        : NEClientType.MAC
      : NEClientType.WEB;
    localStorage.setItem(LOCALSTORAGE_SSO_APP_KEY, appKey);
    const url = `${ssoUrl}?callback=${clientCallbackUrl}&idp=${ipdId}&key=${key}&clientType=${clientType}&appKey=${appKey}`;
    if (eleIpcIns) {
      eleIpcIns.sendMessage('open-browser-window', url);
    } else {
      window.location.href = url;
    }
    if (!isEmail) {
      if (rememberCode) {
        localStorage.setItem('nemeeting-website-sso', _enterpriseCode);
      } else {
        localStorage.removeItem('nemeeting-website-sso');
      }
    }
  };

  useEffect(() => {
    if (
      (enterpriseCode.value.length && !isEmail) ||
      (isEmail && enterpriseEmail.value.length)
    ) {
      setDisableButton(true);
    } else {
      setDisableButton(false);
    }
  }, [enterpriseCode.value, enterpriseEmail.value, isEmail]);

  useEffect(() => {
    if (code) {
      setEnterpriseCode({
        value: code,
        valid: true,
      });
    } else {
      const _ssoCode = localStorage.getItem('nemeeting-website-sso');
      if (_ssoCode) {
        setEnterpriseCode({
          value: _ssoCode,
          valid: true,
        });
      }
    }
  }, []);

  const onChange = (e: any) => {
    const checked = e.target.checked;
    setRememberCode(checked);
  };

  const handleGoBack = () => {
    goBack?.();
  };

  const SSOInputValidator = (value: string) => {
    return /^[a-zA-Z0-9|@|.]*$/.test(value);
  };
  return (
    <div className={styles.loginBySSO + ' login-panel'} style={{ ...style }}>
      <section className={classnames(styles.content, 'login-content')}>
        <LoginHeader
          title={isEmail ? t('authLoginByCorpMail') : t('authLoginBySSO')}
          goBack={() => handleGoBack()}
        />
        <div className={styles.inputContainer}>
          <BaseInput
            set={isEmail ? setEnterpriseEmail : setEnterpriseCode}
            hasClear={true}
            value={isEmail ? enterpriseEmail.value : enterpriseCode.value}
            placeholder={
              isEmail ? t('authEnterCorpMail') : t('authEnterCorpCode')
            }
            maxLength={50}
            onChangeValidator={SSOInputValidator} // 企业代码只能是数字和字母
            spellCheck={false}
          />
          <div className={styles.rememberCode}>
            <Button
              className={styles.emailLogin}
              type="link"
              onClick={() => {
                setIsEmail(!isEmail);
              }}
            >
              {isEmail ? t('authLoginBySSO') : t('authLoginByCorpMail')}
            </Button>
          </div>
        </div>
        <Button
          // loading={ssoToken || userToken}
          className={styles.nextButton}
          shape="round"
          disabled={!disableButton}
          type="primary"
          loading={loading}
          onClick={ssoAuthorize}
        >
          {t('authLogin')}
        </Button>
      </section>
    </div>
  );
};

const LoginBySSO: React.FC<LoginBySSOComProps> = (props) => {
  return (
    <>
      <div className="login-wrapper">
        <LoginBySSOCom {...props} />
      </div>
    </>
  );
};

export default LoginBySSO;
