import React from 'react';
import './index.less';
interface MeetingInfoProps {
    visible: boolean;
    onClose: () => void;
}
declare const MeetingInfo: React.FC<MeetingInfoProps>;
export default MeetingInfo;
