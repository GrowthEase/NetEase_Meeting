import React from 'react';
import { ModalProps } from 'antd';
import LiveSetting from '.';
import Modal from '@meeting-module/components/common/Modal';
import { LiveSettingInfo } from '@/types';
import NEPreMeetingService from '@meeting-module/kit/impl/service/pre_meeting_service';

interface LiveSettingModalProps extends ModalProps {
  onSave: (liveInfo: LiveSettingInfo) => void;
  onCancel: () => void;
  liveInfo?: LiveSettingInfo;
  preMeetingService?: NEPreMeetingService;
  maxCount: number;
}
const LiveSettingModal: React.FC<LiveSettingModalProps> = (props) => {
  const { onCancel, onSave, liveInfo, preMeetingService, maxCount } = props;

  return (
    <Modal
      rootClassName={
        window.isElectronNative ? 'nemeeting-live-setting-electron' : ''
      }
      {...props}
    >
      <LiveSetting
        maxCount={maxCount}
        className="nemeeting-live-setting-wrapper"
        onCancel={() => onCancel?.()}
        onSave={onSave}
        liveInfo={liveInfo}
        preMeetingService={preMeetingService}
      />
    </Modal>
  );
};

export default React.memo(LiveSettingModal);
