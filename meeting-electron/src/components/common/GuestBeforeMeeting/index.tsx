import { useTranslation } from 'react-i18next'
import { css, cx } from '@emotion/css'
import { Button, Checkbox, Input } from 'antd'
import { useEffect, useRef, useState } from 'react'
import { isLastCharacterEmoji } from '../../../utils'
import Toast from '../toast'
import NEMeetingKit from '../../../index'
import Header from '../../../../app/src/components/layout/Header'
import Footer from '../../../../app/src/components/layout/Footer'
import qs from 'qs'
import {
  PhoneInput,
  VerifyCodeInput,
} from '../../../../app/src/components/input'
import { JoinOptions } from '../../../types'
import Modal from '../Modal'
import { useUpdateEffect } from 'ahooks'

const guestBeforeMeetingContainerCls = css`
  width: 375px;
  height: 670px;
  background: #ffffff;
  box-shadow: 0 10px 30px rgba(47, 56, 111, 0.1);
  border-radius: 10px;
  box-sizing: border-box;
  padding: 24px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  @media screen and (max-width: 590px) {
    width: 100%;
    height: 100%;
    box-shadow: none;
    border-radius: 0;
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: #ffffff;
  }
`

const guestBeforeMeetingTitleCls = css`
  font-size: 24px;
  color: #333333;
  font-weight: 500;
`

const guestBeforeMeetingH5TitleCls = css`
  position: relative;
  font-size: 18px;
  font-weight: 500;
  text-align: center;
  color: #333333;
  height: 50px;
  line-height: 50px;
  border-bottom: 1px solid #dcdce0;
  margin: -24px -24px 0 -24px;
  .login-btn {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
  }
`

const guestBeforeMeetingVideoView = css`
  height: 184px;
  margin: 16px auto;
  background: #292933;
  border-radius: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  .iconfont {
    font-size: 24px;
    color: #fe3b30;
  }
  @media screen and (max-width: 590px) {
    height: 280px;
  }
`

const guestBeforeMeetingBtnGroupCls = css`
  display: flex;
  justify-content: space-around;
  align-items: center;
`
const guestBeforeMeetingBtnCls = css`
  width: 140px;
  height: 48px;
  border-radius: 16px;
  background: #ffffff;
  border: 1px solid #dcdce0;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 16px;
  cursor: pointer;
  .iconfont {
    font-size: 24px;
    margin-right: 8px;
  }
  .closed {
    color: #fe3b30;
  }
`

const guestBeforeMeetingNameInput = css`
  position: relative;
  input {
    text-align: center;
    display: block;
    height: 50px;
    border-radius: 16px;
    background: #f2f3f5;
    width: 100%;
    border: none;
    outline: none;
    font-size: 16px;
    &:focus {
      border: none;
    }
    &:hover {
      border: none;
    }
    &::placeholder {
      color: #a8acb2;
    }
  }
  .input-extra {
    color: #4096ff;
    margin-top: 8px;
    text-align: center;
  }
  .iconfont {
    position: absolute;
    right: 16px;
    top: 18px;
    font-size: 16px;
    color: #a8acb2;
    cursor: pointer;
  }
`

const guestBeforeMeetingJoinBtnCls = css`
  border-radius: 36px;
  width: 100%;
  height: 36px;
  height: 50px;
  background: #337eff;
  margin: 16px 0 10px;
  &.nemeeting-btn-primary:disabled {
    cursor: not-allowed;
    border: none;
    color: #fff;
    background-color: rgba(22, 119, 255, 0.5);
    box-shadow: none;
  }
`

const guestBeforeMeetingJoinAgreementCls = css`
  font-size: 14px;
  color: #999999;
  display: flex;
  width: 100%;
  align-items: center;
  .agree-checkbox {
    margin-right: 4px;
    flex-shrink: 0;
  }
  .agree-text {
    text-align: center;
    flex: 1;
    a {
      margin: 0 4px;
      color: #337eff;
    }
  }
`

const guestBeforeMeetingJoinAuthBackCls = css`
  cursor: pointer;
`

const guestBeforeMeetingJoinAuthTitleCls = css`
  font-size: 28px;
  font-weight: 500;
  color: #222222;
  margin: 16px 0;
`
const guestBeforeMeetingJoinAuthTipCls = css`
  font-size: 14px;
  color: #333333;
`

const guestBeforeMeetingJoinAuthInputCls = css`
  margin: 20px 0;
`

const domain = process.env.MEETING_DOMAIN

