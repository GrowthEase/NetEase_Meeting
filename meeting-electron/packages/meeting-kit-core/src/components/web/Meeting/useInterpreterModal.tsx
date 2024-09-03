import React, { useCallback, useEffect, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType, EventType } from '../../../types'
import Modal, { ConfirmModal } from '../../common/Modal'
import { useTranslation } from 'react-i18next'
import './index.less'
import { MAJOR_AUDIO } from '../../../config'
import Toast from '../../common/toast'
import { getWindow } from '../../../utils/windowsProxy'
import CommonModal from '../../common/CommonModal'
import { Button } from 'antd'

/**
 * 同传对应弹窗
 */
export default function useInterpreterModal(data: {
  isHostOrCoHost: boolean
  handleControlBarDefaultButtonClick: (type: string) => void
  defaultListeningVolume: number
}): {
  setInterFloatingWindow: React.Dispatch<React.SetStateAction<boolean>>
  setOpenInterpretationWindow: React.Dispatch<React.SetStateAction<boolean>>
  openInterpretationSetting: boolean
  setOpenInterpretationSetting: React.Dispatch<React.SetStateAction<boolean>>
  interFloatingWindow: boolean
  openInterpretationWindow: boolean
} {
  const {
    isHostOrCoHost,
    handleControlBarDefaultButtonClick,
    defaultListeningVolume,
  } = data
  const { t } = useTranslation()
  const [openInterpretationSetting, setOpenInterpretationSetting] =
    useState(false)
  const [openInterpretationWindow, setOpenInterpretationWindow] =
    useState(false)
  const {
    eventEmitter,
    dispatch: globalDispatch,
    neMeeting,
    interpretationSetting,
  } = useGlobalContext()
  const [interFloatingWindow, setInterFloatingWindow] = useState(false)
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const showLanguageRemovedInfoRef = useRef<ConfirmModal>()
  const showMyInterpreterRemovedRef = useRef<ConfirmModal>()
  const interpretationSettingRef = useRef(interpretationSetting)
  const interpreterLeaveRef = useRef<ConfirmModal | null>(null)
  const interpreterAllLeaveRef = useRef<ConfirmModal | null>(null)

  interpretationSettingRef.current = interpretationSetting

  const handleHideRemoveLanguageModal = useCallback(() => {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        showLanguageRemovedInfo: {
          show: false,
          language: '',
        },
      },
    })
  }, [dispatch])

  useEffect(() => {
    if (!meetingInfo.interpretation?.started) {
      if (showLanguageRemovedInfoRef.current) {
        showLanguageRemovedInfoRef.current.destroy()
      }

      handleHideRemoveLanguageModal()
      return
    }

    if (meetingInfo.showLanguageRemovedInfo?.show) {
      if (showLanguageRemovedInfoRef.current) {
        showLanguageRemovedInfoRef.current.destroy()
      }

      showLanguageRemovedInfoRef.current = Modal.confirm({
        title: t('commonTitle'),
        width: 270,
        content: t('interpLanguageRemoved', {
          language: meetingInfo.showLanguageRemovedInfo?.language,
        }),
        okText: t('globalView'),
        cancelText: t('gotIt'),
        onCancel: () => {
          showLanguageRemovedInfoRef.current?.destroy()
          handleHideRemoveLanguageModal()
        },
        onOk: () => {
          showLanguageRemovedInfoRef.current?.destroy()
          handleHideRemoveLanguageModal()
          handleControlBarDefaultButtonClick('interpretation')
        },
      })
    }
  }, [
    meetingInfo.interpretation?.started,
    meetingInfo.showLanguageRemovedInfo?.show,
    meetingInfo.showLanguageRemovedInfo?.language,
    handleHideRemoveLanguageModal,
    t,
  ])

  useEffect(() => {
    if (isHostOrCoHost) {
      eventEmitter?.on(EventType.OnInterpreterLeave, () => {
        if (window.isElectronNative) {
          if (
            getWindow('interpreterSettingWindow') ||
            interpreterLeaveRef.current
          ) {
            return
          }
        } else {
          if (interpreterLeaveRef.current || openInterpretationSetting) {
            return
          }
        }

        interpreterLeaveRef.current = CommonModal.confirm({
          title: t('commonTitle'),
          width: 400,
          content: t('interpInterpreterInMeetingStatusChanged'),
          okText: t('interpSettings'),
          cancelText: t('gotIt'),
          afterClose: () => {
            interpreterLeaveRef.current = null
          },
          onOk: () => {
            interpreterLeaveRef.current?.destroy()
            interpreterLeaveRef.current = null
            handleControlBarDefaultButtonClick('interpretation')
          },
        })
      })

      return () => {
        eventEmitter?.off(EventType.OnInterpreterLeave)
      }
    }
  }, [isHostOrCoHost, openInterpretationSetting, eventEmitter])

  useEffect(() => {
    eventEmitter?.on(EventType.OnInterpreterLeaveAll, (listeningChannel) => {
      if (interpreterAllLeaveRef.current) {
        return
      }

      interpreterAllLeaveRef.current = Modal.confirm({
        title: t('commonTitle'),
        width: 270,
        content: t('interpInterpreterOffline'),
        okText: t('interpSwitchToMajorAudio'),
        cancelText: t('interpDontSwitch'),
        afterClose: () => {
          interpreterAllLeaveRef.current = null
        },
        onOk: () => {
          listeningChannel && neMeeting?.leaveRtcChannel(listeningChannel)
          globalDispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              interpretationSetting: {
                listenLanguage: MAJOR_AUDIO,
                isListenMajor: false,
              },
            },
          })
          neMeeting?.muteMajorAudio(false, defaultListeningVolume)
          interpreterAllLeaveRef.current?.destroy()
          interpreterAllLeaveRef.current = null
        },
      })
    })

    eventEmitter?.on(EventType.MyInterpreterRemoved, () => {
      if (showMyInterpreterRemovedRef.current) {
        showMyInterpreterRemovedRef.current.destroy()
      }

      if (isHostOrCoHost) {
        return
      }

      showMyInterpreterRemovedRef.current = CommonModal.confirm({
        width: 400,
        title: t('commonTitle'),
        okText: t('globalView'),
        className: 'nemeeting-interp-tip-modal',
        footer: null,
        content: (
          <div>
            <div className="nemeeting-interp-remove-modal-tip">
              {t('interpUnassignInterpreter')}
            </div>
            <div className="nemeeting-interp-modal-footer">
              <Button
                onClick={() => {
                  showMyInterpreterRemovedRef.current?.destroy()
                }}
                type="primary"
              >
                {t('sure')}
              </Button>
            </div>
          </div>
        ),
      })
    })
    return () => {
      eventEmitter?.off(EventType.MyInterpreterRemoved)
      eventEmitter?.off(EventType.OnInterpreterLeaveAll)
    }
  }, [
    eventEmitter,
    t,
    defaultListeningVolume,
    globalDispatch,
    neMeeting,
    isHostOrCoHost,
  ])

  useEffect(() => {
    if (meetingInfo.isInterpreter) {
      eventEmitter?.on(EventType.RtcChannelError, (channel) => {
        const speakerLangs =
          meetingInfo.interpretation?.interpreters[meetingInfo.localMember.uuid]
        const speakerChannel = speakerLangs?.map((lang) => {
          return meetingInfo.interpretation?.channelNames[lang]
        })

        if (speakerChannel && speakerChannel.includes(channel)) {
          const modal = Modal.confirm({
            title: t('commonTitle'),
            width: 270,
            content: t('interpJoinChannelErrorMsg'),
            cancelText: t('globalCancel'),
            okText: t('interpReJoinChannel'),
            onOk: () => {
              neMeeting?.joinRtcChannel(channel)
              modal?.destroy()
            },
            onCancel: async () => {
              modal?.destroy()
              const speakerLang =
                interpretationSettingRef.current?.speakerLanguage

              if (!speakerLang || speakerLang === MAJOR_AUDIO) {
                return
              }

              // 如果点击取消并且当前手收听的频道是主频道则切换到主频道
              const speakerChannel =
                meetingInfo.interpretation?.channelNames[speakerLang]

              if (speakerChannel === channel) {
                await neMeeting?.enableAndPubAudio(false, channel)
                await neMeeting?.enableAndPubAudio(true, '')
              }
            },
          })
        }
      })
      return () => {
        eventEmitter?.off(EventType.RtcChannelError)
      }
    }
  }, [
    meetingInfo.isInterpreter,
    eventEmitter,
    meetingInfo.interpretation,
    neMeeting,
    meetingInfo.localMember.uuid,
    t,
  ])

  useEffect(() => {
    if (meetingInfo.isInterpreter) {
      return
    }

    if (meetingInfo.interpretation?.started) {
      Toast.info(t('interpStartNotification'))
    }
  }, [meetingInfo.interpretation?.started, t, meetingInfo.isInterpreter])

  return {
    setInterFloatingWindow,
    setOpenInterpretationWindow,
    interFloatingWindow,
    openInterpretationWindow,
    openInterpretationSetting,
    setOpenInterpretationSetting,
  }
}
