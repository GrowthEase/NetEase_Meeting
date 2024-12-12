import React, { useEffect, useState, useCallback, useMemo } from 'react'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../store'
import { useMount, useUpdateEffect } from 'ahooks'
import {
  ActionType,
  CreateMeetingResponse,
  EventType,
  getWindow,
  hostAction,
  Modal,
  NEClientType,
  NEMeetingInfo,
  NEMember,
  NERoomChatMessage,
  Role,
  Toast,
} from '../kit'
import { useTranslation } from 'react-i18next'
import { Checkbox } from 'antd'
import { NECommonError } from 'neroom-types'
import { merge } from 'lodash'
import dayjs from 'dayjs'

type FileEx = File & {
  base64?: string
  url?: string
  filePath?: string
  height?: number
  width?: number
}

export const fileSizeLimit = 200 * 1024 * 1024 // 单位Byte

export const imgSizeLimit = 20 * 1024 * 1024 // 单位Byte

export const imageExtensions = '.jpg,.png,.jpeg,.bmp'

export const fileExtensions =
  '.mp3,.aac,.wav,.pcm,.mp4,.flv,.mov,.doc,.docx,.xls,.xlsx,.ppt,.pdf,.zip,.7z,.biz,.tar,.txt,.apk,.ipa,.jpg,.png,.jpeg,.bmp'

export const uuid = () => {
  const data = 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(
    /[xy]/g,
    function (c) {
      const r = (Math.random() * 16) | 0
      const v = c === 'x' ? r : (r & 0x3) | 0x8

      return v.toString(16)
    }
  )

  return data
}

export type ChatRoomMember = {
  tags: string[]
  account: string
  nick: string
  waitingRoom: boolean
  avatar?: string
  role?: Role
}

type Props = {
  children?: React.ReactNode
}

type ChatRoomContextType = {
  messages: NERoomChatMessage[]
  privateChatMember?: ChatRoomMember
  chatRoomMemberList: ChatRoomMember[]
  chatWaitingRoomMemberList: ChatRoomMember[]
  privateChatMemberId: string
  disabled: number
  onSendTextMsg: (text: string) => Promise<void>
  onSendFileMsg: (
    type: 'image' | 'file',
    file: File,
    resendId?: string
  ) => Promise<void>
  onPrivateChatMemberSelected: (id: string, auto?: boolean) => void
  onRemoveMember?: (id: string) => void
  recallMessage?: (msg: NERoomChatMessage) => void
  cancelSendFileMessage?: (msg: NERoomChatMessage) => Promise<void>
  onResend?: (msg: NERoomChatMessage) => Promise<void>
  openFile?: (msg: NERoomChatMessage, isDic: boolean) => void
  downloadAttachment?: (msg: NERoomChatMessage, path: string) => void
  cancelDownloadAttachment?: (msg: NERoomChatMessage) => void
  exportChatroomHistoryMessageList?: (
    meetingId?: number,
    myUuid?: string
  ) => void
  addEventListenerAtChatWindow?: () => void
  fetchHistoryMessages?: (meetingId?: number) => Promise<void>
  clearMessages?: () => void
}

export const ChatRoomContext = React.createContext<ChatRoomContextType>({
  messages: [],
  chatRoomMemberList: [],
  chatWaitingRoomMemberList: [],
  privateChatMemberId: '',
  disabled: 0,
  onSendTextMsg: () => Promise.resolve(),
  onSendFileMsg: () => Promise.resolve(),
  onPrivateChatMemberSelected: () => void 0,
})

