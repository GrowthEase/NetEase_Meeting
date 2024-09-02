import React, { useEffect, useRef, useState } from 'react';

import { Button, Dropdown, Form, Input, MenuProps, Switch } from 'antd';
import { NEPreviewController } from 'neroom-types';
import { useTranslation } from 'react-i18next';
import { MeetingSetting } from '@meeting-module/types';
import { getDefaultDeviceId, getMeetingDisplayId } from '@meeting-module/utils';
import Toast from '@meeting-module/components/common/toast';
import { SettingTabType } from '@meeting-module/components/web/Setting/Setting';
import './index.less';
import { worker } from '@meeting-module/components/web/Meeting/Meeting';
import { NESettingsService } from 'nemeeting-web-sdk';

type SummitValue = {
  meetingId: string;
  openCamera: boolean;
  openMic: boolean;
};
export type RecentMeetingList = {
  meetingNum: string;
  subject: string;
}[];

interface JoinMeetingProps {
  previewController?: NEPreviewController | null;
  settingsService?: NESettingsService;
  meetingNum: string;
  submitLoading?: boolean;
  setting?: MeetingSetting | null;
  settingOpen?: boolean;
  nickname?: string;
  avatar?: string;
  recentMeetingList?: RecentMeetingList;
  onSummit?: (value: SummitValue) => void;
  onSettingChange?: (setting: MeetingSetting) => void;
  onOpenSetting?: (tab?: SettingTabType) => void;
  onClearRecentMeetingList?: () => void;
  open: boolean;
}

