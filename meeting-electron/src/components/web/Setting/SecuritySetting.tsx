import './index.less'
import { Button, Form, Input } from 'antd'
import React, { useEffect, useState } from 'react'

import { IPCEvent, LoginUserInfo } from '../../../../app/src/types'
import Modal from '../../common/Modal'
import { useTranslation } from 'react-i18next'
import { modifyPasswordApi } from '../../../../app/src/api'
import { checkPassword, md5Password } from '../../../utils'
import classNames from 'classnames'
import {
  LOCALSTORAGE_LOGIN_BACK,
  LOCALSTORAGE_USER_INFO,
} from '../../../config'

const SecuritySetting: React.FC = () => {
  const { t } = useTranslation()
  const [userInfo, setUserInfo] = useState<
    (LoginUserInfo & { appKey: string }) | null
  >(null)
  const [openModifyPwd, setOpenModifyPwd] = useState(false)
  const [errorTip, setErrorTip] = useState('')
  const [heightLithTip, setHeightLitTip] = useState(false)
  const [form] = Form.useForm()

  const oldPwd = Form.useWatch('oldPwd', form)
  const newPwd = Form.useWatch('newPwd', form)
  const confirmPwd = Form.useWatch('confirmPwd', form)

  useEffect(() => {
    // 从localstroage中获取用户信息
    const userInfoStr = localStorage.getItem(LOCALSTORAGE_USER_INFO)

    if (userInfoStr) {
      try {
        const userInfo = JSON.parse(userInfoStr || '{}')

        console.log('userInfo', userInfo)
        setUserInfo(userInfo)
      } catch (error) {
        console.log('parseUserInfoError', error)
      }
    }
  }, [])
  useEffect(() => {
    if (newPwd) {
      setHeightLitTip(true)
    } else {
      setHeightLitTip(false)
    }
  }, [newPwd])
  useEffect(() => {
    setErrorTip('')
  }, [oldPwd, newPwd, confirmPwd])
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
    )
  }

  const onClickModifyPassword = () => {
    setOpenModifyPwd(true)
  }

  const onHandleModifyPwd = () => {
    const { oldPwd, newPwd, confirmPwd } = form.getFieldsValue()

    if (!checkPassword(confirmPwd)) {
      setErrorTip(t('newPwdNotMath'))
      return
    } else if (newPwd !== confirmPwd) {
      setErrorTip(t('newPwdNotMathReEnter'))
      return
    }

    modifyPasswordApi({
      password: md5Password(oldPwd),
      newPassword: md5Password(confirmPwd),
      username: userInfo?.username as string,
      appKey: userInfo?.appKey as string,
    })
      .then(() => {
        localStorage.removeItem(LOCALSTORAGE_USER_INFO)
        localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK)
        // 官网登录信息也干掉
        localStorage.removeItem('loginWayV2')
        localStorage.removeItem('loginAppNameSpaceV2')
        if (window.isElectronNative) {
          window.ipcRenderer?.send(IPCEvent.relaunch)
        } else {
          window.location.reload()
        }
      })
      .catch((e) => {
        setErrorTip(e.msg)
      })
  }

  return (
    <div className="nemeeting-security-and-account">
      <section>
        <div className="">
          <span className="security-account-title">
            {t('settingAccountInfo')}
          </span>
          <span className="security-account-tip">
            （{t('settingConnectAdmin')}）
          </span>
        </div>
        <div className="security-account-item-wrap">
          <span className="security-account-label security-account-item">
            {t('settingUserName')}：
          </span>
          <span className="security-account-item">
            {userInfo?.nickname || t('authUnavailable')}
          </span>
        </div>
        <div className="security-account-item-wrap">
          <span className="security-account-label security-account-item">
            {t('authMobileNum')}：
          </span>
          <span className="security-account-item">
            {userInfo?.phoneNumber || t('authUnavailable')}
          </span>
        </div>
        <div className="security-account-item-wrap">
          <span className="security-account-label security-account-item">
            {t('settingEmail')}：
          </span>
          <span className="security-account-item">
            {userInfo?.email || t('authUnavailable')}
          </span>
        </div>
      </section>
      <section className="nemeeting-security-section">
        <div className="security-account-title">
          {t('settingAccountSecurity')}
        </div>
        <div className="security-account-modify">
          <div>
            <span className="security-account-item">
              {t('settingChangePassword')}
            </span>
            <span className="security-account-tip">
              （{t('settingChangePasswordTip')}）
            </span>
          </div>
          <Button shape="round" onClick={onClickModifyPassword}>
            {t('settingChangePassword')}
          </Button>
        </div>
      </section>
      <Modal
        open={openModifyPwd}
        title={t('settingChangePassword')}
        width={375}
        wrapClassName="security-meeting-modal-wrap"
        getContainer={false}
        maskClosable={false}
        afterClose={() => {
          form.resetFields()
          setErrorTip('')
        }}
        destroyOnClose
        footer={
          <div className="before-meeting-modal-footer">
            <Button
              className="before-meeting-modal-footer-button"
              disabled={oldPwd && newPwd && confirmPwd ? false : true}
              type="primary"
              onClick={() => onHandleModifyPwd()}
            >
              {t('globalSure')}
            </Button>
          </div>
        }
        onCancel={() => setOpenModifyPwd(false)}
      >
        <div className="security-account-input-wrap">
          <Form form={form}>
            <Form.Item name="oldPwd" noStyle>
              <Input.Password
                iconRender={eyeIcon}
                className="security-account-input"
                placeholder={t('settingEnterOldPassword')}
              />
            </Form.Item>
            <Form.Item name="newPwd" noStyle>
              <Input.Password
                iconRender={eyeIcon}
                className="security-account-input"
                placeholder={t('settingEnterNewPassword')}
              />
            </Form.Item>
            <div
              className={classNames([
                'security-account-input-tip',
                {
                  'security-account-input-tip-light': heightLithTip,
                },
              ])}
            >
              {t('settingValidatorPwdTip')}
            </div>
            <Form.Item name="confirmPwd" noStyle>
              <Input.Password
                iconRender={eyeIcon}
                className="security-account-input"
                placeholder={t('settingEnterNewPasswordConfirm')}
              />
            </Form.Item>
            <div
              style={{ visibility: errorTip ? 'visible' : 'hidden' }}
              className="security-account-error-tip"
            >
              {errorTip}
            </div>
          </Form>
        </div>
      </Modal>
    </div>
  )
}

export default SecuritySetting
