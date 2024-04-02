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
import YUVCanvas from '../../../../src/libs/yuv-canvas';
import {
  drawWatermark,
  stopDrawWatermark,
} from '../../../../src/utils/watermark';

const VideoCard: React.FC<{
  member: NEMember;
  sharingScreen: boolean;
  volume: number;
  isMySelf: boolean;
}> = ({ member, sharingScreen, volume, isMySelf }) => {
  const viewRef = useRef<HTMLDivElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  /*
  function getPosition() {
    if (member.isVideoOn) {
      const targetElement = document.getElementById(
        `nemeeting-${member.uuid}-video-card`,
      );
      if (targetElement) {
        const rect = targetElement.getBoundingClientRect();
        // 计算相对于<body>的位置
        const bodyRect = document.body.getBoundingClientRect();
        const relativePosition = {
          x: rect.x - bodyRect.x,
          y: rect.y - bodyRect.y,
          width: targetElement.clientWidth,
          height: targetElement.clientHeight,
        };
        window.ipcRenderer?.send('nemeeting-video-card-open', {
          uuid: member.uuid,
          position: relativePosition,
          mirroring: false,
          type: 'video',
          isMySelf: isMySelf,
          streamType: 1,
        });
      }
    }
  }
  */

  /*
  useEffect(() => {
    if (sharingScreen) {
      setTimeout(() => {
        getPosition();
      }, 100);
      return () => {
        window.ipcRenderer?.send('nemeeting-video-card-close', {
          uuid: member.uuid,
          type: 'video',
        });
      };
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [member.isVideoOn, sharingScreen]);
  */

  useEffect(() => {
    if (member.isVideoOn) {
      window.ipcRenderer?.send('nemeeting-sharing-screen', {
        method: 'videoOpen',
        data: {
          uuid: member.uuid,
          isMySelf,
        },
      });

      const canvas = canvasRef.current;
      if (canvas && viewRef.current) {
        const yuv = YUVCanvas.attach(canvas);
        function handle(
          _: any,
          uuid: string,
          bSubVideo: boolean,
          data: any,
          type: string,
          width: number,
          height: number,
        ) {
          if (uuid === member.uuid) {
            if (canvas && viewRef.current) {
              canvas.style.height = `${viewRef.current.clientHeight}px`;
            }
            const uvWidth = width / 2;
            let pixelStorei = 1;
            if (uvWidth % 8 === 0) {
              pixelStorei = 8;
            } else if (uvWidth % 4 === 0) {
              pixelStorei = 4;
            } else if (uvWidth % 2 === 0) {
              pixelStorei = 2;
            }
            const buffer = {
              format: {
                width,
                height,
                chromaWidth: width / 2,
                chromaHeight: height / 2,
                cropLeft: 0, // default
                cropTop: 0, // default
                cropHeight: height,
                cropWidth: width,
                displayWidth: width, // derived from width via cropWidth
                displayHeight: height, // derived from cropHeight
                pixelStorei,
              },
              ...data,
            };
            yuv.drawFrame(buffer);
          }
        }
        window.ipcRenderer?.on('onVideoFrameData', handle);
        return () => {
          window.ipcRenderer?.send('nemeeting-sharing-screen', {
            method: 'videoClose',
            data: {
              uuid: member.uuid,
              isMySelf,
            },
          });
          window.ipcRenderer?.removeListener('onVideoFrameData', handle);
        };
      }
    }
  }, [member.isVideoOn, member.uuid, isMySelf]);

  return (
    <div
      className="video-view-wrap video-card sharing-screen-video-card"
      key={member.uuid}
      id={`nemeeting-${member.uuid}-video-card`}
      ref={viewRef}
      // style={{
      //   background: member.isVideoOn ? 'transparent' : undefined,
      // }}
    >
      <canvas
        ref={canvasRef}
        className="nemeeting-video-view-canvas"
        style={{ display: member.isVideoOn ? '' : 'none' }}
      />
      {member.isVideoOn ? '' : member.name}
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
  const [isSharing, setIsSharing] = useState(false);

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
    if (videoCount === 4) {
      window.ipcRenderer?.send('nemeeting-sharing-screen', {
        method: 'videoWindowHeightChange',
        data: {
          height: 120 * memberListFilter.length,
        },
      });
    }
  }, [memberListFilter.length, videoCount]);

  useEffect(() => {
    window.ipcRenderer?.send('nemeeting-sharing-screen', {
      method: 'videoCountModelChange',
      data: {
        videoCount,
      },
    });
  }, [videoCount]);

  useEffect(() => {
    window.ipcRenderer?.on('updateData', (_, data) => {
      const { meetingInfo, memberList } = data;
      setMeetingInfo(meetingInfo);
      setMemberList(memberList);
    });
    window.ipcRenderer?.on('nemeeting-sharing-screen', (_, value) => {
      const { method, data } = value;
      switch (method) {
        case 'startScreenShare':
          memberListRef.current.forEach((member) => {
            if (member.isVideoOn) {
              window.ipcRenderer?.send('nemeeting-sharing-screen', {
                method: 'videoClose',
                data: {
                  uuid: member.uuid,
                },
              });
            }
          });
          setIsSharing(true);
          break;
        case 'stopScreenShare':
          setIsSharing(false);
          break;
        case 'videoCountModelChange':
          const { videoCount } = data;
          setVideoCount(videoCount);
          break;
      }
    });
  }, []);

  useEffect(() => {
    if (meetingInfo?.localMember?.uuid) {
      const listener = (_: any, value: any) => {
        const { method, data } = value;
        switch (method) {
          case 'audioVolumeIndication':
            const { key, payload } = data;
            if (key === EventType.RtcLocalAudioVolumeIndication) {
              setVolumeMap((prev) => ({
                ...prev,
                [meetingInfo.localMember.uuid]: payload,
              }));
            }
            if (key === EventType.RtcAudioVolumeIndication) {
              payload.forEach((item: any) => {
                setVolumeMap((prev) => ({
                  ...prev,
                  [item.userUuid]: item.volume,
                }));
              });
            }
            break;
        }
      };
      window.ipcRenderer?.on('nemeeting-sharing-screen', listener);
      return () => {
        window.ipcRenderer?.off('nemeeting-sharing-screen', listener);
      };
    }
  }, [volumeMap, meetingInfo?.localMember?.uuid]);

  useEffect(() => {
    if (meetingInfo && videoPageDomRef.current) {
      const localMember = meetingInfo?.localMember;
      const needDrawWatermark =
        meetingInfo.meetingNum &&
        meetingInfo.watermark &&
        (meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.OPEN ||
          meetingInfo.watermark.videoStrategy ===
            WATERMARK_STRATEGY.FORCE_OPEN);

      if (needDrawWatermark && meetingInfo.watermark) {
        const { videoStyle, videoFormat } = meetingInfo.watermark;
        const supportInfo = {
          name: meetingInfo.watermarkConfig?.name || localMember.name,
          phone: meetingInfo.watermarkConfig?.phone || '',
          email: meetingInfo.watermarkConfig?.email || '',
          jobNumber: meetingInfo.watermarkConfig?.jobNumber || '',
        };
        function replaceFormat(format: string, info: Record<string, string>) {
          const regex = /{([^}]+)}/g;
          const result = format.replace(regex, (match, key) => {
            const value = info[key];
            return value ? value : match; // 如果值存在，则返回对应的值，否则返回原字符串
          });
          return result;
        }

        drawWatermark({
          container: videoPageDomRef.current,
          content: replaceFormat(videoFormat, supportInfo),
          type: videoStyle,
          offsetX: 20,
          offsetY: 30,
        });
      } else {
        stopDrawWatermark();
      }
      return () => {
        stopDrawWatermark();
      };
    }
  }, [meetingInfo, memberListFilter]);

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
      {isSharing ? (
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
      ) : null}
    </>
  );
}
