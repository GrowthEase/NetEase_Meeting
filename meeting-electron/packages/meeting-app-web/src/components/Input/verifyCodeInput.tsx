import React, {
  FC,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import BaseInput, { InputProps } from './baseInput';
import './index.less';
import { sendVerifyCodeApi, sendVerifyCodeApiByGuest } from '../../api';
import { Button } from 'antd';
import Toast from '@meeting-module/components/common/toast';
import { useTranslation } from 'react-i18next';

const VerifyCodeInput: FC<InputProps> = (props) => {
  const { t } = useTranslation();
  const { phone, scene, appKey, meetingNum, ...otherProps } = props;
  const [count, setCount] = useState(60);
  const countTimerRef = useRef<NodeJS.Timeout | number>();

  const checkCode = (value: string) => {
    return /^\d{6}$/.test(value);
  };

  useEffect(() => {
    if (count < 1) {
      setCount(60);
    } else if (count < 60) {
      countTimerRef.current = setTimeout(() => {
        countTimerRef.current = undefined;
        setCount(count - 1);
      }, 1000);
    } else {
      countTimerRef.current && clearTimeout(countTimerRef.current);
      countTimerRef.current = undefined;
    }
  }, [count]);

  const sendCode = useCallback(() => {
    if (!phone) return;
    setCount(59);
    if (meetingNum) {
      sendVerifyCodeApiByGuest(meetingNum, phone as string).catch((e) => {
        setCount(60);
        Toast.fail(e.msg || e.message || e.code);
      });
    } else {
      sendVerifyCodeApi({
        appKey: appKey as string,
        mobile: phone as string,
        scene: scene as number,
      }).catch((e) => {
        setCount(60);
        Toast.fail(e.msg || e.message || e.code);
      });
    }
  }, [phone, scene, appKey]);

  const suffix = useMemo(() => {
    return count < 60 ? (
      <span style={{ fontSize: 14, color: '#333' }}>
        <span className="countdown">{count}s</span>
        {t('authResendCode')}
      </span>
    ) : (
      <Button
        onClick={sendCode}
        style={{
          fontSize: '14px',
          margin: 0,
          padding: 0,
          height: '30px',
        }}
        disabled={!phone}
        type="link"
        className="send-code-button"
      >
        {t('authGetCheckCode')}
      </Button>
    );
  }, [phone, count]);

  return (
    <BaseInput
      className={`verifyCodeInput baseInputContent`}
      validator={checkCode}
      hasClear={true}
      suffix={suffix}
      placeholder={t('authEnterCheckCode')}
      maxLength={'6'}
      size="large"
      format="number"
      {...otherProps}
    />
  );
};

export default VerifyCodeInput;
