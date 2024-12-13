import { Button, Checkbox } from 'antd';
import React, { useCallback, useEffect, useState } from 'react';
import AppAboutLogoImage from '../../assets/app-about-logo.png';
import MobLogo from '../../assets/mob-logo@2x.png';
import {
  Toast,
  getDeviceKey,
  NEClientInnerType,
  NEMeetingService,
} from 'nemeeting-web-sdk';
import './index.less';
import LoginBySSO, { matchURL } from './bySSO';
import NormalLogin from './normalLogin';
import GuestPhoneJoin from './guestPhoneJoin';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import BaseInput from '../Input';
import EnterpriseLogin from './enterpriseLogin';
import { getEnterPriseInfoApi } from '../../api';
import { EnterPriseInfo } from '../../types';
import { useTranslation } from 'react-i18next';
import {
  DOMAIN_SERVER,
  LOCALSTORAGE_LOGIN_BACK,
  PROTOCOL,
  LOCALSTORAGE_SSO_APP_KEY,
  LOCAL_GUEST_RECENT_MEETING_LIST,
  LOCALSTORAGE_INVITE_MEETING_URL,
} from '../../config';
import classNames from 'classnames';
import GuestJoinModal, { getLocalRecentList, JoinOptions } from './guestJoin';
import getMeetingKitInstance from '../web/BeforeMeetingHome/neMeetingKit';
import { NEMeetingCode, NEMeetingStatus } from '@meeting-module/types/type';
import { IPCEvent } from '@meeting-module/app/src/types';
import { getMeetingIdFromUrl } from '@/utils';
import qs from 'qs';

const domain = process.env.MEETING_DOMAIN;

// export const CREATE_ACCOUNT_URL = process.env.CREATE_ACCOUNT_URL;
export const CREATE_ACCOUNT_URL =
  'https://doc.yunxin.163.com/meeting/concept/DI1MDY1ODg?platform=console';

export type ShowType =
  | 'home'
  | 'sso'
  | 'login'
  | 'register'
  | 'enterprise'
  | 'guestPhoneJoin'
  | 'enterpriseLogin';
interface BeforeLoginProps {
  onLogged: () => void;
  onJoined: () => void;
}

