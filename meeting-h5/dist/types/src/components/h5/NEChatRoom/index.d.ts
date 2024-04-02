import React from 'react';
import { NERoomChatMessage } from '../../../types';
import './index.less';
interface NEChatRoomProps {
    visible: boolean;
    onClose: () => void;
    unReadChange: (count: number) => void;
    receiveMsg: NERoomChatMessage[] | undefined;
}
declare const NEChatRoom: React.FC<NEChatRoomProps>;
export default NEChatRoom;
