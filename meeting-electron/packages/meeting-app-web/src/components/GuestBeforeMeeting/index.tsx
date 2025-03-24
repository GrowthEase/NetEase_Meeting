import { useTranslation } from 'react-i18next';
import { css, cx } from '@emotion/css';
import { Button, Checkbox, Input } from 'antd';
import { Switch } from 'antd-mobile/es';
import React, { useEffect, useRef, useState } from 'react';
import { isLastCharacterEmoji } from '@meeting-module/utils';
import { Toast } from 'nemeeting-web-sdk';
import NEMeetingKit from '@meeting-module/index';
import Header from '../Layout/Header';
import Footer from '../Layout/Footer';
import qs from 'qs';
import { PhoneInput, VerifyCodeInput } from '../Input';
import { useUpdateEffect } from 'ahooks';
import Modal from '@meeting-module/components/common/Modal';
import { JoinOptions } from '@meeting-module/types';
import { IPCEvent } from '../../types';
import './index.less';
import UnSupportBrowserModal from '../web/BeforeMeetingModal/unSupportBrowser';
import { checkSystemRequirements } from '../web/BeforeMeetingHome/neMeetingKit';
import browserPng from '../../assets/browser.png';

interface CommonError {
  code: number;
  msg: string;
}

const guestBeforeMeetingJoinAuthBackCls = css`
  cursor: pointer;
`;

const guestBeforeMeetingJoinAuthTitleCls = css`
  font-size: 28px;
  font-weight: 500;
  color: #222222;
  margin: 16px 0;
`;
const guestBeforeMeetingJoinAuthTipCls = css`
  font-size: 14px;
  color: #333333;
`;

const guestBeforeMeetingJoinAuthInputCls = css`
  margin: 20px 0;
`;

const domain = process.env.MEETING_DOMAIN;

interface GuestBeforeMeetingProps {
  className?: string;
  isH5?: boolean;
  onLogin?: () => void;
}

