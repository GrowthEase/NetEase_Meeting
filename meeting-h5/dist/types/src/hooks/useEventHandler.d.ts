/**
 * app的web和h5复用逻辑
 */
import { Dispatch as DispatchR, SetStateAction } from 'react';
import { NERoomRtcNetworkQualityInfo } from 'neroom-web-sdk';
interface UseEventHandlerInterface {
    joinLoading: boolean | undefined;
    showReplayDialog: boolean;
    showReplayScreenDialog: boolean;
    isShowAudioDialog: boolean;
    isShowVideoDialog: boolean;
    showReplayAudioSlaveDialog: boolean;
    showTimeTip: boolean;
    networkQuality: NERoomRtcNetworkQualityInfo;
    setIsOpenVideoByHost: DispatchR<SetStateAction<boolean>>;
    setIsShowVideoDialog: DispatchR<SetStateAction<boolean>>;
    setIsOpenAudioByHost: DispatchR<SetStateAction<boolean>>;
    setIsShowAudioDialog: DispatchR<SetStateAction<boolean>>;
    setShowTimeTip: DispatchR<SetStateAction<boolean>>;
    timeTipContent: string;
    confirmToReplay: (type: 'audio' | 'video' | 'audioSlave' | 'screen') => void;
    confirmUnMuteMyAudio: () => void;
    confirmUnMuteMyVideo: () => void;
}
export default function useEventHandler(): UseEventHandlerInterface;
export {};
