import { useUpdateEffect } from 'ahooks'
import { ActionSheet } from 'antd-mobile/es'
import { Action } from 'antd-mobile/es/components/action-sheet'
import classNames from 'classnames'
import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  ActionType,
  BrowserType,
  EventType,
  GlobalContext as GlobalContextInterface,
  NEChatPermission,
  NEClientType,
  NEMember,
  NERoomChatMessage,
  Role,
} from '../../../types'
import {
  getBrowserType,
  getClientType,
  getIosVersion,
  getUUID,
} from '../../../utils'
import UserAvatar from '../../common/Avatar'
import Toast from '../../common/toast'
import MemberListUI from '../MemberList'
import NEChatRoomUI from '../NEChatRoomUI'
import './index.less'
import { handleRecMsgService } from './service'
import ChatEmojiContent from '../NEChatRoomUI/ChatEmojiContent'
import { getEmojiPath } from '../../common/Emoji'

const fileSizeLimit = 200 * 1024 * 1024 // 单位Byte
const imgSizeLimit = 20 * 1024 * 1024 // 单位Byte

const uuid = () => {
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

interface NEChatRoomProps {
  visible: boolean
  isWaitingRoom?: boolean
  onClose: () => void
  unReadChange: (count: number) => void
  receiveMsg: NERoomChatMessage[] | undefined
}

const NEChatRoom: React.FC<NEChatRoomProps> = ({
  visible = false,
  isWaitingRoom = false,
  onClose,
  unReadChange,
  receiveMsg,
}) => {
  const { t } = useTranslation()

  const { neMeeting, eventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const { meetingInfo, memberList, dispatch } = useContext(MeetingInfoContext)
  const [selfShow, setSelfShow] = useState(false)
  const [unReadMsgs, setUnReadMsgsCount] = useState(0)
  const [msgList, setMsgList] = useState<NERoomChatMessage[]>([]) // 聊天室消息
  const [privateChatMemberId, setPrivateChatMemberId] = useState<string>() // 私聊对象
  const contentRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const [isFocus, setIsFocus] = useState(false)
  const [memberListOpen, setMemberListOpen] = useState<boolean>(false)
  const [hostOrCohostList, setHostOrCohostList] = useState<NEMember[]>([])
  const [actionSheetOpen, setActionSheetOpen] = useState<boolean>(false)
  const [avatarClickMsg, setAvatarClickMsg] = useState<NERoomChatMessage>()
  const [longPressMsg, setLongPressMsg] = useState<NERoomChatMessage>()
  const [showToBottom, setShowToBottom] = useState<boolean>(false)
  const [inputRange, setInputRange] = useState<Range>()
  const [emojiOpen, setEmojiOpen] = useState<boolean>(false)
  const emojiOpenRef = useRef(false)

  emojiOpenRef.current = emojiOpen

  const privateChatMemberIdRef = useRef(privateChatMemberId)
  const msgListRef = useRef(msgList)
  const disabledRef = useRef(0)
  const isScrolledToBottomRef = useRef(true)

  privateChatMemberIdRef.current = privateChatMemberId
  msgListRef.current = msgList

  const { localMember, meetingChatPermission, waitingRoomChatPermission } =
    meetingInfo

  const chatController = neMeeting?.chatController

  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  const privateChatContentRightText = useMemo(() => {
    if (isHostOrCoHost || isWaitingRoom) {
      return ''
    }

    if (meetingChatPermission === NEChatPermission.PUBLIC_CHAT_ONLY) {
      return t('chatPublicOnly')
    }

    if (meetingChatPermission === NEChatPermission.PRIVATE_CHAT_HOST_ONLY) {
      return t('chatPrivateHostOnly')
    }
  }, [isHostOrCoHost, meetingChatPermission, t, isWaitingRoom])

  const getHostAndCohostList = useCallback(() => {
    neMeeting?.getHostAndCohostList().then((res) => {
      setHostOrCohostList(res)
    })
  }, [neMeeting])

  const privateChatMembers = useMemo(() => {
    let _memberList: NEMember[] = []

    if (isWaitingRoom) {
      _memberList = hostOrCohostList
    } else if (isHostOrCoHost) {
      _memberList = memberList
    } else if (
      meetingChatPermission === NEChatPermission.PUBLIC_CHAT_ONLY ||
      meetingChatPermission === NEChatPermission.PRIVATE_CHAT_HOST_ONLY
    ) {
      _memberList = memberList.filter(
        (item) => item.role === Role.host || item.role === Role.coHost
      )
    } else if (meetingChatPermission === NEChatPermission.NO_CHAT) {
      _memberList = []
    } else {
      _memberList = memberList
    }

    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []

    _memberList.forEach((member) => {
      if (member.role === Role.host) {
        host.push(member)
      } else if (member.role === Role.coHost) {
        coHost.push(member)
      } else if (member.uuid === localMember.uuid) {
        // 本人永远排在主持和联席主持人之后
        return
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
    const hostOrCoHostWithMe =
      [...host, ...coHost]?.findIndex(
        (item) => item.uuid === localMember.uuid
      ) > -1
        ? [...host, ...coHost]
        : [...host, ...coHost, localMember]
    const res = [
      ...hostOrCoHostWithMe,
      ...handsUp,
      ...sharingWhiteboardOrScreen,
      ...audioAndVideoOn,
      ...videoOn,
      ...audioOn,
      ...other,
    ].filter(
      (item) =>
        item.clientType !== NEClientType.SIP &&
        item.clientType !== NEClientType.H323
    )

    return res
  }, [
    memberList,
    isWaitingRoom,
    hostOrCohostList,
    isHostOrCoHost,
    meetingChatPermission,
    localMember,
  ])

  const actions: Action[] = useMemo(() => {
    const disabled =
      privateChatMembers.findIndex(
        (item) => item.uuid === avatarClickMsg?.from
      ) === -1

    return [
      {
        text: (
          <span style={{ color: disabled ? '#999' : undefined }}>
            {t('chatPrivate')}
          </span>
        ),
        key: 'chatPrivate',
        onClick: () => {
          if (disabled) {
            Toast.fail(t('chatMemberLeft'))
          } else {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                privateChatMemberId: avatarClickMsg?.from,
              },
            })
          }

          setActionSheetOpen(false)
        },
      },
    ]
  }, [avatarClickMsg, privateChatMembers, t, dispatch])

  // 0 可以发送消息 1 全体禁言 2 没有成员可以说 3 等待室禁言
  const disabled = useMemo(() => {
    if (isHostOrCoHost) {
      return 0
    } else {
      if (isWaitingRoom) {
        if (waitingRoomChatPermission === 0) {
          return 3
        } else if (
          privateChatMembers.filter((item) =>
            [Role.host, Role.coHost].includes(item.role as Role)
          ).length === 0
        ) {
          return 2
        } else {
          return 0
        }
      } else {
        if (meetingChatPermission === 4) {
          return 1
        } else if (
          meetingChatPermission === NEChatPermission.PRIVATE_CHAT_HOST_ONLY &&
          privateChatMembers.filter((item) =>
            [Role.host, Role.coHost].includes(item.role as Role)
          ).length === 0
        ) {
          return 2
        }
      }
    }

    return 0
  }, [
    isHostOrCoHost,
    meetingChatPermission,
    isWaitingRoom,
    privateChatMembers,
    waitingRoomChatPermission,
  ])

  disabledRef.current = disabled

  useUpdateEffect(() => {
    if (meetingInfo.privateChatMemberId === undefined) {
      setPrivateChatMemberId('meetingAll')
    } else {
      setPrivateChatMemberId(meetingInfo.privateChatMemberId)
    }
  }, [
    meetingInfo.privateChatMemberId,
    meetingInfo.meetingChatPermission,
    privateChatMembers,
  ])

  useUpdateEffect(() => {
    const disabled =
      privateChatMembers.findIndex(
        (item) => item.uuid === avatarClickMsg?.from
      ) === -1

    if (localMember.role === Role.member && disabled) {
      setActionSheetOpen(false)
    }
  }, [localMember.role, privateChatMembers])

  useEffect(() => {
    if (contentRef.current) {
      const lastMsg = msgList[msgList.length - 1]

      if (isScrolledToBottomRef.current || lastMsg?.isMe) {
        setTimeout(
          () => {
            scrollToBottom()
          },
          lastMsg?.type === 'image' ? 100 : 0
        )
      } else {
        setShowToBottom(true)
      }
    }
  }, [msgList.length])

  const chatroomUIProps = {
    msgs: msgList,
  }

  useEffect(() => {
    receiveMsg && onReceiveMsgs(receiveMsg)
    // eslint-disable-next-line
  }, [receiveMsg])

  useEffect(() => {
    setSelfShow(visible)
    if (visible) {
      unReadChange?.(0)
      setUnReadMsgsCount(0)
    } else {
      unReadChange?.(unReadMsgs)
    }
  }, [visible, unReadMsgs, unReadChange])

  useEffect(() => {
    isWaitingRoom && visible && getHostAndCohostList()
  }, [isWaitingRoom, getHostAndCohostList, visible])

  useEffect(() => {
    if (!visible) {
      setEmojiOpen(false)
    }
  }, [visible])

  const bottomClassName = useMemo(() => {
    // ios15需要特殊处理浏览器地址栏在底部并且会覆盖输入框
    if (
      getClientType() === 'IOS' &&
      getIosVersion() === '15.0' &&
      getBrowserType() != BrowserType.WX
    ) {
      if (isFocus) {
        return 'ne-chatroom-footer-bottom50'
      } else {
        // 失去焦时，整个界面不会随着键盘滚动到底部需要手动滚动下
        window.scrollBy(0, 1)
      }
    }

    return 'ne-chatroom-footer-bottom0'
  }, [isFocus])

  const onCloseClick = () => {
    onClose?.()
  }

  function onDeleteMsg(msg: NERoomChatMessage): boolean {
    if (
      msg.type === 'notification' &&
      msg.attach?.type === 'deleteChatroomMsg'
    ) {
      const _msg = msgList.find((item) => item.idClient === msg.attach?.msgId)

      if (_msg) {
        const index = msgList.findIndex(
          (item) => item.idClient === msg.attach?.msgId
        )

        if (index > -1) {
          msgList[index] = {
            ...msg,
            idClient: msg.attach.msgId,
            time: msg.attach.msgTime,
            isMe: _msg.isMe,
            fromNick: _msg.fromNick,
          }
          setMsgList([...msgList])
        }
      }

      return true
    }

    return false
  }

  // 接受消息
  function onReceiveMsgs(data: NERoomChatMessage[]) {
    console.log('onReceiveMsgs', data)
    const messages = data
    const type = messages[0].attach && messages[0].attach.type
    const updateListType = [
      'memberExit',
      'memberEnter',
      'kickMember',
      'updateChatroom',
    ]

    handleRecMsg(messages.filter((msg) => !onDeleteMsg(msg)))
    if (type && updateListType.includes(type)) {
      getMembers()
    }
  }

  function updateMsg(id: string, msg: Partial<NERoomChatMessage>) {
    const msgList = msgListRef.current
    const index = msgList.findIndex((item) => item.idClient === id)

    if (index !== -1) {
      const _msg = msgList[index]

      msgList[index] = {
        ..._msg,
        ...msg,
      }
      setMsgList([...msgList])
    }
  }

  async function inputFile(type: 'image' | 'file'): Promise<File> {
    return new Promise((resolve, reject) => {
      const fileInput = document.createElement('input')

      fileInput.type = 'file'
      const accept =
        type === 'image'
          ? '.jpg,.png,.jpeg,.bmp'
          : '.mp3,.aac,.wav,.pcm,.mp4,.flv,.mov,.doc,.docx,.xls,.xlsx,.ppt,.pdf,.zip,.7z,.biz,.tar,.txt,.apk,.ipa,.jpg,.png,.jpeg,.bmp'

      fileInput.accept = accept
      fileInput.onchange = (e) => {
        const file = (e.target as HTMLInputElement).files?.[0]

        if (file) {
          const ext = file.name && file.name.split('.').pop()?.toLowerCase()

          if (ext && !accept.includes(ext)) {
            Toast.fail(t('fileTypeNotSupport'))
            reject()
          }

          if (type === 'file' && file.size > fileSizeLimit) {
            Toast.fail(t('chatFileSizeExceedTheLimit'))
            reject()
          }

          if (type === 'image' && file.size > imgSizeLimit) {
            Toast.fail(t('chatImageSizeExceedTheLimit'))
            reject()
          }

          resolve(Object.assign(file, { url: URL.createObjectURL(file) }))
        }

        fileInput.parentElement?.removeChild(fileInput)
      }

      document.body.appendChild(fileInput)
      fileInput.click()
    })
  }

  function addTempMsg(
    file: File,
    idClient: string,
    type: string,
    privateChatMember?: NEMember
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
        url: URL.createObjectURL(file),
        name: file.name,
      },
      type,
      isMe: true,
      fromNick: localMember.name,
      fromAvatar: localMember.avatar,
      time: Date.now(),
      text: '',
      from: localMember.uuid,
      toNickname: privateChatMember?.name,
    } as NERoomChatMessage

    setMsgList((prev) => [...prev, tempMsg])
    return tempMsg
  }

  // 发送文件消息
  async function onSendFileMsg(
    type: 'image' | 'file',
    resendMsg?: NERoomChatMessage
  ) {
    const beforePrivateChatMemberId = privateChatMemberIdRef.current
    const idClient = resendMsg?.idClient || uuid()
    const file = resendMsg?.tempFile
      ? resendMsg.tempFile
      : await inputFile(type)

    // 选完文件后，如果私聊对象变了，不发送
    if (
      beforePrivateChatMemberId !== privateChatMemberIdRef.current ||
      disabledRef.current !== 0
    ) {
      return
    }

    const privateChatMember = getPrivateChat()

    resendMsg
      ? updateMsg(idClient, {
          status: 'sending',
        })
      : addTempMsg(file, idClient, type, privateChatMember)

    const toAccounts = privateChatMember ? [privateChatMember.uuid] : []

    try {
      const res =
        type === 'file'
          ? await chatController?.sendFileMessage(
              idClient,
              file,
              toAccounts,
              isWaitingRoom ? 1 : 0
            )
          : await chatController?.sendImageMessage(
              idClient,
              file,
              0,
              0,
              toAccounts,
              isWaitingRoom ? 1 : 0
            )
      const msg: NERoomChatMessage | undefined = res?.data as
        | NERoomChatMessage
        | undefined

      if (res?.code === 0 && msg) {
        // type === 'image' && Object.assign(msg, { file })
        updateMsg(msg.messageUuid || idClient, msg)
      } else {
        updateMsg(idClient, {
          status: 'failed',
          tempFile: file,
        })
      }
    } catch {
      updateMsg(idClient, {
        status: 'failed',
        tempFile: file,
      })
    }
  }

  function getPrivateChat(): NEMember | undefined {
    if (privateChatMemberIdRef.current === 'meetingAll') {
      return
    }

    return privateChatMembers.find(
      (item) => item.uuid === privateChatMemberIdRef.current
    )
  }

  async function onSendTextMsg() {
    if (!inputRef.current) {
      return
    }

    const nodes = Array.from(inputRef.current.childNodes) as HTMLImageElement[]

    let msgStr = ''

    // 需要根据图片节点拆分消息发送
    nodes.forEach((node) => {
      // 文本节点
      if (node.nodeType === 3) {
        msgStr += node.nodeValue
      } else if (node.nodeName === 'IMG') {
        const emojiText = node.getAttribute('data-emoji')

        if (emojiText) {
          msgStr += emojiText
        }
      } else if (node.innerText) {
        // 其他节点
        msgStr += node.innerText
      }
    })

    if (!(msgStr && msgStr.trim())) {
      Toast.fail(t('chatCannotSendBlankLetter'))
      return
    }

    if (msgStr.length > 5000) {
      // 发送完消息，失去焦点
      inputRef.current?.blur()
      Toast.fail(t('messageLengthLimit'))
      return
    }

    const idClient = getUUID()
    const privateChatMember = getPrivateChat()
    const toAccounts = privateChatMember ? [privateChatMember.uuid] : []
    const res = await chatController?.sendTextMessage(
      idClient,
      msgStr,
      toAccounts,
      isWaitingRoom ? 1 : 0
    )
    const msg: NERoomChatMessage | undefined = res?.data as
      | NERoomChatMessage
      | undefined

    if (res?.code === 0 && msg) {
      msg.isMe = true
      msg.isPrivate = !!privateChatMember
      msg.toNickname = privateChatMember?.name
      setMsgList((prev) => [...prev, msg])
    }

    inputRef.current.innerHTML = ''
    // 发送完消息，失去焦点
    inputRef.current?.blur()
  }

  // 重发消息
  const onResendMsg = async (msg: NERoomChatMessage) => {
    if (msg.idClient) {
      if (msg.type === 'file') {
        await onSendFileMsg('file', msg)
      } else if (msg.type === 'image') {
        await onSendFileMsg('image', msg)
      }
    }
  }

  // 处理收到的消息
  function handleRecMsg(newMsgs: NERoomChatMessage[]) {
    const oldMsgs = [...msgList]
    const { msgs, unReadMsgsCount } = handleRecMsgService(newMsgs)

    setUnReadMsgsCount(unReadMsgsCount + unReadMsgs)
    const msgArr = [...oldMsgs, ...msgs]

    setMsgList(msgArr)
  }

  function onHandleFocus() {
    setIsFocus(true)
    setTimeout(() => {
      if (emojiOpenRef.current) {
        inputRef.current?.blur()
      }
    })
  }

  function onHandleBlur() {
    try {
      const range = window.getSelection()?.getRangeAt(0)

      setInputRange(range)
    } catch {
      // getRangeAt 可能异常
    }

    setIsFocus(false)
  }

  // 获取在线人数
  function getMembers() {
    if (!neMeeting?.chatController) {
      console.error('not init chatroom')
      return
    }

    const MyAccid = localMember.uuid
    let members = memberList

    members = members.filter(
      (item) => item.isInChatroom && item.uuid !== MyAccid
    )
    return members
  }

  const onRevokeMsg = async (msg: NERoomChatMessage) => {
    if (msg.idClient && msg.status === 'success') {
      await chatController?.recallChatroomMessage(
        msg.idClient,
        msg.time,
        msg.chatroomType
      )
    }
  }

  const onAvatarClick = (msg: NERoomChatMessage) => {
    if (msg.isMe) {
      return
    }

    const uuid = msg.from
    const member = privateChatMembers.find((item) => item.uuid === uuid)
    let actionSheetOpen = false

    if (isWaitingRoom && waitingRoomChatPermission !== 0) {
      if (member) {
        actionSheetOpen = true
      }
    } else {
      if (meetingChatPermission === NEChatPermission.FREE_CHAT) {
        actionSheetOpen = true
      } else if (member) {
        actionSheetOpen = true
      }
    }

    if (actionSheetOpen) {
      setAvatarClickMsg(msg)
    }

    setActionSheetOpen(actionSheetOpen)
  }

  const onScroll = () => {
    setLongPressMsg(undefined)
    if (contentRef.current) {
      const { clientHeight, scrollHeight, scrollTop } = contentRef.current

      isScrolledToBottomRef.current =
        scrollHeight - clientHeight <= scrollTop + 10
      if (isScrolledToBottomRef.current) {
        setShowToBottom(false)
      }
    }
  }

  const scrollToBottom = () => {
    if (contentRef.current) {
      contentRef.current.scrollTop = contentRef.current.scrollHeight
      isScrolledToBottomRef.current = true
      setShowToBottom(false)
    }
  }

  useUpdateEffect(() => {
    visible && scrollToBottom()
  }, [visible])

  useEffect(() => {
    function handleManagersUpdated(data: NEMember[]) {
      setHostOrCohostList(data)
    }

    eventEmitter?.on(
      EventType.WaitingRoomOnManagersUpdated,
      handleManagersUpdated
    )
    return () => {
      eventEmitter?.off(
        EventType.WaitingRoomOnManagersUpdated,
        handleManagersUpdated
      )
    }
  }, [eventEmitter])

  useEffect(() => {
    window.addEventListener('online', getHostAndCohostList)
    return () => {
      window.removeEventListener('online', getHostAndCohostList)
    }
  }, [getHostAndCohostList])

  const renderPrivateChat = () => {
    let privateChatLabel = isWaitingRoom ? t('chatPrivate') : t('chatSendTo')
    let privateUser

    // 不在等候室，且是主持人或权限不是私聊主持人，且私聊对象是所有人
    if (
      !isWaitingRoom &&
      (isHostOrCoHost ||
        meetingChatPermission !== NEChatPermission.PRIVATE_CHAT_HOST_ONLY) &&
      privateChatMemberId === 'meetingAll'
    ) {
      privateUser = (
        <div className="private-user">
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconsuoyouren-24px"></use>
          </svg>
          <span className="private-user-name">
            {t('chatAllMembersInMeeting')}
          </span>
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#icona-xialajiantou-xianxing-14px1"></use>
          </svg>
        </div>
      )
    } else {
      privateChatLabel = t('chatPrivate')
      const privateMember = privateChatMembers?.find(
        (item) => item.uuid === privateChatMemberId
      )

      if (!privateMember) {
        // 如果在等候室，或者不是主持人，且权限是私聊主持人。 选择第一个人
        if (
          isWaitingRoom ||
          (!isHostOrCoHost &&
            meetingChatPermission === NEChatPermission.PRIVATE_CHAT_HOST_ONLY)
        ) {
          privateChatMembers[0]?.uuid &&
            setPrivateChatMemberId(privateChatMembers[0].uuid)
        } else {
          setPrivateChatMemberId('meetingAll')
        }

        return null
      } else {
        privateUser = (
          <div className="private-user">
            <UserAvatar
              size={22}
              nickname={privateMember.name}
              avatar={privateMember.avatar}
            />
            <span className="private-user-name">{privateMember.name}</span>
            <span>
              {privateMember.role === Role.host ? `(${t('host')})` : null}
              {privateMember.role === Role.coHost ? `(${t('coHost')})` : null}
            </span>
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#icona-xialajiantou-xianxing-14px1"></use>
            </svg>
          </div>
        )
      }
    }

    return (
      <div className="private-chat-content">
        <div
          className="private-chat-content-left"
          onClick={() => {
            getHostAndCohostList()
            setMemberListOpen(true)
          }}
        >
          <div className="private-label">{privateChatLabel}</div>
          {privateUser}
        </div>
        <div className="private-chat-content-right">
          {privateChatContentRightText}
        </div>
      </div>
    )
  }

  return (
    <div
      className={`ne-meeting-chatroom ${selfShow ? 'show' : ''}`}
      onClick={onCloseClick}
    >
      <div
        className={`ne-chatroom-body ${selfShow ? 'show' : ''}`}
        onClick={(e) => {
          e.stopPropagation()
        }}
      >
        <div className="ne-chatroom-header">
          <span className="chatroom-icon-close" onClick={onCloseClick}>
            {t('globalClose')}
          </span>
          <span className="title">{t('chat')}</span>
        </div>
        <div
          className="ne-chatroom-content"
          ref={contentRef}
          onScroll={onScroll}
        >
          <NEChatRoomUI
            {...chatroomUIProps}
            longPressMsg={longPressMsg}
            onRevokeMsg={onRevokeMsg}
            onResendMsg={onResendMsg}
            onAvatarClick={onAvatarClick}
            onLongPress={setLongPressMsg}
          />
          {visible && showToBottom && (
            <div
              className="ne-chatroom-to-bottom"
              onClick={() => scrollToBottom()}
            >
              ↓ {t('newMessage')}
            </div>
          )}
        </div>
        {disabled !== 0 ? (
          <div className="ne-chatroom-footer-disabled-content">
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconjinyan"></use>
            </svg>
            <span>
              {
                [
                  '',
                  t('chatHostMutedEveryone'),
                  t('chatHostLeft'),
                  t('chatWaitingRoomMuted'),
                ][disabled]
              }
            </span>
          </div>
        ) : null}
        <div
          className={classNames('ne-chatroom-footer', bottomClassName, {
            ['ne-chatroom-footer-disabled']: disabled !== 0,
          })}
        >
          {renderPrivateChat()}
          <div className="chat-input-wrapper">
            <svg
              className="icon iconfont"
              aria-hidden="true"
              onClick={() => onSendFileMsg('image')}
            >
              <use xlinkHref="#icontupian1"></use>
            </svg>
            <svg
              className="icon iconfont"
              aria-hidden="true"
              onClick={() => onSendFileMsg('file')}
            >
              <use xlinkHref="#iconwenjian1"></use>
            </svg>
            <div className="ne-chatroom-input-container">
              <div
                ref={inputRef}
                contentEditable
                className="ne-chatroom-input"
                data-placeholder={t('chatInputMessageHint')}
                onFocus={onHandleFocus}
                onBlur={onHandleBlur}
                // @ts-expect-error enterKeyHint
                enterKeyHint="send"
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    onSendTextMsg()
                  }
                }}
                onClickCapture={() => {
                  setEmojiOpen(false)
                  emojiOpenRef.current = false
                }}
              />
            </div>
            <svg
              className="icon iconfont"
              aria-hidden="true"
              onClick={() => {
                setEmojiOpen((pre) => {
                  if (pre) {
                    inputRef.current?.focus()
                  }

                  return !pre
                })
              }}
            >
              <use
                xlinkHref={emojiOpen ? '#iconjianpan' : '#iconbiaoqing'}
              ></use>
            </svg>
          </div>
          {emojiOpen ? (
            <ChatEmojiContent
              inputDom={inputRef.current}
              onSendTextMsg={onSendTextMsg}
              onClick={(emojiKey) => {
                let range = inputRange

                if (!range) {
                  inputRef.current?.focus()
                  range = window.getSelection()?.getRangeAt(0)
                  inputRef.current?.blur()
                }

                const image = new Image()

                image.src = getEmojiPath(emojiKey) ?? ''

                image.style.width = '20px'
                image.style.margin = '0 1px 0 0'
                image.style.verticalAlign = 'text-bottom'
                image.setAttribute('data-emoji', emojiKey)

                const selection = window.getSelection()

                if (range) {
                  range.deleteContents()
                  range.insertNode(image)
                  // // 设置光标位置到图片之后
                  range.setStartAfter(image)
                  // 开始和结束关闭合并
                  range.collapse(true)
                  // 删除所有range进行重置
                  selection?.removeAllRanges()
                  // 重新添加回最新range
                  selection?.addRange(range)

                  inputRef.current?.blur()
                }

                image.scrollIntoView()
              }}
            />
          ) : null}
        </div>
      </div>
      <ActionSheet
        extra={avatarClickMsg?.fromNick}
        cancelText={t('globalCancel')}
        visible={actionSheetOpen}
        actions={actions}
        getContainer={null}
        onClose={() => setActionSheetOpen(false)}
      />
      {disabled === 0 ? (
        <MemberListUI
          visible={memberListOpen}
          isPrivateChat
          onClose={() => setMemberListOpen(false)}
          memberList={privateChatMembers}
          privateChatMemberId={privateChatMemberId}
          privateChatAll={
            isHostOrCoHost ||
            (!isWaitingRoom &&
              meetingChatPermission !== NEChatPermission.PRIVATE_CHAT_HOST_ONLY)
          }
        />
      ) : null}
    </div>
  )
}

export default NEChatRoom
