import {
  ChatroomHelper,
  render,
  unmountComponentAtNode,
} from '@xkit-yx/kit-chatroom-web'
import { Message } from '@xkit-yx/kit-chatroom-web/es/Chatroom/chatroomHelper'
import '@xkit-yx/kit-chatroom-web/es/Chatroom/style/index.css'
import EventEmitter from 'eventemitter3'
import { NERoomService } from 'neroom-web-sdk'
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import EmptyViewMsgImage from '../../../assets/empty-view-msg.png'
import NEMeetingService from '../../../services/NEMeeting'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  ActionType,
  EventType,
  NEMeetingInfo,
  NEMember,
  Role,
  UserEventType,
} from '../../../types'
import Modal from '../../common/Modal'
import './index.less'

export interface ChatroomProps {
  isWaitingRoom?: boolean
  className?: string
  subject?: string
  startTime?: number
  memberList?: NEMember[]
  meetingInfo?: NEMeetingInfo
  waitingRoomInfo?: {
    memberCount: number
    isEnabledOnEntry: boolean
    unReadMsgCount?: number
  }
  neMeeting?: NEMeetingService
  eventEmitter?: EventEmitter
  roomArchiveId?: string
  roomService?: NERoomService
  // 会前预览历史
  isViewHistory?: boolean
  accountId?: string
  visible: boolean
}
const Chatroom: React.FC<ChatroomProps> = (props) => {
  const {
    memberList: initMemberList,
    meetingInfo: initMeetingInfo,
    neMeeting: initNeMeeting,
    waitingRoomInfo: initWaitingRoomInfo,
    eventEmitter: initEventEmitter,
    visible,
    subject,
    startTime,
    roomArchiveId,
    isViewHistory,
    roomService,
    accountId,
    isWaitingRoom,
  } = props
  const { t } = useTranslation()
  const { neMeeting: neMeetingContext, eventEmitter: eventEmitterContext } =
    useGlobalContext()
  const { waitingRoomInfo: waitingRoomInfoContext } = useWaitingRoomContext()
  const {
    memberList: memberListContext,
    meetingInfo: meetingInfoContext,
    dispatch,
  } = useMeetingInfoContext()

  const { i18n } = useTranslation()
  const chatroomRef = useRef<any>(null)
  const isMountedRef = useRef(false)
  const visibleRef = useRef(false)
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  const memberListRef = useRef<NEMember[] | null>(null)

  let language = 'en' as 'en' | 'zh' | 'ja'
  if (i18n.language.startsWith('zh')) {
    language = 'zh'
  } else if (i18n.language.startsWith('ja')) {
    language = 'ja'
  }

  const [waitingRoomInfo, setWaitingRoomInfo] = useState(
    initWaitingRoomInfo || waitingRoomInfoContext
  )

  const [memberList, setMemberList] = useState(
    initMemberList || memberListContext
  )
  const [meetingInfo, setMeetingInfo] = useState(
    initMeetingInfo || meetingInfoContext
  )

  meetingInfoRef.current = meetingInfo
  memberListRef.current = memberList

  useEffect(() => {
    setMemberList(initMemberList || memberListContext)
  }, [initMemberList, memberListContext])

  useEffect(() => {
    setMeetingInfo(initMeetingInfo || meetingInfoContext)
  }, [initMeetingInfo, meetingInfoContext])

  useEffect(() => {
    setWaitingRoomInfo(initWaitingRoomInfo || waitingRoomInfoContext)
  }, [initWaitingRoomInfo, waitingRoomInfoContext])

  const neMeeting = initNeMeeting || neMeetingContext
  const eventEmitter = initEventEmitter || eventEmitterContext

  useEffect(() => {
    visibleRef.current = visible
  }, [visible])

  const isWaitingRoomEnabled =
    waitingRoomInfo.memberCount > 0 &&
    (meetingInfo.localMember.role === Role.host ||
      meetingInfo.localMember.role === Role.coHost)

  useEffect(() => {
    let imagePreviewMsg: Message | undefined
    let attachmentProgressMessageIds: string[] = []
    const stopPropagationFn = (e) => {
      e.stopPropagation()
    }
    if (
      ((isWaitingRoom || neMeeting?.chatController?.isSupported) &&
        !meetingInfo.localMember.hide) ||
      roomArchiveId
    ) {
      render(chatroomRef.current, {
        language,
        ownerUserUuid: meetingInfo.ownerUserUuid,
        isWaitingRoomEnabled,
        isWaitingRoom,
        viewHistoryEmptyImage: EmptyViewMsgImage,
        roomName: meetingInfo.subject || subject,
        roomStartTime: meetingInfo.startTime || startTime,
        role: meetingInfo.localMember.role,
        isRooms: meetingInfo.isRooms,
        isViewHistory,
        nim: neMeeting?.imInfo?.nim,
        chatroomController: neMeeting?.chatController,
        roomService: neMeeting?.roomService || roomService,
        roomArchiveId: meetingInfo.roomArchiveId || roomArchiveId,
        memberList: chatroomMemberList,
        appKey: neMeeting?.imInfo?.imAppKey || '',
        token: neMeeting?.imInfo?.imToken || '',
        chatroomId: neMeeting?.imInfo?.chatRoomId || '',
        avatar: meetingInfo.localMember.avatar,
        account:
          neMeeting?.imInfo?.imAccid ||
          meetingInfo.localMember.uuid ||
          accountId ||
          '',
        nickName: meetingInfo.localMember.name,
        imPrivateConf: {},
        ...meetingInfo.chatroomConfig,
        onFocus: (e) => {
          if (!meetingInfo.enableUnmuteBySpace) {
            return
          }
          // 获取焦点后阻止长安空格的监听事件
          document.addEventListener('keydown', handleFocused, true)
          document.addEventListener('keyup', handleFocused, true)
        },
        onBlur: (e) => {
          if (!meetingInfo.enableUnmuteBySpace) {
            return
          }
          // 移除阻止长安空格的监听事件
          document.removeEventListener('keydown', handleFocused, true)
          document.removeEventListener('keyup', handleFocused, true)
        },
        onImagePreview: (visible, msg: Message) => {
          if (visible) {
            imagePreviewMsg = msg
            document.addEventListener('contextmenu', stopPropagationFn, true)
          } else {
            imagePreviewMsg = undefined
            document.removeEventListener('contextmenu', stopPropagationFn, true)
          }
        },
        onMsg: (msgs) => {
          // 隐藏聊天室的情况增加未读数
          if (!visibleRef.current) {
            if (msgs && msgs.length > 0) {
              const _msgs = msgs.filter((msg) => {
                return (
                  msg &&
                  ['text', 'image', 'audio', 'video', 'file'].includes(msg.type)
                )
              })
              _msgs.length > 0 && eventEmitter?.emit('newMsgs', _msgs)
            }
            const filterMsgs = msgs
              .filter((item) => ['text', 'image', 'file'].includes(item.type))
              .filter((item) => Date.now() - item.time < 3000)
            if (filterMsgs.length) {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  unReadChatroomMsgCount:
                    (meetingInfoRef.current?.unReadChatroomMsgCount || 0) +
                    filterMsgs.length,
                },
              })
            }
          }
        },
        onMyMessageList: (msgs) => {
          window.ipcRenderer?.send('nemeeting-sharing-screen', {
            method: 'chatroomMyMessageList',
            data: JSON.parse(JSON.stringify(msgs)),
          })
        },
        onMessageRemove: (msg) => {
          window.ipcRenderer?.send('nemeeting-sharing-screen', {
            method: 'chatroomRemoveMessage',
            data: JSON.parse(JSON.stringify(msg)),
          })
        },
        isChangeTimePosition: true,
      })
    }
    eventEmitter?.on(EventType.ReceiveChatroomMessages, (messages) => {
      console.log('ReceiveChatroomMessages', messages)
      messages.forEach((element) => {
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
        if (element.type === 'notification' && element.attach) {
          if (!element.attach.fromNick) {
            element.attach.fromNick = memberListRef.current?.find(
              (item) => item.uuid === element.attach.from
            )?.name
          }
          element.attach.isMe =
            element.attach.from === meetingInfoRef.current?.localMember.uuid
          if (
            element.attach.type === 'deleteChatroomMsg' &&
            (imagePreviewMsg?.idClient === element.attach.msgId ||
              attachmentProgressMessageIds.includes(element.attach.msgId)) &&
            visibleRef.current
          ) {
            Modal.warning({
              title: i18n.t('messageRecalled'),
              width: 200,
              okText: i18n.t('ok'),
            })
          }
        }
        if (!element.status) {
          element.status = 'success'
        }
      })

      const filterMsgs = messages.filter((item) => {
        return (
          ['text', 'image', 'audio', 'video', 'file'].includes(item.type) ||
          (item.type === 'notification' &&
            item.attach?.type === 'deleteChatroomMsg')
        )
      })
      filterMsgs.length > 0 &&
        (ChatroomHelper as any).getInstance().emit('onMessage', filterMsgs)
    })
    eventEmitter?.on(
      EventType.ChatroomMessageAttachmentProgress,
      (messageUuid, transferred, total) => {
        if (total > transferred) {
          attachmentProgressMessageIds.push(messageUuid)
        } else {
          attachmentProgressMessageIds = attachmentProgressMessageIds.filter(
            (item) => item !== messageUuid
          )
        }
        ;(ChatroomHelper as any)
          .getInstance()
          .emit('onMessageAttachmentProgress', messageUuid, transferred, total)
      }
    )
    isMountedRef.current = true

    window.ipcRenderer?.on('nemeeting-sharing-screen', (_, value) => {
      const { method, data } = value
      if (method === 'chatroomMyMessageList') {
        ;(ChatroomHelper as any).getInstance().emit('onMessageNoEmit', data)
      }
      if (method === 'chatroomRemoveMessage') {
        ;(ChatroomHelper as any).getInstance().emit('onMessageRemove', data)
      }
      if (method === 'openChatRoom') {
        visibleRef.current = true
      }
      if (method === 'closeChatRoom') {
        visibleRef.current = false
      }
    })

    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages)
      eventEmitter?.off(EventType.ChatroomMessageAttachmentProgress)
      chatroomRef.current && unmountComponentAtNode(chatroomRef.current)
    }
  }, [])

  const chatroomMemberList = useMemo(() => {
    const members = memberList.filter(
      (member) => member.uuid != meetingInfo.myUuid
    )
    return members.map((member) => {
      return {
        tags: [],
        account: member.uuid,
        nick: member.name,
      }
    })
  }, [memberList])

  useEffect(() => {
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit('onVisibleChange', visible)
    }
  }, [visible])

  useEffect(() => {
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit('onWaitingRoomEnable', isWaitingRoomEnabled)
    }
  }, [isWaitingRoomEnabled])

  useEffect(() => {
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onMemberRoleChange',
        meetingInfo.localMember.role
      )
    }
  }, [meetingInfo.localMember.role])

  useEffect(() => {
    // 更新聊天室内本端昵称
    // 更新聊天室内成员列表
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit('onMembersUpdate', chatroomMemberList)
    }
  }, [chatroomMemberList])

  useEffect(() => {
    // 更新聊天室内本端昵称
    if (isMountedRef.current && ChatroomHelper.instance) {
      ;(ChatroomHelper as any)
        .getInstance()
        .emit('onMyNameChanged', meetingInfo.localMember.name)
    }
  }, [meetingInfo.localMember.name])

  useEffect(() => {
    // 更新聊天室内多语言
    if (isMountedRef.current && ChatroomHelper.instance) {
      ;(ChatroomHelper as any).getInstance().emit('onLanguageChange', language)
    }
  }, [language])

  const handleFocused = useCallback((e) => {
    const keyNum = window.event ? e.keyCode : e.which
    if (keyNum === 32) {
      e.stopPropagation()
    }
  }, [])

  useEffect(() => {
    return () => {
      if (ChatroomHelper.instance && isMountedRef.current) {
        ChatroomHelper.instance.emit('onVisibleChange', false)
      }
    }
  }, [])

  useEffect(() => {
    function handle() {
      if (ChatroomHelper.instance && isMountedRef.current) {
        ChatroomHelper.instance.emit('onMessagesClear')
      }
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          unReadChatroomMsgCount: 0,
        },
      })
    }
    handle()
  }, [meetingInfo.roomArchiveId])

  return <div ref={chatroomRef} className="nemeeting-chatroom-wrapper" />
}

export default Chatroom
