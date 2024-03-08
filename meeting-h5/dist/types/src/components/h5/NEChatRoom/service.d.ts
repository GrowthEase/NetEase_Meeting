import { NERoomChatMessage } from '../../../types/innerType';
export declare function handleRecMsgService(msgs: NERoomChatMessage[]): any;
export declare function handleSendMsgService(request: any, params: {
    msgType: 'orientation' | 'group' | 'resend';
    type: string;
    text: string;
}): any;
export declare function formatMsg(msg: NERoomChatMessage, myUuid?: string): any;