export const ChatRoomContextProvider: React.FC<Props> = (props) => {
  const { t } = useTranslation()
  const { eventEmitter, neMeeting } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const { memberList: waitingRoomMemberList } = useWaitingRoomContext()
  const [messages, setMessages] = useState<NERoomChatMessage[]>([]) // 聊天室消息
  const [hostOrCohostList, setHostOrCohostList] = useState<NEMember[]>([])
  const [privateChatMemberId, setPrivateChatMemberId] = useState('')

  const messagesRef = React.useRef<NERoomChatMessage[]>([])
  const meetingInfoRef = React.useRef<NEMeetingInfo>(meetingInfo)
  const isSendWaitingChatroomRef = React.useRef<boolean>(false)
  const privateChatMemberIdRef = React.useRef<string>(privateChatMemberId)
  const disabledRef = React.useRef<number>(0)
  const exportFileName = React.useRef<string>('')

  meetingInfoRef.current = meetingInfo
  messagesRef.current = messages
  privateChatMemberIdRef.current = privateChatMemberId

  const {
    inWaitingRoom = false,
    waitingRoomChatPermission,
    meetingChatPermission,
    localMember,
  } = meetingInfo

  const isHostOrCohost =
    localMember.role === Role.host || localMember.role === Role.coHost

  const onlyHostOrCohost =
    (!isHostOrCohost && meetingChatPermission === 3) ||
    (inWaitingRoom && waitingRoomChatPermission === 1)

  const onlyPublic = !isHostOrCohost && meetingChatPermission === 2

  const chatRoomMemberList = useMemo(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []
    const chatRoomMemberList = inWaitingRoom ? hostOrCohostList : memberList

    chatRoomMemberList
      .filter(
        (member) =>
          member.uuid != meetingInfo.myUuid &&
          member.clientType !== NEClientType.SIP &&
          member.clientType !== NEClientType.H323
      )
      .forEach((member) => {
        if (member.role === Role.host) {
          host.push(member)
        } else if (member.role === Role.coHost) {
          coHost.push(member)
        } else if (member.isHandsUp) {
          handsUp.push(member)
        } else if (member.isSharingWhiteboard || member.isSharingScreen) {
          sharingWhiteboardOrScreen.push(member)
        } else if (member.isAudioOn && member.isVideoOn) {
          audioAndVideoOn.push(member)
        } else if (member.isVideoOn) {
          videoOn.push(member)
        } else if (member.isAudioOn) {
          audioOn.push(member)
        } else {
          other.push(member)
        }
      })
    other.sort((a, b) => {
      return a.name.localeCompare(b.name)
    })
    const members = [
      ...host,
      ...coHost,
      ...handsUp,
      ...sharingWhiteboardOrScreen,
      ...audioAndVideoOn,
      ...videoOn,
      ...audioOn,
      ...other,
    ]

    return members
      .filter((member) => {
        if (onlyPublic || onlyHostOrCohost) {
          return member.role === Role.host || member.role === Role.coHost
        }

        return true
      })
      .map((member) => {
        return {
          tags: [],
          account: member.uuid,
          nick: member.name,
          avatar: member.avatar,
          role: member.role,
          waitingRoom: false,
        }
      }) as ChatRoomMember[]
  }, [
    memberList,
    meetingInfo.myUuid,
    hostOrCohostList,
    inWaitingRoom,
    onlyHostOrCohost,
    onlyPublic,
  ])

  // 0 可以发送消息 1 全体禁言 2 没有成员可以说 3 等待室禁言
  const disabled = useMemo(() => {
    if (inWaitingRoom) {
      if (waitingRoomChatPermission === 0) {
        return 3
      } else if (
        chatRoomMemberList.filter((item) =>
          ['host', 'cohost'].includes(item.role ?? '')
        ).length === 0
      ) {
        return 2
      } else {
        return 0
      }
    }

    if (!isHostOrCohost && meetingChatPermission === 4) {
      return 1
    }

    if (
      onlyHostOrCohost &&
      chatRoomMemberList.filter((item) =>
        ['host', 'cohost'].includes(item.role ?? '')
      ).length === 0
    ) {
      return 2
    }

    return 0
  }, [
    isHostOrCohost,
    meetingChatPermission,
    chatRoomMemberList,
    inWaitingRoom,
    waitingRoomChatPermission,
    onlyHostOrCohost,
  ])

  disabledRef.current = disabled

  const chatWaitingRoomMemberList = useMemo(() => {
    if (!isHostOrCohost) {
      return []
    }

    return (
      waitingRoomMemberList.map((member) => ({
        tags: [],
        account: member.uuid,
        nick: member.name,
        avatar: member.avatar,
        waitingRoom: true,
      })) || []
    )
  }, [isHostOrCohost, waitingRoomMemberList])

  const privateChatHandler = useCallback(() => {
    // 等候室全员
    if (
      privateChatMemberId === 'waitingRoomAll' &&
      chatWaitingRoomMemberList.length > 0
    ) {
      isSendWaitingChatroomRef.current = true
      return
    }

    // 会议成员私聊
    let privateChatMember = chatRoomMemberList.find(
      (item) => item.account === privateChatMemberId
    )

    if (privateChatMember) {
      isSendWaitingChatroomRef.current = inWaitingRoom
      return privateChatMember
    }

    // 等候室会议成员私聊
    privateChatMember = chatWaitingRoomMemberList.find(
      (item) => item.account === privateChatMemberId
    )
    if (privateChatMember) {
      isSendWaitingChatroomRef.current = true
      return privateChatMember
    }

    isSendWaitingChatroomRef.current = false

    return
  }, [privateChatMemberId, chatRoomMemberList, chatWaitingRoomMemberList])

  function formatMessage(element): NERoomChatMessage {
    if (element.fromUserUuid && !element.from) {
      element.from = element.fromUserUuid
    }

    element.isMe = element.from === localMember.uuid

    element.isPrivate = false
    if (element.custom) {
      try {
        const custom = JSON.parse(element.custom)

        if (custom.toAccounts?.length > 0) {
          element.isPrivate = true
        }
      } catch (e) {
        element.custom = {}
      }
    }

    if (element.toUserUuidList?.length > 0) {
      element.isPrivate = true
    }

    if (element.messageType && !element.type) {
      element.type = element.messageType
    }

    if (element.messageUuid && !element.idClient) {
      element.idClient = element.messageUuid
    }

    if (element.fromUserUuid && !element.from) {
      element.from = element.fromUserUuid
    }

    if (
      (element.type === 'file' || element.type === 'image') &&
      !element.file
    ) {
      element.file = {
        url: element.url,
        name: element.displayName,
        size: element.size,
        md5: element.md5,
        ext: element.extension,
        w: element.width,
        h: element.height,
      }
    }

    if (element.attachStr) {
      element.attach = JSON.parse(element.attachStr)
      switch (element.attach.id) {
        case 323:
          element.attach.type = 'deleteChatroomMsg'
          break
        case 302:
          element.attach.type = 'memberEnter'
          break
        default:
      }

      element.attach.from = element.attach.operator
    }

    if (!element.status) {
      element.status = 'success'
    }

    return element
  }

  function updateMsg(id: string, msg: Partial<NERoomChatMessage>) {
    const msgList = messagesRef.current
    const index = msgList.findIndex((item) => item.idClient === id)

    if (index !== -1) {
      const _msg = msgList[index]

      msgList[index] = merge(_msg, msg)
      setMessages([...msgList])
    }
  }

  function addTempMsg(
    file: FileEx,
    idClient: string,
    type: string,
    privateChatMember?: ChatRoomMember
  ): NERoomChatMessage {
    const tempMsg = {
      idClient,
      fromClientType: 'Web',
      messageType: 'file',
      fromUserUuid: localMember.uuid,
      status: 'sending',
      file: {
        ext: file.name.split('.').pop(),
        size: file.size,
        url:
          file.base64 !== undefined ? file.base64 : URL.createObjectURL(file),
        filePath: file.url,
        name: file.name,
        w: file.width ?? 0,
        h: file.height ?? 0,
      },
      type,
      isMe: true,
      fromNick: localMember.name,
      fromAvatar: localMember.avatar,
      time: Date.now(),
      text: '',
      from: localMember.uuid,
      toNickname: privateChatMember?.nick,
      progress: { percentage: 1 },
      tempFile: file,
    } as NERoomChatMessage

    setMessages((prev) => [...prev, tempMsg])
    return tempMsg
  }

  const onSendTextMsg = useCallback(
    async (text: string) => {
      const idClient = uuid()
      const privateChatMember = privateChatHandler()
      const toAccounts = privateChatMember ? [privateChatMember.account] : []

      const res = await neMeeting?.chatController?.sendTextMessage(
        idClient,
        text,
        toAccounts,
        isSendWaitingChatroomRef.current ? 1 : 0
      )
      const msg: NERoomChatMessage | undefined = formatMessage(res?.data) as
        | NERoomChatMessage
        | undefined

      if (res?.code === 0 && msg) {
        msg.isMe = true
        msg.isPrivate = !!privateChatMember
        msg.toNickname = privateChatMember?.nick
        setMessages((prev) => [...prev, msg])
      }
    },
    [privateChatHandler, neMeeting, inWaitingRoom]
  )

  // 发送文件消息
  async function onSendFileMsg(type: string, file: FileEx, resendId?: string) {
    const chatController = neMeeting?.chatController
    const beforePrivateChatMemberId = privateChatMemberIdRef.current
    const idClient = resendId || uuid()

    // 选完文件后，如果私聊对象变了，不发送
    if (
      beforePrivateChatMemberId !== privateChatMemberIdRef.current ||
      disabledRef.current !== 0
    ) {
      return
    }

    const privateChatMember = privateChatHandler()

    resendId
      ? updateMsg(idClient, {
          status: 'sending',
        })
      : addTempMsg(file, idClient, type, privateChatMember)

    const toAccounts = privateChatMember ? [privateChatMember.account] : []

    try {
      const fileSource = file.base64 !== undefined && file.url ? file.url : file

      const res =
        type === 'file'
          ? await chatController?.sendFileMessage(
              idClient,
              fileSource,
              toAccounts,
              isSendWaitingChatroomRef.current ? 1 : 0
            )
          : await chatController?.sendImageMessage(
              idClient,
              fileSource,
              file.width ?? 0,
              file.height ?? 0,
              toAccounts,
              isSendWaitingChatroomRef.current ? 1 : 0
            )
      const msg: NERoomChatMessage | undefined = formatMessage(res?.data) as
        | NERoomChatMessage
        | undefined

      if (res?.code === 0 && msg) {
        const id = msg.messageUuid || idClient

        updateMsg(id, msg)
      } else {
        updateMsg(idClient, {
          status: 'fail',
        })
      }
    } catch {
      updateMsg(idClient, {
        status: 'fail',
      })
    }
  }

  async function recallMessage(msg: NERoomChatMessage) {
    const msgId = msg.idClient
    const time = msg.time

    return neMeeting?.chatController?.recallChatroomMessage(
      msgId,
      time,
      msg.chatroomType ?? 0
    )
  }

  async function cancelSendFileMessage(msg: NERoomChatMessage) {
    await neMeeting?.chatController?.cancelSendFileMessage(
      msg.idClient,
      msg.chatroomType
    )
    updateMsg(msg.idClient, {
      status: 'fail',
    })
  }

  async function onResend(msg: NERoomChatMessage) {
    if (msg.tempFile) {
      onSendFileMsg(msg.type, msg.tempFile, msg.idClient)
    }
  }

  function openFile(msg: NERoomChatMessage, isDir: boolean) {
    const filePath = msg.file?.filePath

    if (!filePath) {
      return
    }

    window.ipcRenderer?.send('nemeeting-open-file', {
      isDir,
      filePath,
    })

    window.ipcRenderer?.removeAllListeners('nemeeting-open-file-reply')
    window.ipcRenderer?.once('nemeeting-open-file-reply', (_, exist) => {
      if (!exist) {
        if (msg.isMe) {
          Toast.info(t('fileNotExist'))
        } else {
          Toast.info(t('fileNotExistReDownload'))
          if (msg.file) {
            updateMsg(msg.idClient, {
              file: { ...msg.file, filePath: '' },
            })
          }
        }
      }
    })
  }

  async function downloadAttachment(msg: NERoomChatMessage, path: string) {
    if (
      messagesRef.current.find(
        (item) =>
          item.idClient === msg.idClient &&
          // 可能被替换成删除的通知消息
          item.type === msg.type
      ) &&
      msg.file
    ) {
      updateMsg(msg.idClient, {
        status: 'downloading',
      })
      try {
        await neMeeting?.chatController?.downloadAttachment?.(
          msg.idClient,
          msg.file.url,
          path,
          msg.chatroomType
        )
        updateMsg(msg.idClient, {
          status: 'success',
          file: { ...msg.file, filePath: path },
        })
      } catch {
        updateMsg(msg.idClient, {
          status: 'fail',
          file: { ...msg.file, filePath: path },
        })
      }
    }
  }

  async function cancelDownloadAttachment(msg: NERoomChatMessage) {
    await neMeeting?.chatController?.cancelDownloadAttachment?.(
      msg.idClient,
      msg.chatroomType ?? 0
    )
    if (msg.file) {
      updateMsg(msg.idClient, {
        status: 'success',
        file: { ...msg.file, filePath: '' },
      })
    }
  }

  async function exportChatroomHistoryMessageList(
    meetingId?: number,
    myUuid: string = ''
  ) {
    if (neMeeting?.roomService) {
      let _meetingInfo:
        | NEMeetingInfo
        | CreateMeetingResponse
        | undefined = undefined

      try {
        _meetingInfo = meetingId
          ? await neMeeting.getMeetingInfoByMeetingId(meetingId)
          : meetingInfo
      } catch {
        //
      }

      const {
        data: url,
      } = await neMeeting.roomService.exportChatroomHistoryMessages(
        String(_meetingInfo?.meetingId || meetingId)
      )

      const blob = new Blob([url], {
        type: 'text/csv;charset=UTF-8',
      })
      const link = document.createElement('a')

      link.href = window.URL.createObjectURL(blob)
      const fileName = _meetingInfo
        ? `${_meetingInfo.subject}_${dayjs(_meetingInfo.startTime).format(
            'YYYYMMDDHHmmss'
          )}.csv`
        : exportFileName.current

      if (myUuid && window.isElectronNative) {
        link.download = `auto_save!${myUuid}!` + decodeURIComponent(fileName)
      } else {
        link.download = decodeURIComponent(fileName)
      }

      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      return
    }
  }

  async function fetchHistoryMessages(meetingId?: number) {
    const filterMessages = messagesRef.current.filter((message) =>
      ['image', 'file', 'text'].includes(message.type)
    )
    const limit = 20
    let startTime = filterMessages[0]?.time || Date.now()
    const inMeeting = !!meetingInfo.meetingNum

    const messages: NERoomChatMessage[] = []

    if (inMeeting) {
      const chatController = neMeeting?.chatController

      if (chatController) {
        startTime = startTime - 1
        // 获取等候室聊天室历史记录
        try {
          const res = await chatController.fetchChatroomHistoryMessages(
            {
              startTime: startTime,
              limit: limit,
            },
            1
          )

          if (res.code === 0 && res.data.length > 0) {
            res.data.forEach((item) => {
              messages.push(formatMessage(item))
            })
          }
        } catch (e) {
          //
          console.log('fetchChatroomHistoryMessages error', e)
        }

        try {
          const res = await chatController.fetchChatroomHistoryMessages(
            {
              startTime: startTime,
              limit: limit,
            },
            0
          )

          console.log('fetchChatroomHistoryMessages11', res)
          if (res.code === 0 && res.data.length > 0) {
            res.data.forEach((item) => {
              messages.push(formatMessage(item))
            })
          }
        } catch (e) {
          //
          console.log('fetchChatroomHistoryMessages1 error', e)
        }
      }
    } else {
      const roomService = neMeeting?.roomService

      if (roomService && meetingId) {
        try {
          const res = await roomService.fetchChatroomHistoryMessages(
            String(meetingId),
            {
              startTime,
              limit,
              order: 0,
            }
          )

          if (res.code === 0 && res.data.length > 0) {
            res.data.forEach((item) => {
              messages.push(formatMessage(item))
            })
          }
        } catch {
          //
        }
      }
    }

    messages.reverse()

    setMessages((prev) => [
      ...messages.filter((message) =>
        ['image', 'file', 'text'].includes(message.type)
      ),
      ...prev,
    ])
  }

  function clearMessages() {
    setMessages([])
  }

  function addEventListenerAtChatWindow() {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      switch (event) {
        case 'windowOpen':
        case 'updateChatRoomMessages':
        case 'updateData':
          if (
            payload.chatRoomMessages &&
            JSON.stringify(payload.chatRoomMessages) !==
              JSON.stringify(messagesRef.current)
          ) {
            messagesRef.current = payload.chatRoomMessages
            setMessages(payload.chatRoomMessages)
          }

          break
        default:
          break
      }
    }

    const chatWindow = getWindow('chatWindow')

    chatWindow?.addEventListener('message', handleMessage)

    const bulletScreenMessageWindow = getWindow('bulletScreenMessageWindow')

    bulletScreenMessageWindow?.addEventListener('message', handleMessage)
  }

  const getHostAndCohostList = useCallback(() => {
    neMeeting?.getHostAndCohostList().then(setHostOrCohostList)
  }, [neMeeting])

  const onPrivateChatMemberSelected = (id: string, auto?: boolean) => {
    if (!auto) {
      const member =
        chatRoomMemberList.find((item) => item.account === id) ||
        chatWaitingRoomMemberList.find((item) => item.account === id)

      // 等候室
      if (member || id === 'meetingAll' || id === 'waitingRoomAll') {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            privateChatMemberId: member?.account || id,
          },
        })
      } else {
        Toast.fail(t('chatMemberLeft'))
      }
    }

    setPrivateChatMemberId(() => id)
  }

  const onRemoveMember = (id) => {
    const member = chatRoomMemberList?.find((item) => item.account === id)
    const waitingRoomMember = chatWaitingRoomMemberList?.find(
      (item) => item.account === id
    )
    let isChecked = false

    if (member) {
      Modal.confirm({
        title: t('participantRemove'),
        width: 270,
        content: (
          <>
            <div>{t('participantRemoveConfirm') + member.nick}</div>
            {meetingInfo.enableBlacklist && (
              <Checkbox
                className="close-checkbox-tip"
                onChange={(e) => (isChecked = e.target.checked)}
              >
                {t('meetingNotAllowedToRejoin')}
              </Checkbox>
            )}
          </>
        ),
        onOk: async () => {
          try {
            await neMeeting?.sendHostControl(
              hostAction.remove,
              member?.account,
              isChecked
            )
          } catch (e: unknown) {
            const error = e as NECommonError

            Toast.fail(
              error.message || error.msg || t('participantFailedToRemove')
            )
          }
        },
      })
    }

    if (waitingRoomMember) {
      Modal.confirm({
        title: t('participantExpelWaitingMemberDialogTitle'),
        width: 270,
        content: meetingInfo.enableBlacklist && (
          <Checkbox
            className="close-checkbox-tip"
            onChange={(e) => (isChecked = e.target.checked)}
          >
            {t('notAllowJoin')}
          </Checkbox>
        ),
        cancelText: t('globalCancel'),
        okText: t('participantRemove'),
        onOk: async () => {
          try {
            await neMeeting?.expelMember(waitingRoomMember?.account, isChecked)
          } catch (e: unknown) {
            const error = e as NECommonError

            Toast.fail(error?.msg || error?.message)
          }
        },
      })
    }
  }

  useEffect(() => {
    if (inWaitingRoom) {
      getHostAndCohostList()
      window.addEventListener('online', getHostAndCohostList)
      return () => {
        window.removeEventListener('online', getHostAndCohostList)
      }
    }
  }, [getHostAndCohostList, inWaitingRoom])

  useEffect(() => {
    // React.18 导致问题，需要延迟设置
    setTimeout(() => {
      setPrivateChatMemberId((prev) => meetingInfo.privateChatMemberId ?? prev)
    }, 100)
  }, [
    meetingInfo.privateChatMemberId,
    meetingChatPermission,
    waitingRoomChatPermission,
  ])

  useMount(() => {
    eventEmitter?.on(EventType.ReceiveChatroomMessages, (messages) => {
      // 处理消息
      messages = messages.map(formatMessage)

      setMessages((prev) => [...prev, ...messages])

      const { rightDrawerTabActiveKey } = meetingInfoRef.current

      const chatWindow = getWindow('chatWindow')

      if (chatWindow || rightDrawerTabActiveKey === 'chatroom') {
        // 聊天室打开状态
        return
      }

      if (messages && messages.length > 0) {
        const _msgs = messages
          .filter((msg) => {
            return (
              msg &&
              ['text', 'image', 'audio', 'video', 'file'].includes(msg.type)
            )
          })
          .filter((item) => Date.now() - item.time < 3000)

        if (_msgs.length > 0) {
          eventEmitter?.emit('newMsgs', _msgs)
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              unReadChatroomMsgCount:
                (meetingInfoRef.current?.unReadChatroomMsgCount || 0) +
                _msgs.length,
            },
          })
        }
      }
    })

    eventEmitter?.on(
      EventType.WaitingRoomOnManagersUpdated,
      (data: NEMember[]) => {
        setHostOrCohostList(data)
      }
    )

    eventEmitter?.on(
      EventType.ChatroomMessageAttachmentProgress,
      (messageUuid, transferred, total) => {
        const percentage = Math.floor((transferred / total) * 100)

        if (percentage === 100) {
          updateMsg(messageUuid, {
            progress: {
              percentage,
            },
            status: 'success',
          })
        } else {
          updateMsg(messageUuid, {
            progress: {
              percentage,
            },
          })
        }
      }
    )
  })

  useEffect(() => {
    if (messages.length > 0) {
      const chatWindow = getWindow('chatWindow')
      const bulletScreenMessageWindow = getWindow('bulletScreenMessageWindow')
      const parentWindow = window.parent

      const postMessageData = {
        event: 'updateChatRoomMessages',
        payload: {
          chatRoomMessages: JSON.parse(JSON.stringify(messages)),
        },
      }

      chatWindow?.postMessage(postMessageData)
      bulletScreenMessageWindow?.postMessage(postMessageData)
      parentWindow?.postMessage(postMessageData)
    }
  }, [messages])

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      setMessages([])
    }
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      switch (event) {
        case 'windowOpen':
        case 'updateChatRoomMessages':
        case 'updateData':
          if (
            payload.chatRoomMessages &&
            JSON.stringify(payload.chatRoomMessages) !==
              JSON.stringify(messagesRef.current)
          ) {
            messagesRef.current = payload.chatRoomMessages
            setMessages(payload.chatRoomMessages)
          }

          break
        default:
          break
      }
    }

    window.addEventListener('message', handleMessage)
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  useUpdateEffect(() => {
    setMessages([])
  }, [inWaitingRoom])

  useEffect(() => {
    if (meetingInfo.subject && meetingInfo.startTime) {
      exportFileName.current = `${meetingInfo.subject}_${dayjs(
        meetingInfo.startTime
      ).format('YYYYMMDDHHmmss')}.csv`
    }
  }, [meetingInfo.subject, meetingInfo.startTime])

  return (
    <ChatRoomContext.Provider
      value={{
        messages,
        chatRoomMemberList,
        chatWaitingRoomMemberList,
        privateChatMemberId,
        disabled,
        onSendTextMsg,
        onSendFileMsg,
        onPrivateChatMemberSelected,
        onRemoveMember,
        recallMessage,
        cancelSendFileMessage,
        onResend,
        openFile,
        downloadAttachment,
        cancelDownloadAttachment,
        exportChatroomHistoryMessageList,
        addEventListenerAtChatWindow,
        fetchHistoryMessages,
        clearMessages,
      }}
    >
      {props.children}
    </ChatRoomContext.Provider>
  )
}

export const useChatRoomContext = (): ChatRoomContextType =>
  React.useContext<ChatRoomContextType>(ChatRoomContext)
