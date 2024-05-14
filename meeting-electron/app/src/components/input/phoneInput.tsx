import React, { FC } from 'react';
import BaseInput, { InputProps } from './baseInput';
// import { Icon } from 'antd';
import './index.less';
import { useTranslation } from 'react-i18next';

const PhoneInput: FC<InputProps> = (props) => {
  const { t } = useTranslation();
  const checkPhone = (value: string) => {
    return /^1[3,4,5,6,7,8,9]\d{9}/.test(value);
  };

  const onChangeValidator = (value: string) => {
    return /^\d*$/.test(value);
  };

  const getCheckedPhone = (str: string) => {
    return str.replace(/\D/g, '');
  };
  const closeIcon = (
    // <Icon
    //   type="close-circle-fill"
    //   onClick={() => props.set({ value: '', valid: false })}
    // />
    <div>{'<'}</div>
  );

  return (
    <BaseInput
      className={`phoneInput baseInputContent`}
      validator={checkPhone}
      onValueChange={getCheckedPhone}
      hasClear={true}
      prefix={<div className={'phoneInputNumber'}>+86</div>}
      placeholder={t('authEnterMobile')}
      errorTip=""
      maxLength="11"
      size="large"
      format="number"
      onChangeValidator={onChangeValidator}
      {...props}
    />
  );
};

export default PhoneInput;
