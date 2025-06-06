import classNames from 'classnames';
import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';

import AudioIcon from '@meeting-module/components/common/AudioIcon';
import UserAvatar from '@meeting-module/components/common/Avatar';
import SpeakerList from '@meeting-module/components/web/SpeakerList';
import useWatermark from '@meeting-module/hooks/useWatermark';
import {
  EventType,
  NEMeetingInfo,
  NEMember,
  Speaker,
} from '@meeting-module/types';

import './index.less';
import { IPCEvent } from '@/types';
import { useGlobalContext, useMeetingInfoContext } from '@meeting-module/store';
import Emoticons from '@meeting-module/components/common/Emoticons';
import useVideoShortcutOperation from '@meeting-module/hooks/useVideoShortcutOperation';
import { useUpdateEffect } from 'ahooks';
import useNetworkQuality from '@meeting-module/hooks/useNetworkQuality';
import { NEMemberVolumeInfo } from 'neroom-types';

const VideoCard: React.FC<{
  member: NEMember;
  sharingScreen: boolean;
  isMySelf: boolean;
  enableVideoMirroring?: boolean;
}> = ({ member, isMySelf, enableVideoMirroring }) => {
  useWatermark({ offsetX: 30, offsetY: 50 });

  const { meetingInfo } = useMeetingInfoContext();
  const mouseLeaveTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null);
  const viewRef = useRef<HTMLDivElement | null>(null);
  const [isMouseLeave, setIsMouseLeave] = useState<boolean>(true);
  const { isNetworkQualityBad } = useNetworkQuality(member);

  const isInPhone = useMemo(() => {
    return member.properties?.phoneState?.value == '1';
  }, [member.properties?.phoneState?.value]);

  const { operatorItems } = useVideoShortcutOperation({
    member,
    isMySelf,
  });

  useUpdateEffect(() => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'popover',
        payload: {
          type: 'hide',
        },
      },
      parentWindow.origin,
    );
  }, [member.role]);

  const handlePopover = useCallback(() => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'popover',
        payload: {
          type: 'open',
          items: operatorItems
            ? JSON.parse(JSON.stringify(operatorItems))
            : operatorItems,
        },
      },
      parentWindow.origin,
    );
  }, [operatorItems]);

  const nicknameHide = useMemo(() => {
    if (
      meetingInfo.setting.videoSetting.showMemberName === false &&
      isMouseLeave
    ) {
      return true;
    }

    return false;
  }, [isMouseLeave, meetingInfo.setting.videoSetting.showMemberName]);

  useEffect(() => {
    if (member.isVideoOn) {
      const parentWindow = window.parent;

      if (!isMySelf) {
        parentWindow?.postMessage(
          {
            event: 'rtcController',
            payload: {
              fnKey: 'setupRemoteVideoCanvas',
              args: ['', member.uuid],
            },
          },
          parentWindow.origin,
        );
        parentWindow?.postMessage(
          {
            event: 'neMeeting',
            payload: {
              fnKey: 'subscribeRemoteVideoStream',
              args: [member.uuid, 1],
            },
          },
          parentWindow.origin,
        );
      } else {
        parentWindow?.postMessage(
          {
            event: 'neMeeting',
            payload: {
              fnKey: 'setupLocalVideoCanvas',
              args: [member.uuid, false],
            },
          },
          parentWindow.origin,
        );
      }

      return () => {
        if (!isMySelf) {
          parentWindow?.postMessage(
            {
              event: 'neMeeting',
              payload: {
                fnKey: 'unsubscribeRemoteVideoStream',
                args: [member.uuid],
              },
            },
            parentWindow.origin,
          );
        } else {
          parentWindow?.postMessage(
            {
              event: 'neMeeting',
              payload: {
                fnKey: 'setupLocalVideoCanvas',
                args: [member.uuid, true],
              },
            },
            parentWindow.origin,
          );
        }
      };
    }
  }, [member.isVideoOn, member.uuid, isMySelf]);

  return (
    <div
      className={`video-view-wrap video-card sharing-screen-video-card ${
        enableVideoMirroring && isMySelf ? 'screenSharing-video-mirror' : ''
      }`}
      key={member.uuid}
      id={`nemeeting-${member.uuid}-video-card`}
      ref={viewRef}
      onMouseLeave={() => {
        mouseLeaveTimerRef.current = setTimeout(() => {
          setIsMouseLeave(true);
        }, 2000);
      }}
      onMouseEnter={() => {
        mouseLeaveTimerRef.current && clearTimeout(mouseLeaveTimerRef.current);
        setIsMouseLeave(false);
      }}
    >
      <div
        className="nemeeting-video-card-operate"
        onClick={() => handlePopover()}
      >
        <svg className="icon iconfont icon-operator" aria-hidden="true">
          <use xlinkHref="#iconzimugengduo"></use>
        </svg>
      </div>
      <div className={classNames('nemeeting-video-card-emoticons-container')}>
        <Emoticons
          size={40}
          isHandsUp={member.isHandsUp}
          userUuid={member.uuid}
          onlyHandsUp
        />
        <Emoticons size={40} userUuid={member.uuid} />
      </div>
      {member.isVideoOn ? (
        ''
      ) : (
        <UserAvatar
          size={48}
          nickname={member.name}
          avatar={member.avatar}
          className=""
        />
      )}
      {isInPhone ? (
        <>
          <div className="nemeeting-audio-card-phone-icon">
            <svg
              className="icon iconfont nemeeting-icon-phone"
              style={{ fontSize: '32px' }}
              aria-hidden="true"
            >
              <use xlinkHref="#icondianhua"></use>
            </svg>
          </div>
        </>
      ) : null}
      {nicknameHide ? null : (
        <div className={'nickname-tip'}>
          <div className="nickname">
            {isNetworkQualityBad && (
              <svg
                className="icon iconfont icon-hover icon-red nemeeting-card-network"
                aria-hidden="true"
              >
                <use xlinkHref="#icona-zu684" />
              </svg>
            )}
            {member.isAudioConnected ? (
              member.isAudioOn ? (
                <AudioIcon className="icon iconfont" memberId={member.uuid} />
              ) : (
                <svg className="icon icon-red iconfont" aria-hidden="true">
                  <use xlinkHref="#iconkaiqimaikefeng-mianxing"></use>
                </svg>
              )
            ) : null}
            {member.name}
          </div>
        </div>
      )}
    </div>
  );
};

