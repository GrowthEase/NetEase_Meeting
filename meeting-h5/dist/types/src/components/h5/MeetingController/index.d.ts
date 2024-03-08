import React from 'react';
import './index.less';
interface MeetingControllerProps {
    className?: string;
    visible?: boolean;
    onClick?: (e: any) => void;
    onRef?: React.RefObject<unknown>;
}
declare const MeetingController: React.FC<MeetingControllerProps>;
export default MeetingController;
