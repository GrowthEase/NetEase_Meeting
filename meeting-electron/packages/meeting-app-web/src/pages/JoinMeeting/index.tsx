import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';

import JoinMeeting from '../../components/web/BeforeMeetingModal/JoinMeeting';
import './index.less';
import { MeetingSetting } from '@meeting-module/types';
import { useGlobalContext } from '@meeting-module/store';
import { IPCEvent, ServerGuestErrorCode } from '@/types';
import Toast from '@meeting-module/components/common/toast';
import {
  CommonModal,
  Modal,
  NELocalHistoryMeeting,
  setLocalStorageSetting,
} from 'nemeeting-web-sdk';
import { Input } from 'antd';
import { ConfirmModal } from '@meeting-module/components/common/Modal';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';

const JoinMeetingPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const { neMeeting } = useGlobalContext();
  const [submitLoading, setSubmitLoading] = useState(false);
  const [setting, setSetting] = useState<MeetingSetting | null>(null);
  const [settingOpen, setSettingOpen] = useState(false);
  const [invitationMeetingNum, setInvitationMeetingNum] = useState('');
  const [nickname, setNickname] = useState('');
  const [avatar, setAvatar] = useState('');
  const [localHistoryMeetingList, setLocalHistoryMeetingList] = useState<
    NELocalHistoryMeeting[]
  >([]);

  const passwordRef = React.useRef<string>('');
  const summitValueRef = React.useRef<{
    meetingId: string;
    openCamera: boolean;
    openMic: boolean;
  }>();

  const [open, setOpen] = useState(false);

  const settingsService = useMemo(() => {
    return neMeetingKit.getSettingsService();
  }, [neMeetingKit]);

  const onSettingChange = useCallback((setting: MeetingSetting): void => {
    setSetting(setting);
    setLocalStorageSetting(JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }, []);

  const previewController = useMemo(
    () => neMeeting?.previewController,
    [neMeeting],
  );

  useEffect(() => {
    let modal: ConfirmModal | undefined;

    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'setJoinMeetingData') {
        payload.nickname && setNickname(payload.nickname);
        payload.avatar && setAvatar(payload.avatar);
        payload.setting && setSetting(payload.setting);
        payload.settingOpen && setSettingOpen(payload.settingOpen);
        payload.invitationMeetingNum &&
          setInvitationMeetingNum(payload.invitationMeetingNum);
        setOpen(true);
      } else if (event === 'joinMeetingFail') {
        const InputComponent = (inputValue) => {
          return (
            <Input
              placeholder={t('livePasswordTip')}
              value={inputValue}
              maxLength={6}
              allowClear
              onChange={(event) => {
                passwordRef.current = event.target.value.replace(/[^0-9]/g, '');
                modal?.update({
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

        if (payload.code === 1020) {
          if (modal) {
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
            });
          } else {
            passwordRef.current = '';
            modal = Modal.confirm({
              getContainer: () =>
                document.getElementById('join-meeting-page') as HTMLDivElement,
              title: t('meetingPassword'),
              width: 375,
              content: <>{InputComponent('')}</>,
              okButtonProps: {
                disabled: true,
                style: { color: 'rgba(22, 119, 255, 0.5)' },
              },
              onOk: async () => {
                const parentWindow = window.parent;

                parentWindow?.postMessage(
                  {
                    event: 'joinMeeting',
                    payload: {
                      value: {
                        ...summitValueRef.current,
                        password: passwordRef.current,
                      },
                    },
                  },
                  parentWindow.origin,
                );
                return Promise.reject();
              },
              onCancel: () => {
                modal = undefined;
              },
            });
          }
        } else if (payload?.code === 1019) {
          Toast.info(t('meetingLocked'));
        } else if (payload?.code === 1004) {
          Toast.fail(t('meetingNotExist'));
        } else if (
          payload?.code === ServerGuestErrorCode.MEETING_GUEST_JOIN_DISABLED
        ) {
          CommonModal.warning({
            width: 400,
            content: (
              <div className="nemeeting-cross-app-permission">
                {t('meetingCrossAppJoinNotSupported')}
              </div>
            ),
            okText: t('IkonwIt'),
          });
        } else {
          Toast.fail(payload.errorMsg || t('meetingJoinFail'));
        }

        setSubmitLoading(false);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    if (open) {
      neMeetingKit
        .getMeetingService()
        ?.getLocalHistoryMeetingList()
        .then((res) => {
          setLocalHistoryMeetingList(res.data);
        });
    }
  }, [open, neMeetingKit]);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('meetingJoin');
    });
  }, [t]);

  return (
    <>
      <div className={'join-meeting-page'} id="join-meeting-page">
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('meetingJoin')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="join-meeting-page-content">
          <JoinMeeting
            previewController={previewController}
            setting={setting}
            nickname={nickname}
            avatar={avatar}
            settingsService={settingsService}
            settingOpen={settingOpen}
            onSettingChange={onSettingChange}
            open={open}
            meetingNum={invitationMeetingNum}
            submitLoading={submitLoading}
            recentMeetingList={localHistoryMeetingList}
            onClearRecentMeetingList={() => {
              neMeetingKit.getMeetingService()?.clearLocalHistoryMeetingList();
              setLocalHistoryMeetingList([]);
            }}
            onSummit={(value) => {
              summitValueRef.current = value;

              setSubmitLoading(true);
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'joinMeeting',
                  payload: {
                    value,
                  },
                },
                parentWindow.origin,
              );
            }}
          />
        </div>
      </div>
    </>
  );
};

export default JoinMeetingPage;
