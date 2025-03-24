import {
  MutableRefObject,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react'
import NEMeetingService from '../services/NEMeeting'
import {
  ActionType,
  CaptionMessageUserInfo,
  Dispatch,
  NEMember,
} from '../types'
import { NERoomCaptionMessage } from 'neroom-types'
import Toast from '../components/common/toast'
import { useTranslation } from 'react-i18next'
import { getWindow } from '../kit'

interface CaptionProps {
  neMeeting?: NEMeetingService
  dispatch?: Dispatch
  memberList: NEMember[]
  isElectronSharingScreen?: boolean
  meetingNum: string
  isH5?: boolean
}
// 开始转写消息
const TranscriptionStartMessage = {
  fromUserUuid: '',
  content: '',
  timestamp: 0,
  isFinal: false,
}

// 结束转写消息
const TranscriptionEndMessage = {
  fromUserUuid: '',
  content: '',
  timestamp: 0,
  isFinal: true,
}

interface CaptionRes {
  transcriptionMessageList: NERoomCaptionMessage[]
  messageUserInfosRef: MutableRefObject<Map<string, CaptionMessageUserInfo>>
  hasTranscriptionHistoryMessages: () => boolean
}

export default function useTranscription(params: CaptionProps): CaptionRes {
  const { t } = useTranslation()
  const {
    neMeeting,
    dispatch,
    memberList,
    isElectronSharingScreen,
    meetingNum,
    isH5,
  } = params

  const memberListRef = useRef<NEMember[]>(memberList)

  const messageUserInfosRef = useRef(new Map<string, CaptionMessageUserInfo>())

  // 转写消息历史，每个元素为一段时间内的转写消息
  const transcriptionMessagesRef = useRef<NERoomCaptionMessage[][]>([
    [TranscriptionStartMessage],
  ])

  // 当前阶段内的 Final 消息
  const currentFinalTranscriptionMessages = useRef<NERoomCaptionMessage[]>([])

  const currentNonFinalTranscriptionMessagesMapRef = useRef(
    new Map<string, NERoomCaptionMessage>()
  )

  memberListRef.current = memberList

  const [transcriptionMessageList, setTranscriptionMessageList] = useState<
    NERoomCaptionMessage[]
  >([TranscriptionStartMessage])

  const transcriptionMessageListRef = useRef(transcriptionMessageList)

  transcriptionMessageListRef.current = transcriptionMessageList

  const generateTranscriptionMessageList = useCallback(
    (needMerge?: boolean, isMessageFinal?: boolean) => {
      let segments: NERoomCaptionMessage[] = []
      const tmpTranscriptionMessages = [
        ...currentFinalTranscriptionMessages.current,
      ]

      if (neMeeting?.liveTranscriptionController?.isTranscriptionEnabled()) {
        if (needMerge) {
          // 表示已是一句完整的句子则从tmpTranscriptionMessages合并最后两项

          if (isMessageFinal) {
            // 删除最后一项,合并到最后一个相同id的消息上
            const originLastMsg = tmpTranscriptionMessages.pop()
            const len = tmpTranscriptionMessages.length
            const lastMsg = tmpTranscriptionMessages[len - 1]

            if (len > 0) {
              // 合并到最后一个相同id的消息上
              const index = tmpTranscriptionMessages.findLastIndex(
                (msg) => msg.fromUserUuid === originLastMsg?.fromUserUuid
              )

              if (index > -1) {
                tmpTranscriptionMessages[index].content =
                  lastMsg.content + originLastMsg?.content

                if (originLastMsg?.translationContent) {
                  tmpTranscriptionMessages[index].translationContent =
                    (lastMsg.translationContent || '') +
                    (originLastMsg?.translationContent || '')
                }
              }
            } else {
              originLastMsg && tmpTranscriptionMessages.push(originLastMsg)
            }

            currentFinalTranscriptionMessages.current = tmpTranscriptionMessages
          } else {
            const tmpMessagesLen = tmpTranscriptionMessages.length
            const tmpCurrentNonFinalTranscriptionMessagesMap = new Map(
              currentNonFinalTranscriptionMessagesMapRef.current
            )
            const lastMessage: NERoomCaptionMessage = JSON.parse(
              JSON.stringify(tmpTranscriptionMessages[tmpMessagesLen - 1])
            )

            const tmpNonFinalMsg =
              tmpCurrentNonFinalTranscriptionMessagesMap.get(
                lastMessage.fromUserUuid
              )

            lastMessage.content = lastMessage.content + tmpNonFinalMsg?.content

            if (tmpNonFinalMsg?.translationContent) {
              lastMessage.translationContent =
                (lastMessage.translationContent || '') +
                (tmpNonFinalMsg.translationContent || '')
            }

            currentNonFinalTranscriptionMessagesMapRef.current.delete(
              lastMessage.fromUserUuid
            )
            tmpTranscriptionMessages[tmpMessagesLen - 1] = lastMessage
          }
        }

        segments = [
          ...tmpTranscriptionMessages,
          ...currentNonFinalTranscriptionMessagesMapRef.current.values(),
        ].sort((a, b) => a.timestamp - b.timestamp)
      }

      setTranscriptionMessageList(
        [...transcriptionMessagesRef.current, ...segments].flat()
      )
    },
    [neMeeting?.liveTranscriptionController]
  )

  const handleReceiveTranscriptionMessageList = useCallback(
    (messages: NERoomCaptionMessage[]) => {
      //如果一段时间内仅有一个人持续说话，则持续在末尾追加文字，无需换行，大于200字再换行

      let needMerge = false
      let isMessageFinal = false

      if (messages.length === 1) {
        const transcriptionMessages = transcriptionMessageListRef.current
        const len = transcriptionMessages.length
        const nonFinale =
          currentNonFinalTranscriptionMessagesMapRef.current.get(
            messages[0].fromUserUuid
          )

        // 判断最后一条消息是否和新接受到消息为同一个人。且最后一条消息是已断句的，如果不是断句的走原先逻辑即可。
        if (
          len > 0 &&
          transcriptionMessages[len - 1].fromUserUuid ===
            messages[0].fromUserUuid &&
          !nonFinale &&
          transcriptionMessages[len - 1].isFinal
        ) {
          const lastMessage = transcriptionMessages[len - 1]

          // 如果最后一条消息长度小于200则添加到最后，如果是大于200则走原先逻辑
          if (lastMessage.content.length < 200) {
            needMerge = true
            isMessageFinal = messages[0].isFinal
          }
        }
      }

      messages.forEach((message) => {
        const nonFinale =
          currentNonFinalTranscriptionMessagesMapRef.current.get(
            message.fromUserUuid
          )

        if (nonFinale) {
          message.timestamp = nonFinale.timestamp
        }

        if (message.isFinal) {
          currentNonFinalTranscriptionMessagesMapRef.current.delete(
            message.fromUserUuid
          )
          currentFinalTranscriptionMessages.current.push(message)
        } else {
          currentNonFinalTranscriptionMessagesMapRef.current.set(
            message.fromUserUuid,
            message
          )
        }
      })

      generateTranscriptionMessageList(needMerge, isMessageFinal)
    },
    [generateTranscriptionMessageList]
  )

  /** 是否有转写历史消息 */
  function hasTranscriptionHistoryMessages(): boolean {
    return (
      currentFinalTranscriptionMessages.current.length > 0 ||
      currentNonFinalTranscriptionMessagesMapRef.current.size > 0 ||
      transcriptionMessagesRef.current.length > 0
    )
  }

  useEffect(() => {
    if (!meetingNum) {
      setTranscriptionMessageList([])
      currentFinalTranscriptionMessages.current = []
      currentNonFinalTranscriptionMessagesMapRef.current.clear()
    }
  }, [meetingNum])

  useEffect(() => {
    const liveTranscriptionController = neMeeting?.liveTranscriptionController

    const listener = {
      onReceiveCaptionMessages: (messages) => {
        messages.forEach((message) => {
          const member = memberListRef.current.find(
            (item) => item.uuid === message.fromUserUuid
          )

          if (member) {
            messageUserInfosRef.current.set(message.fromUserUuid, {
              userId: message.fromUserUuid,
              nickname: member.name,
              avatar: member.avatar,
            })
          }
        })
        if (neMeeting?.liveTranscriptionController?.isTranscriptionEnabled()) {
          handleReceiveTranscriptionMessageList(messages)
        }
      },

      onTranscriptionEnableChanged(enable) {
        if (enable) {
          // 默认已有开启消息一条
          if (transcriptionMessagesRef.current.length > 1) {
            transcriptionMessagesRef.current.push([TranscriptionStartMessage])
          }

          if (!isH5) {
            Toast.info(t('transcriptionStartedNotificationMsg'))
          }
        } else {
          if (!isH5) {
            Toast.info(t('transcriptionStoppedTip'))
          }

          const segments = [
            ...currentFinalTranscriptionMessages.current,
            ...currentNonFinalTranscriptionMessagesMapRef.current.values(),
          ].sort((a, b) => a.timestamp - b.timestamp)

          transcriptionMessagesRef.current.push(segments)
          currentFinalTranscriptionMessages.current = []
          currentNonFinalTranscriptionMessagesMapRef.current.clear()
          transcriptionMessagesRef.current.push([TranscriptionEndMessage])
        }

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isTranscriptionEnabled: enable,
          },
        })
        generateTranscriptionMessageList()
      },
    }

    liveTranscriptionController?.addListener(listener)

    return () => {
      liveTranscriptionController?.removeListener(listener)
    }
  }, [
    neMeeting?.liveTranscriptionController,
    dispatch,
    t,
    isH5,
    handleReceiveTranscriptionMessageList,
    generateTranscriptionMessageList,
  ])

  useEffect(() => {
    if (!isElectronSharingScreen) {
      return
    }

    const transcriptionInMeetingWindow = getWindow(
      'transcriptionInMeetingWindow'
    )

    if (transcriptionInMeetingWindow) {
      transcriptionInMeetingWindow?.postMessage(
        {
          event: 'updateData',
          payload: {
            transcriptionMessageList: transcriptionMessageList
              ? JSON.parse(JSON.stringify(transcriptionMessageList))
              : [],
            messageUserInfosRef: messageUserInfosRef.current,
          },
        },
        transcriptionInMeetingWindow.origin
      )
    }
  }, [isElectronSharingScreen, transcriptionMessageList])

  return {
    transcriptionMessageList,
    messageUserInfosRef,
    hasTranscriptionHistoryMessages,
  }
}
