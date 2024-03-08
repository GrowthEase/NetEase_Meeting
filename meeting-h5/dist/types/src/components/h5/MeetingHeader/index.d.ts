import React from 'react';
import './index.less';
interface MeetingHeaderProps {
    className?: string;
    visible?: boolean;
    onClick?: (e: any) => void;
}
declare const MeetingHeader: React.FC<MeetingHeaderProps>;
export default MeetingHeader;
