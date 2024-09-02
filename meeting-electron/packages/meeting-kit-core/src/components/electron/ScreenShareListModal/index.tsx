import { Button, Checkbox, ModalProps, Spin, Popover } from 'antd'
import React, {
  forwardRef,
  useCallback,
  useEffect,
  useImperativeHandle,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../app/src/types'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import './index.less'
import { closeWindow, openWindow } from '../../../utils/windowsProxy'

interface ShareListItem {
  id: number
  displayId: number
  thumbnail: string
  appIcon: string
  name: string
  isApp: boolean
  index: number
}

interface ScreenShareListProps extends ModalProps {
  onStartShare: (info: ShareListItem, preferMotion: boolean) => void
  shareSound?: boolean
  onShareSoundChanged?: (flag: boolean) => void
  onStartShareSystemAudio: () => void
}

export interface ScreenShareModalRef {
  getShareList: (autoShare?: boolean) => void
}

const ScreenShareListModal = forwardRef<
  ScreenShareModalRef,
  React.PropsWithChildren<ScreenShareListProps>
>((props, ref) => {
  const { t } = useTranslation()
  const i18n = {
    title: t('selectSharedContent'),
    confirm: t('globalSure'),
    cancel: t('globalCancel'),
    startShare: t('startShare'),
    desktop: t('desktop'),
    applicationWindow: t('applicationWindow'),
    shareLocalComputerSound: t('shareLocalComputerSound'),
    getScreenCaptureSourceListError: t('getScreenCaptureSourceListError'),
  }

  const { neMeeting } = useGlobalContext()
  const { dispatch } = useMeetingInfoContext()
  const {
    onStartShare,
    shareSound,
    onShareSoundChanged,
    onStartShareSystemAudio,
    ...restProps
  } = props
  const [shareInfos, setShareInfos] = useState<{
    screenList: ShareListItem[]
    windowList: ShareListItem[]
  }>()
  const [currentInfo, setCurrentInfo] = useState<ShareListItem>()
  const [computerSoundOnly, setComputerSoundOnly] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [preferMotion, setPreferMotion] = useState(false)
  const { meetingInfo } = useMeetingInfoContext()

  const handleSelectShare = (item) => {
    setComputerSoundOnly(false)
    setCurrentInfo(item)
  }

  useEffect(() => {
    if (!restProps.open) {
      shareInfos?.screenList.forEach((item, index) => {
        closeWindow(`screenMarker${index}`)
      })
    }
  }, [shareInfos?.screenList, restProps.open])

  const getShareList = useCallback(
    async (autoShare?: boolean) => {
      setIsLoading(true)
      function toDataURL(data, size) {
        function toRGBA(data: number[]) {
          const result: number[][] = []

          for (let i = 0; i < data.length; i += 4) {
            result.push(data.slice(i, i + 4))
          }

          result.forEach((item) => {
            const green = item[0]

            item[0] = item[2]
            item[2] = green
          })
          return result.flat()
        }

        if (size.width && size.height) {
          const canvas = document.createElement('canvas')
          const context = canvas.getContext('2d')
          const imageData = context?.createImageData(size.width, size.height)

          imageData?.data.set(toRGBA(Array.from(data)))
          imageData && context?.putImageData(imageData, 0, 0)
          return canvas.toDataURL()
        } else {
          return ''
        }
      }

      try {
        const res = await neMeeting?.getScreenCaptureSourceList()

        console.log('获取到的原始桌面及窗口信息', res)

        if (res?.data && res.data?.length > 0) {
          const _screenList: ShareListItem[] = []
          const _windowList: ShareListItem[] = []

          const excludeNames = [
            '网易会议',
            'ne-meeting-electron',
            'Electron',
            'StatusIndicator',
            'Netease',
          ]

          res.data?.forEach(async (item) => {
            if (
              excludeNames.includes(item.title) ||
              excludeNames.includes(item.name) ||
              !(item.thumbImage?.length > 0)
            ) {
              return
            }

            if (item.type === 1) {
              // 过滤掉全白的桌面
              let length = 0

              item.thumbImage.data.forEach((item) => {
                if (item === 255) {
                  length++
                }
              })
              if (length === item.thumbImage.data.length) {
                return
              }

              const index = _screenList.length

              _screenList.push({
                id: item.id,
                name: `桌面 ${index + 1}`,
                thumbnail:
                  item.thumbImage && item.thumbImage.length > 0
                    ? toDataURL(item.thumbImage.data, item.thumbImage.size)
                    : toDataURL(item.icon.data, item.icon.size),
                appIcon: '',
                displayId: item.id,
                isApp: false,
                index: index,
              })
              !autoShare &&
                openWindow(
                  `screenMarker${index}`,
                  `#/screenSharing/screenMarker/${index}`
                )
            } else {
              _windowList.push({
                id: item.id,
                name: item.title,
                thumbnail:
                  item.thumbImage && item.thumbImage.length > 0
                    ? toDataURL(item.thumbImage.data, item.thumbImage.size)
                    : toDataURL(item.icon.data, item.icon.size),
                appIcon: '',
                displayId: item.id,
                isApp: true,
                index: _windowList.length,
              })
            }
          })

          setShareInfos({
            windowList: _windowList,
            screenList: _screenList,
          })
          if (_screenList.length > 0) {
            handleSelectShare(_screenList[0])
            autoShare && onStartShare(_screenList[0], preferMotion)
          }

          setIsLoading(false)
          return true
        } else {
          setIsLoading(false)
          return false
        }
      } catch (e: unknown) {
        setIsLoading(false)
        setTimeout(() => {
          Toast.fail(i18n.getScreenCaptureSourceListError)
          restProps.onCancel?.(e as React.MouseEvent<HTMLButtonElement>)
        }, 500)
        return false
      }
    },
    [neMeeting, i18n.getScreenCaptureSourceListError, restProps]
  )

  useImperativeHandle(
    ref,
    () => ({
      getShareList,
    }),
    [getShareList]
  )

  const getIsFullScreen = async () => {
    return new Promise((resolve) => {
      window.ipcRenderer?.send(IPCEvent.isMainFullscreen)
      window.ipcRenderer?.once(
        // 注意这里使用 `once` 而非 `on`
        IPCEvent.isMainFullscreenReply,
        (event, isFullScreen) => {
          resolve(isFullScreen) // 使用 resolve
        }
      )
    })
  }

  useEffect(() => {
    if (restProps.open) {
      setShareInfos({
        windowList: [],
        screenList: [],
      })
    }
  }, [restProps.open])

  useEffect(() => {
    if (restProps.open) {
      window.ipcRenderer?.on(IPCEvent.displayChanged, () => {
        // 这里需要调用下暂停否则列表获取又问题
        shareInfos?.screenList.forEach((item, index) => {
          closeWindow(`screenMarker${index}`)
        })
        getShareList()
      })
      return () => {
        window.ipcRenderer?.removeAllListeners(IPCEvent.displayChanged)
      }
    }
  }, [shareInfos?.screenList, restProps.open])

  const getPartContent = useCallback(
    (list: ShareListItem[]) => {
      return list?.map((item: ShareListItem) => (
        <div
          className={`share-item ${
            item.id === currentInfo?.id ? 'share-item-select' : ''
          }`}
          key={item.id}
          onClick={() => handleSelectShare(item)}
        >
          <div className="share-item-img-wrapper">
            <img
              src={item.thumbnail}
              alt={item.name}
              className="share-item-img"
            ></img>
          </div>
          <div className="share-item-name" title={item.name}>
            {item.name}
          </div>
        </div>
      ))
    },
    [currentInfo]
  )

  return (
    <Modal
      title={i18n.title}
      centered
      okText={i18n.confirm}
      cancelText={i18n.cancel}
      wrapClassName="modal share-modal"
      width={850}
      {...restProps}
      maskClosable={false}
      footer={
        <div className="screen-share-list-modal-footer">
          <Checkbox
            disabled={computerSoundOnly}
            checked={shareSound}
            defaultChecked={shareSound}
            id={`share-sound-checkbox-${shareSound}`}
            onChange={() => onShareSoundChanged?.(!shareSound)}
          >
            {i18n.shareLocalComputerSound}
          </Checkbox>
          <Checkbox
            disabled={computerSoundOnly}
            checked={preferMotion}
            defaultChecked={preferMotion}
            id={`share-sound-checkbox-${shareSound}`}
            onChange={() => setPreferMotion(!preferMotion)}
          >
            {t('preferMotionModel')}
            <Popover
              trigger={'hover'}
              placement={'top'}
              content={
                <div className="toolbar-tip">{t('preferMotionModelTips')}</div>
              }
            >
              <span>
                <svg
                  className="icon iconfont icona-45 nemeeting-blacklist-tip"
                  aria-hidden="true"
                >
                  <use xlinkHref="#icona-45"></use>
                </svg>
              </span>
            </Popover>
          </Checkbox>
          <Button
            type="primary"
            disabled={isLoading}
            onClick={async () => {
              if (computerSoundOnly) {
                await onStartShareSystemAudio()
              } else {
                if (!currentInfo) return
                const isFullScreen = await getIsFullScreen()

                if (isFullScreen) {
                  window.ipcRenderer?.send(IPCEvent.quiteFullscreen)
                }

                setTimeout(
                  () => {
                    if (shareSound) {
                      if (window?.systemPlatform === 'darwin') {
                        neMeeting?.previewController?.installAudioCaptureDriver?.()
                      }

                      dispatch &&
                        dispatch({
                          type: ActionType.UPDATE_MEETING_INFO,
                          data: {
                            startSystemAudioLoopbackCapture: true,
                          },
                        })
                    } else {
                      dispatch &&
                        dispatch({
                          type: ActionType.UPDATE_MEETING_INFO,
                          data: {
                            startSystemAudioLoopbackCapture: false,
                          },
                        })
                    }

                    // 分享的是桌面，需要记录下来
                    if (!currentInfo.isApp) {
                      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
                        method: 'share-screen',
                        data: currentInfo.index,
                      })
                    }

                    onStartShare?.(currentInfo, preferMotion)
                  },
                  isFullScreen ? 1000 : 0
                )
              }
            }}
          >
            {i18n.startShare}
          </Button>
        </div>
      }
      bodyStyle={{
        padding: '0 0 0 10px',
        height: '440px',
        overflowY: 'scroll',
      }}
    >
      <Spin spinning={isLoading}>
        <div className="screen-share-list-modal-content">
          {!!shareInfos?.screenList?.length && (
            <div className="screen-share-list-modal-part">
              <div className="part-title">{i18n.desktop}</div>
              {getPartContent(shareInfos?.screenList)}
              {!meetingInfo.isInterpreter && (
                <div
                  className={`share-item ${
                    computerSoundOnly ? 'share-item-select' : ''
                  }`}
                  key="computerSoundOnly"
                  onClick={() => {
                    setCurrentInfo(undefined)
                    setComputerSoundOnly(true)
                  }}
                >
                  <div className="share-item-img-wrapper">
                    <svg
                      className="icon iconfont computer-sound-only-icon"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconjindiannaoshengyin"></use>
                    </svg>
                  </div>
                  <div
                    className="share-item-name"
                    title={t('computerSoundOnly')}
                  >
                    {t('computerSoundOnly')}
                  </div>
                </div>
              )}
            </div>
          )}
          {!!shareInfos?.windowList?.length && (
            <div className="screen-share-list-modal-part">
              {
                // 同时有桌面和应用时需要区分，无桌面不需要区分
                !!shareInfos?.screenList?.length && (
                  <div className="part-title">{i18n.applicationWindow}</div>
                )
              }
              {getPartContent(shareInfos?.windowList)}
            </div>
          )}
        </div>
      </Spin>
    </Modal>
  )
})

ScreenShareListModal.displayName = 'ScreenShareListModal'

export default ScreenShareListModal
