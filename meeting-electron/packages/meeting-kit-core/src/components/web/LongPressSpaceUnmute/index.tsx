import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { useGlobalContext, useMeetingInfoContext } from '../../../store'

import { Role } from '../../../types'
import AudioIcon from '../../common/AudioIcon'
import Toast from '../../common/toast'
import './index.less'
import { errorCodeMap } from '../../../config'

const LongPressSpaceUnmute: React.FC = () => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const { neMeeting } = useGlobalContext()

  const keyDownTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)
  const localMember = meetingInfo.localMember
  const isHostOrCoHost =
    localMember.role === Role.host || localMember.role === Role.coHost

  const focusRef = useRef(false)
  const [longPressSpaceAudio, setLongPressSpaceAudio] = useState<boolean>(false)
  const handleKeyDownRef = useRef(false)

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  useEffect(() => {
    if (!localMember.isAudioOn) {
      setLongPressSpaceAudio(false)
    }
  }, [localMember.isAudioOn])

  useEffect(() => {
    if (isElectronSharingScreen || !localMember.isAudioConnected) {
      return
    }

    function handleKeyDown(e) {
      if (
        handleKeyDownRef.current ||
        localMember.isAudioOn ||
        e.key !== ' ' ||
        keyDownTimerRef.current ||
        longPressSpaceAudio ||
        focusRef.current
      ) {
        return
      }

      if (e.key === ' ') {
        handleKeyDownRef.current = true
      }

      keyDownTimerRef.current = setTimeout(async () => {
        if (
          !meetingInfo.unmuteAudioBySelfPermission &&
          !isHostOrCoHost &&
          // 本端在共享
          localMember.uuid !== meetingInfo.screenUuid
        ) {
          // 需要举手
        } else {
          try {
            await neMeeting?.unmuteLocalAudio()
            setLongPressSpaceAudio(true)
            if (!handleKeyDownRef.current) {
              await neMeeting?.muteLocalAudio()
              setLongPressSpaceAudio(false)
            }
          } catch (err: unknown) {
            const knownError = err as {
              message: string
              msg: string
              code: number
            }

            Toast.fail(
              knownError?.msg ||
                t(errorCodeMap[knownError?.code] || 'unMuteAudioFail')
            )
          }
        }
      }, 1000)
    }

    async function handleKeyUp(e) {
      if (handleKeyDownRef.current && e.key !== ' ') {
        return
      }

      if (e.key === ' ') {
        handleKeyDownRef.current = false
      }

      keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
      keyDownTimerRef.current = null
      setLongPressSpaceAudio(false)
      if (localMember.isAudioOn && longPressSpaceAudio && e.key === ' ') {
        let failCount = 0

        const muteLocalAudio = async () => {
          try {
            await neMeeting?.muteLocalAudio()
          } catch {
            failCount++
            setTimeout(() => {
              failCount < 100 && muteLocalAudio()
            }, 500)
          }
        }

        await muteLocalAudio()
      }
    }

    async function handleFocus(event) {
      if (
        event.target instanceof HTMLInputElement ||
        event.target instanceof HTMLTextAreaElement ||
        event.target.className === 'nemeeting-chatroom-editable'
      ) {
        focusRef.current = true
        keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
        keyDownTimerRef.current = null
        setLongPressSpaceAudio(false)
        if (localMember.isAudioOn && longPressSpaceAudio) {
          await neMeeting?.muteLocalAudio()
        }
      }
    }

    async function handleBlur() {
      if (focusRef.current) {
        focusRef.current = false
      }
    }

    async function handleVisibilityChange() {
      if (document.visibilityState !== 'visible') {
        keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
        keyDownTimerRef.current = null
        setLongPressSpaceAudio(false)
        if (localMember.isAudioOn && longPressSpaceAudio) {
          await neMeeting?.muteLocalAudio()
        }
      }
    }

    async function handleWindowBlur() {
      keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
      keyDownTimerRef.current = null
      setLongPressSpaceAudio(false)
      if (localMember.isAudioOn && longPressSpaceAudio) {
        await neMeeting?.muteLocalAudio()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    document.addEventListener('keyup', handleKeyUp)
    document.addEventListener('focus', handleFocus, true)
    document.addEventListener('blur', handleBlur, true)
    document.addEventListener('visibilitychange', handleVisibilityChange)
    window.addEventListener('blur', handleWindowBlur)

    return () => {
      document.removeEventListener('keydown', handleKeyDown)
      document.removeEventListener('keyup', handleKeyUp)
      document.removeEventListener('focus', handleFocus, true)
      document.removeEventListener('blur', handleBlur, true)
      document.removeEventListener('visibilitychange', handleVisibilityChange)
      window.removeEventListener('blur', handleWindowBlur)
    }
  }, [
    meetingInfo,
    localMember,
    isHostOrCoHost,
    longPressSpaceAudio,
    neMeeting,
    localMember.isAudioConnected,
    t,
    isElectronSharingScreen,
  ])

  // 打开屏幕共享暂停音频
  useEffect(() => {
    if (
      localMember.isAudioOn &&
      longPressSpaceAudio &&
      isElectronSharingScreen
    ) {
      handleKeyDownRef.current = false
      neMeeting?.muteLocalAudio()
    }
  }, [
    isElectronSharingScreen,
    localMember.isAudioOn,
    longPressSpaceAudio,
    neMeeting,
  ])

  // 打开屏幕共享暂停音频
  useEffect(() => {
    if (
      localMember.isAudioOn &&
      !localMember.isAudioConnected &&
      longPressSpaceAudio
    ) {
      setLongPressSpaceAudio(false)
      handleKeyDownRef.current = false
      neMeeting?.muteLocalAudio()
    }
  }, [
    localMember.isAudioOn,
    localMember.isAudioConnected,
    longPressSpaceAudio,
    neMeeting,
  ])

  useEffect(() => {
    if (!localMember.isAudioConnected) {
      keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
      keyDownTimerRef.current = null
      setLongPressSpaceAudio(false)
    }
  }, [localMember.isAudioConnected])

  useEffect(() => {
    if (localMember.isAudioOn && !longPressSpaceAudio) {
      keyDownTimerRef.current && clearTimeout(keyDownTimerRef.current)
      keyDownTimerRef.current = null
    }
  }, [localMember.isAudioOn])

  return (
    <div>
      {longPressSpaceAudio ? (
        <div className="long-press-space-box">
          <AudioIcon className="mic-img" memberId={localMember.uuid} />
          {/* <img className="mic-img" src={micImage} alt="" /> */}
          <span>{t('unmute')}</span>
        </div>
      ) : null}
    </div>
  )
}

export default LongPressSpaceUnmute