const JoinMeeting: React.FC<JoinMeetingProps> = ({
  previewController: initPreviewController,
  settingsService,
  submitLoading,
  setting,
  onSummit,
  onSettingChange,
  onClearRecentMeetingList,
  ...restProps
}) => {
  const { t } = useTranslation();

  const i18n = {
    title: t('meetingJoin'),
    inputPlaceholder: t('meetingIDInputPlaceholder'),
    submitBtn: t('meetingJoin'),
    mic: t('microphone'),
    camera: t('camera'),
    clearAll: t('clearAll'),
    clearAllSuccess: t('clearAllSuccess'),
    openCameraInMeeting: t('openCameraInMeeting'),
    openMicInMeeting: t('openMicInMeeting'),
  };

  const videoPreviewRef = useRef<HTMLDivElement>(null);
  const [cameraId, setCameraId] = useState<string>('');
  const [openAudio, setOpenAudio] = useState<boolean>(false);
  const [openVideo, setOpenVideo] = useState<boolean>(false);
  const [openRecentMeetingList, setOpenRecentMeetingList] = useState(false);
  const [meetingNum, setMeetingNum] = useState<string>('');

  const [recentMeetingList, setRecentMeetingList] = useState<RecentMeetingList>(
    [],
  );
  const [previewController, setPreviewController] = useState<
    NEPreviewController | undefined | null
  >(initPreviewController);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const mirror = setting?.videoSetting.enableVideoMirroring || false;

  const joinMeetingInputRef = useRef<HTMLInputElement>(null);

  const onOpenMicStatusChange = (checked: boolean) => {
    setOpenAudio(checked);
    onHandleSettingChange({
      openAudio: checked,
      openVideo,
      cameraId,
    });
  };

  const onOpenCameraStatusChange = (checked: boolean) => {
    setOpenVideo(checked);
    onHandleSettingChange({
      openAudio,
      openVideo: checked,
      cameraId,
    });
  };

  const items: MenuProps['items'] = [
    ...recentMeetingList.map((item) => ({
      key: item.meetingNum,
      label: (
        <div className="recent-meeting-item">
          <div className="recent-meeting-item-title">{item.subject}</div>
          <div>{getMeetingDisplayId(item.meetingNum)}</div>
        </div>
      ),
      onClick: () => {
        setMeetingNum(item.meetingNum);
        setOpenRecentMeetingList(false);
      },
    })),

    {
      key: 'clear',
      label: <div className="recent-meeting-clear">{i18n.clearAll}</div>,
      onClick: () => {
        onClearRecentMeetingList?.();
        setRecentMeetingList([]);
        Toast.success(i18n.clearAllSuccess);
      },
    },
  ];

  function onFinish() {
    const data = {
      meetingId: meetingNum.replace(/-/g, '').replace(/\s/g, ''),
      openCamera: openVideo,
      openMic: openAudio,
    };

    onSummit?.(data);
  }

  function onHandleSettingChange({
    openAudio,
    openVideo,
    cameraId,
  }: {
    openAudio: boolean;
    openVideo: boolean;
    cameraId: string;
  }) {
    setting &&
      onSettingChange &&
      onSettingChange({
        ...setting,
        normalSetting: {
          ...setting.normalSetting,
          openAudio,
          openVideo,
        },
        videoSetting: {
          ...setting.videoSetting,
          deviceId: cameraId,
        },
      });
  }

  useEffect(() => {
    if (restProps.open) {
      setPreviewController(initPreviewController);
    }
  }, [restProps.open, initPreviewController, mirror]);
  useEffect(() => {
    if (restProps.meetingNum) {
      setMeetingNum(restProps.meetingNum);
    }
  }, [restProps.meetingNum]);

  useEffect(() => {
    const result = restProps?.recentMeetingList?.reduce(
      (unique: RecentMeetingList, o) => {
        if (!unique.some((obj) => obj.meetingNum === o.meetingNum)) {
          unique.push(o);
        }

        return unique;
      },
      [],
    );

    setRecentMeetingList(result || []);
  }, [restProps?.recentMeetingList]);

  useEffect(() => {
    if (
      previewController &&
      videoPreviewRef.current &&
      restProps.open &&
      openVideo
    ) {
      if (window.isElectronNative) {
        previewController.setupLocalVideoCanvas();
        previewController.startPreview();
      } else {
        previewController.startPreview(videoPreviewRef.current);
      }

      return () => {
        previewController.stopPreview();
      };
    }
  }, [restProps.open, openVideo, previewController]);

  useEffect(() => {
    function getDeviceList() {
      if (previewController) {
        previewController.enumCameraDevices().then(({ data }) => {
          if (data.length > 0) {
            let deviceId = '';

            if (
              data.find(
                (item) => item.deviceId === setting?.videoSetting.deviceId,
              )
            ) {
              deviceId = setting?.videoSetting.deviceId || data[0].deviceId;
            } else {
              deviceId = data[0].deviceId;
            }

            setCameraId(deviceId);
            if (setting?.videoSetting.deviceId !== deviceId) {
              previewController?.switchDevice({
                type: 'camera',
                deviceId: getDefaultDeviceId(deviceId),
              });
            }
          }
        });
      }
    }

    if (restProps.open) {
      setOpenAudio(setting?.normalSetting.openAudio ?? false);
      setOpenVideo(setting?.normalSetting.openVideo ?? false);

      navigator.mediaDevices.addEventListener('devicechange', getDeviceList);
      return () => {
        navigator.mediaDevices.removeEventListener(
          'devicechange',
          getDeviceList,
        );
      };
    }
  }, [
    previewController,
    restProps.open,
    setting?.videoSetting.deviceId,
    setting?.normalSetting.openVideo,
    setting?.normalSetting.openAudio,
  ]);

  useEffect(() => {
    const canvas = canvasRef.current;
    const view = videoPreviewRef.current;
    const uuid = 'mySelf';

    if (canvas && view && openVideo) {
      const offscreen = canvas.transferControlToOffscreen();

      worker.postMessage(
        {
          canvas: offscreen,
          uuid,
        },
        [offscreen],
      );

      const handleMessage = (e: MessageEvent) => {
        const { event, payload } = e.data;

        if (event === 'onVideoFrameData') {
          const { data, width, height } = payload;

          const viewWidth = view.clientWidth;
          const viewHeight = view.clientHeight;

          if (viewWidth / (width / height) > viewHeight) {
            canvas.style.height = `${viewHeight}px`;
            canvas.style.width = `${viewHeight * (width / height)}px`;
          } else {
            canvas.style.width = `${viewWidth}px`;
            canvas.style.height = `${viewWidth / (width / height)}px`;
          }

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
        }
      };

      window.addEventListener('message', handleMessage);
      return () => {
        window.removeEventListener('message', handleMessage);
      };
    }
  }, [openVideo]);

  useEffect(() => {
    if (restProps.open) {
      settingsService?.isTurnOnMyVideoWhenJoinMeetingEnabled().then((res) => {
        setOpenVideo(res.data);
      });
      settingsService?.isTurnOnMyAudioWhenJoinMeetingEnabled().then((res) => {
        setOpenAudio(res.data);
      });
    }
  }, [restProps.open]);

  useEffect(() => {
    settingsService?.enableTurnOnMyAudioWhenJoinMeeting(openAudio);
  }, [openAudio]);

  useEffect(() => {
    settingsService?.enableTurnOnMyVideoWhenJoinMeeting(openVideo);
  }, [openVideo]);

  // 打开加入会议窗口自动focus
  useEffect(() => {
    joinMeetingInputRef.current?.focus();
  }, []);

  return (
    <div className="join-meeting-wrap">
      {/* <div className="before-meeting-modal-content">
        <div
          ref={videoPreviewRef}
          className={`video-preview ${
            setting?.videoSetting.enableVideoMirroring
              ? 'nemeeting-video-mirror'
              : ''
          }`}
        >
          {window.isElectronNative && openVideo && (
            <canvas
              style={{
                display: openVideo ? 'block' : 'none',
              }}
              className="nemeeting-video-view-canvas"
              ref={canvasRef}
            />
          )}
          <UserAvatar
            style={{
              display: openVideo ? 'none' : 'block',
            }}
            className="user-avatar"
            nickname={nickname || ''}
            size={48}
            avatar={avatar}
          />
        </div>
      </div> */}

      <Dropdown
        trigger={openRecentMeetingList ? ['click'] : []}
        menu={{ items }}
        placement="bottom"
        autoAdjustOverflow={false}
        open={openRecentMeetingList && recentMeetingList.length > 0}
        onOpenChange={(open) => setOpenRecentMeetingList(open)}
        rootClassName="recent-meeting-dropdown"
        getPopupContainer={(node) => node}
        destroyPopupOnHide
      >
        <Form
          name="basic"
          autoComplete="off"
          onClick={(e) => {
            e.stopPropagation();
          }}
        >
          <Input
            className="join-meeting-modal-input"
            placeholder={i18n.inputPlaceholder}
            // @ts-expect-error antd type error
            ref={joinMeetingInputRef}
            prefix={
              <span
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
                className="meeting-id-prefix"
              >
                {t('meetingNumber')}
              </span>
            }
            value={meetingNum}
            allowClear
            onChange={(e) => {
              if (/^[0-9-]*$/.test(e.target.value)) {
                setMeetingNum(e.target.value.trim());
              }
            }}
            suffix={
              recentMeetingList.length > 0 ? (
                openRecentMeetingList ? (
                  <span
                    onClick={() => {
                      setTimeout(() => {
                        setOpenRecentMeetingList(false);
                      }, 250);
                    }}
                    className="iconxiajiantou-up"
                  >
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconxiajiantou-shixin"></use>
                    </svg>
                  </span>
                ) : (
                  <span
                    onClick={() => {
                      setTimeout(() => {
                        setOpenRecentMeetingList(true);
                      }, 250);
                    }}
                    className="iconxiajiantou-up"
                  >
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconxiajiantou-shixin"></use>
                    </svg>
                  </span>
                )
              ) : null
            }
          />
        </Form>
      </Dropdown>
      <div className="meeting-open-mic-wrapper join-meeting-line-item">
        <div
          className="meeting-open-mic-title"
          style={{
            fontWeight: 'bold',
          }}
        >
          {i18n.openMicInMeeting}
        </div>
        <div>
          <Switch value={openAudio} onChange={onOpenMicStatusChange}></Switch>
        </div>
      </div>
      <div className="meeting-open-video-wrapper immediate-meeting-line-item">
        <div
          className="meeting-open-video-title"
          style={{
            fontWeight: 'bold',
          }}
        >
          {i18n.openCameraInMeeting}
        </div>
        <div>
          <Switch
            value={openVideo}
            onChange={onOpenCameraStatusChange}
          ></Switch>
        </div>
      </div>
      <div className="before-meeting-modal-footer join-meeting-footer-button">
        {/* <div
          className={classNames('audio-button audio-button-close', {
            'audio-button-open': openAudio,
          })}
          onClick={() => {
            setOpenAudio(!openAudio);
            onHandleSettingChange({
              openAudio: !openAudio,
              openVideo,
              cameraId,
            });
          }}
        >
          <div>
            <svg
              className={classNames('icon iconfont icon-audio', {
                'icon-open': openAudio,
              })}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  openAudio ? '#iconyx-tv-voice-onx' : '#iconyx-tv-voice-offx'
                }`}
              ></use>
            </svg>
          </div>
          <div className="device-list-title">{i18n.mic}</div>
        </div>
        <div
          className={classNames('video-button video-button-close', {
            'video-button-open': openVideo,
          })}
          onClick={() => {
            setOpenVideo(!openVideo);
            onHandleSettingChange({
              openAudio,
              openVideo: !openVideo,
              cameraId,
            });
          }}
        >
          <div>
            <svg
              className={classNames('icon iconfont iconyx-tv-video', {
                'icon-red': !openVideo,
              })}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  openVideo ? '#iconyx-tv-video-onx' : '#iconyx-tv-video-offx'
                }`}
              ></use>
            </svg>
          </div>
          <div className="device-list-title">{i18n.camera}</div>
        </div> */}

        <Button
          loading={submitLoading}
          className="join-meeting-footer-button-submit"
          disabled={!meetingNum}
          type="primary"
          onClick={() => onFinish()}
        >
          <span className="submit-text">{i18n.submitBtn}</span>
        </Button>
      </div>
    </div>
  );
};

export default JoinMeeting;
