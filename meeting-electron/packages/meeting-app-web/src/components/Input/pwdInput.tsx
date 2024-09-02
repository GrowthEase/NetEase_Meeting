import React, { FC, useCallback } from 'react';
import BaseInput, { InputProps } from './baseInput';
import './index.less';
import { checkPassword } from 'nemeeting-web-sdk';
import { useTranslation } from 'react-i18next';

const PwdInput: FC<InputProps & { needCheck?: boolean }> = (props) => {
  const { t } = useTranslation();
  const checkPwd = useCallback((value: string) => {
    return checkPassword(value);
  }, []);

  const eyeIcon = (visible: boolean) => {
    return (
      <svg
        style={{ width: '20px', height: '20px' }}
        className={'icon'}
        aria-hidden="true"
      >
        <use
          xlinkHref={`${
            !visible ? '#iconpassword-hidex' : '#iconpassword-displayx'
          }`}
        ></use>
      </svg>
    );
  };

  return (
    <BaseInput
      ispassword={'true'}
      className={`pwdInput baseInputContent`}
      validator={props.needCheck ? checkPwd : undefined}
      iconRender={eyeIcon}
      placeholder={props.placeholder || t('authEnterPassword')}
      errorTip=""
      maxLength="18"
      size="large"
      {...props}
    />
  );
};

export default PwdInput;
