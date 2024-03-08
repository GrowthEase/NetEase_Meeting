import { LayoutTypeEnum, NEMember } from '../../../types';
export declare function groupMembersService(data: {
    memberList: NEMember[];
    myUuid: string;
    groupNum: number;
    focusUuid: string;
    screenUuid: string;
    activeSpeakerUuid: string;
    groupType: 'web' | 'h5';
    enableSortByVoice: boolean;
    layout?: LayoutTypeEnum;
    isWhiteboardTransparent?: boolean;
    whiteboardUuid?: string;
}): Array<NEMember[]>;
