import React, { useContext, useEffect, useMemo, useRef, useState } from 'react'
import {
  GlobalContext,
  MeetingInfoContext,
  useGlobalContext,
  useMeetingInfoContext,
} from '../../../store'
import { ActionSheet } from 'antd-mobile/es'
import type { Action } from 'antd-mobile/es/components/action-sheet'
import MeetingInfoPopUp from './meetingInfo'
import {
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  ActionType,
  Role,
} from '../../../types'
import { DeviceType, NEDeviceBaseInfo } from 'neroom-types'
import classNames from 'classnames'
import Network from '../../common/Network'

// 移动端摄像头类型
enum MobileCameraType {
  FRONT = 'user', // 前置摄像头
  BACK = 'environment', // 后置摄像头
}

// 移动端麦克风类型
// enum MobileMicrophoneType {
//   HEADSET = 'headset', // 耳机
//   SPEAKER = 'speakerphone', // 扬声电话（免提）
//   EARPIECE = 'earpiece', // 听筒
// }
import './index.less'
import { useTranslation } from 'react-i18next'
import Dialog from '../ui/dialog'

interface MeetingHeaderProps {
  className?: string
  visible?: boolean
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
}

const MeetingHeader: React.FC<MeetingHeaderProps> = ({
  className = '',
  visible = false,
  onClick,
}) => {
  const { meetingInfo } = useMeetingInfoContext()
  const { showCloudRecordingUI } = useGlobalContext()
  const [showMeetingInfo, setShowMeetingInfo] = useState(false)
  const [showExitAction, setShowExitAction] = useState(false)
  const {
    meetingInfo: { localMember, subject },
    dispatch,
  } = useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const {
    neMeeting,
    dispatch: globalDispatch,
    showSubject,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const [actions, setActions] = useState<Action[]>([])
  // 开始录制弹窗提醒
  const [startMeetingRecordingModal, setStartMeetingRecordingModal] =
    useState(false)
  const isSwitchingRef = useRef<boolean>(false)

  const [mobileDeviceType, setMobileDeviceType] = useState<{
    cameraType: MobileCameraType // 前置或后置摄像头
    // microType: MobileMicrophoneType
  }>({
    cameraType: MobileCameraType.FRONT,
    // microType: MobileMicrophoneType.SPEAKER
  })
  const [deviceInfo, setDeviceInfo] = useState<{
    cameras: NEDeviceBaseInfo[]
    cameraItem: NEDeviceBaseInfo | undefined
  }>()
  const isHost = useMemo(() => {
    return localMember.role == Role.host
  }, [localMember.role])
  const possibleCameraField = {
    [MobileCameraType.FRONT]: ['front', '前置'],
    [MobileCameraType.BACK]: ['back', '后置'],
  }

  const { t } = useTranslation()
  const i18n = {
    leave: t('leave'),
    meetingQuit: t('meetingQuit'),
    meetingLeave: t('meetingLeave'),
    globalCancel: t('globalCancel'),
    unsupportedSwitchCamera: t('unsupportedSwitchCamera'),
    meetingRepeatEnd: t('meetingRepeatEnd'),
    end: t('meetingQuit'),
    globalAppName: t('globalAppName'),
  }

  // 点击离开/结束按钮
  const onExitClick = () => {
    const actions: Action[] = [
      {
        text: i18n.leave,
        key: 'leave',
        onClick: async () => {
          await leaveMeetingRoom()
        },
      },
      {
        text: i18n.meetingQuit,
        key: 'end',
        danger: true,
        onClick: async () => {
          await endMeetingRoom()
        },
      },
      {
        text: i18n.globalCancel,
        key: 'cancel',
        onClick: async () => {
          setShowExitAction(false)
        },
      },
    ]

    if (!isHost) {
      actions.splice(1, 1) // 非主持人不能结束会议
    }

    setActions(actions)
    setShowExitAction(true)
  }

  const leaveMeetingRoom = async () => {
    try {
      await neMeeting?.leave()
      setTimeout(() => {
        dispatch &&
          dispatch({
            type: ActionType.RESET_MEETING,
            data: null,
          })
      }, 2000)
    } catch (error) {
      console.log('leaveMeetingRoom', error)
      dispatch &&
        dispatch({
          type: ActionType.RESET_MEETING,
          data: null,
        })
      neMeeting?.destroy()
    } finally {
      globalDispatch &&
        globalDispatch({
          type: ActionType.JOIN_LOADING,
          data: false,
        })
    }
  }

  const endMeetingRoom = async () => {
    try {
      await neMeeting?.end()
    } catch (error) {
      console.log('leaveMeetingRoom', error)
      dispatch &&
        dispatch({
          type: ActionType.RESET_MEETING,
          data: null,
        })
      neMeeting?.destroy()
    } finally {
      globalDispatch &&
        globalDispatch({
          type: ActionType.JOIN_LOADING,
          data: false,
        })
    }
  }

  const initDeviceInfo = async () => {
    const promiseArr = [neMeeting?.getCameras()]
    const result = await Promise.all(promiseArr)

    if (result[0]) {
      const cameras = result[0]
      const cameraId = neMeeting?.getSelectedCameraDevice()
      const cameraItem = cameras?.find(
        (item: NEDeviceBaseInfo) => item.deviceId === cameraId
      )
      const deviceInfo = {
        cameras,
        cameraItem,
      }
      let cameraType = MobileCameraType.FRONT

      if (cameraItem) {
        const back_flag = possibleCameraField[MobileCameraType.BACK].includes(
          cameraItem.deviceName.toLowerCase()
        )

        cameraType = back_flag ? MobileCameraType.BACK : MobileCameraType.FRONT
      }

      setMobileDeviceType(() => {
        return {
          cameraType,
        }
      })
      setDeviceInfo(() => {
        return deviceInfo
      })
      return deviceInfo
    }
  }

  const switchDevice = async (type: DeviceType) => {
    if (isSwitchingRef.current) return
    isSwitchingRef.current = true
    let cameras = deviceInfo?.cameras

    if (!cameras || cameras?.length === 0) {
      const result = await initDeviceInfo()

      if (result) {
        cameras = result?.cameras
      }
    }

    const { cameraType } = mobileDeviceType

    if (cameras) {
      if (type === 'camera') {
        const cameraId =
          cameraType === MobileCameraType.BACK
            ? MobileCameraType.FRONT
            : MobileCameraType.BACK

        await neMeeting?.muteLocalVideo(false)
        neMeeting
          ?.unmuteLocalVideo(cameraId)
          .then(() => {
            setMobileDeviceType({
              cameraType: cameraId as MobileCameraType,
              // microType: mobileDeviceType.microType
            })
          })
          .catch((error: unknown) => {
            console.log(error)
          })
          .finally(() => {
            isSwitchingRef.current = false
          })
      }
    }

    isSwitchingRef.current = false
  }

  function onHeaderClick(event: React.MouseEvent<HTMLDivElement>) {
    onClick?.(event)
  }

  useEffect(() => {
    if (meetingInfo?.isCloudRecording && showCloudRecordingUI) {
      setStartMeetingRecordingModal(true)
    } else {
      setStartMeetingRecordingModal(false)
    }
  }, [showCloudRecordingUI, meetingInfo?.isCloudRecording])

  return (
    <>
      <div
        className={classNames(
          `meeting-header-wrap ${className || ''} ${
            showMeetingInfo ? 'h-full' : ''
          }`,
          {
            ['meeting-header-wrap-visible']: visible,
          }
        )}
        onClick={(e) => {
          e.stopPropagation()
        }}
      >
        <div
          onClick={(e) => onHeaderClick(e)}
          className="meeting-header bg-zinc-900"
        >
          <div className="absolute flex meeting-header-icons">
            {/* todo: icon颜色问题 */}
            {/* todo: 目前android10、所有ios扬声器列表都为空，不支持切换听筒及扬声器，暂不展示 */}
            {/* { localMember?.isAudioOn &&
                <>
                  {
                    mobileDeviceType.microType === MobileMicrophoneType.HEADSET && (
                      <svg className="icon icon-white" aria-hidden="true">
                        <use xlinkHref="#iconheadset1x"></use>
                      </svg>
                    )
                  }
                  {
                    mobileDeviceType.microType === MobileMicrophoneType.SPEAKER && (
                      <svg className="icon icon-white" aria-hidden="true" onClick={()=>{
                        switchDevice('microphone', MobileMicrophoneType.EARPIECE)
                      }}>
                        <use xlinkHref="#iconamplify"></use>
                      </svg>
                    )
                  }
                  {
                    mobileDeviceType.microType === MobileMicrophoneType.EARPIECE && (
                      <svg className="icon icon-white" aria-hidden="true" onClick={()=>{
                        switchDevice('microphone', MobileMicrophoneType.SPEAKER)
                      }}>
                        <use xlinkHref="#iconearpiece1x"></use>
                      </svg>
                    )
                  }
                </>
              } */}
            {localMember?.isVideoOn && (
              <>
                <svg
                  className="icon iconfont icon-white"
                  onClick={() => {
                    switchDevice('camera')
                  }}
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconyx-tv-filpx"></use>
                </svg>
              </>
            )}
          </div>
          <div className="header-title">
            <span
              className={'meeting-name text-base'}
              onClick={() => {
                setShowMeetingInfo(!showMeetingInfo)
              }}
            >
              {showSubject ? subject : i18n.globalAppName}
            </span>
            <svg
              className="icon iconfont icon-white"
              onClick={() => {
                setShowMeetingInfo(!showMeetingInfo)
              }}
              aria-hidden="true"
            >
              <use xlinkHref="#icona-45"></use>
            </svg>
          </div>

          <div className="header-right">
            <div className="nemeeting-signal-wrapper">
              <Network />
            </div>
            <button
              className="exit-btn bg-red-500 text-white rounded h-6 text-xs button-ele"
              onClick={onExitClick}
            >
              {isHost ? i18n.end : i18n.meetingLeave}
            </button>
          </div>
        </div>
        <MeetingInfoPopUp
          visible={showMeetingInfo}
          onClose={() => {
            setShowMeetingInfo(false)
          }}
        />
      </div>
      <ActionSheet
        visible={showExitAction}
        actions={actions}
        getContainer={null}
        onClose={() => setShowExitAction(false)}
      />
      <Dialog
        visible={startMeetingRecordingModal}
        title={t('beingMeetingRecorded')}
        cancelText={t('meetingLeaveFull')}
        confirmText={t('gotIt')}
        width={305}
        onCancel={() => {
          setStartMeetingRecordingModal(false)
          onExitClick()
        }}
        onConfirm={() => {
          setStartMeetingRecordingModal(false)
        }}
      >
        <div className="start-meeting-record-modal">
          <div className="record-message">{t('startRecordTipByMember')}</div>
          <div className="record-agree-message">
            {t('agreeInRecordMeeting')}
          </div>
        </div>
      </Dialog>
    </>
  )
}

export default MeetingHeader
