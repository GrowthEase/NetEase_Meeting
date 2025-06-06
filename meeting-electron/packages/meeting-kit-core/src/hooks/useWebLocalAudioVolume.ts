import { useEffect } from 'react'
import { useGlobalContext } from '../store'

// web&h5本端音量波动
export default function useWebLocalAudioVolume(isAudioOn: boolean) {
  const { neMeeting } = useGlobalContext()

  useEffect(() => {
    if (window.isElectronNative) {
      return
    }

    if (isAudioOn) {
      neMeeting?.startWebLocalAudioVolumeIndication()
    } else {
      neMeeting?.stopWebLocalAudioVolumeIndication()
    }
  }, [isAudioOn])

  useEffect(() => {
    return () => {
      neMeeting?.stopWebLocalAudioVolumeIndication()
    }
  }, [])
}