const GuestBeforeMeeting: React.FC<GuestBeforeMeetingProps> = (props) => {
  const { onLogin } = props;
  const { t, i18n: i18next } = useTranslation();
  const [inMeeting, setInMeeting] = useState(false);
  const [isAgree, setIsAgree] = useState(false);
  const [audioOpen, setAudioOpen] = useState(false);
  const [videoOpen, setVideoOpen] = useState(false);
  const [inputExtraShow, setInputExtraShow] = useState(false);
  const [joinMeetingLoading, setJoinMeetingLoading] = useState(false);
  const [needAuth, setNeedAuth] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState({ value: '', valid: false });
  const [code, setCode] = useState({ value: '', valid: false });
  const [appKey, setAppKey] = useState('');
  const [isH5, setIsH5] = useState(false);
  // 不支持当前浏览器的弹窗
  const [unSupportBrowserModalOpen, setUnSupportBrowserModalOpen] =
    useState(false);
  const videoViewRef = useRef(null);
  const meetingNumRef = useRef('');
  const passwordRef = useRef<string>('');
  const isComposingRef = useRef(false);

  const previewController = NEMeetingKit.actions.neMeeting?.previewController;

  function checkIsAgree() {
    if (!isAgree) {
      Toast.info(t('authPrivacyCheckedTips'));
      return false;
    }

    return true;
  }

  function handleInputChange(value: string) {
    setInputExtraShow(false);
    let userInput = value;

    if (!isComposingRef.current) {
      let inputLength = 0;

      for (let i = 0; i < userInput.length; i++) {
        // 检测字符是否为中文字符
        if (userInput.charCodeAt(i) > 127) {
          inputLength += 2;
        } else {
          inputLength += 1;
        }

        // 判断当前字符长度是否超过限制，如果超过则终止 for 循环
        if (inputLength > 20) {
          if (isLastCharacterEmoji(userInput)) {
            userInput = userInput.slice(0, -2);
          } else {
            userInput = userInput.slice(0, i);
          }

          setInputExtraShow(true);
          break;
        }
      }
    }

    setName(userInput);
  }

  function joinMeeting() {
    if (!window.isElectronNative && !checkSystemRequirements()) {
      if (isH5) {
        showUnSupportedBrowserModal();
        return;
      } else {
        setUnSupportBrowserModalOpen(true);
        return;
      }
    }

    if (checkIsAgree()) {
      if (phone.value && code.value && needAuth) {
        guestRequest(phone.value, code.value);
      } else {
        guestRequest();
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
            phone: '',
            email: '',
          },
        },
        function (e) {
          if (e) {
            reject(e);
          }

          resolve();
        },
      );
    });
  }

  function guestRequest(phoneNum?: string, verifyCode?: string) {
    setJoinMeetingLoading(true);
    NEMeetingKit.actions.neMeeting
      ?.getGuestInfo({
        meetingNum: meetingNumRef.current,
        phoneNum: phoneNum,
        verifyCode: verifyCode,
      })
      .then((res) => {
        const { meetingUserUuid, meetingUserToken, meetingAuthType } = res;

        NEMeetingKit.actions.login(
          {
            accountId: meetingUserUuid,
            accountToken: meetingUserToken,
            isTemporary: true,
            authType: meetingAuthType,
          },
          (e) => {
            if (!e) {
              let modal;
              const joinOptions: JoinOptions = {
                meetingNum: meetingNumRef.current,
                nickName: name,
                video: videoOpen ? 1 : 2,
                audio: audioOpen ? 1 : 2,
              };

              fetchJoin({
                ...joinOptions,
              })
                .then(() => {
                  setInMeeting(true);
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
                            '',
                          );
                          modal.update({
                            content: <>{InputComponent(passwordRef.current)}</>,
                            okButtonProps: {
                              disabled: !passwordRef.current,
                              style: !passwordRef.current
                                ? { color: 'rgba(22, 119, 255, 0.5)' }
                                : {},
                            },
                          });
                        }}
                      />
                    );
                  };

                  if (e.code === 1020) {
                    passwordRef.current = '';
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
                          });
                          setInMeeting(true);
                        } catch (e: unknown) {
                          const error = e as CommonError;

                          if (error.code === 1020) {
                            modal.update({
                              width: 375,
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
                            });
                          } else if (error.code === 3102) {
                            modal.destroy();
                          }

                          throw e;
                        }
                      },
                    });
                  } else {
                    throw e;
                  }
                })
                .finally(() => {
                  setJoinMeetingLoading(false);
                });
            } else {
              Toast.fail(e.msg || e.message);
              setJoinMeetingLoading(false);
            }
          },
        );
      })
      .catch((err) => {
        setJoinMeetingLoading(false);
        if (err.code === 3433) {
          setNeedAuth(true);
        } else {
          Toast.fail(err.msg || err.message || t('networkAbnormality'));
        }
      });
  }

  // h5 浏览器不支持提示
  function showUnSupportedBrowserModal() {
    Modal.warning({
      title: t('unSupportBrowserTitle'),
      content: (
        <div className="h5-un-support-browser-content">
          <div className="h5-un-support-browser-tip">
            {t('unSupportBrowserTip')}
          </div>
          <img className="h5-browser-png" src={browserPng}></img>
        </div>
      ),
      okText: t('gotIt'),
    });
  }

  useEffect(() => {
    if (!window.isElectronNative && !checkSystemRequirements()) {
      if (isH5) {
        showUnSupportedBrowserModal();
      } else {
        setUnSupportBrowserModalOpen(true);
      }
    }
  }, []);

  // 初始化
  useEffect(() => {
    // 创建URL对象
    const qsObj = qs.parse(window.location.href.split('?')[1]?.split('#/')[0]);

    const meetingId = qsObj.meetingId as string;
    const meetingAppKey = qsObj.meetingAppKey as string;

    if (meetingId && meetingAppKey) {
      meetingNumRef.current = meetingId;
      setAppKey(meetingAppKey);
      const config = {
        appKey: meetingAppKey, //云信服务appKey
        meetingServerDomain: domain, //会议服务器地址，支持私有化部署
        locale: i18next.language, //语言
      };

      NEMeetingKit.actions.init(0, 0, config, () => {
        console.log;
      });
      NEMeetingKit.actions.on('roomEnded', (reason) => {
        console.log('roomEnded>>>>>', reason);
        setTimeout(() => {
          window.location.reload();
        });
      });
    }
  }, []);

  useUpdateEffect(() => {
    if (videoOpen && videoViewRef.current && !needAuth) {
      previewController?.startPreview(videoViewRef.current);
      return () => {
        previewController?.stopPreview();
      };
    }
  }, [videoOpen, needAuth]);

  useEffect(() => {
    function calculateSize() {
      if (document.body.clientWidth < 590 || document.body.clientHeight < 700) {
        setIsH5(true);
      } else {
        setIsH5(false);
      }
    }

    calculateSize();

    window.addEventListener('resize', calculateSize);

    return () => {
      window.removeEventListener('resize', calculateSize);
    };
  }, []);

  return (
    <>
      {inMeeting ? null : (
        <>
          <Header onLogin={onLogin} />
          <div
            className={`guest-before-meeting-container-cls ${
              isH5 ? 'guest-before-meeting-container-h5' : ''
            }`}
          >
            {!needAuth ? (
              <>
                <div>
                  {isH5 ? (
                    <div>
                      <div className="guest-before-meeting-h5-title-cls">
                        <Button
                          className="login-btn"
                          type="link"
                          onClick={onLogin}
                        >
                          {t('authLogin')}
                        </Button>
                        <div
                          style={{
                            fontWeight: 600,
                          }}
                        >
                          {t('meetingJoin')}
                        </div>
                      </div>
                      <div className="guest-before-meeting-name-input guest-before-meeting-name-input-h5">
                        <div className="guest-before-meeting-name-input-title">
                          {t('meetingNickname')}
                        </div>
                        <Input
                          title="name"
                          className="guest-before-meeting-name-input-input"
                          type="text"
                          placeholder={t('meetingGuestJoinNamePlaceholder')}
                          style={{
                            lineHeight: '24px',
                          }}
                          value={name}
                          onChange={(e) =>
                            handleInputChange(e.currentTarget.value)
                          }
                          onCompositionStart={() =>
                            (isComposingRef.current = true)
                          }
                          onCompositionEnd={(e) => {
                            isComposingRef.current = false;
                            handleInputChange(e.currentTarget.value);
                          }}
                        />
                        {name ? (
                          <svg
                            className="icon iconfont"
                            onClick={() => {
                              setName('');
                              setInputExtraShow(false);
                            }}
                          >
                            <use xlinkHref="#iconcross-y1x"></use>
                          </svg>
                        ) : null}
                        {inputExtraShow ? (
                          <div className="input-extra">{t('reNameTips')}</div>
                        ) : null}
                      </div>
                      <div className="before-meeting-home-lines">
                        <div className="audio-line">
                          <div className="audio-line-title">
                            {t('openMicInMeeting')}
                          </div>
                          <div className="audio-line-switch">
                            <Switch
                              checked={audioOpen}
                              onChange={(value) => {
                                setAudioOpen(value);
                              }}
                            />
                          </div>
                        </div>
                        <div className="video-line">
                          <div className="video-line-title">
                            {t('openCameraInMeeting')}
                          </div>
                          <div className="video-line-switch">
                            <Switch
                              checked={videoOpen}
                              onChange={(value) => {
                                setVideoOpen(value);
                              }}
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div>
                      <div className="guest-before-meeting-title-cls">
                        {t('meetingJoin')}
                      </div>
                      <div className="guest-before-meeting-name-input">
                        <input
                          title="name"
                          type="text"
                          placeholder={t('meetingGuestJoinNamePlaceholder')}
                          value={name}
                          onChange={(e) =>
                            handleInputChange(e.currentTarget.value)
                          }
                          onCompositionStart={() =>
                            (isComposingRef.current = true)
                          }
                          onCompositionEnd={(e) => {
                            isComposingRef.current = false;
                            handleInputChange(e.currentTarget.value);
                          }}
                        />
                        {name ? (
                          <svg
                            className="icon iconfont"
                            onClick={() => {
                              setName('');
                              setInputExtraShow(false);
                            }}
                          >
                            <use xlinkHref="#iconcross-y1x"></use>
                          </svg>
                        ) : null}
                        {inputExtraShow ? (
                          <div className="input-extra">{t('reNameTips')}</div>
                        ) : null}
                      </div>
                      <div className="guest-before-meeting-btn-group-cls">
                        <div
                          className="guest-before-meeting-btn-cls"
                          onClick={() => setAudioOpen(!audioOpen)}
                        >
                          <svg
                            className={cx('icon iconfont', {
                              ['closed']: !audioOpen,
                              ['open']: audioOpen,
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
                          className="guest-before-meeting-btn-cls"
                          onClick={() => setVideoOpen(!videoOpen)}
                        >
                          <svg
                            className={cx('icon iconfont', {
                              ['closed']: !videoOpen,
                              ['open']: videoOpen,
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
                  )}
                </div>
                <div>
                  <Button
                    type="primary"
                    className="guest-before-meeting-join-btn-cls  join-btn"
                    disabled={!name}
                    onClick={() => joinMeeting()}
                    loading={joinMeetingLoading}
                  >
                    {t('meetingJoin')}
                  </Button>
                  <div className="guest-before-meeting-join-agreement-cls">
                    <Checkbox
                      className="agree-checkbox"
                      onChange={(e) => {
                        setIsAgree(e.target.checked);
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
                              IPCEvent.openBrowserWindow,
                              'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml',
                            );
                            e.preventDefault();
                          }
                        }}
                        rel="noreferrer"
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
                              IPCEvent.openBrowserWindow,
                              'https://netease.im/meeting/clauses?serviceType=0',
                            );
                            e.preventDefault();
                          }
                        }}
                        rel="noreferrer"
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
                      guestBeforeMeetingJoinAuthBackCls,
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
                    className="guest-before-meeting-join-btn-cls phone-join-btn"
                    disabled={!phone.value || !code.value ? true : false}
                    onClick={() => joinMeeting()}
                    loading={joinMeetingLoading}
                  >
                    {t('meetingJoin')}
                  </Button>
                  <Button
                    className="guest-before-meeting-join-btn-cls phone-cancel-btn"
                    onClick={() => setNeedAuth(false)}
                  >
                    {t('globalCancel')}
                  </Button>
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
      {!window.isElectronNative && (
        <UnSupportBrowserModal
          visible={unSupportBrowserModalOpen}
          onClose={() => setUnSupportBrowserModalOpen(false)}
        />
      )}
    </>
  );
};

export default GuestBeforeMeeting;
