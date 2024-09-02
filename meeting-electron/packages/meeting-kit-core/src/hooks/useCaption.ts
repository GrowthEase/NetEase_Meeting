import { useCallback, useEffect, useRef, useState } from 'react'
import NEMeetingService from '../services/NEMeeting'
import {
  ActionType,
  Dispatch,
  NEMeetingCaptionMessage,
  NEMember,
} from '../types'
import { NECommonError, NERoomCaptionTranslationLanguage } from 'neroom-types'
import Toast from '../components/common/toast'
import { useTranslation } from 'react-i18next'
import { getLocalStorageSetting } from '../kit'

interface CaptionProps {
  neMeeting?: NEMeetingService
  dispatch?: Dispatch
  memberList: NEMember[]
  meetingNum: string
  isMouseOverCaption?: boolean
  canShowCaption?: boolean
}

interface CaptionRes {
  captionMessageList: NEMeetingCaptionMessage[]
  enableCaption: (
    enable: boolean,
    lang?: NERoomCaptionTranslationLanguage
  ) => Promise<void>
}

interface EnableCaptionRes {
  enableCaption: (enable: boolean) => Promise<void>
  setEnableCaptionLoading: (enable: boolean) => void
}

export function useEnableCaption(params: {
  neMeeting?: NEMeetingService
  dispatch?: Dispatch
}): EnableCaptionRes {
  const { t } = useTranslation()
  const { neMeeting, dispatch } = params
  const setEnableCaptionLoading = useCallback(
    (enable: boolean) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          enableCaptionLoading: enable,
        },
      })
    },
    [dispatch]
  )

  const enableCaption = useCallback(
    async (enable: boolean): Promise<void> => {
      const setting = getLocalStorageSetting()
      const targetLanguage = setting.captionSetting?.targetLanguage

      if (targetLanguage && enable) {
        try {
          await neMeeting?.setCaptionTranslationLanguage(targetLanguage)
        } catch (error) {
          console.log('setCaptionTranslationLanguage error', error)
        }
      }

      return neMeeting?.liveTranscriptionController
        ?.enableCaption(enable, () => {
          if (enable) {
            setEnableCaptionLoading(true)
          }
        })
        .then(() => {
          if (!enable) {
            Toast.success(t('transcriptionDisableCaptionHint'))
          } else {
            Toast.success(t('transcriptionEnableCaptionHint'))
          }
        })
        .catch((error: unknown) => {
          if ((error as NECommonError).code === 1041) {
            Toast.fail(t('transcriptionCanNotEnableCaption'))
          } else {
            Toast.fail(
              enable
                ? t('transcriptionStartFailed')
                : t('transcriptionStopFailed')
            )
          }
        })
    },
    [neMeeting?.liveTranscriptionController, setEnableCaptionLoading, t]
  )

  return {
    enableCaption,
    setEnableCaptionLoading,
  }
}

