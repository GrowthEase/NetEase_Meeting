import { IMAGE_SIZE_LIMIT } from '@/config';
import { IPCEvent, LiveSettingInfo, PlatformInfo } from '@/types';
import { LiveBgPreviewImg } from '@meeting-module/components/web/Live';
import { Button, Checkbox, Input, message, Spin, Upload } from 'antd';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import './index.less';
import { PlusCircleOutlined } from '@ant-design/icons';
import { AddOtherPlatform } from '@meeting-module/components/web/Live/AddOtherPlatform';
import NEPreMeetingService from '@meeting-module/kit/impl/service/pre_meeting_service';
import { BeforeMeetingConfig, Toast } from '@meeting-module/kit';

interface LiveSettingProps {
  className?: string;
  liveInfo?: LiveSettingInfo;
  onCancel: () => void;
  onSave: (liveInfo: LiveSettingInfo) => void;
  preMeetingService?: NEPreMeetingService;
  globalConfig?: BeforeMeetingConfig;
  maxCount: number;
}

interface LiveBgPreviewItemProps {
  onClick: () => void;
}

const LiveBgPreviewItem: React.FC<LiveBgPreviewItemProps> = ({ onClick }) => {
  const { t } = useTranslation();

  return (
    <div className={`nemeeting-live-bg-preview`} onClick={onClick}>
      <PlusCircleOutlined style={{ fontSize: '20px' }} />
      <span className="nemeeting-live-bg-preview-tip">
        {t('liveCoverPictureTip')}
      </span>
    </div>
  );
};

interface LiveBackgroundInfo {
  backgroundUrl?: string;
  thumbnailBackgroundUrl?: string;
  coverUrl?: string;
  thumbnailCoverUrl?: string;
  backgroundFile?: Blob | string;
  coverFile?: Blob | string;
}

