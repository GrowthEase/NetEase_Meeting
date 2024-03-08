import React, { CSSProperties, LegacyRef } from 'react';
import './index.less';
import { NEMember } from '../../../types';
interface VideoCardProps {
    isMySelf: boolean;
    member: NEMember;
    isMain: boolean;
    type?: 'video' | 'screen';
    isSubscribeVideo?: boolean;
    className?: string;
    showBorder?: boolean;
    onClick?: (e: any) => void;
    iosTime?: number;
    canShowCancelFocusBtn?: boolean;
    focusBtnClassName?: string;
    style?: CSSProperties;
    ref?: LegacyRef<HTMLDivElement> | undefined;
    mirroring?: boolean;
}
declare const _default: React.NamedExoticComponent<VideoCardProps>;
export default _default;
