import React, { FC, useEffect, useMemo, useState } from 'react'
import BaseInput, { InputProps } from './baseInput'
import './index.less'
import { sendVerifyCodeApi } from '../../api'
import { Button } from 'antd'
import Toast from '../../../../components/common/toast'
import { useTranslation } from 'react-i18next'

const VerifyCodeInput: FC<InputProps> = (props) => {
  const { t } = useTranslation()
  const { phone, scene, appKey, ...otherProps } = props
  const [count, setCount] = useState(60)

  const checkCode = (value: string) => {
    return /^\d{6}$/.test(value)
  }

  useEffect(() => {
    if (count < 1) {
      setCount(60)
    } else if (count < 60) {
      setTimeout(() => {
        setCount(count - 1)
      }, 1000)
    }
  }, [count])
  const sendCode = () => {
    if (!phone) return
    setCount(59)
    sendVerifyCodeApi({
      appKey,
      mobile: phone,
      scene,
    }).catch((e) => {
      Toast.fail(e.msg || e.message || e.code)
    })
  }

  const sendCodeStyle = {
    fontSize: '14px',
    // width: '70px',
    margin: 0,
    padding: 0,
    height: '30px',
  }
  const suffix = useMemo(() => {
    return count < 60 ? (
      <span style={{ fontSize: 14, color: '#333' }}>
        <span className="countdown">{count}s</span>
        {t('authResendCode')}
      </span>
    ) : (
      <Button
        onClick={sendCode}
        style={sendCodeStyle}
        disabled={!phone}
        type="link"
        className="send-code-button"
      >
        {t('authGetCheckCode')}
      </Button>
    )
  }, [phone, count])

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
  )
}

export default VerifyCodeInput
