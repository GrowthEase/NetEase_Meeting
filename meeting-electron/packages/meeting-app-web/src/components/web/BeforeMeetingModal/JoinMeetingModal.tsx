import React from 'react';

import { ModalProps } from 'antd';
import { NEPreviewController } from 'neroom-types';
import { useTranslation } from 'react-i18next';
import { MeetingSetting } from '@meeting-module/types';
import Modal from '@meeting-module/components/common/Modal';
import { SettingTabType } from '@meeting-module/components/web/Setting/Setting';
import JoinMeeting from './JoinMeeting';
import './index.less';
import { NESettingsService } from 'nemeeting-web-sdk';

type SummitValue = {
  meetingId: string;
  openCamera: boolean;
  openMic: boolean;
};
type RecentMeetingList = {
  meetingNum: string;
  subject: string;
}[];

interface JoinMeetingModalProps extends ModalProps {
  previewController?: NEPreviewController;
  meetingNum: string;
  submitLoading?: boolean;
  setting?: MeetingSetting | null;
  settingOpen?: boolean;
  nickname?: string;
  avatar?: string;
  settingsService?: NESettingsService;
  recentMeetingList?: RecentMeetingList;
  onSummit?: (value: SummitValue) => void;
  onSettingChange?: (setting: MeetingSetting) => void;
  onOpenSetting?: (tab?: SettingTabType) => void;
  onClearRecentMeetingList?: () => void;
  open: boolean;
}

const JoinMeetingModal: React.FC<JoinMeetingModalProps> = ({
  ...restProps
}) => {
  const { t } = useTranslation();

  const i18n = {
    title: t('meetingJoin'),
    inputPlaceholder: t('meetingIDInputPlaceholder'),
    submitBtn: t('meetingJoin'),
    mic: t('microphone'),
    camera: t('camera'),
    clearAll: t('clearAll'),
    clearAllSuccess: t('clearAllSuccess'),
  };

  return (
    <div
      // onClick={() => {
      //   setTimeout(() => {
      //     setOpenRecentMeetingList(false)
      //   }, 200)
      // }}
      className="join-meeting-modal"
    >
      <Modal
        title={i18n.title}
        width={375}
        maskClosable={false}
        centered={window.ipcRenderer ? false : true}
        wrapClassName="user-select-none"
        footer={null}
        {...restProps}
        destroyOnClose
        afterClose={() => {
          restProps.afterClose?.();
        }}
      >
        <JoinMeeting {...restProps}></JoinMeeting>
      </Modal>
    </div>
  );
};

export default JoinMeetingModal;
