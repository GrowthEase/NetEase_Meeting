import React from 'react';
import './index.less';
import { useTranslation } from 'react-i18next';
import Modal from '@meeting-module/components/common/Modal';
import { LOCAL_GUEST_RECENT_MEETING_LIST } from '@/config';
import GuestJoin from './GuestJoin';
import { ModalProps } from 'antd';

type RecentMeeting = {
  meetingNum: string;
  subject: string;
};
interface BeforeHomeProps extends ModalProps {
  onJoin: (joinOptions: JoinOptions) => Promise<void>;
  onMeetingGuestNeedVerify: (data: {
    meetingNum: string;
    nickname: string;
    openVideo: boolean;
    openAudio: boolean;
  }) => void;
  open: boolean;

  isAgree: boolean;
  onAgreeChange: (isAgree: boolean) => void;
  checkIsAgree: () => boolean;
  meetingNum: string;
  onMeetingNumChange: (meetingNum: string) => void;
}

export interface JoinOptions {
  meetingNum: string;
  nickname: string;
  password?: string;
  phoneNumber?: string;
  smsCode?: string;
  openVideo?: boolean;
  openAudio?: boolean;
}

export function getLocalRecentList(): RecentMeeting[] {
  let list: RecentMeeting[] = [];

  try {
    list = JSON.parse(
      localStorage.getItem(LOCAL_GUEST_RECENT_MEETING_LIST) ?? '[]',
    );
  } catch (error) {
    // 忽略
  }

  return list;
}

const GuestJoinModal: React.FC<BeforeHomeProps> = (props) => {
  const { t } = useTranslation();
  const {
    onMeetingGuestNeedVerify,
    onJoin,
    isAgree,
    onAgreeChange,
    checkIsAgree,
    meetingNum,
    onMeetingNumChange,
  } = props;

  return (
    <Modal {...props} width={370} title={t('joinMeeting')} footer={null}>
      <GuestJoin
        checkIsAgree={checkIsAgree}
        isAgree={isAgree}
        onAgreeChange={onAgreeChange}
        className="nemeeting-app-guest-join-wrapper"
        onJoin={onJoin}
        onMeetingGuestNeedVerify={onMeetingGuestNeedVerify}
        meetingNum={meetingNum}
        onMeetingNumChange={onMeetingNumChange}
      />
    </Modal>
  );
};

export default GuestJoinModal;