export default function VideoPage() {
  const { eventEmitter } = useGlobalContext();
  const videoPageDomRef = useRef<HTMLDivElement | null>(null);
  const [memberList, setMemberList] = useState<NEMember[]>([]);
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [videoCount, setVideoCount] = useState(1);
  const [pageNum, setPageNum] = useState(1);
  const [speakerList, setSpeakerList] = useState<Speaker[]>([]);
  // 说话者列表Timer
  const audioVolumeIndicationTimer = useRef<
    null | number | ReturnType<typeof setTimeout>
  >(null);

  const memberListRef = useRef<NEMember[]>([]);

  memberListRef.current = memberList;

  const pageTotal = useMemo(() => {
    return memberList ? Math.ceil(memberList.length / 4) : 0;
  }, [memberList]);

  const memberListFilter = useMemo(() => {
    if (videoCount === 0) {
      return [];
    }

    const memberListWithoutSelf = memberList.filter(
      (member) => member.uuid !== meetingInfo?.localMember.uuid,
    );
    const memberListVideoOn = memberListWithoutSelf.filter(
      (member) => member.isVideoOn,
    );
    const memberListVideoOff = memberListWithoutSelf.filter(
      (member) => !member.isVideoOn,
    );
    let sortMemberList: NEMember[] = [];

    const enableHideMyVideo =
      meetingInfo?.setting.videoSetting?.enableHideMyVideo;
    const enableHideVideoOffAttendees =
      meetingInfo?.setting.videoSetting?.enableHideVideoOffAttendees;

    // 开启隐藏非视频参会者
    if (enableHideVideoOffAttendees) {
      sortMemberList = meetingInfo ? [...memberListVideoOn] : [];
      // 如果未开启隐藏本端
      if (!enableHideMyVideo || sortMemberList.length === 0) {
        sortMemberList = [meetingInfo.localMember, ...sortMemberList];
      }
    } else {
      sortMemberList = meetingInfo
        ? [...memberListVideoOn, ...memberListVideoOff]
        : [];
      if (!enableHideMyVideo || sortMemberList.length === 0) {
        sortMemberList = meetingInfo
          ? [meetingInfo.localMember, ...sortMemberList]
          : [...sortMemberList];
      }
    }

    const viewOrder =
      meetingInfo?.remoteViewOrder || meetingInfo?.localViewOrder;

    if (viewOrder) {
      const idOrder = viewOrder.split(',');

      sortMemberList.sort((a, b) => {
        // 获取 a 和 b 对象的 id 在 idOrder 数组中的索引位置
        const indexA = idOrder.indexOf(a.uuid);
        const indexB = idOrder.indexOf(b.uuid);

        // 根据 id 在 idOrder 中的索引位置进行排序
        if (indexA === -1 && indexB === -1) {
          return 0; // 如果两个都不在给定的 UUID 数组中，则保持原顺序
        } else if (indexA === -1) {
          return 1; // 如果 a 不在数组中但 b 在，则 b 应该在前面
        } else if (indexB === -1) {
          return -1; // 如果 b 不在数组中但 a 在，则 a 应该在前面
        } else {
          return indexA - indexB; // 否则按照在给定数组中的位置排序
        }
      });
    }

    if (videoCount === 1) {
      if (enableHideMyVideo) {
        return sortMemberList.length > 0 ? [sortMemberList[0]] : [];
      } else {
        return [meetingInfo?.localMember];
      }
    }

    const res = sortMemberList.slice((pageNum - 1) * 4, pageNum * 4);

    if (res.length === 0) {
      setPageNum((prev) => prev - 1);
      return [];
    } else if (res.length < 4) {
      // 获取倒数 4 个
      return sortMemberList.slice(-4);
    } else {
      return res;
    }
  }, [memberList, meetingInfo, videoCount, pageNum]);

  useEffect(() => {
    if (videoCount === 0) {
      const handle = (data: NEMemberVolumeInfo[]) => {
        const speakerList = data
          .map((item) => {
            const member = memberList.find(
              (member) => member.uuid == item.userUuid,
            );
            let name = item.userUuid;

            if (member) {
              name = member.name;
            }

            return {
              uid: item.userUuid,
              nickName: name,
              level: item.volume,
              show:
                member &&
                member.role !== 'screen_sharer' &&
                member.isAudioConnected,
            };
          })
          .filter((item) => item.show);

        setSpeakerList(speakerList);
        if (audioVolumeIndicationTimer.current) {
          clearTimeout(audioVolumeIndicationTimer.current);
          audioVolumeIndicationTimer.current = null;
        }

        // 4s未收到新数据表示没人说话 情况列表
        audioVolumeIndicationTimer.current = window.setTimeout(() => {
          setSpeakerList([]);
        }, 4000);
      };

      setSpeakerList((per) =>
        per.filter((item) => {
          return memberList.find((member) => member.uuid === item.uid)
            ?.isAudioConnected;
        }),
      );

      eventEmitter?.on(EventType.RtcAudioVolumeIndication, handle);
      return () => {
        eventEmitter?.off(EventType.RtcAudioVolumeIndication, handle);
      };
    }
  }, [memberList, videoCount]);

  useEffect(() => {
    let height = 35;

    if (videoCount === 1) {
      height = 120;
    } else if (videoCount === 4) {
      height = 120 * memberListFilter.length;
    }

    window.ipcRenderer?.send(IPCEvent.sharingScreen, {
      method: 'videoWindowHeightChange',
      data: {
        height,
      },
    });
  }, [memberListFilter.length, videoCount]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { meetingInfo, memberList } = payload;

        meetingInfo && setMeetingInfo(meetingInfo);
        memberList && setMemberList(memberList);
      }
    }

    window.addEventListener('message', handleMessage);
    window.ipcRenderer?.send(IPCEvent.sharingScreen, {
      method: 'videoWindowOpen',
    });
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  //本地录制功能需要，当前渲染布局发生变化时，需要通知本地录制模块，更新录制的布局
  useEffect(() => {
    if(!meetingInfo?.isLocalRecording){
      return
    }
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'electronScreenSharevideoLayoutChange',
        payload: {
          memberListFilter,
          videoCount,
          pageNum,
        },
      },
      parentWindow.origin,
    );
  }, [
    memberListFilter,
    videoCount,
    meetingInfo?.isLocalRecording, //用于录制状态变化的通知，作用于首次开始录制
  ]);

  return (
    <>
      <div className="video-parent-page-header">
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 0,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(0)}
        >
          <use xlinkHref="#icona-Frame1"></use>
        </svg>
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 1,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(1)}
        >
          <use xlinkHref="#icona-Frame21"></use>
        </svg>
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 4,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(4)}
        >
          <use xlinkHref="#icona-Frame3"></use>
        </svg>
        <div className="drag-area"></div>
      </div>
      <div className="video-page" ref={videoPageDomRef}>
        {videoCount === 4 && (
          <>
            {pageNum > 1 && (
              <svg
                className="icon iconfont page-turn-icon previous-page"
                aria-hidden="true"
                onClick={() => setPageNum((prev) => prev - 1)}
              >
                <use xlinkHref="#icontriangle-up1x"></use>
              </svg>
            )}
            {pageNum < pageTotal && (
              <svg
                className="icon iconfont page-turn-icon next-page"
                aria-hidden="true"
                onClick={() => setPageNum((prev) => prev + 1)}
              >
                <use xlinkHref="#icontriangle-down1x"></use>
              </svg>
            )}
          </>
        )}
        {videoCount === 0 ? (
          <SpeakerList speakerList={speakerList} />
        ) : (
          memberListFilter?.map((member) =>
            member ? (
              <VideoCard
                sharingScreen={
                  meetingInfo?.localMember.isSharingScreen ?? false
                }
                member={member}
                key={pageNum + member.uuid}
                isMySelf={member.uuid === meetingInfo?.localMember.uuid}
                enableVideoMirroring={
                  meetingInfo?.setting.videoSetting.enableVideoMirroring
                }
              />
            ) : null,
          )
        )}
      </div>
    </>
  );
}
