/**
 * 自定义input组件，支持：
 *   - 双向绑定
 *   - 数据校验
 *   - 错误信息展示
 */
import React, { FC, FormEvent, useEffect, useState } from 'react';
import './index.less';
import { Input } from 'antd';
import { NEProps } from 'nemeeting-web-sdk';

export interface InputProps {
  set: (params: { value: string; valid: boolean }) => void;
  validator?: (value: string) => boolean;
  onChangeValidator?: (value: string) => boolean;
  required?: boolean;
  errorTip?: string;
  format?: string; // format为number，会限制输入的内容只能是数字
  hasClear?: boolean;
  onValueChange?: (value: string) => string;
  defaultValue?: string;
  prefix?: React.ReactNode;
  meetingNum?: string;
  [key: string]: NEProps;
}

const BaseInput: FC<InputProps> = (props) => {
  const {
    required = true,
    validator = () => true,
    onChangeValidator = () => true,
    set,
    errorTip,
    hasClear = false,
    defaultValue = '',
    prefix,
    onValueChange,
    ...otherProps
  } = props;
  const [valid, setValid] = useState(true);
  const [baseValue, setBaseValue] = useState('');

  useEffect(() => {
    setBaseValue(defaultValue);
  }, [defaultValue]);

  const inputChange = (e: FormEvent<HTMLInputElement>) => {
    let value = e.currentTarget.value;

    if (onValueChange) {
      value = onValueChange(value);
    }

    if (!onChangeValidator(value)) return;
    if (!checkFormat(value)) return;
    const tempValid = checkVaild(value);

    setBaseValue(value);
    set({
      value,
      valid: tempValid,
    });
    setValid(tempValid);
  };

  const checkVaild = (value: string) => {
    if (value) {
      return validator ? validator(value) : true;
    } else {
      return !required;
    }
  };

  const checkFormat = (value: string) => {
    if (props.format === 'number' && !(+value >= 0)) {
      return false;
    }

    return true;
  };

  return (
    <div className={'baseInput'}>
      {otherProps.ispassword === 'true' ? (
        <Input.Password
          prefix={prefix}
          className={'baseInputContent'}
          size={otherProps.size || 'large'}
          allowClear={hasClear}
          onChange={inputChange}
          value={baseValue}
          {...otherProps}
        />
      ) : (
        <Input
          prefix={prefix}
          className={'baseInputContent'}
          size={otherProps.size || 'large'}
          allowClear={hasClear}
          onChange={inputChange}
          value={baseValue}
          {...otherProps}
        />
      )}

      {!valid && <div className={'tip'}>{errorTip}</div>}
    </div>
  );
};

export default BaseInput;
