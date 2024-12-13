import { ConfirmModal } from '@meeting-module/components/common/Modal';
import { Input } from 'antd';
import { CommonModal, getWindow } from 'nemeeting-web-sdk';
import React, { useRef } from 'react';
import { useTranslation } from 'react-i18next';

export default function usePasswordJoin() {
  const { t } = useTranslation();
  const modalRef = useRef<ConfirmModal | null>(null);
  const passwordRef = useRef<string>('');

  async function handleJoinPasswordMeeting(e, handleJoinMeeting) {
    if (window.isElectronNative) {
      const joinMeetingWindow = getWindow('joinMeetingWindow');
      const errorMsg = e.message || e.msg || e.code;

      joinMeetingWindow?.postMessage(
        {
          event: 'joinMeetingFail',
          payload: {
            code: e.code,
            errorMsg,
          },
        },
        joinMeetingWindow.origin,
      );
    }

    const InputComponent = (inputValue) => {
      return (
        <Input
          placeholder={t('livePasswordTip')}
          value={inputValue}
          maxLength={6}
          allowClear
          onChange={(event) => {
            passwordRef.current = event.target.value.replace(/[^0-9]/g, '');
            modalRef.current?.update({
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

    // 需要密码
    modalRef.current = CommonModal.confirm({
      title: t('meetingPassword'),
      width: 375,
      content: <>{InputComponent('')}</>,
      okButtonProps: {
        disabled: true,
      },
      onOk: async () => {
        handleJoinMeeting();
      },
      onCancel: () => {
        modalRef.current = null;
      },
    });
  }

  return {
    handleJoinPasswordMeeting,
    passwordRef,
  };
}
