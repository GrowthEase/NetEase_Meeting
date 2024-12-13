import { Button, Checkbox, Dropdown, Input, MenuProps, Switch } from 'antd';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { isLastCharacterEmoji } from '@meeting-module/utils';
import { getLocalRecentList, JoinOptions } from '..';
import { ServerGuestErrorCode } from '@/types';
import { CommonModal, getMeetingDisplayId, Toast } from 'nemeeting-web-sdk';
import './index.less';
import usePasswordJoin from '../../hook/usePassword';
import {
  LOCAL_GUEST_JOIN_NICKNAME,
  LOCAL_GUEST_RECENT_MEETING_LIST,
  LOCAL_GUEST_REMEMBER_NICKNAME,
} from '@/config';

interface JoinMeetingProps {
  className?: string;
  onJoin: (joinOptions: JoinOptions) => Promise<void>;
  onMeetingGuestNeedVerify?: (data: {
    meetingNum: string;
    nickname: string;
    openVideo: boolean;
    openAudio: boolean;
  }) => void;
  isAgree: boolean;
  onAgreeChange: (isAgree: boolean) => void;
  checkIsAgree: () => boolean;
  meetingNum: string;
  onMeetingNumChange: (meetingNum: string) => void;
}

interface RecentMeeting {
  meetingNum: string;
  subject: string;
}

