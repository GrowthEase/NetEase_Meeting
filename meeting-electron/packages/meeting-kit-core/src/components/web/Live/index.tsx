import { NERoomLiveLayout, NERoomLiveRequest } from 'neroom-types'
import React, {
  Dispatch,
  SetStateAction,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import useWatch from '../../../hooks/useWatch'
import {
  MeetingInfoContext,
  useGlobalContext,
  useMeetingInfoContext,
} from '../../../store'
import {
  ActionType,
  LiveBackgroundInfo,
  NELiveMember,
  PlatformInfo,
} from '../../../types'
import { copyElementValue, getThumbnailUrl } from '../../../utils'
import Toast from '../../common/toast'
import './index.less'
import LivePreview from './LivePreview'

import { message, Spin, Upload } from 'antd'
import arrowImg from '../../../assets/arrow.png'
import { IPCEvent } from '../../../app/src/types'
import Modal from '../../common/Modal'
import LiveThirdPart from './LiveThirdPart'
import { useUpdateEffect } from 'ahooks'

type Model = '' | 'gallery' | 'focus' | 'shareScreen'
interface LiveProps {
  className?: string
  members: NELiveMember[]
  title: string
  state: number | undefined
  randomPassword: string
  // 用于electron独立窗口，重新打开时传入用于主动调用接口获取数据
  open?: boolean
}
interface LiveTitleInfoProps {
  liveTitle: string
  setLiveTitle: Dispatch<SetStateAction<string>>
  isStarted: boolean
  liveUrl: string
  onHandleCopy: (url: string) => void
}

interface LiveInfoProps {
  enablePassword: boolean
  setEnablePassword: Dispatch<SetStateAction<boolean>>
  onPasswordChange: (event: React.MouseEvent<HTMLInputElement>) => void
  isStarted: boolean
  livePassword: string
  setLivePassword: Dispatch<SetStateAction<string>>
  enableChat: boolean
  setEnableChat: Dispatch<SetStateAction<boolean>>
  onlyEmployeesAllow: boolean
  setOnlyEmployeesAllow: Dispatch<SetStateAction<boolean>>
  onClickUploadBackground: () => void
  onClickDeleteBackground: () => void
  onClickUploadCover: () => void
  onClickDeleteCover: () => void
  onClickThirdPart: () => void
  liveBackgroundInfo?: LiveBackgroundInfo
  uploadBackgroundLoading?: boolean
  uploadCoverLoading?: boolean
  backgroundBeforeUpload: (file, fileList) => boolean | Promise<File>
  onBackgroundChange: (info) => void
  coverBeforeUpload: (file, fileList) => boolean | Promise<File>
  onCoverChange: (info) => void
  enableThirdPartPush: boolean
  onEnableThirdPartPushChange: (checked: boolean) => void
}
interface LocalMember extends NELiveMember {
  isSelected: boolean
  index: number
}
interface LiveViewProps {
  localMembers: LocalMember[]
  membersSelected: string[]
  onSelectMember: (member: NELiveMember) => void
  showLayoutChangeTip: boolean
  isStarted: boolean
  model: Model
  memberCount: number
  isSharing: boolean
  isSelectedInSharing: boolean
  onChangeModel: (mode: 'gallery' | 'focus' | '') => void
}
interface LiveBgPreviewItemProps {
  onClick: () => void
  isStarted: boolean
}

interface LiveBgPreviewImgProps {
  url?: string
  onClose: () => void
  onClick: () => void
  isStarted: boolean
}

const IMAGE_SIZE_LIMIT = 5 * 1024 * 1024
const LiveTitleInfo: React.FC<LiveTitleInfoProps> = (props) => {
  const { t } = useTranslation()
  const { liveTitle, isStarted, liveUrl, onHandleCopy, setLiveTitle } = props
  const onTitleChange = (event) => {
    setLiveTitle(event.target.value)
  }

  return (
    <div className="nemeeint-live-info">
      <div className="form-item">
        <p className="live-title">{t('meetingLiveTitle')}</p>
        <div className="password-input-wrap flex1">
          <input
            className="live-input"
            maxLength={30}
            type="text"
            value={liveTitle}
            disabled={isStarted}
            onChange={onTitleChange}
            placeholder={t('liveTitlePlaceholder')}
          />
          {liveTitle && !isStarted && (
            <span
              className="close-btn"
              onClick={() => {
                setLiveTitle('')
              }}
            >
              <svg className={'icon'} aria-hidden="true">
                <use xlinkHref={'#iconcross'}></use>
              </svg>
            </span>
          )}
        </div>
      </div>
      {/*  直播观看地址*/}
      <div className="form-item ml36" style={{ width: '370px' }}>
        <p className="live-title">{t('liveUrl')}</p>
        <div className="live-url">
          <p className="live-link live-input">{liveUrl}</p>
          <p className="copy-link" onClick={() => onHandleCopy(liveUrl)}>
            {t('globalCopy')}
          </p>
        </div>
      </div>
    </div>
  )
}

export const LiveBgPreviewImg: React.FC<LiveBgPreviewImgProps> = ({
  url,
  onClose,
  onClick,
  isStarted,
}) => {
  const { t } = useTranslation()

  function handleClose(event) {
    event.stopPropagation()
    onClose?.()
  }

  return (
    <div className="nemeeting-live-bg-preview-img-wrap">
      <div className="nemeeting-live-bg-preview-img-container">
        <img className="nemeeting-live-bg-preview-img" src={url} />
        {!isStarted && (
          <div
            className="nemeeting-live-bg-preview-re-upload"
            onClick={onClick}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="13"
              height="13"
              viewBox="0 0 13 14"
              fill="none"
            >
              <path d="M0.5 7H12.5" stroke="white" strokeLinecap="round" />
              <path d="M6.5 1L6.5 13" stroke="white" strokeLinecap="round" />
            </svg>
            <span className="nemeeting-live-bg-preview-re-upload-tip">
              {t('liveReUpload')}
            </span>
          </div>
        )}
      </div>
      {!isStarted && (
        <>
          <div className="icon-close-wrap" onClick={handleClose}>
            <svg className="icon iconfont icon-close" aria-hidden="true">
              <use xlinkHref="#iconcross"></use>
            </svg>
          </div>
        </>
      )}
    </div>
  )
}

const LiveBgPreviewItem: React.FC<LiveBgPreviewItemProps> = ({
  onClick,
  isStarted,
}) => {
  const { t } = useTranslation()

  return (
    <div
      className={`nemeeting-live-bg-preview ${
        isStarted ? 'nemeeting-live-bg-preview-disabled' : ''
      }`}
      onClick={onClick}
    >
      <svg
        style={{ color: '#333' }}
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
      <span className="nemeeting-live-bg-preview-tip">
        {t('liveCoverPictureTip')}
      </span>
    </div>
  )
}

const LiveInfo: React.FC<LiveInfoProps> = (props) => {
  const {
    enablePassword,
    setEnablePassword,
    onPasswordChange,
    isStarted,
    livePassword,
    setLivePassword,
    enableChat,
    setEnableChat,
    onlyEmployeesAllow,
    setOnlyEmployeesAllow,
    onClickDeleteBackground,
    onClickDeleteCover,
    onClickUploadBackground,
    onClickUploadCover,
    onClickThirdPart,
    liveBackgroundInfo,
    uploadBackgroundLoading,
    uploadCoverLoading,
    onBackgroundChange,
    onCoverChange,
    coverBeforeUpload,
    backgroundBeforeUpload,
    enableThirdPartPush,
    onEnableThirdPartPushChange,
  } = props
  const { t } = useTranslation()
  const { globalConfig } = useGlobalContext()
  const liveBgPreviewImgBackgroundMemo = useMemo(
    () => (
      <LiveBgPreviewImg
        onClick={onClickUploadBackground}
        onClose={onClickDeleteBackground}
        isStarted={isStarted}
        url={
          liveBackgroundInfo?.thumbnailBackgroundUrl ||
          liveBackgroundInfo?.backgroundUrl
        }
      />
    ),

    [
      liveBackgroundInfo?.thumbnailBackgroundUrl,
      liveBackgroundInfo?.backgroundUrl,
      isStarted,
    ]
  )
  const liveBgPreviewImgCoverMemo = useMemo(
    () => (
      <LiveBgPreviewImg
        isStarted={isStarted}
        onClose={onClickDeleteCover}
        onClick={onClickUploadCover}
        url={
          liveBackgroundInfo?.thumbnailCoverUrl || liveBackgroundInfo?.coverUrl
        }
      />
    ),

    [
      liveBackgroundInfo?.coverUrl,
      liveBackgroundInfo?.thumbnailCoverUrl,
      isStarted,
    ]
  )

  const isMeetingLiveOfficialPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.officialPushEnabled

  const isMeetingLiveThirdPartyPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.thirdPartyPushEnabled

  return (
    <div className="nemeeint-live-info">
      <div className="form-wrap">
        {isMeetingLiveOfficialPushSupported ? (
          <>
            <div className="form-item enable-wrap">
              <input
                type="checkbox"
                name="enablePassword"
                id="enablePassword"
                className="live-checkbox"
                onChange={() => setEnablePassword(!enablePassword)}
                checked={enablePassword}
                disabled={isStarted}
              />
              <label className="sub-title" htmlFor="enablePassword">
                {t('enableLivePassword')}
              </label>
              <div className="password-input-wrap flex1">
                <input
                  maxLength={6}
                  className="live-input"
                  value={livePassword}
                  onInput={onPasswordChange}
                  disabled={!enablePassword || isStarted}
                  placeholder={
                    enablePassword ? t('pleaseInputLivePasswordHint') : ''
                  }
                />
                {livePassword && !isStarted && (
                  <span
                    className="close-btn"
                    onClick={() => {
                      setLivePassword('')
                    }}
                  >
                    <svg className="icon" aria-hidden="true">
                      <use xlinkHref="#iconcross"></use>
                    </svg>
                  </span>
                )}
              </div>
            </div>
            <div className="form-item-employees">
              <div className="chat-tip nemeeting-live-employees">
                <input
                  type="checkbox"
                  name="onlyEmployeesAllow"
                  id="onlyEmployeesAllow"
                  className="live-checkbox"
                  checked={onlyEmployeesAllow}
                  disabled={isStarted}
                  onChange={() => setOnlyEmployeesAllow(!onlyEmployeesAllow)}
                />
                <label className="sub-title mr14" htmlFor="onlyEmployeesAllow">
                  {t('onlyEmployeesAllow')}
                </label>
              </div>
              <div className="chat-tip">({t('onlyEmployeesAllowTip')})</div>
            </div>
          </>
        ) : null}
        {isMeetingLiveThirdPartyPushSupported ? (
          <div className="form-item-employees">
            <div className="chat-tip nemeeting-live-employees">
              <input
                type="checkbox"
                name="enableThirdPartPush"
                id="enableThirdPartPush"
                disabled={isStarted}
                className="live-checkbox"
                checked={enableThirdPartPush}
                onChange={() =>
                  onEnableThirdPartPushChange(!enableThirdPartPush)
                }
              />
              <label className="sub-title" htmlFor="enableThirdPartPush">
                <span>{t('meetingLiveToOtherPlatform')}</span>
              </label>
              {enableThirdPartPush && !isStarted && (
                <span
                  className="nemeeting-live-third-edit-btn"
                  onClick={onClickThirdPart}
                >
                  {t('globalEdit')}
                </span>
              )}
            </div>
          </div>
        ) : null}
      </div>
      {isMeetingLiveOfficialPushSupported ? (
        <div className="form-wrap nemeeting-live-enable-chat-wrap">
          {/*  开启观众互动*/}
          <div className="form-item enable-wrap nemeeting-live-enable-chat">
            <input
              type="checkbox"
              name="enableChat"
              id="enableChat"
              className="live-checkbox"
              checked={enableChat}
              onChange={() => setEnableChat(!enableChat)}
            />
            <label className="sub-title mr14" htmlFor="enableChat">
              {t('enableChat')}
            </label>
            <span className="chat-tip flex1">{t('enableChatTip')}</span>
          </div>
          <div className="form-item enable-wrap ml35">
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
                      isStarted={isStarted}
                      onClick={onClickUploadBackground}
                    />
                  )
                ) : (
                  <Upload
                    accept=".jpg,.png,.jpeg,"
                    itemRender={() => null}
                    onChange={onBackgroundChange}
                    beforeUpload={backgroundBeforeUpload}
                    disabled={isStarted}
                    maxCount={1}
                  >
                    {liveBackgroundInfo?.backgroundUrl ? (
                      liveBgPreviewImgBackgroundMemo
                    ) : (
                      <LiveBgPreviewItem
                        isStarted={isStarted}
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
                    <LiveBgPreviewItem
                      isStarted={isStarted}
                      onClick={onClickUploadCover}
                    />
                  )
                ) : (
                  <Upload
                    accept=".jpg,.png,.jpeg,"
                    itemRender={() => null}
                    onChange={onCoverChange}
                    beforeUpload={coverBeforeUpload}
                    disabled={isStarted}
                    maxCount={1}
                  >
                    {liveBackgroundInfo?.coverUrl ? (
                      liveBgPreviewImgCoverMemo
                    ) : (
                      <LiveBgPreviewItem
                        isStarted={isStarted}
                        onClick={onClickUploadCover}
                      />
                    )}
                  </Upload>
                )}
              </Spin>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  )
}

const LiveView: React.FC<LiveViewProps> = (props) => {
  const {
    localMembers,
    membersSelected,
    onSelectMember,
    showLayoutChangeTip,
    isStarted,
    model,
    memberCount,
    isSelectedInSharing,
    onChangeModel,
  } = props
  const { t, i18n } = useTranslation()

  return (
    <div className="form-wrap live-setting">
      <div className="live-content">
        <p className="live-title">{t('liveViewSetting')}</p>
        <div className="live-setting-wrap ">
          <div>
            <div className="live-member-list">
              {localMembers.map((member) => {
                return (
                  <div
                    className={`nemeeting-member-item ${
                      !member.isSelected && memberCount >= 4
                        ? 'nemeeting-member-disable'
                        : ''
                    }`}
                    key={member.accountId}
                    onClick={() => onSelectMember(member)}
                  >
                    <div
                      className={`member-select ${
                        member.isSelected ? 'member-selected' : ''
                      }`}
                    >
                      {/* 展示顺序为选中顺序 */}
                      {member.isSelected
                        ? membersSelected?.findIndex(
                            (item) => item == member.accountId
                          ) + 1
                        : ''}
                    </div>
                    <div className="live-member-name">{member.nickName}</div>
                  </div>
                )
              })}
            </div>
            <p className="live-list-tip">{t('liveView')}</p>
          </div>
          <div className="arrow">
            <img src={arrowImg} />
          </div>
          <div className="view-layout">
            {/*画廊视图*/}
            {!isSelectedInSharing && (
              <div className="view-group">
                <div
                  className={`${
                    model === 'gallery'
                      ? 'layout-wrap view-selected'
                      : 'layout-wrap'
                  } `}
                >
                  <div
                    className="view-wrap"
                    onClick={() => onChangeModel('gallery')}
                  >
                    <div className="per1-4 view-bg view-item"></div>
                    <div className="per1-4 view-bg view-item"></div>
                    <div className="per1-4 view-bg view-item"></div>
                    <div className="per1-4 view-bg view-item"></div>
                  </div>
                  <p className="layout-title">{t('liveGalleryView')}</p>
                </div>
              </div>
            )}
            {/*焦点视图和共享视频*/}
            <div className="view-group">
              {/*焦点视图*/}
              {!isSelectedInSharing && (
                <div
                  className={`${
                    model === 'focus'
                      ? 'layout-wrap view-selected'
                      : 'layout-wrap'
                  } mr8`}
                >
                  <div
                    className="view-wrap"
                    onClick={() => onChangeModel('focus')}
                  >
                    <div className="per6-9 view-bg view-item"></div>
                    <div className="per1-9-wrap">
                      <div className="per1-9 view-bg view-item"></div>
                      <div className="per1-9 view-bg view-item"></div>
                      <div className="per1-9 view-bg view-item"></div>
                    </div>
                  </div>
                  <p className="layout-title">{t('liveFocusView')}</p>
                </div>
              )}
              {/* 共享视图*/}
              {(isSelectedInSharing || memberCount === 0) && (
                <div
                  className={`${
                    isSelectedInSharing
                      ? 'layout-wrap view-selected'
                      : 'layout-wrap'
                  } `}
                >
                  <div className="view-wrap">
                    <div className="per8-12 view-bg view-item"></div>
                    <div className="per1-12-wrap">
                      <div className="per1-12 view-bg view-item"></div>
                      <div className="per1-12 view-bg view-item"></div>
                      <div className="per1-12 view-bg view-item"></div>
                      <div className="per1-12 view-bg view-item"></div>
                    </div>
                  </div>
                  <p className="layout-title">{t('shareView')}</p>
                </div>
              )}
            </div>
          </div>
          <div className="arrow mr50">
            <img src={arrowImg} />
          </div>
          {/* 预览 */}
          <div className="preview">
            {/* 直播状态发生变化提示框*/}
            {showLayoutChangeTip && isStarted && (
              <div
                className={`live-state-change ${
                  i18n.language === 'ja-JP' ? 'jp' : ''
                }`}
              >
                <div className="error-icon">!</div>
                <div className="tip-content">
                  <p className="tip-title">{t('liveStatusChange')}</p>
                  <div className="tip-text">
                    <p>
                      <span>{t('pleaseClick')}&quot;</span>
                      <span className="state-setting">
                        {t('liveUpdateSetting')}
                      </span>
                      <span>&quot;</span>
                    </p>
                    <p>{t('refreshLiveLayout')}</p>
                  </div>
                </div>
                <span className="live-state-arrow"></span>
              </div>
            )}
            <LivePreview
              isSharing={isSelectedInSharing}
              model={model}
              memberCount={memberCount}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

const MODEL_GALLERY = 'gallery'
const Live: React.FC<LiveProps> = (props) => {
  const { members, title, state, randomPassword, open } = props
  const { meetingInfo } = useContext(MeetingInfoContext)
  const { neMeeting, globalConfig } = useGlobalContext()
  const { dispatch } = useMeetingInfoContext()
  const { t } = useTranslation()
  const [model, setModel] = useState<Model>(MODEL_GALLERY)
  // 保存变更前的数据，用于判断是否需要提示用户更新直播
  const [originModel, setOriginModel] = useState<Model>(MODEL_GALLERY)
  const [originMembersSelected, setOriginMembersSelected] = useState<string[]>(
    []
  )
  // const [membersFromLiveInfo, setMembersFromLiveInfo] = useState<string[]>([])
  const [originEnableChat, setOriginEnableChat] = useState<boolean>(true)
  const [membersSelected, setMembersSelected] = useState<string[]>([])
  const [liveTitle, setLiveTitle] = useState(title)
  const [livePassword, setLivePassword] = useState('')
  const [enablePassword, setEnablePassword] = useState(false)
  const [enableChat, setEnableChat] = useState(true) // 聊天室默认打开
  const [canUpdate, setCanUpdate] = useState(false)
  const [uploadBackgroundLoading, setUploadBackgroundLoading] = useState(false)
  const [uploadCoverLoading, setUploadCoverLoading] = useState(false)
  // 是否显示直播状态变化通知
  const [showLayoutChangeTip, setShowLayoutChangeTip] = useState(false)
  const [openLiveThirdPartModal, setOpenLiveThirdPartModal] = useState(false)
  const [platformInfoList, setPlatformInfoList] = useState<PlatformInfo[]>([])
  const [enableThirdPartPush, setEnableThirdPartPush] = useState(false)
  const isMountedRef = useRef(false)
  const [onlyEmployeesAllow, setOnlyEmployeesAllow] = useState(false)
  // 缓存服务端的成员列表，用于和本地更新检查，如关闭视频重新打开，也应该在选中状态
  const remoteUserUuidListRef = useRef<string[]>([])
  const liveInfoPasswordRef = useRef('')
  const liveBackgroundInfoRef = useRef<LiveBackgroundInfo | undefined>(
    meetingInfo.liveBackgroundInfo
  )

  const membersSelectedRef = useRef(membersSelected)

  membersSelectedRef.current = membersSelected

  const liveTitleRef = useRef(liveTitle)

  const isMeetingLiveOfficialPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.officialPushEnabled

  liveTitleRef.current = liveTitle

  const memberCount = useMemo(() => {
    return membersSelected.length
  }, [membersSelected.length])

  const liveUrl = meetingInfo.liveConfig?.liveAddress

  const isStarted = state === 2

  const canStart = useMemo(() => {
    if (isMeetingLiveOfficialPushSupported) {
      return membersSelected.length > 0 && members.length > 0
    } else {
      return (
        membersSelected.length > 0 && members.length > 0 && enableThirdPartPush
      )
    }
  }, [
    membersSelected.length,
    members.length,
    isMeetingLiveOfficialPushSupported,
    enableThirdPartPush,
  ])

  liveBackgroundInfoRef.current = meetingInfo.liveBackgroundInfo

  console.log('memberSelected', membersSelected)
  const onChangeModel = (_model: Model) => {
    if (memberCount === 0) {
      return
    }

    setModel(_model)
    handleUpdateView({ model: _model, membersSelected })
  }

  const handleUpdateView = (options: {
    model: Model
    membersSelected: string[]
    enableChat?: boolean
  }) => {
    // 开始或更新直播后选中的成员是否与之前一致，包括选中顺序
    const isSameUser =
      JSON.stringify(options.membersSelected) ===
      JSON.stringify(originMembersSelected)
    // 开始或更新直播后选中的视图是否与之前一致
    const isSameModel = options.model === originModel
    const isSameEnableChat =
      (options.enableChat !== undefined ? options.enableChat : enableChat) ===
      originEnableChat

    if (isStarted) {
      if (isSameUser && isSameModel) {
        setShowLayoutChangeTip(false)
      } else {
        setShowLayoutChangeTip(true)
      }

      if (isSameEnableChat && isSameModel && isSameUser) {
        setCanUpdate(false)
      } else {
        setCanUpdate(true)
      }
    }
  }

  function handleSelectFile() {
    window.ipcRenderer?.removeAllListeners(IPCEvent.choseFileDone)
    window.ipcRenderer?.once(
      IPCEvent.choseFileDone,
      (_, { type, file, extendedData }) => {
        if (navigator.onLine) {
          console.log(type, file, extendedData)
          // 如果不是图片类型直接返回报错
          if (type !== 'image') {
            return
          }

          if (type === 'image' && file.size > IMAGE_SIZE_LIMIT) {
            message.error(t('imageSizeLimit5'))
            return
          }

          if (extendedData.type === 'background') {
            setUploadBackgroundLoading(true)
          } else {
            setUploadCoverLoading(true)
          }

          neMeeting?.nosService
            ?.uploadResource(file.url)
            .then((res) => {
              console.log('上传成功', res)
              const thumbnailUrl = getThumbnailUrl(res.data)
              const data: LiveBackgroundInfo = {
                ...liveBackgroundInfoRef.current,
              }

              if (extendedData.type === 'background') {
                data.backgroundUrl = res.data
                data.thumbnailBackgroundUrl = thumbnailUrl
                data.coverUrl = liveBackgroundInfoRef.current?.coverUrl || ''
                data.thumbnailCoverUrl =
                  liveBackgroundInfoRef.current?.thumbnailCoverUrl || ''
              } else {
                data.coverUrl = res.data
                data.thumbnailCoverUrl = thumbnailUrl
                data.backgroundUrl =
                  liveBackgroundInfoRef.current?.backgroundUrl || ''
                data.thumbnailBackgroundUrl =
                  liveBackgroundInfoRef.current?.thumbnailBackgroundUrl || ''
              }

              liveBackgroundInfoRef.current = data
              neMeeting
                ?.updateBackgroundInfo(data)
                .then((result) => {
                  if (!result) {
                    return
                  }

                  dispatch?.({
                    type: ActionType.UPDATE_MEETING_INFO,
                    data: {
                      liveBackgroundInfo: {
                        ...data,
                        sequence: result.data,
                        newSequence: result.data,
                      },
                    },
                  })
                })
                .catch((e) => {
                  console.log('更新失败>>>>>', e)
                  Toast.fail(e.message || e.msg || e.code)
                  // 失败需要重置回来
                  if (extendedData.type === 'background') {
                    liveBackgroundInfoRef.current = {
                      ...liveBackgroundInfoRef.current,
                      backgroundUrl: '',
                      thumbnailBackgroundUrl: '',
                    }
                  } else {
                    liveBackgroundInfoRef.current = {
                      ...liveBackgroundInfoRef.current,
                      coverUrl: '',
                      thumbnailCoverUrl: '',
                    }
                  }
                })
            })
            .catch((e) => {
              Toast.fail(e.message || e.msg || e.code)
            })
            .finally(() => {
              if (extendedData.type === 'background') {
                setUploadBackgroundLoading(false)
              } else {
                setUploadCoverLoading(false)
              }
            })
        } else {
          message.error(t('networkError'))
        }
      }
    )
  }

  useEffect(() => {
    // 直播中若已选中的直播成员关闭再开启视频，则需要重新更新选中项
    const membersSelected = [...membersSelectedRef.current]

    membersSelectedRef.current?.forEach((memberId) => {
      const index = members.findIndex((member) => member.accountId === memberId)

      // 当前成员不存在了需要把选中的也删除
      if (index < 0) {
        // 删除
        const delIndex = membersSelected.findIndex((id) => id === memberId)

        membersSelected.splice(delIndex, 1)
      }
    })
    setMembersSelected(membersSelected)
  }, [members])

  const localMembers = useMemo(() => {
    const _members = members.map((member) => {
      const index = membersSelected.findIndex(
        (uuid) => uuid === member.accountId
      )

      return {
        ...member,
        isSelected: index > -1,
        index: index + 1,
      }
    })

    handleUpdateView({
      model,
      membersSelected: membersSelected,
    })
    return _members
  }, [members, membersSelected])

  // 当前选中的人是否在共享
  const isSelectedInSharing = useMemo(() => {
    if (meetingInfo.screenUuid) {
      const sharingId = meetingInfo.screenUuid

      return membersSelected.includes(sharingId)
    } else {
      return false
    }
  }, [meetingInfo.screenUuid, membersSelected])

  useWatch<number>(localMembers.length, (preLen) => {
    preLen = preLen || 0
    // 表示可选成员减少
    if (preLen > localMembers.length) {
      const tmpMembersSelected = [...membersSelected]

      tmpMembersSelected.forEach((accountId) => {
        const index = members.findIndex(
          (member) => member.accountId === accountId
        )

        // 未找到表示已删除
        if (index < 0) {
          const _membersSelected = [...membersSelected]
          const delIndex = _membersSelected.findIndex((id) => id === accountId)

          _membersSelected.splice(delIndex, 1)
          setMembersSelected(_membersSelected)
          handleUpdateView({ model, membersSelected: _membersSelected })
        }
      })
    }
  })

  useEffect(() => {
    if (enablePassword && !livePassword) {
      setLivePassword(
        liveInfoPasswordRef.current
          ? liveInfoPasswordRef.current
          : randomPassword
      )
    } else if (!enablePassword) {
      setLivePassword('')
    }
  }, [enablePassword])

  useEffect(() => {
    if (memberCount === 0) {
      setModel('')
    } else {
      if (!model) {
        setModel(MODEL_GALLERY)
        handleUpdateView({ model: MODEL_GALLERY, membersSelected })
      }
    }
  }, [memberCount])

  useEffect(() => {
    window.addEventListener('online', updateBackgroundInfo)
    return () => {
      window.removeEventListener('online', updateBackgroundInfo)
    }
  }, [])
  // 直播状态变化或本地成员角色变更时都需要重新获取直播信息
  useEffect(() => {
    getLiveInfo()
    // 延迟1s设置，否则每次渲染都会出现是否更新视图提示
    setTimeout(() => {
      isMountedRef.current = true
    }, 1000)
  }, [meetingInfo?.localMember?.role, state])

  const updateBackgroundInfo = useCallback(() => {
    neMeeting
      ?.getBackgroundInfo()
      .then((res) => {
        if (!res) {
          return
        }

        const { data } = res

        if (!data) {
          return
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveBackgroundInfo: {
              sequence: data.backgroundUpdatedSequence,
              newSequence: data.backgroundUpdatedSequence,
              backgroundUrl: data.backgroundUrl,
              thumbnailBackgroundUrl: data.thumbnailBackgroundUrl,
              coverUrl: data.coverUrl,
              thumbnailCoverUrl: data.thumbnailCoverUrl,
            },
          },
        })
      })
      .catch((e) => {
        console.log('getBackgroundInfo>>>', e)
      })
  }, [])

  useEffect(() => {
    if (
      !meetingInfo.liveBackgroundInfo?.sequence ||
      meetingInfo.liveBackgroundInfo.newSequence !=
        meetingInfo.liveBackgroundInfo.sequence
    ) {
      updateBackgroundInfo()
    }
  }, [meetingInfo.liveBackgroundInfo?.newSequence])

  function getLive3PartInfo() {
    neMeeting?.getLive3PartInfo().then((res) => {
      setPlatformInfoList(res)
      if (res.length > 0) {
        setEnableThirdPartPush(true)
      } else {
        setEnableThirdPartPush(false)
      }
    })
  }

  useEffect(() => {
    getLive3PartInfo()
  }, [])

  useUpdateEffect(() => {
    if (open) {
      setPlatformInfoList([])
      setEnableThirdPartPush(false)
      getLive3PartInfo()
      getLiveInfo()
    }
  }, [open])
  useEffect(() => {
    if (title && !liveTitle) {
      setLiveTitle(title)
    }
  }, [title, liveTitle])

  async function getLiveInfo() {
    const liveInfo = await neMeeting?.getLiveInfo()

    if (liveInfo) {
      setModel(layout2model(liveInfo.liveLayout))
      setOriginModel(layout2model(liveInfo.liveLayout))
      setLiveTitle(liveInfo.title || '')
      // 更新密码和是否开启密码状态
      liveInfoPasswordRef.current = liveInfo.password || ''
      setLivePassword(liveInfo.password || '')
      setEnablePassword(liveInfo.password ? true : false)
      if (liveInfo.extensionConfig) {
        try {
          const config = JSON.parse(liveInfo.extensionConfig)

          setEnableChat(config.liveChatRoomEnable)
          setOriginEnableChat(config.liveChatRoomEnable)
          setOnlyEmployeesAllow(config.onlyEmployeesAllow)
        } catch (e) {
          console.warn('parse liveChatRoomEnabled failed', e)
        }
      }

      const _userUuidList = Array.from(liveInfo.userUuidList || [])

      remoteUserUuidListRef.current = _userUuidList
      // 结束直播了则使用当前本地选择的成员
      if (state === 2) {
        setMembersSelected([..._userUuidList])
      }

      setOriginMembersSelected(_userUuidList)
      // setMembersFromLiveInfo([..._userUuidList])
      if (_userUuidList?.length && state === 2) {
        if (members.length > 0) {
          let initMembersSelected = [..._userUuidList]

          _userUuidList?.forEach((accountId) => {
            const idx = members.findIndex(
              (member) => member.accountId == accountId
            )

            // 远端获取到的数据与目前最新数据对比，如果当前这个人已经关闭视频或者共享了则删除
            if (idx < 0) {
              const _membersSelected = [...initMembersSelected]
              const delIndex = _membersSelected.findIndex(
                (id) => id == accountId
              )

              _membersSelected.splice(delIndex, 1)
              setMembersSelected(_membersSelected)
              initMembersSelected = [..._membersSelected]
              handleUpdateView({
                model,
                membersSelected: members?.map((item) => item.accountId),
              })
            }
          })
          // 如果当前视图是共享，则还需要判断下当前是否在共享，并且是否有选中的人在共享
          // if(this.model === 'shareScreen') {
          //   if(this.meetingInfo.screenSharersAvRoomUid && this.meetingInfo.shareMode === shareMode.screen) {
          //     const sharingId = this.meetingInfo.screenSharersAvRoomUid[0]
          //     if(!this.membersSelected.includes(sharingId)) {
          //       this.model = ''
          //     }
          //   }else {
          //     this.model = ''
          //   }
          // }
        } else {
          setMembersSelected([])
          setOriginMembersSelected([])
          setModel('')
          setOriginModel('')
        }
      }
    }
  }

  const onSelectMember = (member: NELiveMember) => {
    // 如果已经存在则表示删除
    if (membersSelected.includes(member.accountId)) {
      const index = membersSelected.findIndex((id) => member.accountId === id)

      // 如果删除的人是共享的则删除对应
      if (member.isSharingScreen) {
        // this.isSelectedSharingScreen = false
        // 如果这个时候剩余一项则表示即将清空
        setModel(membersSelected.length === 1 ? '' : MODEL_GALLERY)
      }

      const _membersSelected = [...membersSelected]

      _membersSelected.splice(index, 1)
      setMembersSelected(_membersSelected)
      handleUpdateView({ model, membersSelected: _membersSelected })
    } else {
      if (membersSelected.length >= 4) {
        return
      }

      // if(member.isSharingScreen) {
      //   // this.isSelectedSharingScreen = true
      //   this.model = 'shareScreen'
      // }else if(!this.model) {
      //   this.model = 'gallery'
      // }
      const _members = [...membersSelected]

      if (_members?.findIndex((item) => item == member.accountId) === -1) {
        _members.push(member.accountId)
      }

      setMembersSelected(_members)
      handleUpdateView({ model, membersSelected: _members })
    }
  }

  const mapLayout = (model: string) => {
    const layoutMap = {
      gallery: 1,
      focus: 2,
      shareScreen: 4,
    }

    return layoutMap[model] || 0
  }

  const onStartLive = () => {
    if (!canStart) {
      return
    }

    if (!liveTitle) {
      Toast.info(t('liveSubjectTip'))
      return
    }

    if (enablePassword) {
      if (!livePassword || !/\d{6}/.test(livePassword)) {
        Toast.info(t('livePasswordTip'))
        return
      }
    }

    const options: NERoomLiveRequest = {
      title: liveTitle,
      liveLayout: mapLayout(model),
      userUuidList: membersSelected,
      extensionConfig: JSON.stringify({
        listUids: membersSelected,
        liveChatRoomEnable: enableChat,
        onlyEmployeesAllow: onlyEmployeesAllow,
      }),
      enableThirdParties: enableThirdPartPush,
    }

    if (enablePassword) {
      options.password = livePassword
    }

    neMeeting
      ?.startLive?.(options)
      ?.then(() => {
        setCanUpdate(false)
        remoteUserUuidListRef.current = membersSelected
        setShowLayoutChangeTip(false)
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveState: 2,
          },
        })
        setOriginModel(layout2model(options.liveLayout))
        setOriginMembersSelected([...(membersSelected || [])])
        setOriginEnableChat(enableChat)
      })
      .catch((e) => {
        console.error('e', e)
        Toast.info(e.msg || e.message)
      })
  }

  const onUpdateLive = () => {
    if (!canUpdate) {
      return
    }

    const options: NERoomLiveRequest = {
      title: liveTitle,
      liveLayout: mapLayout(model),
      userUuidList: membersSelected,
      extensionConfig: JSON.stringify({
        listUids: membersSelected,
        liveChatRoomEnable: enableChat,
        onlyEmployeesAllow: onlyEmployeesAllow,
      }),
    }

    if (enablePassword) {
      options.password = livePassword
    }

    if (membersSelected?.length === 0) {
      Toast.info(t('liveNeedMemberHint'))
      return
    }

    neMeeting
      ?.updateLive(options)
      ?.then(() => {
        setCanUpdate(false)
        remoteUserUuidListRef.current = membersSelected
        setShowLayoutChangeTip(false)
        setOriginModel(layout2model(options.liveLayout))
        setOriginMembersSelected([...(membersSelected || [])])
        setOriginEnableChat(enableChat)
      })
      .catch((e) => {
        Toast.info(e.msg || e.message)
      })
  }

  const onStopLive = () => {
    neMeeting
      ?.stopLive?.()
      ?.then(() => {
        setCanUpdate(false)
        setShowLayoutChangeTip(false)
      })
      ?.catch((err) => {
        Toast.info(err.msg || err.message)
      })
  }

  const onHandleCopy = (value) => {
    copyElementValue(value, () => {
      Toast.info(t('copySuccess'))
    })
  }

  const onPasswordChange = (event) => {
    if (/^[0-9]*$/.test(event.target.value)) {
      const value = String(event.target.value)

      if (value.length > 6) {
        setLivePassword(value.slice(0, 6))
      } else {
        setLivePassword(value)
      }
    }
  }

  const layout2model = (layout?: NERoomLiveLayout): Model => {
    if (!layout) {
      return ''
    }

    const modelMap = {
      0: 'gallery',
      1: 'gallery',
      2: 'focus',
      4: 'shareScreen',
    }

    return (modelMap[layout] || '') as Model
  }

  function onClickDeleteBackground() {
    if (liveBackgroundInfoRef.current) {
      liveBackgroundInfoRef.current.backgroundUrl = ''
      liveBackgroundInfoRef.current.thumbnailBackgroundUrl = ''
    }

    neMeeting
      ?.updateBackgroundInfo({
        backgroundUrl: '',
        thumbnailBackgroundUrl: '',
        coverUrl: liveBackgroundInfoRef.current?.coverUrl || '',
        thumbnailCoverUrl:
          liveBackgroundInfoRef.current?.thumbnailCoverUrl || '',
      })
      .then((res) => {
        if (!res) {
          return
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveBackgroundInfo: {
              ...liveBackgroundInfoRef.current,
              backgroundUrl: '',
              thumbnailBackgroundUrl: '',
              sequence: res.data,
              newSequence: res.data,
            },
          },
        })
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg || e.code)
      })
  }

  function onClickDeleteCover() {
    if (liveBackgroundInfoRef.current) {
      liveBackgroundInfoRef.current.coverUrl = ''
      liveBackgroundInfoRef.current.thumbnailCoverUrl = ''
    }

    neMeeting
      ?.updateBackgroundInfo({
        backgroundUrl: liveBackgroundInfoRef.current?.backgroundUrl || '',
        thumbnailBackgroundUrl:
          liveBackgroundInfoRef.current?.thumbnailBackgroundUrl || '',
        coverUrl: '',
        thumbnailCoverUrl: '',
      })
      .then((res) => {
        if (!res) {
          return
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveBackgroundInfo: {
              ...liveBackgroundInfoRef.current,
              coverUrl: '',
              thumbnailCoverUrl: '',
              sequence: res.data,
              newSequence: res.data,
            },
          },
        })
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg || e.code)
      })
  }

  function onClickUploadBackground() {
    if (isStarted) {
      return
    }

    handleSelectFile()
    window.ipcRenderer?.send(IPCEvent.choseFile, {
      type: 'image',
      extensions: ['jpg', 'png', 'jpeg'],
      extendedData: {
        type: 'background',
      },
    })
  }

  function onBackgroundChange(info) {
    console.log('onBackgroundChange', info)
  }

  function onCoverChange(info) {
    console.log('onCoverChange', info)
  }

  function onClickThirdPart() {
    setOpenLiveThirdPartModal(true)
  }

  function uploadWebFile(file, type: 'background' | 'cover') {
    const ext = file.name && file.name.split('.').pop().toLowerCase()

    if (file.size > IMAGE_SIZE_LIMIT) {
      message.error(t('imageSizeLimit5'))
      return
    }

    if (!['jpg', 'png', 'jpeg'].includes(ext?.toLowerCase())) {
      return
    }

    if (type === 'background') {
      setUploadBackgroundLoading(true)
    } else {
      setUploadCoverLoading(true)
    }

    neMeeting?.nosService
      ?.uploadResource({
        blob: file,
        type: 'image',
      })
      .then((res) => {
        const url = res.data
        const thumbnailUrl = getThumbnailUrl(url)
        let data = liveBackgroundInfoRef.current

        if (type === 'background') {
          data = {
            ...data,
            backgroundUrl: url,
            thumbnailBackgroundUrl: thumbnailUrl,
          }
        } else {
          data = {
            ...data,
            coverUrl: url,
            thumbnailCoverUrl: thumbnailUrl,
          }
        }

        liveBackgroundInfoRef.current = {
          ...data,
        }
        neMeeting
          ?.updateBackgroundInfo({
            ...data,
          })
          .then((result) => {
            if (!result) {
              return
            }

            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                liveBackgroundInfo: {
                  ...liveBackgroundInfoRef.current,
                  sequence: result.data,
                  newSequence: result.data,
                },
              },
            })
          })
          .catch((e) => {
            Toast.fail(e.message || e.msg || e.code)
            if (type === 'background') {
              liveBackgroundInfoRef.current = {
                ...liveBackgroundInfoRef.current,
                backgroundUrl: '',
                thumbnailBackgroundUrl: '',
              }
            } else {
              liveBackgroundInfoRef.current = {
                ...liveBackgroundInfoRef.current,
                coverUrl: '',
                thumbnailCoverUrl: '',
              }
            }
          })
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg || e.code)
      })
      .finally(() => {
        if (type === 'background') {
          setUploadBackgroundLoading(false)
        } else {
          setUploadCoverLoading(false)
        }
      })
  }

  function backgroundBeforeUpload(file): boolean {
    uploadWebFile(file, 'background')
    return false
  }

  function coverBeforeUpload(file): boolean {
    uploadWebFile(file, 'cover')
    return false
  }

  function onClickUploadCover() {
    if (isStarted) {
      return
    }

    handleSelectFile()
    window.ipcRenderer?.send(IPCEvent.choseFile, {
      type: 'image',
      extensions: ['jpg', 'png', 'jpeg'],
      extendedData: {
        type: 'cover',
      },
    })
  }

  function handelSaveLiveThirdPart(platformInfoList: PlatformInfo[]) {
    setPlatformInfoList(platformInfoList)
    setOpenLiveThirdPartModal(false)
    if (platformInfoList.length === 0) {
      setEnableThirdPartPush(false)
    }

    if (isStarted) {
      setShowLayoutChangeTip(true)
      setCanUpdate(true)
    }
  }

  function onEnableThirdPartPushChange(enable: boolean) {
    setEnableThirdPartPush(enable)
    if (!enable && isStarted) {
      setShowLayoutChangeTip(true)
      setCanUpdate(true)
    }
  }

  return (
    <div className="nemeeting-live-config">
      {isMeetingLiveOfficialPushSupported ? (
        <LiveTitleInfo
          isStarted={isStarted}
          liveTitle={liveTitle}
          setLiveTitle={setLiveTitle}
          liveUrl={liveUrl}
          onHandleCopy={onHandleCopy}
        />
      ) : null}
      <LiveInfo
        enableThirdPartPush={enableThirdPartPush}
        onEnableThirdPartPushChange={onEnableThirdPartPushChange}
        onBackgroundChange={onBackgroundChange}
        onCoverChange={onCoverChange}
        backgroundBeforeUpload={backgroundBeforeUpload}
        coverBeforeUpload={coverBeforeUpload}
        enableChat={enableChat}
        enablePassword={enablePassword}
        livePassword={livePassword}
        setLivePassword={setLivePassword}
        setEnablePassword={setEnablePassword}
        uploadCoverLoading={uploadCoverLoading}
        uploadBackgroundLoading={uploadBackgroundLoading}
        setEnableChat={(type) => {
          handleUpdateView({
            model,
            membersSelected,
            enableChat: type as boolean,
          })
          setEnableChat(type)
        }}
        onClickDeleteBackground={onClickDeleteBackground}
        onClickDeleteCover={onClickDeleteCover}
        onClickUploadBackground={onClickUploadBackground}
        onClickUploadCover={onClickUploadCover}
        onClickThirdPart={onClickThirdPart}
        isStarted={isStarted}
        onlyEmployeesAllow={onlyEmployeesAllow}
        setOnlyEmployeesAllow={setOnlyEmployeesAllow}
        onPasswordChange={onPasswordChange}
        liveBackgroundInfo={meetingInfo.liveBackgroundInfo}
      />
      <LiveView
        isSelectedInSharing={isSelectedInSharing}
        isStarted={isStarted}
        isSharing={isSelectedInSharing}
        memberCount={memberCount}
        model={model}
        localMembers={localMembers}
        membersSelected={membersSelected}
        onChangeModel={onChangeModel}
        onSelectMember={onSelectMember}
        showLayoutChangeTip={showLayoutChangeTip}
      />
      <Modal
        footer={null}
        width={375}
        open={openLiveThirdPartModal}
        onCancel={() => setOpenLiveThirdPartModal(false)}
        title={t('meetingLive')}
      >
        <LiveThirdPart
          onCancel={() => setOpenLiveThirdPartModal(false)}
          onSave={handelSaveLiveThirdPart}
          platformInfoList={platformInfoList}
        />
      </Modal>
      {/*  开始直播按钮*/}
      <div className="live-footer">
        {isStarted ? (
          <>
            <div
              className={`live-btn live-update-btn ${
                canUpdate ? '' : 'btn-disabled'
              }`}
              onClick={onUpdateLive}
            >
              <span>{t('liveUpdate')}</span>
            </div>
            <div className="live-btn live-stop-btn" onClick={onStopLive}>
              <span>{t('liveStop')}</span>
            </div>
          </>
        ) : (
          <div
            className={`live-btn live-start-btn ${
              canStart ? '' : 'btn-disabled'
            }`}
            onClick={onStartLive}
          >
            <span>{t('liveStart')}</span>
          </div>
        )}
      </div>
    </div>
  )
}

export default React.memo(Live)
