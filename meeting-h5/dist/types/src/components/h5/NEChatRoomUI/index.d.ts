import './index.less';
import React from 'react';
import { NERoomChatMessage } from '../../../types';
interface NEChatRoomUIProps {
    msgs: NERoomChatMessage[];
    resendMsg: () => void;
}
declare const NEChatRoomUI: React.FC<NEChatRoomUIProps>;
export default NEChatRoomUI;
