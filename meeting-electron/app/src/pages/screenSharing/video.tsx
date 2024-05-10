import classNames from 'classnames';
import { useEffect, useMemo, useRef, useState } from 'react';

import AudioIcon from '../../../../src/components/common/AudioIcon';
import UserAvatar from '../../../../src/components/common/Avatar';
import SpeakerList from '../../../../src/components/web/SpeakerList';
import useWatermark from '../../../../src/hooks/useWatermark';
import { NEMeetingInfo, NEMember } from '../../../../src/types';

import { worker } from '../../../../src/components/web/Meeting/Meeting';
import './index.less';

const VideoCard: React.FC<{
  member: NEMember;
  sharingScreen: boolean;
  volume: number;
  isMySelf: boolean;
}> = ({ member, volume, isMySelf }) => {
  useWatermark({ offsetX: 30, offsetY: 50 });

  const viewRef = useRef<HTMLDivElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  const isInPhone = useMemo(() => {
    return member.properties?.phoneState?.value == '1';
  }, [member.properties?.phoneState?.value]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (canvas && viewRef.current) {
      canvas.style.height = `${viewRef.current.clientHeight}px`;
      // @ts-ignore
      const offscreen = canvas.transferControlToOffscreen();
      worker.postMessage(
        {
          canvas: offscreen,
          uuid: member.uuid,
        },
        [offscreen],
      );
    }
  }, [member.uuid]);

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
        }
      };
    }
  }, [member.isVideoOn, member.uuid, isMySelf]);

  return (
    <div
      className="video-view-wrap video-card sharing-screen-video-card"
      key={member.uuid}
      id={`nemeeting-${member.uuid}-video-card`}
      ref={viewRef}
    >
      <canvas
        ref={canvasRef}
        className="nemeeting-video-view-canvas"
        style={{ display: member.isVideoOn ? '' : 'none' }}
      />
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
      <div className={'nickname-tip'}>
        <div className="nickname">
          {member.isAudioConnected ? (
            member.isAudioOn ? (
              <AudioIcon className="icon iconfont" audioLevel={volume} />
            ) : (
              <svg className="icon icon-red iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-voice-offx"></use>
              </svg>
            )
          ) : null}
          {member.name}
        </div>
      </div>
    </div>
  );
};

export default function VideoPage() {
  const videoPageDomRef = useRef<HTMLDivElement | null>(null);
  const [memberList, setMemberList] = useState<NEMember[]>([]);
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [videoCount, setVideoCount] = useState(1);
  const [pageNum, setPageNum] = useState(1);
  const [volumeMap, setVolumeMap] = useState<Record<string, number>>({});

  const memberListRef = useRef<NEMember[]>([]);

  memberListRef.current = memberList;

  const pageTotal = useMemo(() => {
    return Math.ceil(memberList.length / 4);
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
    const sortMemberList = meetingInfo
      ? [meetingInfo.localMember, ...memberListVideoOn, ...memberListVideoOff]
      : [];
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
      return [meetingInfo?.localMember];
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

  const speakerList = useMemo(() => {
    return memberList
      .filter(
        (member) =>
          member.isAudioOn &&
          member.isAudioConnected &&
          volumeMap[member.uuid] > 0,
      )
      .map((member) => ({
        uid: member.uuid,
        nickName: member.name,
        level: volumeMap[member.uuid],
      }));
  }, [memberList, volumeMap]);

  useEffect(() => {
    let height = 35;
    if (videoCount === 1) {
      height = 120;
    } else if (videoCount === 4) {
      height = 120 * memberListFilter.length;
    }
    window.ipcRenderer?.send('nemeeting-sharing-screen', {
      method: 'videoWindowHeightChange',
      data: {
        height,
      },
    });
  }, [memberListFilter.length, videoCount]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'onVideoFrameData') {
        const { uuid, data, width, height } = payload;
        worker.postMessage(
          {
            frame: {
              width,
              height,
              data,
            },
            uuid,
          },
          [data.bytes.buffer],
        );
      } else if (event === 'updateData') {
        const { meetingInfo, memberList } = payload;
        setMeetingInfo(meetingInfo);
        setMemberList(memberList);
      }
    }
    window.addEventListener('message', handleMessage);
    window.ipcRenderer?.send('nemeeting-sharing-screen', {
      method: 'videoWindowOpen',
    });
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'audioVolumeIndication') {
        setVolumeMap({
          ...volumeMap,
          [payload.userUuid]: payload.volume,
        });
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [volumeMap]);

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
                volume={volumeMap[member.uuid] || 0}
                isMySelf={member.uuid === meetingInfo?.localMember.uuid}
              />
            ) : null,
          )
        )}
      </div>
    </>
  );
}
