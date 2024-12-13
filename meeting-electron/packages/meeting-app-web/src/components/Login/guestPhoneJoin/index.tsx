import React, { useState, useMemo } from 'react';
import { PhoneInput, VerifyCodeInput } from '../../Input';
import './index.less';
import { Button } from 'antd';
import classnames from 'classnames';
import Toast from '@meeting-module/components/common/toast';
import LoginHeader from '../header';
import { useTranslation } from 'react-i18next';
import { ShowType } from '..';
import { JoinOptions } from '../guestJoin';
import usePasswordJoin from '../hook/usePassword';

interface LoginComProps {
  style?: Record<string, string>;
  goTo: (type: ShowType) => void;
  onJoin: (joinOptions: JoinOptions) => Promise<void>;
  joinInfo: {
    meetingNum: string;
    nickname: string;
    openVideo: boolean;
    openAudio: boolean;
  };
}
export const PhoneJoinCom: React.FC<LoginComProps> = ({
  style = {},
  goTo,
  joinInfo,
  onJoin,
}) => {
  const { t } = useTranslation();
  const [phone, setPhone] = useState({ value: '', valid: false });
  const [code, setCode] = useState({ value: '', valid: false });
  const [loading, setLoading] = useState(false);
  const { handleJoinPasswordMeeting, passwordRef } = usePasswordJoin();

  const handleJoinMeeting = async () => {
    setLoading(true);
    const { meetingNum, nickname, openAudio, openVideo } = joinInfo;
    const payload = {
      phoneNumber: phone.value,
      smsCode: code.value,
      meetingNum: meetingNum,
      nickname,
      password: passwordRef.current,
      openAudio,
      openVideo,
    };

    try {
      await onJoin?.(payload);
    } catch (err: unknown) {
      const error = err as { code: number; msg: string; message: string };

      if (error.code === 1020) {
        handleJoinPasswordMeeting(error, handleJoinMeeting);
      } else {
        console.log(err);
        Toast.fail(error.msg || error.message);
      }
    } finally {
      setLoading(false);
    }
  };

  // 账号密码登录时不需要校验格式
  // 验证码登录时需要校验手机号和验证码格式
  const btnValid = useMemo(() => {
    return code.valid && phone.valid;
  }, [code.valid, phone.valid]);

  const handleGoBack = () => {
    goTo?.('home');
  };

  return (
    <div
      className={'guestPhoneJoin login-login' + ' login-panel'}
      style={{ ...style }}
    >
      <section className={classnames('login-content')}>
        <LoginHeader
          title={t('meetingGuestJoinAuthTitle')}
          goBack={() => handleGoBack()}
        />
        <div className="meeting-guest-join-auth-tip">
          {t('meetingGuestJoinAuthTip')}
        </div>
        <div className="input-container">
          <PhoneInput value={phone.value} set={setPhone} errorTip="" />

          <VerifyCodeInput
            value={code.value}
            set={setCode}
            phone={phone.valid && phone.value}
            scene={1}
            meetingNum={joinInfo.meetingNum}
          />
        </div>
        <Button
          type="primary"
          disabled={!phone.valid || !code.valid}
          className={`login-button ${btnValid ? '' : 'inactive'}`}
          onClick={handleJoinMeeting}
          loading={loading}
        >
          {t('confirmJoinMeeting')}
        </Button>
      </section>
    </div>
  );
};

const GuestPhoneJoin: React.FC<LoginComProps> = (props) => {
  return (
    <>
      <div className="login-wrapper">
        <PhoneJoinCom {...props} />
      </div>
    </>
  );
};

export default GuestPhoneJoin;
