import { useEffect, useRef } from 'react'
import { LoginUserInfo } from '../../../../app/src/types'
import { LOCALSTORAGE_USER_INFO } from '../../../config'
import { EventType } from '../../../types'
import { worker } from '../Meeting/Meeting'
import EventEmitter from 'eventemitter3'

type CanvasSettingReturnType = {
  getUserInfo: () => LoginUserInfo | undefined
  videoCanvas: React.RefObject<HTMLDivElement>
  canvasRef: React.RefObject<HTMLCanvasElement>
}

export function useCanvasSetting(data?: {
  eventEmitter: EventEmitter
}): CanvasSettingReturnType {
  const videoCanvas = useRef<HTMLDivElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  function getUserInfo(): LoginUserInfo | undefined {
    try {
      const userInfo = JSON.parse(
        localStorage.getItem(LOCALSTORAGE_USER_INFO) || '{}'
      )

      return userInfo as LoginUserInfo
    } catch (error) {
      console.log('parseUserInfoError', error)
    }
  }

  useEffect(() => {
    const userInfo = getUserInfo()
    const canvas = canvasRef.current

    if (canvas && videoCanvas.current && window.isElectronNative) {
      canvas.style.height = `${videoCanvas.current.clientHeight}px`
      // @ts-ignore
      const offscreen = canvas.transferControlToOffscreen()

      worker.postMessage(
        {
          canvas: offscreen,
          uuid: userInfo?.userUuid,
        },
        [offscreen]
      )
    }

    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      if (event === 'onVideoFrameData') {
        const { data, width, height } = payload

        worker.postMessage(
          {
            frame: {
              width,
              height,
              data,
            },
            uuid: userInfo?.userUuid,
          },
          [data.bytes.buffer]
        )
      } else if (event === EventType.rtcVirtualBackgroundSourceEnabled) {
        const { enabled, reason } = payload

        data?.eventEmitter?.emit(EventType.rtcVirtualBackgroundSourceEnabled, {
          enabled,
          reason,
        })
      } else if (event === EventType.RtcLocalAudioVolumeIndication) {
        data?.eventEmitter?.emit(
          EventType.RtcLocalAudioVolumeIndication,
          payload.volume
        )
      }
    }

    if (window.isElectronNative) {
      window.addEventListener('message', handleMessage)
      return () => {
        window.removeEventListener('message', handleMessage)
      }
    }
  }, [data?.eventEmitter])

  return {
    getUserInfo,
    videoCanvas,
    canvasRef,
  }
}

export function useAudioSetting(eventEmitter: EventEmitter): void {
  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      if (event === EventType.rtcVirtualBackgroundSourceEnabled) {
        const { enabled, reason } = payload

        eventEmitter?.emit(EventType.rtcVirtualBackgroundSourceEnabled, {
          enabled,
          reason,
        })
      } else if (event === EventType.RtcLocalAudioVolumeIndication) {
        eventEmitter?.emit(
          EventType.RtcLocalAudioVolumeIndication,
          payload.volume
        )
      }
    }

    if (window.isElectronNative) {
      window.addEventListener('message', handleMessage)
      return () => {
        window.removeEventListener('message', handleMessage)
      }
    }
  }, [eventEmitter])
}
