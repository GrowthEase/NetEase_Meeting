import React, { useContext, useEffect, useRef, useState } from 'react'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import { ActionSheet } from 'antd-mobile'
import type { Action } from 'antd-mobile/es/components/action-sheet'
import MeetingInfoPopUp from './meetingInfo'
import {
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  ActionType,
  Role,
} from '../../../types'
import { DeviceType, NEDeviceBaseInfo } from 'neroom-web-sdk'
import Toast from '../../common/toast'

// 移动端摄像头类型
enum MobileCameraType {
  FRONT = 'front', // 前置摄像头
  BACK = 'back', // 后置摄像头
}

// 移动端麦克风类型
enum MobileMicrophoneType {
  HEADSET = 'headset', // 耳机
  SPEAKER = 'speakerphone', // 扬声电话（免提）
  EARPIECE = 'earpiece', // 听筒
}
import './index.less'
import { member } from 'typedoc/dist/lib/output/themes/default/partials/member'

interface MeetingHeaderProps {
  className?: string
  visible?: boolean
  onClick?: (e: any) => void
}

const MeetingHeader: React.FC<MeetingHeaderProps> = ({
  className = '',
  visible = false,
  onClick,
}) => {
  const [showMeetingInfo, setShowMeetingInfo] = useState(false)
  const [showExitAction, setShowExitAction] = useState(false)
  const {
    meetingInfo: { localMember, hostUuid, myUuid, subject },
    dispatch,
  } = useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const {
    neMeeting,
    dispatch: globalDispatch,
    showSubject,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const [actions, setActions] = useState<Action[]>([])
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
    cameraItem: any
  }>()

  const isHost =
    localMember.role == Role.host || localMember.role == Role.coHost
  const possibleCameraField = {
    [MobileCameraType.FRONT]: ['front', '前置'],
    [MobileCameraType.BACK]: ['back', '后置'],
  }

  // 点击离开/结束按钮
  const onExitClick = () => {
    const actions: Action[] = [
      {
        text: '离开会议',
        key: 'leave',
        onClick: async () => {
          await leaveMeetingRoom()
        },
      },
      {
        text: '结束会议',
        key: 'end',
        danger: true,
        onClick: async () => {
          await endMeetingRoom()
        },
      },
      {
        text: '取消',
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
        (item: any) => item.deviceId === cameraId
      )
      const deviceInfo = {
        cameras,
        cameraItem,
      }
      console.log('-------------device---------------')
      console.log(deviceInfo)
      let cameraType = MobileCameraType.FRONT
      if (cameraItem) {
        const back_flag = possibleCameraField[MobileCameraType.BACK].includes(
          cameraItem.deviceName.toLowerCase()
        )
        cameraType = back_flag ? MobileCameraType.BACK : MobileCameraType.FRONT
      }
      setMobileDeviceType((x) => {
        return {
          cameraType,
        }
      })
      setDeviceInfo((x) => {
        return deviceInfo
      })
      return deviceInfo
    }
  }

  const switchDevice = async (
    type: DeviceType,
    switchTag: MobileMicrophoneType | MobileCameraType
  ) => {
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
    console.log('switchDevice  ', type, mobileDeviceType)
    if (cameras) {
      if (type === 'camera') {
        const cameraId =
          cameraType === MobileCameraType.BACK
            ? MobileCameraType.FRONT
            : MobileCameraType.BACK
        cameras.sort((a, b) => {
          if (a.deviceName < b.deviceName) return -1
          if (a.deviceName > b.deviceName) return 1
          return 0
        })
        console.log('switchTag  ', cameraId)
        const cameraItem = cameras.find((item) => {
          const flag = possibleCameraField[cameraId].some(
            (field) => item.deviceName.toLowerCase().indexOf(field) > -1
          )
          if (flag) return item
        })
        if (cameraItem?.deviceId) {
          // 部分机型存在直接切换不了的问题，故先关后开
          await neMeeting?.muteLocalVideo(false)
          await neMeeting?.changeLocalVideo(cameraItem.deviceId)
          neMeeting
            ?.unmuteLocalVideo('', false)
            .then((res: any) => {
              setMobileDeviceType({
                cameraType: cameraId as MobileCameraType,
                // microType: mobileDeviceType.microType
              })
            })
            .catch((error: any) => {
              console.log(error)
            })
            .finally(() => {
              isSwitchingRef.current = false
            })
        } else {
          Toast.info('该设备暂不支持切换摄像头')
        }
      }
    }
    isSwitchingRef.current = false
  }

  function onHeaderClick(event: any) {
    onClick?.(event)
  }

  return (
    <>
      {visible && (
        <div
          className={`meeting-header-wrap ${className || ''} ${
            showMeetingInfo ? 'h-full' : ''
          }`}
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
                  <i
                    className="iconfont icon-white iconyx-tv-filpx"
                    onClick={() => {
                      switchDevice('camera', mobileDeviceType.cameraType)
                    }}
                  ></i>
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
                {showSubject ? subject : '网易会议'}
              </span>
              <i
                onClick={() => {
                  setShowMeetingInfo(!showMeetingInfo)
                }}
                className="iconfont icona-45"
              ></i>
            </div>
            <button
              className="exit-btn bg-red-500 text-white rounded h-6 text-xs absolute top-5 right-4 button-ele"
              onClick={onExitClick}
            >
              {isHost ? '结束' : '离开'}
            </button>
          </div>
          <MeetingInfoPopUp
            visible={showMeetingInfo}
            onClose={() => {
              setShowMeetingInfo(false)
            }}
          />
          <ActionSheet
            visible={showExitAction}
            actions={actions}
            getContainer={null}
            onClose={() => setShowExitAction(false)}
          />
        </div>
      )}
    </>
  )
}
export default MeetingHeader
