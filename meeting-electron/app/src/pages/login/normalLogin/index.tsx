import React, { FC, useState, useEffect } from 'react';
import {
  PhoneInput,
  VerifyCodeInput,
  PwdInput,
} from '../../../components/input';
import styles from './index.less';
import { Md5 } from 'ts-md5/dist/md5';
import { Button, Modal } from 'antd';
import classnames from 'classnames';
import { loginApi } from '../../../api';
import { APP_KEY, LOCALSTORAGE_USER_INFO } from '../../../config';
import lottie from 'lottie-web';
import loadingJSON from '../../../assets/loading.json';
import Toast from '../../../../../src/components/common/toast';
import LoginHeader from '../header';
import { useTranslation } from 'react-i18next';

interface LoginComProps {
  style?: Record<string, string>;
  onSSOLogin: () => void;
  goBack: () => void;
  onLogged: () => void;
}

export const LoginCom: React.FC<LoginComProps> = ({
  style = {},
  onSSOLogin,
  goBack,
  onLogged,
}) => {
  const { t } = useTranslation();
  const [isCode, setType] = useState(true); // 是否为验证码登录
  // const [loginType, setLoginType] = useState(''); // 是否为显示密码登录（只有特殊客户需要显示这个按钮，一般不提供）
  const [phone, setPhone] = useState({ value: '', valid: false });
  const [code, setCode] = useState({ value: '', valid: false });
  const [pwd, setPwd] = useState({ value: '', valid: false });
  const [loading, setLoading] = useState(false);
  const [newVersion, setNewVersion] = useState<boolean>(false);

  useEffect(() => {
    if (loading) {
      const container = document.getElementById(
        'loading-modal-svg',
      ) as HTMLElement;
      lottie.loadAnimation({
        name: 'loading-modal-svg',
        container,
        renderer: 'svg',
        loop: true,
        autoplay: true,
        animationData: loadingJSON,
      });
      lottie.play();
    } else {
      lottie.destroy('loading-modal-svg');
    }
    return () => {
      lottie.destroy('loading-modal-svg');
    };
  }, [loading]);

  const logins = () => {
    setLoading(true);
    const payload = isCode
      ? {
          mobile: phone.value,
          verifyCode: code.value,
        }
      : {
          username: phone.value,
          password: newVersion
            ? Md5.hashStr(pwd.value + '@yiyong.im')
            : Md5.hashStr(pwd.value + '@163'),
        };
    loginApi(payload)
      .then((data) => {
        console.log('res..', data);
        let userInfo = data;
        userInfo = Object.assign(
          {
            appKey: APP_KEY,
            loginType: 'normal',
          },
          userInfo,
        );
        localStorage.setItem(LOCALSTORAGE_USER_INFO, JSON.stringify(userInfo));
        window.ipcRenderer?.send('flushStorageData');
        onLogged();
        setTimeout(() => {
          setLoading(false);
        }, 500);
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg);
        setLoading(false);
      });
  };
  // 账号密码登录时不需要校验格式
  // 验证码登录时需要校验手机号和验证码格式
  const btnValid = isCode
    ? code.valid && phone.valid
    : pwd.value && phone.value;

  const handleGoBack = () => {
    goBack?.();
  };

  return (
    <div className={styles.login + ' login-panel'} style={{ ...style }}>
      <section className={classnames(styles.content, 'login-content')}>
        <LoginHeader
          title={t('authLoginByMobile')}
          goBack={() => handleGoBack()}
        />
        <div className="input-container">
          <PhoneInput value={phone.value} set={setPhone} errorTip="" />
          {isCode ? (
            <VerifyCodeInput
              value={code.value}
              set={setCode}
              phone={phone.valid && phone.value}
              scene={1}
            />
          ) : (
            <PwdInput value={pwd.value} set={setPwd} errorTip="" />
          )}
          {/* 暂不支持后续的重置密码，故先注释 */}
          {/* {!isCode && <Link to="/login/forget">忘记密码</Link>} */}
        </div>
        <Button
          type="primary"
          shape="round"
          disabled={!phone.valid || !code.valid}
          className={`login-button ${btnValid ? '' : 'inactive'}`}
          onClick={logins}
          loading={loading}
        >
          {t('authLogin')}
        </Button>
        <div className={styles.toggleLogin}>
          <div className={classnames(styles.footer, 'login-footer')}>
            <span
              onClick={
                () => {
                  onSSOLogin();
                }
                // history.push({
                //   pathname: newVersion ? '/login/sso/v2' : '/login/sso',
                //   query: {
                //     returnURL: history.location.query?.returnURL as string,
                //     backUrl: history.location.query?.backUrl as string,
                //   },
                // })
              }
            >
              {t('authLoginBySSO')}
            </span>
          </div>
        </div>
      </section>
      <Modal
        title=""
        centered
        open={loading}
        maskClosable={false}
        width={230}
        closable={false}
        footer={null}
        keyboard={false}
        maskStyle={{
          background: 'rgba(0, 0, 0, 0.1)',
        }}
        bodyStyle={{
          margin: '-20px -24px',
        }}
      >
        <div className={styles.loadingModal}>
          <div className={styles.loadingModalSvg} id={`loading-modal-svg`} />
          <div className={styles.loadingModalText}>{t('authLoggingIn')}</div>
        </div>
      </Modal>
    </div>
  );
};

const Login: React.FC<LoginComProps> = (props) => {
  return (
    <>
      <div className="login-wrapper">
        <LoginCom {...props} />
      </div>
    </>
  );
};

export default Login;
