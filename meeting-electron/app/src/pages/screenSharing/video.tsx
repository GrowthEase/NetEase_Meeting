import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { useEffect, useMemo, useRef, useState } from 'react';
import classNames from 'classnames';
import AudioIcon from '../../../../src/components/common/AudioIcon';
import {
  EventType,
  NEMeetingInfo,
  NEMember,
  WATERMARK_STRATEGY,
} from '../../../../src/types';
import SpeakerList from '../../../../src/components/web/SpeakerList';
import {
  drawWatermark,
  stopDrawWatermark,
} from '../../../../src/utils/watermark';
import { worker } from '../../../../src/components/web/Meeting/Meeting';
import UserAvatar from '../../../../src/components/common/Avatar';

const VideoCard: React.FC<{
  member: NEMember;
  sharingScreen: boolean;
  volume: number;
  isMySelf: boolean;
}> = ({ member, volume, isMySelf }) => {
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
          '*',
        );
        parentWindow?.postMessage({
          event: 'rtcController',
          payload: {
            fnKey: 'subscribeRemoteVideoStream',
            args: [member.uuid, 1],
          },
        });
      }

      return () => {
        if (!isMySelf) {
          parentWindow?.postMessage(
            {
              event: 'rtcController',
              payload: {
                fnKey: 'unsubscribeRemoteVideoStream',
                args: [member.uuid],
              },
            },
            '*',
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
    if (videoCount === 1) {
      return [meetingInfo?.localMember];
    }
    if (videoCount === 4) {
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
    const sortMemberList = [
      meetingInfo?.localMember,
      ...memberListVideoOn,
      ...memberListVideoOff,
    ];
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