const LiveSetting: React.FC<LiveSettingProps> = ({
  className,
  liveInfo,
  onCancel,
  onSave,
  maxCount,
  globalConfig,
}) => {
  const { t } = useTranslation();
  const [liveTitle, setLiveTitle] = useState(liveInfo?.title || '');
  const [uploadBackgroundLoading, setUploadBackgroundLoading] = useState(false);
  const [uploadCoverLoading, setUploadCoverLoading] = useState(false);
  const [liveBackgroundInfo, setLiveBackgroundInfo] = useState<
    LiveBackgroundInfo | undefined
  >();
  const [showAddOtherPlatform, setShowOtherPlatform] = useState(false);
  const [enablePassword, setEnablePassword] = useState(!!liveInfo?.password);
  const [password, setPassword] = useState(liveInfo?.password || '');
  const [enableAddOtherPlatform, setEnableAddOtherPlatform] = useState(false);
  const [platformInfoList, setPlatformInfoList] = useState<PlatformInfo[]>([]);
  const [liveChatRoomEnable, setLiveChatRoomEnable] = useState(false);
  const [currentPlatformInfo, setCurrentPlatformInfo] = useState<
    (PlatformInfo & { index?: number }) | undefined
  >();
  const isEditPlatformInfoRef = useRef(false);

  const liveBackgroundInfoRef = useRef<LiveBackgroundInfo | undefined>(
    liveBackgroundInfo,
  );

  const isMeetingLiveOfficialPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.officialPushEnabled;

  const isMeetingLiveThirdPartyPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.thirdPartyPushEnabled;

  liveBackgroundInfoRef.current = liveBackgroundInfo;

  useEffect(() => {
    if (liveInfo) {
      setLiveTitle(liveInfo.title || '');
      setPassword(liveInfo.password || '');
      setEnablePassword(!!liveInfo.password);
      setPlatformInfoList(liveInfo.pushThirdParties || []);
      setLiveChatRoomEnable(!!liveInfo.liveChatRoomEnable);
      setEnableAddOtherPlatform(
        !!(liveInfo.pushThirdParties && liveInfo.pushThirdParties?.length > 0),
      );
      if (liveInfo.background) {
        const {
          backgroundUrl,
          thumbnailBackUrl,
          notStartCoverUrl,
          notStartThumbnailUrl,
        } = liveInfo.background;

        setLiveBackgroundInfo({
          backgroundUrl: backgroundUrl,
          thumbnailBackgroundUrl: thumbnailBackUrl,
          coverUrl: notStartCoverUrl,
          thumbnailCoverUrl: notStartThumbnailUrl,
        });
      }
    }
  }, [liveInfo]);

  function onClickDeleteBackground() {
    //
    const _liveBackgroundInfo = { ...liveBackgroundInfo };

    _liveBackgroundInfo.backgroundUrl = '';
    _liveBackgroundInfo.thumbnailBackgroundUrl = '';
    _liveBackgroundInfo.backgroundFile = '';
    setLiveBackgroundInfo(_liveBackgroundInfo);
    liveBackgroundInfoRef.current = _liveBackgroundInfo;
  }

  function coverBeforeUpload(file): boolean {
    uploadWebFile(file, 'cover');
    return false;
  }

  function onBackgroundChange(info) {
    console.log('onBackgroundChange', info);
  }

  function handleGoBack() {
    setShowOtherPlatform(false);
  }

  function onClickUploadCover() {
    handleSelectFile();
    window.ipcRenderer?.send(IPCEvent.choseFile, {
      type: 'image',
      extensions: ['jpg', 'png', 'jpeg'],
      extendedData: {
        type: 'cover',
      },
    });
  }

  function handleSaveOtherPlatform(platformInfo: PlatformInfo) {
    const _platformInfoList = [...platformInfoList];

    // 编辑
    if (isEditPlatformInfoRef.current) {
      const index = currentPlatformInfo?.index;

      if (index !== undefined && index > -1) {
        _platformInfoList[index] = platformInfo;
      }
    } else {
      // 新增
      _platformInfoList.push(platformInfo);
    }

    setPlatformInfoList(_platformInfoList);
    setShowOtherPlatform(false);
  }

  function handleSelectFile() {
    window.ipcRenderer?.removeAllListeners(IPCEvent.choseFileDone);
    window.ipcRenderer?.once(
      IPCEvent.choseFileDone,
      (_, { type, file, extendedData }) => {
        if (navigator.onLine) {
          console.log(type, file, extendedData);
          // 如果不是图片类型直接返回报错
          if (type !== 'image') {
            return;
          }

          if (type === 'image' && file.size > IMAGE_SIZE_LIMIT) {
            message.error(t('imageSizeLimit5'));
            return;
          }

          if (extendedData.type === 'background') {
            setUploadBackgroundLoading(true);
          } else {
            setUploadCoverLoading(true);
          }

          const data: LiveBackgroundInfo = {
            ...liveBackgroundInfoRef.current,
          };

          if (extendedData.type === 'background') {
            data.backgroundUrl = file.base64;
            data.thumbnailBackgroundUrl = '';
            data.backgroundFile = file.url;
          } else {
            data.coverUrl = file.base64;
            data.thumbnailCoverUrl = '';
            data.coverFile = file.url;
          }

          liveBackgroundInfoRef.current = data;
          setLiveBackgroundInfo(liveBackgroundInfoRef.current);
          if (extendedData.type === 'background') {
            setUploadBackgroundLoading(false);
          } else {
            setUploadCoverLoading(false);
          }
        } else {
          message.error(t('networkError'));
        }
      },
    );
  }

  function onClickUploadBackground() {
    handleSelectFile();
    window.ipcRenderer?.send(IPCEvent.choseFile, {
      type: 'image',
      extensions: ['jpg', 'png', 'jpeg'],
      extendedData: {
        type: 'background',
      },
    });
  }

  function onClickDeleteCover() {
    const _liveBackgroundInfo = { ...liveBackgroundInfo };

    _liveBackgroundInfo.coverUrl = '';
    _liveBackgroundInfo.thumbnailCoverUrl = '';
    _liveBackgroundInfo.coverFile = '';
    setLiveBackgroundInfo(_liveBackgroundInfo);
    liveBackgroundInfoRef.current = _liveBackgroundInfo;
  }

  function onCoverChange(info) {
    console.log('onCoverChange', info);
  }

  function uploadWebFile(file, type: 'background' | 'cover') {
    const ext = file.name && file.name.split('.').pop().toLowerCase();

    if (file.size > IMAGE_SIZE_LIMIT) {
      message.error(t('imageSizeLimit5'));
      return;
    }

    if (!['jpg', 'png', 'jpeg'].includes(ext?.toLowerCase())) {
      return;
    }

    if (type === 'background') {
      setUploadBackgroundLoading(true);
    } else {
      setUploadCoverLoading(true);
    }

    let data = liveBackgroundInfoRef.current;
    const URL = window.URL || window.webkitURL;
    const imgURL = URL.createObjectURL(file);

    if (type === 'background') {
      data = {
        ...data,
        backgroundUrl: imgURL,
        thumbnailBackgroundUrl: '',
        backgroundFile: file,
      };
    } else {
      data = {
        ...data,
        coverUrl: imgURL,
        thumbnailCoverUrl: '',
        coverFile: file,
      };
    }

    liveBackgroundInfoRef.current = {
      ...data,
    };
    setLiveBackgroundInfo({
      ...liveBackgroundInfoRef.current,
    });

    if (type === 'background') {
      setUploadBackgroundLoading(false);
    } else {
      setUploadCoverLoading(false);
    }
  }

  function backgroundBeforeUpload(file): boolean {
    uploadWebFile(file, 'background');
    return false;
  }

  const liveBgPreviewImgBackgroundMemo = useMemo(
    () => (
      <LiveBgPreviewImg
        onClick={onClickUploadBackground}
        onClose={onClickDeleteBackground}
        isStarted={false}
        url={
          liveBackgroundInfo?.thumbnailBackgroundUrl ||
          liveBackgroundInfo?.backgroundUrl
        }
      />
    ),

    [
      liveBackgroundInfo?.thumbnailBackgroundUrl,
      liveBackgroundInfo?.backgroundUrl,
    ],
  );
  const liveBgPreviewImgCoverMemo = useMemo(
    () => (
      <LiveBgPreviewImg
        isStarted={false}
        onClose={onClickDeleteCover}
        onClick={onClickUploadCover}
        url={
          liveBackgroundInfo?.thumbnailCoverUrl || liveBackgroundInfo?.coverUrl
        }
      />
    ),

    [liveBackgroundInfo?.coverUrl, liveBackgroundInfo?.thumbnailCoverUrl],
  );

  function addOtherPlatform() {
    isEditPlatformInfoRef.current = false;
    setCurrentPlatformInfo(undefined);
    setShowOtherPlatform(true);
  }

  function editOtherPlatform(e: React.MouseEvent, index: number) {
    isEditPlatformInfoRef.current = true;
    e.stopPropagation();
    e.preventDefault();
    const platformInfo = platformInfoList[index];

    setCurrentPlatformInfo({ ...platformInfo, index });
    setShowOtherPlatform(true);
  }

  function handleDeletePlatform(e: React.MouseEvent, index: number) {
    e.stopPropagation();
    e.preventDefault();
    const _platformInfoList = [...platformInfoList];

    // 删除该项
    if (index > -1) {
      _platformInfoList.splice(index, 1);
      setPlatformInfoList([..._platformInfoList]);
    }
  }

  function handleSavePlatformInfo() {
    if (enablePassword && password.trim().length < 6) {
      Toast.fail(t('livePasswordTip'));
      return;
    }

    const platformInfo: LiveSettingInfo = {
      title: liveTitle,
      password: password,
      liveChatRoomEnable,
    };
    const _liveBackgroundInfo = { ...liveBackgroundInfo };

    if (_liveBackgroundInfo) {
      const {
        backgroundUrl,
        backgroundFile,
        coverUrl,
        coverFile,
        thumbnailBackgroundUrl,
        thumbnailCoverUrl,
      } = _liveBackgroundInfo;

      platformInfo.background = {
        backgroundUrl,
        notStartCoverUrl: coverUrl,
        backgroundFile: backgroundFile || '',
        thumbnailBackFile: coverFile || '',
        thumbnailBackUrl: thumbnailBackgroundUrl,
        notStartThumbnailUrl: thumbnailCoverUrl,
      };
    }

    platformInfo.pushThirdParties = [...platformInfoList];
    platformInfo.enableThirdParties = enableAddOtherPlatform;

    onSave?.({ ...platformInfo });
  }

  function onTitleChange(title: string) {
    setLiveTitle(title);
  }

  return (
    <div
      className={`nemeeting-app-live-setting schedule-meeting-container-wrap ${
        className || ''
      }`}
    >
      {!showAddOtherPlatform ? (
        <>
          <div className="live-meeting-container">
            {isMeetingLiveOfficialPushSupported ? (
              <>
                <div>
                  <div className="live-meeting-title">
                    {t('meetingLiveTitle')}
                  </div>
                  <div>
                    <Input
                      value={liveTitle}
                      placeholder={t('liveTitlePlaceholder')}
                      maxLength={30}
                      onChange={(e) => onTitleChange(e.target.value)}
                      allowClear={true}
                    />
                  </div>
                </div>
                {/* 直播密码 */}
                <div className="nemeeting-live-setting-item">
                  <div style={{ width: '100%' }}>
                    <Checkbox
                      checked={enablePassword}
                      onChange={(e) => {
                        setEnablePassword(e.target.checked);
                      }}
                    >
                      {t('enableLivePassword')}
                    </Checkbox>
                    {enablePassword && (
                      <div className="nemeeting-live-setting-pwd">
                        <Input
                          placeholder={
                            enablePassword ? t('livePasswordTip') : ``
                          }
                          value={password}
                          maxLength={6}
                          allowClear
                          onKeyPress={(event) => {
                            if (!/^\d+$/.test(event.key)) {
                              event.preventDefault();
                            }
                          }}
                          onChange={(event) => {
                            const password = event.target.value.replace(
                              /[^0-9]/g,
                              '',
                            );

                            setPassword(password);
                          }}
                        />
                      </div>
                    )}
                  </div>
                </div>
                {/* 观众互动 */}
                <div className="nemeeting-live-setting-item">
                  <div>
                    <div>
                      <Checkbox
                        checked={liveChatRoomEnable}
                        onChange={(e) =>
                          setLiveChatRoomEnable(e.target.checked)
                        }
                      >
                        {t('enableChat')}
                      </Checkbox>
                    </div>
                    <div className="live-setting-tip">{t('enableChatTip')}</div>
                  </div>
                </div>
                <div className="nemeeting-live-setting-item nemeeting-live-setting-item-preview">
                  {/* 直播背景图 */}
                  <div className="nemeeting-live-bg-preview-wrap">
                    <div className="nemeeting-live-bg-preview-title">
                      {t('liveViewPageBackgroundImage')}
                    </div>
                    <Spin
                      wrapperClassName="nemeeting-live-bg-preview-spin"
                      className="nemeeting-live-span"
                      spinning={uploadBackgroundLoading}
                    >
                      {window.isElectronNative ? (
                        liveBackgroundInfo?.backgroundUrl ? (
                          liveBgPreviewImgBackgroundMemo
                        ) : (
                          <LiveBgPreviewItem
                            onClick={onClickUploadBackground}
                          />
                        )
                      ) : (
                        <Upload
                          accept=".jpg,.png,.jpeg,"
                          itemRender={() => null}
                          onChange={onBackgroundChange}
                          beforeUpload={backgroundBeforeUpload}
                          disabled={false}
                          maxCount={1}
                        >
                          {liveBackgroundInfo?.backgroundUrl ? (
                            liveBgPreviewImgBackgroundMemo
                          ) : (
                            <LiveBgPreviewItem
                              onClick={onClickUploadBackground}
                            />
                          )}
                        </Upload>
                      )}
                    </Spin>
                  </div>
                  {/* 直播封面 */}
                  <div className="nemeeting-live-bg-preview-wrap ml35">
                    <div className="nemeeting-live-bg-preview-title">
                      {t('liveCoverPicture')}
                    </div>
                    <Spin
                      wrapperClassName="nemeeting-live-bg-preview-spin"
                      spinning={uploadCoverLoading}
                    >
                      {window.isElectronNative ? (
                        liveBackgroundInfo?.coverUrl ? (
                          liveBgPreviewImgCoverMemo
                        ) : (
                          <LiveBgPreviewItem onClick={onClickUploadCover} />
                        )
                      ) : (
                        <Upload
                          accept=".jpg,.png,.jpeg,"
                          itemRender={() => null}
                          onChange={onCoverChange}
                          beforeUpload={coverBeforeUpload}
                          disabled={false}
                          maxCount={1}
                        >
                          {liveBackgroundInfo?.coverUrl ? (
                            liveBgPreviewImgCoverMemo
                          ) : (
                            <LiveBgPreviewItem onClick={onClickUploadCover} />
                          )}
                        </Upload>
                      )}
                    </Spin>
                  </div>
                </div>
              </>
            ) : null}

            {isMeetingLiveThirdPartyPushSupported ? (
              <>
                <div className="nemeeting-live-setting-item">
                  <Checkbox
                    checked={enableAddOtherPlatform}
                    onChange={(e) =>
                      setEnableAddOtherPlatform(e.target.checked)
                    }
                  >
                    {t('meetingLiveToOtherPlatform')}
                  </Checkbox>
                </div>
                {enableAddOtherPlatform && (
                  <div className="nemeeting-live-setting-add-item">
                    <div className="nemeeting-live-setting-add-item-wrap">
                      {platformInfoList.map((item, index) => (
                        <div
                          key={index}
                          className="nemeeting-live-setting-add-wrapper nemeeting-live-setting-platform-item"
                        >
                          <div
                            className="nemeeting-live-setting-platform-item-name nemeeting-ellipsis"
                            title={item.platformName}
                          >
                            {item.platformName}
                          </div>
                          <div>
                            <Button
                              type="link"
                              size="small"
                              onClick={(e) => editOtherPlatform(e, index)}
                            >
                              {t('globalEdit')}
                            </Button>
                            <Button
                              type="link"
                              danger
                              size="small"
                              onClick={(e) => handleDeletePlatform(e, index)}
                            >
                              {t('globalDelete')}
                            </Button>
                          </div>
                        </div>
                      ))}
                      {platformInfoList.length < maxCount && (
                        <div
                          className="nemeeting-live-setting-add-wrapper"
                          onClick={() => addOtherPlatform()}
                        >
                          <svg
                            style={{ marginRight: '12px' }}
                            viewBox="64 64 896 896"
                            focusable="false"
                            data-icon="plus"
                            width="1em"
                            height="1em"
                            fill="currentColor"
                            aria-hidden="true"
                          >
                            <path d="M482 152h60q8 0 8 8v704q0 8-8 8h-60q-8 0-8-8V160q0-8 8-8z"></path>
                            <path d="M192 474h672q8 0 8 8v60q0 8-8 8H160q-8 0-8-8v-60q0-8 8-8z"></path>
                          </svg>
                          <div>{t('globalAdd')}</div>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </>
            ) : null}
          </div>
          <div className="before-meeting-modal-footer before-meeting-schedule-modal-footer">
            <div className="nemeeting-live-setting-footer-button">
              <Button
                style={{ width: '164px', height: '36px' }}
                onClick={onCancel}
              >
                {t('globalCancel')}
              </Button>
              <Button
                style={{ width: '164px', height: '36px' }}
                type="primary"
                onClick={handleSavePlatformInfo}
              >
                {t('save')}
              </Button>
            </div>
          </div>
        </>
      ) : (
        <AddOtherPlatform
          platformInfo={currentPlatformInfo}
          onGoBack={handleGoBack}
          onSave={handleSaveOtherPlatform}
        />
      )}
    </div>
  );
};

export default React.memo(LiveSetting);