const GuestJoin: React.FC<JoinMeetingProps> = ({
  onJoin,
  className,
  onMeetingGuestNeedVerify,
  onAgreeChange,
  isAgree,
  checkIsAgree,
  meetingNum,
  onMeetingNumChange,
}) => {
  const { t } = useTranslation();
  const isComposingRef = useRef(false);
  const [nickname, setNickname] = useState('');
  const [openRecentMeetingList, setOpenRecentMeetingList] = useState(false);
  const [rememberNickname, setRememberNickname] = useState(true);
  const [openAudio, setOpenAudio] = useState(false);
  const [openVideo, setOpenVideo] = useState(false);
  const [joinLoading, setJoinLoading] = useState(false);
  const [recentMeetingList, setRecentMeetingList] = useState<RecentMeeting[]>(
    [],
  );
  const joinMeetingInputRef = useRef<HTMLInputElement>(null);
  const { handleJoinPasswordMeeting, passwordRef } = usePasswordJoin();

  useEffect(() => {
    setRecentMeetingList(getLocalRecentList());
    const nickname = localStorage.getItem(LOCAL_GUEST_JOIN_NICKNAME);

    nickname && setNickname(nickname);

    const rememberNickname = localStorage.getItem(
      LOCAL_GUEST_REMEMBER_NICKNAME,
    );

    if (rememberNickname === 'false') {
      setRememberNickname(false);
    } else {
      rememberNickname && setRememberNickname(true);
    }
  }, []);

  useEffect(() => {
    if (rememberNickname) {
      localStorage.setItem(
        LOCAL_GUEST_REMEMBER_NICKNAME,
        String(rememberNickname),
      );
    } else {
      localStorage.removeItem(LOCAL_GUEST_REMEMBER_NICKNAME);
    }
  }, [rememberNickname]);

  const canJoin = useMemo(() => {
    return nickname && nickname.trim() && meetingNum;
  }, [nickname, meetingNum]);

  async function handleJoinMeeting() {
    if (!checkIsAgree()) {
      return;
    }

    setJoinLoading(true);

    if (rememberNickname) {
      localStorage.setItem(LOCAL_GUEST_JOIN_NICKNAME, nickname);
    } else {
      localStorage.removeItem(LOCAL_GUEST_JOIN_NICKNAME);
    }

    try {
      await onJoin?.({
        meetingNum,
        nickname,
        openVideo,
        openAudio,
        password: passwordRef.current,
      });
    } catch (err: unknown) {
      const e = err as { code: number; msg: string; message: string };

      if (e.code === 1020) {
        handleJoinPasswordMeeting(e, handleJoinMeeting);
      } else if (e.code === ServerGuestErrorCode.MEETING_GUEST_JOIN_DISABLED) {
        // 不允许访客入会
        CommonModal.warning({
          width: 400,
          content: (
            <div className="nemeeting-cross-app-permission">
              {t('meetingCrossAppNoPermission')}
            </div>
          ),
          okText: t('IkonwIt'),
        });
      } else if (e.code === ServerGuestErrorCode.MEETING_GUEST_NEED_VERIFY) {
        // 需要验证码登录
        onMeetingGuestNeedVerify?.({
          meetingNum,
          nickname,
          openAudio,
          openVideo,
        });
      } else {
        Toast.fail(e.msg || e.message);
      }
    } finally {
      setJoinLoading(false);
    }
  }

  function handleInputChange(value: string) {
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

          break;
        }
      }
    }

    setNickname(userInput);
  }

  function onClearRecentMeetingList() {
    console.log('onClearRecentMeetingList');
  }

  function handelRememberNickName(checked: boolean) {
    console.log('handelRememberNickName');
    setRememberNickname(checked);
  }

  function handleOpenAudio(checked: boolean) {
    setOpenAudio(checked);
  }

  function handleOpenVideo(checked: boolean) {
    setOpenVideo(checked);
  }

  const items: MenuProps['items'] = [
    ...recentMeetingList.map((item) => ({
      key: item.meetingNum,
      label: (
        <div className="recent-meeting-item">
          <div className="recent-meeting-item-title">{item.subject}</div>
          <div>{getMeetingDisplayId(item.meetingNum)}</div>
        </div>
      ),
      onClick: () => {
        onMeetingNumChange(item.meetingNum);
        setOpenRecentMeetingList(false);
      },
    })),

    {
      key: 'clear',
      label: <div className="recent-meeting-clear">{t('clearAll')}</div>,
      onClick: () => {
        onClearRecentMeetingList?.();
        setRecentMeetingList([]);
        localStorage.removeItem(LOCAL_GUEST_RECENT_MEETING_LIST);
        Toast.success(t('clearAllSuccess'));
      },
    },
  ];

  return (
    <div className={`nemeeting-app-guest-join ${className || ''}`}>
      <div className="meeting-guest-join-wrapper meeting-guest-join-num">
        <Dropdown
          trigger={openRecentMeetingList ? ['click'] : []}
          menu={{ items }}
          placement="bottom"
          autoAdjustOverflow={false}
          open={openRecentMeetingList && recentMeetingList.length > 0}
          onOpenChange={(open) => setOpenRecentMeetingList(open)}
          getPopupContainer={(node) => node}
          destroyPopupOnHide
        >
          <div>
            <Input
              className="join-meeting-modal-input"
              placeholder={t('meetingIDInputPlaceholder')}
              // @ts-expect-error antd type error
              ref={joinMeetingInputRef}
              prefix={
                <span
                  style={{
                    fontWeight:
                      window.systemPlatform === 'win32' ? 'bold' : '500',
                  }}
                  className="meeting-id-prefix"
                >
                  {t('meetingNumber')}
                </span>
              }
              value={meetingNum}
              allowClear
              onChange={(e) => {
                if (/^[0-9-]*$/.test(e.target.value)) {
                  onMeetingNumChange(e.target.value.trim().slice(0, 12));
                }
              }}
              suffix={
                recentMeetingList.length > 0 ? (
                  openRecentMeetingList ? (
                    <span
                      onClick={() => {
                        setTimeout(() => {
                          setOpenRecentMeetingList(false);
                        }, 250);
                      }}
                      className="iconxiajiantou-up"
                    >
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconxiajiantou-shixin"></use>
                      </svg>
                    </span>
                  ) : (
                    <span
                      onClick={() => {
                        setTimeout(() => {
                          setOpenRecentMeetingList(true);
                        }, 250);
                      }}
                      className="iconxiajiantou-up"
                    >
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconxiajiantou-shixin"></use>
                      </svg>
                    </span>
                  )
                ) : null
              }
            />
          </div>
        </Dropdown>
        <Input
          className="join-meeting-modal-input"
          placeholder={t('meetingGuestJoinNamePlaceholder')}
          allowClear
          prefix={
            <span
              style={{
                fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
              }}
              className="meeting-id-prefix"
            >
              {t('meetingGuestJoinName')}
            </span>
          }
          value={nickname}
          onChange={(e) => handleInputChange(e.currentTarget.value)}
          onCompositionStart={() => (isComposingRef.current = true)}
          onCompositionEnd={(e) => {
            isComposingRef.current = false;
            handleInputChange(e.currentTarget.value);
          }}
        />
      </div>
      <div className="meeting-guest-join-wrapper">
        <div className="guest-join-meeting-line-item">
          <div
            className="meeting-open-mic-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('meetingGuestRememberJoinName')}
          </div>
          <div>
            <Switch
              value={rememberNickname}
              onChange={handelRememberNickName}
            ></Switch>
          </div>
        </div>
        <div className="guest-join-meeting-line-item">
          <div
            className="meeting-open-mic-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('openMicInMeeting')}
          </div>
          <div>
            <Switch value={openAudio} onChange={handleOpenAudio}></Switch>
          </div>
        </div>
        <div className="guest-join-meeting-line-item">
          <div
            className="meeting-open-mic-title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('openCameraInMeeting')}
          </div>
          <div>
            <Switch value={openVideo} onChange={handleOpenVideo}></Switch>
          </div>
        </div>
      </div>
      <div className="footer-agreement guest-footer-agreement">
        <Checkbox
          onChange={(e) => {
            onAgreeChange(e.target.checked);
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
      <div className="before-meeting-modal-footer guest-join-meeting-footer-button">
        <Button
          disabled={!canJoin}
          type="primary"
          onClick={handleJoinMeeting}
          size="large"
          loading={joinLoading}
          style={{ width: '100%' }}
        >
          {t('enterMeetingToast')}
        </Button>
      </div>
    </div>
  );
};

export default GuestJoin;
