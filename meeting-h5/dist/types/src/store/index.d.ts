import React from 'react';
import { GlobalContext as GlobalContextInterface, GlobalProviderProps, MeetingInfoContextInterface, MeetingInfoProviderProps, NEMember } from '../types';
export declare const GlobalContext: React.Context<GlobalContextInterface>;
export declare const GlobalContextProvider: React.FC<GlobalProviderProps>;
export declare const useGlobalContext: () => GlobalContextInterface;
export declare const MeetingInfoContext: React.Context<MeetingInfoContextInterface>;
export declare const useMeetingInfoContext: () => MeetingInfoContextInterface;
export declare const MeetingInfoContextProvider: React.FC<MeetingInfoProviderProps>;
/**
 * 视频排序规则
 * 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
 * 自己->音视频>视频->音频->都不开
 **/
export declare function sortMembers(memberList: NEMember[], localUuid: string): NEMember[];