const BeforeLogin: React.FC<BeforeLoginProps> = ({ onLogged, onJoined }) => {
  const { t } = useTranslation();
  const [isAgree, setIsAgree] = useState<boolean>(false);
  const [type, setType] = useState<ShowType>('home');
  const [enterpriseCode, setEnterpriseCode] = useState({
    value: localStorage.getItem('nemeeting-website-sso'),
    valid: false,
  });
  const [enterpriseLoading, setEnterpriseLoading] = useState(false);
  const [enterpriseInfo, setEnterpriseInfo] = useState<EnterPriseInfo>();
  const [inMeeting, setInMeeting] = useState(false);
  const [openGuestJoinModal, setOpenGuestJoinModal] = useState(false);
  const [meetingNum, setMeetingNum] = useState('');
  const [joinInfo, setJoinInfo] = useState({
    meetingNum: '',
    nickname: '',
    openVideo: false,
    openAudio: false,
  });

  function login(type: ShowType) {
    setType(type);
  }

  const goType = (type: ShowType) => {
    setType(type);
  };

  function handleInvitationUrl(url: string) {
    let meetingNum = '';

    if (window.isElectronNative) {
      meetingNum = getMeetingIdFromUrl(url);
    } else {
      const query = qs.parse(url.split('?')[1]?.split('#/')[0]);

      meetingNum = query.meetingId as string;
      // 如果是处理一次后，删除url中的meetingId参数
      if (meetingNum) {
        delete query.meetingId;
        history.replaceState(
          {},
          '',
          qs.stringify(query, { addQueryPrefix: true }),
        );
      }
    }

    if (meetingNum) {
      setMeetingNum(meetingNum);
      setOpenGuestJoinModal(true);
    }
  }

  useEffect(() => {
    // 处理邀请链接入会
    if (window.isElectronNative) {
      const url = localStorage.getItem(LOCALSTORAGE_INVITE_MEETING_URL);

      if (url) {
        handleInvitationUrl(url);
        localStorage.removeItem(LOCALSTORAGE_INVITE_MEETING_URL);
      }
    } else {
      handleInvitationUrl(location.href);
    }

    function handleUrl(e, url) {
      handleInvitationUrl(url);
    }

    window.ipcRenderer?.on(IPCEvent.electronJoinMeeting, handleUrl);
    return () => {
      window.ipcRenderer?.removeListener(
        IPCEvent.electronJoinMeeting,
        handleUrl,
      );
    };
  }, []);

  const toSSOUrl = (_enterpriseCode: string, ipdId: number, appKey: string) => {
    const { query } = location;
    const [loginAppNameSpace] = [query?.loginAppNameSpace];
    const { href } = window.location;
    const backUrl = window.localStorage.getItem(LOCALSTORAGE_LOGIN_BACK);
    const returnURL = query?.returnURL
      ? matchURL(
          `${href.split('?')[0]}`,
          `returnURL=${query?.returnURL}&loginAppNameSpace=${
            loginAppNameSpace || _enterpriseCode
          }&backUrl=${window.encodeURIComponent(
            (query?.backUrl as string) || '',
          )}&from=${query?.from || 'web'}`,
        )
      : `${href.split('?')[0]}?loginAppNameSpace=${
          loginAppNameSpace || _enterpriseCode
        }&backUrl=${window.encodeURIComponent(backUrl || '')}&from=${
          query?.from || 'web'
        }`;

    const ssoUrl = `${DOMAIN_SERVER}/scene/meeting/v2/sso-authorize`;
    const key = getDeviceKey();
    const clientCallbackUrl = window.isElectronNative
      ? `${PROTOCOL}://loginSuccess?` // 自定义协议唤起应用
      : `${window.encodeURIComponent(returnURL)}`;
    const clientType = window.isElectronNative
      ? window.isWins32
        ? NEClientInnerType.PC
        : NEClientInnerType.MAC
      : NEClientInnerType.WEB;

    localStorage.setItem(LOCALSTORAGE_SSO_APP_KEY, appKey);
    const url = `${ssoUrl}?callback=${clientCallbackUrl}&idp=${ipdId}&key=${key}&clientType=${clientType}&appKey=${appKey}`;

    if (window.isElectronNative) {
      window.ipcRenderer?.send('open-sso', url);
    } else {
      window.location.href = url;
    }
  };

  const goEnterprise = () => {
    if (!enterpriseCode.value || !checkIsAgree()) {
      return;
    }

    const code = enterpriseCode.value;

    setEnterpriseLoading(true);
    getEnterPriseInfoApi({ code: code })
      .then((data) => {
        localStorage.setItem('nemeeting-website-sso', code);
        if (data.ssoLevel === 2 && data.idpList.length > 0) {
          const ipdInfo = data.idpList.find((item) => {
            return item.type === 1;
          });

          if (ipdInfo) {
            toSSOUrl(code, ipdInfo.id, data.appKey);
            return;
          }
        }

        setType('enterpriseLogin');
        setEnterpriseInfo(data);
        // setEnterpriseCode({ value: '', valid: false });
      })
      .catch((err) => {
        Toast.fail(err.msg || err.message);
      })
      .finally(() => {
        setEnterpriseLoading(false);
      });
  };

  function onCreateAccount() {
    if (window.isElectronNative) {
      window.ipcRenderer?.send('open-browser-window', CREATE_ACCOUNT_URL);
    } else {
      window.open(CREATE_ACCOUNT_URL, '_blank');
    }
  }

  const checkIsAgree = useCallback(() => {
    if (!isAgree) {
      Toast.info(t('authPrivacyCheckedTips'));
      return false;
    }

    return true;
  }, [isAgree]);

  const onClickLogin = (type: ShowType) => {
    login(type);
  };

  function goBack() {
    setType('home');
  }

  function onMeetingNumChange(meetingNum: string) {
    setMeetingNum(meetingNum);
  }

  function addRoomListener(meetingService?: NEMeetingService) {
    meetingService?.addMeetingStatusListener({
      onMeetingStatusChanged: ({ status, arg }) => {
        if (
          status === NEMeetingStatus.MEETING_STATUS_FAILED ||
          status === NEMeetingStatus.MEETING_STATUS_IDLE
        ) {
          setInMeeting(false);
          if (window.isElectronNative) {
            window.ipcRenderer?.send(IPCEvent.beforeEnterRoom);
          }

          window.ipcRenderer?.send('flushStorageData');
        } else if (status === NEMeetingStatus.MEETING_STATUS_DISCONNECTING) {
          console.log('MEETING_STATUS_DISCONNECTING', arg);

          const reasonMap = {
            [NEMeetingCode.MEETING_DISCONNECTING_CLOSED_BY_HOST]:
              t('meetingEnded'),
            [NEMeetingCode.MEETING_DISCONNECTING_END_OF_LIFE]: t('END_OF_LIFE'),
            [NEMeetingCode.MEETING_DISCONNECTING_REMOVED_BY_HOST]:
              t('KICK_OUT'),
            [NEMeetingCode.MEETING_DISCONNECTING_SYNC_DATA_ERROR]:
              t('SYNC_DATA_ERROR'),
            [NEMeetingCode.MEETING_DISCONNECTING_JOIN_TIMEOUT]: 'JOIN_TIMEOUT',
          };

          if (window.isElectronNative) {
            reasonMap[
              NEMeetingCode.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE
            ] = t('meetingSwitchOtherDevice');
          }

          (arg || arg === 0) && reasonMap[arg] && Toast.info(reasonMap[arg]);

          window.ipcRenderer?.send(IPCEvent.quiteFullscreen);
          setInMeeting(false);
          setTimeout(
            async () => {
              if (window.isElectronNative) {
                window.ipcRenderer?.send(IPCEvent.beforeEnterRoom, true);
                const MeetingKitInstance = getMeetingKitInstance();

                try {
                  await MeetingKitInstance.getAccountService()?.logout();
                } finally {
                  await MeetingKitInstance.unInitialize();
                }
              } else {
                window.location.reload();
              }
            },
            window.isElectronNative ? 0 : 1500,
          );
          localStorage.removeItem('ne-meeting-current-info');
          window.ipcRenderer?.send('flushStorageData');
        }
      },
    });
  }

  async function onJoin(options: JoinOptions): Promise<void> {
    if (!checkIsAgree()) {
      return;
    }

    const MeetingKitInstance = getMeetingKitInstance();

    const {
      nickname,
      meetingNum,
      password,
      phoneNumber,
      smsCode,
      openAudio,
      openVideo,
    } = options;

    if (MeetingKitInstance.isInitialized) {
      await MeetingKitInstance.unInitialize?.().catch(() => {
        //
      });
    }

    await MeetingKitInstance.initialize({
      appKey: 'guest',
      serverUrl: domain,
      width: 0,
      height: 0,
    });
    return MeetingKitInstance.getGuestService()
      ?.joinMeetingAsGuest(
        {
          meetingNum,
          displayName: nickname,
          password,
          phoneNumber,
          smsCode,
          watermarkConfig: {
            name: nickname,
            phone: '',
            email: '',
          },
        },
        {
          noAudio: !openAudio,
          noVideo: !openVideo,
        },
      )
      .catch((e) => {
        console.error(e);
        throw e;
      })
      .then(async () => {
        addRoomListener(MeetingKitInstance.getMeetingService());
        let meetingList = getLocalRecentList();

        meetingList = meetingList.filter(
          (item) => item.meetingNum !== meetingNum,
        );

        setTimeout(async () => {
          try {
            const info =
              await MeetingKitInstance.getMeetingService()?.getCurrentMeetingInfo();

            meetingList.unshift({
              meetingNum,
              subject: info?.data.subject || '',
            });

            meetingList = meetingList.slice(0, 10);

            localStorage.setItem(
              LOCAL_GUEST_RECENT_MEETING_LIST,
              JSON.stringify(meetingList),
            );
            setOpenGuestJoinModal(false);
          } catch (error) {
            //
          }
        }, 5000);

        setOpenGuestJoinModal(false);
        setType('home');

        setInMeeting(true);
        window.ipcRenderer?.send(IPCEvent.enterRoom);
        onJoined?.();
      });
  }

  function onMeetingGuestNeedVerify(data: {
    meetingNum: string;
    nickname: string;
    openVideo: boolean;
    openAudio: boolean;
  }) {
    const { meetingNum, nickname, openVideo, openAudio } = data;

    setOpenGuestJoinModal(false);
    setType('guestPhoneJoin');
    setJoinInfo({
      meetingNum,
      nickname,
      openAudio,
      openVideo,
    });
  }

  return (
    <>
      {!inMeeting && (
        <div className={'before-login-wrap'}>
          {window.isElectronNative && (
            <div className="electron-drag-bar">
              <div className="drag-region" />
              {/* {t('appTitle')} */}
              <PCTopButtons maximizable={false} />
            </div>
          )}
          <div
            className={classNames('before-login', {
              'login-home': type === 'home',
              'login-enterprise': type === 'enterpriseLogin',
              'login-register': type === 'register',
              'login-sso': type === 'sso',
              'login-login': type === 'login',
            })}
          >
            <div className="before-login-content">
              <GuestJoinModal
                destroyOnClose
                afterClose={() => {
                  setMeetingNum('');
                }}
                onMeetingNumChange={onMeetingNumChange}
                meetingNum={meetingNum}
                isAgree={isAgree}
                onAgreeChange={(isAgree: boolean) => {
                  setIsAgree(isAgree);
                }}
                checkIsAgree={checkIsAgree}
                onJoin={onJoin}
                onMeetingGuestNeedVerify={onMeetingGuestNeedVerify}
                open={openGuestJoinModal}
                onCancel={() => {
                  setOpenGuestJoinModal(false);
                }}
              />

              {type === 'home' && (
                <>
                  <img
                    className={`${
                      window.isElectronNative ? 'logo-electron' : ''
                    } ${'logo'}`}
                    src={AppAboutLogoImage}
                  />
                  <BaseInput
                    prefix={
                      <svg
                        className="icon iconfont input-prefix-icon"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#iconqiyedaima"></use>
                      </svg>
                    }
                    style={{ width: '100%', paddingLeft: 0 }}
                    size="middle"
                    value={enterpriseCode.value}
                    placeholder={t('authEnterCorpCode')}
                    set={setEnterpriseCode}
                  />
                  <div className="no-enterprise-tip">
                    <div>
                      {/* {t('authNoCorpCode')} */}
                      <Button
                        className="create-count"
                        type="link"
                        onClick={onCreateAccount}
                      >
                        <span className="get-corp-code">
                          {t('authHowToGetCorpCode')}
                        </span>
                      </Button>
                    </div>
                  </div>
                  <Button
                    type="primary"
                    disabled={!enterpriseCode.value}
                    loading={enterpriseLoading}
                    className="login-button"
                    onClick={() => {
                      goEnterprise();
                    }}
                  >
                    {t('authNextStep')}
                  </Button>
                  {/* <Button
                type="link"
                onClick={() => {
                  onClickLogin('sso');
                }}
              >
                {t('authLoginBySSO')}
              </Button> */}
                </>
              )}
              {type === 'enterpriseLogin' && (
                <EnterpriseLogin
                  enterpriseInfo={enterpriseInfo}
                  onLogged={onLogged}
                  goBack={goBack}
                  onSSOLogin={() => {
                    if (enterpriseInfo && enterpriseInfo.idpList.length > 0) {
                      const ipdInfo = enterpriseInfo.idpList.find((item) => {
                        return item.type === 1;
                      });

                      if (ipdInfo && enterpriseCode.value) {
                        toSSOUrl(
                          enterpriseCode.value,
                          ipdInfo.id,
                          enterpriseInfo.appKey,
                        );
                        return;
                      }
                    }

                    Toast.fail(t('authSSONotSupport'));
                  }}
                />
              )}
              {type === 'register' && (
                <>
                  <img
                    className={`${
                      window.isElectronNative ? 'logo-electron' : ''
                    } ${'logo'}`}
                    src={AppAboutLogoImage}
                  />
                  <Button
                    type="primary"
                    className={`login-button  ${'login-and-register-btn'}`}
                    onClick={() => {
                      onClickLogin('login');
                    }}
                  >
                    {t('authRegisterAndLogin')}
                  </Button>
                  <div className="no-enterprise-tip">
                    <div>
                      {t('authHasCorpCode')}
                      <Button
                        onClick={() => goType('home')}
                        className="create-count"
                        type="link"
                      >
                        {t('authLoginToCorpEdition')}
                      </Button>
                    </div>
                    {/* <Button
                  className="create-count"
                  type="link"
                  onClick={() => {
                    onClickLogin('sso');
                  }}
                >
                  {t('authLoginBySSO')}
                </Button> */}
                  </div>
                </>
              )}
              {type === 'sso' && (
                <LoginBySSO
                  checkIsAgree={checkIsAgree}
                  goBack={goBack}
                  code={enterpriseCode.value}
                />
              )}
              {type === 'login' && (
                <NormalLogin
                  checkIsAgree={checkIsAgree}
                  onSSOLogin={() => login('sso')}
                  goBack={goBack}
                  onLogged={onLogged}
                />
              )}
              {type === 'guestPhoneJoin' && (
                <GuestPhoneJoin
                  goTo={goType}
                  onJoin={onJoin}
                  joinInfo={joinInfo}
                />
              )}
            </div>
            {type !== 'enterpriseLogin' && (
              <div className={'footer'}>
                {type === 'home' ? (
                  <div className="footer-login-type">
                    {/* <LoginTypeIcon
                      title={t('authLoginBySSO')}
                      icon="iconSSO1"
                      onClick={() => {
                        login('sso');
                      }}
                    /> */}
                    <div className="footer-login-entry">
                      <Button
                        size="small"
                        type="link"
                        onClick={() => {
                          setOpenGuestJoinModal(true);
                        }}
                      >
                        {t('meetingJoin')}
                      </Button>
                      <div style={{ margin: '0 8px' }}>|</div>
                      <Button
                        size="small"
                        type="link"
                        onClick={() => {
                          login('sso');
                        }}
                      >
                        {t('authLoginBySSO')}
                      </Button>
                      <Button
                        size="small"
                        type="link"
                        onClick={() => {
                          goType('register');
                        }}
                      >
                        {t('authLoginToTrialEdition')}
                      </Button>
                    </div>
                  </div>
                ) : null}

                <div className="footer-agreement">
                  <Checkbox
                    onChange={(e) => {
                      setIsAgree(e.target.checked);
                    }}
                    checked={isAgree}
                  />
                  <span className="text">
                    {t('authHasReadAndAgreeMeeting')}
                    <a
                      href="https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml"
                      target="_blank"
                      title={t('authPrivacy')}
                      onClick={(e) => {
                        if (window.ipcRenderer) {
                          window.ipcRenderer.send(
                            'open-browser-window',
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
                            'open-browser-window',
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
                <img className="footer-logo" src={MobLogo} />
              </div>
            )}
          </div>
        </div>
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
  );
};

export default BeforeLogin;
