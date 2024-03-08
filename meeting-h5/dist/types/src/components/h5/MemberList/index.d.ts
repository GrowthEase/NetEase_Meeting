import React from 'react';
import './index.less';
interface MemberListProps {
    visible: boolean;
    onClose: () => void;
}
declare const MemberListUI: React.FC<MemberListProps>;
export default MemberListUI;