export default function useCaption(params: CaptionProps): CaptionRes {
  const { t } = useTranslation()
  const {
    neMeeting,
    dispatch,
    memberList,
    meetingNum,
    canShowCaption,
    isMouseOverCaption,
  } = params

  const memberListRef = useRef<NEMember[]>(memberList)
  const lastMsgInfoMapRef = useRef(
    new Map<string, { content: string; translationContent?: string }>()
  )
  const enableCaptionTimer = useRef<null | ReturnType<typeof setTimeout>>(null)

  memberListRef.current = memberList

  const [captionMessageList, setCaptionMessageList] = useState<
    NEMeetingCaptionMessage[]
  >([])

  const captionMessageListRef =
    useRef<NEMeetingCaptionMessage[]>(captionMessageList)

  captionMessageListRef.current = captionMessageList

  const { enableCaption, setEnableCaptionLoading } = useEnableCaption({
    neMeeting,
    dispatch,
  })

  const handleEnableTimer = useCallback(() => {
    if (enableCaptionTimer.current) {
      clearTimeout(enableCaptionTimer.current)
      enableCaptionTimer.current = null
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          canShowCaption: true,
        },
      })
    }

    enableCaptionTimer.current = setTimeout(() => {
      enableCaptionTimer.current && clearTimeout(enableCaptionTimer.current)
      enableCaptionTimer.current = null

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          canShowCaption: false,
        },
      })
    }, 5000)
  }, [dispatch])

  useEffect(() => {
    if (!canShowCaption && !isMouseOverCaption) {
      enableCaptionTimer.current && clearTimeout(enableCaptionTimer.current)
      enableCaptionTimer.current = null
      setCaptionMessageList([])
      lastMsgInfoMapRef.current.clear()
    }
  }, [canShowCaption, isMouseOverCaption])

  const handleReceiveCaptionMessageList = useCallback(
    (meetingMessageList: NEMeetingCaptionMessage[]) => {
      let tmCaptionMessageList = [...captionMessageListRef.current]

      meetingMessageList.forEach((item) => {
        const index = tmCaptionMessageList.findLastIndex(
          (msg) => msg.fromUserUuid === item.fromUserUuid
        )

        // 原对话列表无此人直接加入末尾
        if (index < 0) {
          tmCaptionMessageList.push(item)
          if (item.isFinal) {
            lastMsgInfoMapRef.current.set(item.fromUserUuid, {
              content: item.content,
              translationContent: item.translationContent || '',
            })
          }

          return
        }

        const message = tmCaptionMessageList[index]

        const lastMsgInfo = lastMsgInfoMapRef.current.get(item.fromUserUuid)

        const lastMsgContent = lastMsgInfo?.content || ''
        const lastMsgTranslationContent = lastMsgInfo?.translationContent || ''
        const tmpMessage = {
          ...item,
          content: lastMsgContent + item.content,
          translationContent:
            lastMsgTranslationContent + (item.translationContent || ''),
          // 由于是同一个人说话，产品要求排序不能重新排后面，所以时间戳用原先的
          timestamp: item.isFinal ? item.timestamp : message.timestamp,
        }

        // 最后一条消息和新来的消息是同一个人的话，追加
        if (lastMsgInfo) {
          const lastContent = lastMsgInfo?.content || ''
          const lastTranslationContent = lastMsgInfo?.translationContent || ''

          if (item.isFinal) {
            lastMsgInfoMapRef.current.set(item.fromUserUuid, {
              content: (lastContent + item.content).slice(-500),
              translationContent:
                lastTranslationContent +
                (item.translationContent || '').slice(-1000),
            })
          }
        } else {
          item.isFinal &&
            lastMsgInfoMapRef.current.set(item.fromUserUuid, {
              content: item.content,
              translationContent: item.translationContent || '',
            })
        }

        tmCaptionMessageList[index] = tmpMessage
      })

      // 根据时间戳升序排列
      tmCaptionMessageList.sort((a, b) => a.timestamp - b.timestamp)

      if (tmCaptionMessageList.length > 3) {
        tmCaptionMessageList = tmCaptionMessageList.slice(
          tmCaptionMessageList.length - 3
        )
      }

      const now = Date.now()

      // 过滤时间大于5s的消息
      tmCaptionMessageList = tmCaptionMessageList.filter((item) => {
        if (now - item.timestamp < 1000 * 5 || !item.isFinal) {
          return true
        } else {
          // 删除超时的最后一条完整的缓存消息
          lastMsgInfoMapRef.current.delete(item.fromUserUuid)
          return false
        }
      })

      setCaptionMessageList(tmCaptionMessageList)
    },
    []
  )

  useEffect(() => {
    if (!meetingNum) {
      setCaptionMessageList([])
    }
  }, [meetingNum])

  useEffect(() => {
    const liveTranscriptionController = neMeeting?.liveTranscriptionController

    const listener = {
      onReceiveCaptionMessages: (messages) => {
        handleEnableTimer()
        const meetingMessageList = messages.map((message) => {
          const member = memberListRef.current.find(
            (item) => item.uuid === message.fromUserUuid
          )
          let fromNickname = ''

          if (member) {
            fromNickname = member.name || ''
          } else {
            const member = captionMessageListRef.current.find(
              (item) => item.fromUserUuid === message.fromUserUuid
            )

            if (member) {
              fromNickname = member.fromNickname || ''
            }
          }

          return {
            ...message,
            fromNickname: fromNickname,
          }
        })

        if (neMeeting?.liveTranscriptionController?.isCaptionsEnabled()) {
          handleReceiveCaptionMessageList(meetingMessageList)
        }
      },
      onAllowParticipantsEnableCaptionChanged: (
        isAllowParticipantsEnableCaption
      ) => {
        console.warn(
          'onAllowParticipantsEnableCaptionChanged',
          isAllowParticipantsEnableCaption
        )
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isAllowParticipantsEnableCaption,
          },
        })
      },
      onMySelfCaptionEnableChanged: (isCaptionsEnabled: boolean) => {
        if (isCaptionsEnabled) {
          setTimeout(() => {
            setEnableCaptionLoading(false)
          }, 2000)

          handleEnableTimer()
        } else {
          setCaptionMessageList([])
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isCaptionsEnabled,
            canShowCaption: isCaptionsEnabled,
          },
        })
      },
      onMySelfCaptionForbidden: () => {
        Toast.fail(t('transcriptionCaptionForbidden'))
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isCaptionsEnabled: false,
          },
        })
      },
    }

    liveTranscriptionController?.addListener(listener)

    return () => {
      liveTranscriptionController?.removeListener(listener)
    }
  }, [
    neMeeting?.liveTranscriptionController,
    dispatch,
    setEnableCaptionLoading,
    t,
    handleEnableTimer,
    handleReceiveCaptionMessageList,
  ])

  return {
    captionMessageList,
    enableCaption,
  }
}