interface GuestBeforeMeetingProps {
  className?: string
  isH5?: boolean
  onLogin?: () => void
}

const GuestBeforeMeeting: React.FC<GuestBeforeMeetingProps> = (props) => {
  const { isH5, onLogin } = props
  const { t, i18n: i18next } = useTranslation()
  const [inMeeting, setInMeeting] = useState(false)
  const [isAgree, setIsAgree] = useState(false)
  const [audioOpen, setAudioOpen] = useState(false)
  const [videoOpen, setVideoOpen] = useState(false)
  const [inputExtraShow, setInputExtraShow] = useState(false)
  const [joinMeetingLoading, setJoinMeetingLoading] = useState(false)
  const [needAuth, setNeedAuth] = useState(false)
  const [name, setName] = useState('')
  const [phone, setPhone] = useState({ value: '', valid: false })
  const [code, setCode] = useState({ value: '', valid: false })
  const [appKey, setAppKey] = useState('')

  const videoViewRef = useRef(null)
  const meetingNumRef = useRef('')
  const passwordRef = useRef<string>('')
  const isComposingRef = useRef(false)

  const previewController = NEMeetingKit.actions.neMeeting?.previewController

  function checkIsAgree() {
    if (!isAgree) {
      Toast.info(t('authPrivacyCheckedTips'))
      return false
    }
    return true
  }

  function handleInputChange(value: string) {
    setInputExtraShow(false)
    let userInput = value
    if (!isComposingRef.current) {
      let inputLength = 0
      for (let i = 0; i < userInput.length; i++) {
        // 检测字符是否为中文字符
        if (userInput.charCodeAt(i) > 127) {
          inputLength += 2
        } else {
          inputLength += 1
        }
        // 判断当前字符长度是否超过限制，如果超过则终止 for 循环
        if (inputLength > 20) {
          if (isLastCharacterEmoji(userInput)) {
            userInput = userInput.slice(0, -2)
          } else {
            userInput = userInput.slice(0, i)
          }
          setInputExtraShow(true)
          break
        }
      }
    }
    setName(userInput)
  }

  function joinMeeting() {
    if (checkIsAgree()) {
      if (phone.value && code.value && needAuth) {
        guestRequest(phone.value, code.value)
      } else {
        guestRequest()
      }
    }
  }

  function fetchJoin(options: JoinOptions): Promise<void> {
    return new Promise((resolve, reject) => {
      NEMeetingKit.actions.join(
        {
          ...options,
          showCloudRecordingUI: true,
          showMeetingRemainingTip: true,
          env: 'web',
          watermarkConfig: {
            name: options.nickName,
          },
        },
        function (e: any) {
          if (e) {
            reject(e)
          }
          resolve()
        }
      )
    })
  }

  function guestRequest(phoneNum?: string, verifyCode?: string) {
    setJoinMeetingLoading(true)
    NEMeetingKit.actions.neMeeting
      ?.getGuestInfo({
        meetingNum: meetingNumRef.current,
        phoneNum: phoneNum,
        verifyCode: verifyCode,
      })
      .then((res) => {
        const { meetingUserUuid, meetingUserToken, meetingAuthType } = res
        NEMeetingKit.actions.login(
          {
            accountId: meetingUserUuid,
            accountToken: meetingUserToken,
            isTemporary: true,
            authType: meetingAuthType,
          },
          (e) => {
            if (!e) {
              let modal
              const joinOptions: JoinOptions = {
                meetingNum: meetingNumRef.current,
                nickName: name,
                video: videoOpen ? 1 : 2,
                audio: audioOpen ? 1 : 2,
              }
              fetchJoin({
                ...joinOptions,
              })
                .then(() => {
                  setInMeeting(true)
                })
                .catch((e) => {
                  const InputComponent = (inputValue) => {
                    return (
                      <Input
                        placeholder={t('livePasswordTip')}
                        value={inputValue}
                        maxLength={6}
                        allowClear
                        onChange={(event) => {
                          passwordRef.current = event.target.value.replace(
                            /[^0-9]/g,
                            ''
                          )
                          modal.update({
                            content: <>{InputComponent(passwordRef.current)}</>,
                            okButtonProps: {
                              disabled: !passwordRef.current,
                              style: !passwordRef.current
                                ? { color: 'rgba(22, 119, 255, 0.5)' }
                                : {},
                            },
                          })
                        }}
                      />
                    )
                  }
                  if (e.code === 1020) {
                    passwordRef.current = ''
                    modal = Modal.confirm({
                      title: t('meetingPassword'),
                      width: 300,
                      content: <>{InputComponent('')}</>,
                      okButtonProps: {
                        disabled: true,
                        style: { color: 'rgba(22, 119, 255, 0.5)' },
                      },
                      onOk: async () => {
                        try {
                          await fetchJoin({
                            ...joinOptions,
                            password: passwordRef.current,
                          })
                          setInMeeting(true)
                        } catch (e: any) {
                          if (e.code === 1020) {
                            modal.update({
                              content: (
                                <>
                                  {InputComponent(passwordRef.current)}
                                  <div
                                    style={{
                                      color: '#fe3b30',
                                      textAlign: 'left',
                                      margin: '5px 0px -10px 0px',
                                    }}
                                  >
                                    {t('meetingWrongPassword')}
                                  </div>
                                </>
                              ),
                            })
                          } else if (e.code === 3102) {
                            modal.destroy()
                          }
                          throw e
                        }
                      },
                    })
                  } else {
                    throw e
                  }
                })
                .finally(() => {
                  setJoinMeetingLoading(false)
                })
            } else {
              setJoinMeetingLoading(false)
            }
          }
        )
      })
      .catch((err) => {
        setJoinMeetingLoading(false)
        if (err.code === 3433) {
          setNeedAuth(true)
        } else {
          Toast.fail(err.msg || t('networkAbnormality'))
        }
      })
  }

  useEffect(() => {
    // 创建URL对象
    const qsObj = qs.parse(window.location.href.split('?')[1]?.split('#/')[0])

    const meetingId = qsObj.meetingId as string
    const meetingAppKey = qsObj.meetingAppKey as string

    if (meetingId && meetingAppKey) {
      meetingNumRef.current = meetingId
      setAppKey(meetingAppKey)
      const config = {
        appKey: meetingAppKey, //云信服务appKey
        meetingServerDomain: domain, //会议服务器地址，支持私有化部署
        locale: i18next.language, //语言
      }
      NEMeetingKit.actions.init(0, 0, config, () => {
        console.log
      })
      NEMeetingKit.actions.on('roomEnded', (reason: any) => {
        console.log('roomEnded>>>>>', reason)
        setTimeout(() => {
          window.location.reload()
        })
      })
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useUpdateEffect(() => {
    if (videoOpen && videoViewRef.current && !needAuth) {
      previewController?.startPreview(videoViewRef.current)
      return () => {
        previewController?.stopPreview()
      }
    }
  }, [videoOpen, needAuth])

  return (
    <>
      {inMeeting ? null : (
        <>
          <Header onLogin={onLogin} />
          <div className={guestBeforeMeetingContainerCls}>
            {!needAuth ? (
              <>
                <div>
                  {isH5 ? (
                    <div className={guestBeforeMeetingH5TitleCls}>
                      <Button
                        className="login-btn"
                        type="link"
                        onClick={onLogin}
                      >
                        {t('authLogin')}
                      </Button>
                      {t('meetingJoin')}
                    </div>
                  ) : (
                    <div className={guestBeforeMeetingTitleCls}>
                      {t('meetingJoin')}
                    </div>
                  )}
                  <div
                    className={guestBeforeMeetingVideoView}
                    ref={videoViewRef}
                  >
                    {videoOpen ? null : (
                      <svg className="icon iconfont">
                        <use xlinkHref="#iconyx-tv-video-offx"></use>
                      </svg>
                    )}
                  </div>
                  <div className={guestBeforeMeetingBtnGroupCls}>
                    <div
                      className={guestBeforeMeetingBtnCls}
                      onClick={() => setAudioOpen(!audioOpen)}
                    >
                      <svg
                        className={cx('icon iconfont', {
                          ['closed']: !audioOpen,
                        })}
                      >
                        <use
                          xlinkHref={
                            audioOpen
                              ? '#iconyx-tv-voice-onx'
                              : '#iconyx-tv-voice-offx'
                          }
                        ></use>
                      </svg>
                      {t('microphone')}
                    </div>
                    <div
                      className={guestBeforeMeetingBtnCls}
                      onClick={() => setVideoOpen(!videoOpen)}
                    >
                      <svg
                        className={cx('icon iconfont', {
                          ['closed']: !videoOpen,
                        })}
                      >
                        <use
                          xlinkHref={
                            videoOpen
                              ? '#iconyx-tv-video-onx'
                              : '#iconyx-tv-video-offx'
                          }
                        ></use>
                      </svg>
                      {t('camera')}
                    </div>
                  </div>
                </div>
                <div>
                  <div className={guestBeforeMeetingNameInput}>
                    <input
                      title="name"
                      type="text"
                      placeholder={t('meetingGuestJoinNamePlaceholder')}
                      value={name}
                      onChange={(e) => handleInputChange(e.currentTarget.value)}
                      onCompositionStart={() => (isComposingRef.current = true)}
                      onCompositionEnd={(e) => {
                        isComposingRef.current = false
                        handleInputChange(e.currentTarget.value)
                      }}
                    />
                    {name ? (
                      <svg
                        className="icon iconfont"
                        onClick={() => {
                          setName('')
                          setInputExtraShow(false)
                        }}
                      >
                        <use xlinkHref="#iconcross-y1x"></use>
                      </svg>
                    ) : null}
                    {inputExtraShow ? (
                      <div className="input-extra">{t('reNameTips')}</div>
                    ) : null}
                  </div>
                  <Button
                    type="primary"
                    className={guestBeforeMeetingJoinBtnCls}
                    disabled={!name}
                    onClick={() => joinMeeting()}
                    loading={joinMeetingLoading}
                  >
                    {t('meetingJoin')}
                  </Button>
                  <div className={guestBeforeMeetingJoinAgreementCls}>
                    <Checkbox
                      className="agree-checkbox"
                      onChange={(e) => {
                        setIsAgree(e.target.checked)
                      }}
                      checked={isAgree}
                    />
                    <span className="agree-text">
                      {t('authHasReadAndAgreeMeeting')}
                      <a
                        href="https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml"
                        target="_blank"
                        title={t('authPrivacy')}
                        onClick={(e) => {
                          if (window.ipcRenderer) {
                            window.ipcRenderer.send(
                              'open-browser-window',
                              'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml'
                            )
                            e.preventDefault()
                          }
                        }}
                      >
                        {t('authPrivacy')}
                      </a>
                      {t('authAnd')}
                      <a
                        href="https://netease.im/meeting/clauses?serviceType=0"
                        target="_blank"
                        title={t('authUserProtocol')}
                        onClick={(e) => {
                          if (window.ipcRenderer) {
                            window.ipcRenderer.send(
                              'open-browser-window',
                              'https://netease.im/meeting/clauses?serviceType=0'
                            )
                            e.preventDefault()
                          }
                        }}
                      >
                        {t('authUserProtocol')}
                      </a>
                    </span>
                  </div>
                </div>
              </>
            ) : (
              <>
                <div>
                  <svg
                    className={cx(
                      'icon iconfont',
                      guestBeforeMeetingJoinAuthBackCls
                    )}
                    onClick={() => setNeedAuth(false)}
                  >
                    <use xlinkHref="#iconyx-returnx"></use>
                  </svg>
                  <div className={guestBeforeMeetingJoinAuthTitleCls}>
                    {t('meetingGuestJoinAuthTitle')}
                  </div>
                  <div className={guestBeforeMeetingJoinAuthTipCls}>
                    {t('meetingGuestJoinAuthTip')}
                  </div>
                  <div className={guestBeforeMeetingJoinAuthInputCls}>
                    <PhoneInput set={setPhone} value={phone.value} />
                  </div>
                  <div className={guestBeforeMeetingJoinAuthInputCls}>
                    <VerifyCodeInput
                      appKey={appKey}
                      value={code.value}
                      set={setCode}
                      phone={phone.valid && phone.value}
                      scene={3}
                    />
                  </div>
                  <Button
                    type="primary"
                    className={guestBeforeMeetingJoinBtnCls}
                    disabled={!phone.value || !code.value ? true : false}
                    onClick={() => joinMeeting()}
                    loading={joinMeetingLoading}
                  >
                    {t('meetingJoin')}
                  </Button>
                  {/* <Button
                  type="primary"
                  ghost
                  className={guestBeforeMeetingJoinBtnCls}
                  onClick={() => joinMeeting()}
                >
                  {t('globalCancel')}
                </Button> */}
                </div>
              </>
            )}
          </div>
          <Footer className="whiteTheme" logo={false} />
        </>
      )}
      <div
        id="ne-web-meeting"
        style={{
          width: '100%',
          height: '100%',
          display: inMeeting ? 'block' : 'none',
        }}
      />
    </>
  )
}

export default GuestBeforeMeeting
