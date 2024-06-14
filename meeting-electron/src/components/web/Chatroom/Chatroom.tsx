import {
  ChatroomHelper,
  render,
  unmountComponentAtNode,
} from '@xkit-yx/kit-chatroom-web'
import { Message } from '@xkit-yx/kit-chatroom-web/es/Chatroom/chatroomHelper'
import '@xkit-yx/kit-chatroom-web/es/Chatroom/style/index.css'
import { useUpdateEffect } from 'ahooks'
import { Checkbox } from 'antd'
import EventEmitter from 'eventemitter3'
import { NERoomService } from 'neroom-web-sdk'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
import React, {
  Dispatch,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
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
  hostAction,
  NEClientType,
  NEMeetingInfo,
  NEMember,
  Role,
} from '../../../types'
import { getWindow } from '../../../utils/windowsProxy'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import './index.less'

let cacheMsgs: Message[] = []

const setCacheMsgs = (msgs: Message[]): void => {
  cacheMsgs = msgs
}

export { cacheMsgs, setCacheMsgs }

export interface ChatroomProps {
  isWaitingRoom?: boolean
  className?: string
  subject?: string
  startTime?: number
  memberList?: NEMember[]
  hostOrCohostList?: NEMember[]
  meetingInfo?: NEMeetingInfo
  waitingRoomMemberList?: NEWaitingRoomMember[]
  waitingRoomInfo?: {
    memberCount: number
    isEnabledOnEntry: boolean
    unReadMsgCount?: number
  }
  neMeeting?: NEMeetingService
  eventEmitter?: EventEmitter
  roomArchiveId?: number
  roomService?: NERoomService
  // 会前预览历史
  isViewHistory?: boolean
  accountId?: string
  visible: boolean
  initMsgs?: Message[]
  meetingInfoDispatch?: Dispatch<any>
}
const Chatroom: React.FC<ChatroomProps> = (props) => {
  const {
    memberList: initMemberList,
    meetingInfo: initMeetingInfo,
    neMeeting: initNeMeeting,
    waitingRoomMemberList: initWaitingRoomMemberList,
    eventEmitter: initEventEmitter,
    initMsgs,
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
  const { memberList: waitingRoomMemberListContext } = useWaitingRoomContext()
  const {
    memberList: memberListContext,
    meetingInfo: meetingInfoContext,
    dispatch: dispatchContext,
  } = useMeetingInfoContext()

  const { i18n } = useTranslation()
  const chatroomRef = useRef<any>(null)
  const isMountedRef = useRef(false)
  const visibleRef = useRef(false)
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  const memberListRef = useRef<NEMember[] | null>(null)
  const waitingRoomMemberListRef = useRef<NEWaitingRoomMember[]>()
  const isElectronSharingScreenRef = useRef(false)
  const [hostOrCohostList, setHostOrCohostList] = useState<NEMember[]>([])

  let language = 'en' as 'en' | 'zh' | 'ja'

  if (i18n.language.startsWith('zh')) {
    language = 'zh'
  } else if (i18n.language.startsWith('ja')) {
    language = 'ja'
  }

  const meetingInfo = initMeetingInfo || meetingInfoContext
  const memberList = initMemberList || memberListContext
  const waitingRoomMemberList =
    initWaitingRoomMemberList || waitingRoomMemberListContext

  meetingInfoRef.current = meetingInfo
  memberListRef.current =
    hostOrCohostList.length > 0 ? hostOrCohostList : memberList
  waitingRoomMemberListRef.current = waitingRoomMemberList

  const neMeeting = initNeMeeting || neMeetingContext
  const eventEmitter = initEventEmitter || eventEmitterContext
  const dispatch = props.meetingInfoDispatch || dispatchContext

  const isHostOrCohost =
    meetingInfo.localMember.role === Role.host ||
    meetingInfo.localMember.role === Role.coHost

  const chatroomWaitingRoomMemberList = useMemo(() => {
    if (!isHostOrCohost) {
      return []
    }

    return (
      waitingRoomMemberList.map((member) => ({
        tags: [],
        account: member.uuid,
        nick: member.name,
        avatar: member.avatar,
      })) || []
    )
  }, [isHostOrCohost, waitingRoomMemberList])

  isElectronSharingScreenRef.current = !!(
    window.ipcRenderer && meetingInfo.localMember.isSharingScreen
  )

  useEffect(() => {
    visibleRef.current = visible
  }, [visible])

  const getHostAndCohostList = useCallback(() => {
    neMeeting?.getHostAndCohostList().then(setHostOrCohostList)
  }, [neMeeting])

  useEffect(() => {
    if (isWaitingRoom && visible) {
      getHostAndCohostList()
    }
  }, [isWaitingRoom, visible, getHostAndCohostList])

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
        isWaitingRoom,
        viewHistoryEmptyImage: EmptyViewMsgImage,
        roomName: meetingInfo.subject || subject,
        roomStartTime: meetingInfo.startTime || startTime,
        role: meetingInfo.localMember.role,
        isRooms: meetingInfo.isRooms,
        isViewHistory,
        nim: neMeeting?.imInfo?.nim,
        chatroomController: neMeeting?.chatController,
        roomService: roomService || neMeeting?.roomService,
        roomArchiveId: meetingInfo.roomArchiveId || roomArchiveId,
        memberList: chatroomMemberList,
        waitingRoomMembers: chatroomWaitingRoomMemberList,
        appKey: neMeeting?.imInfo?.imAppKey || '',
        token: neMeeting?.imInfo?.imToken || '',
        chatroomId: neMeeting?.imInfo?.chatRoomId || '',
        avatar: meetingInfo.localMember.avatar,
        privateChatMemberId: meetingInfo.privateChatMemberId || 'meetingAll',
        meetingChatPermission: meetingInfo.meetingChatPermission,
        waitingRoomChatPermission: meetingInfo.waitingRoomChatPermission,
        account:
          neMeeting?.imInfo?.imAccid ||
          meetingInfo.localMember.uuid ||
          accountId ||
          '',
        nickName: meetingInfo.localMember.name,
        imPrivateConf: {},
        ...meetingInfo.chatroomConfig,
        onFocus: () => {
          if (!meetingInfo.enableUnmuteBySpace) {
            return
          }

          // 获取焦点后阻止长安空格的监听事件
          document.addEventListener('keydown', handleFocused, true)
          document.addEventListener('keyup', handleFocused, true)
        },
        onBlur: () => {
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
          const isOpen =
            !!getWindow('chatWindow') && isElectronSharingScreenRef.current

          if (isOpen) {
            return
          }

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
        onMsgs: (msgs) => {
          cacheMsgs = msgs
          const parentWindow = window.parent

          parentWindow?.postMessage(
            {
              event: 'chatroomOnMsgs',
              payload: cacheMsgs,
            },
            parentWindow.origin
          )
        },
        onPrivateChatMemberSelectOpen: (open) => {
          isWaitingRoom && open && getHostAndCohostList()
        },
        onPrivateChatMemberSelected: (id) => {
          const member =
            memberListRef.current?.find((item) => item.uuid === id) ||
            waitingRoomMemberListRef.current?.find((item) => item.uuid === id)

          // 等候室
          if (member || id === 'meetingAll' || id === 'waitingRoomAll') {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                privateChatMemberId: member?.uuid || id,
              },
            })
          } else {
            Toast.fail(t('chatMemberLeft'))
          }
        },
        onMeetingChatPermissionChange: (permission) => {
          neMeeting?.sendHostControl(
            hostAction.changeChatPermission,
            '',
            permission
          )
        },
        onWaitingRoomChatPermissionChange: (permission) => {
          neMeeting?.sendHostControl(
            hostAction.changeWaitingRoomChatPermission,
            '',
            permission
          )
        },
        onRemoveMember: (id) => {
          const member = memberListRef.current?.find((item) => item.uuid === id)
          const waitingRoomMember = waitingRoomMemberListRef.current?.find(
            (item) => item.uuid === id
          )
          let isChecked = false

          if (member) {
            Modal.confirm({
              title: t('participantRemove'),
              width: 270,
              content: (
                <>
                  <div>{t('participantRemoveConfirm') + member.name}</div>
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
                    member?.uuid,
                    isChecked
                  )
                } catch (e: any) {
                  Toast.fail(
                    e.message || e.msg || t('participantFailedToRemove')
                  )
                }
              },
            })
          }

          if (waitingRoomMember) {
            Modal.confirm({
              title: t('participantExpelWaitingMemberDialogTitle'),
              width: 270,
              content: meetingInfoRef.current?.enableBlacklist && (
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
                  await neMeeting?.expelMember(
                    waitingRoomMember?.uuid,
                    isChecked
                  )
                } catch (e: any) {
                  Toast.fail(e?.msg || e?.message)
                }
              },
            })
          }
        },

        isChangeTimePosition: true,
      })
    }

    eventEmitter?.on(
      EventType.WaitingRoomOnManagersUpdated,
      (data: NEMember[]) => {
        setHostOrCohostList(data)
      }
    )
    eventEmitter?.on(EventType.ReceiveChatroomMessages, (messages) => {
      messages.forEach((element) => {
        if (element.fromUserUuid && !element.from) {
          element.from = element.fromUserUuid
        }

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
              okText: i18n.t('globalSure'),
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
    const chatroomRefDom = chatroomRef.current

    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages)
      eventEmitter?.off(EventType.ChatroomMessageAttachmentProgress)
      if (chatroomRefDom) {
        unmountComponentAtNode(chatroomRefDom)
      }
    }
  }, [])

  const chatroomMemberList = useMemo(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []
    const chatroomMemberList = isWaitingRoom ? hostOrCohostList : memberList

    chatroomMemberList
      .filter(
        (member) =>
          member.uuid != meetingInfo.myUuid &&
          member.clientType !== NEClientType.SIP
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

    return members.map((member) => {
      return {
        tags: [],
        account: member.uuid,
        nick: member.name,
        avatar: member.avatar,
        role: member.role,
      }
    })
  }, [memberList, meetingInfo.myUuid, hostOrCohostList, isWaitingRoom])

  useEffect(() => {
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit('onVisibleChange', visible)
      if (visible && cacheMsgs.length > 0) {
        ChatroomHelper.instance.emit('initMessages', cacheMsgs)
      }
    }
  }, [visible])

  useEffect(() => {
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onMemberRoleChange',
        meetingInfo.localMember.role
      )
    }
  }, [meetingInfo.localMember.role])

  useEffect(() => {
    cacheMsgs = []
  }, [isWaitingRoom])

  useEffect(() => {
    // 更新聊天室内本端昵称
    // 更新聊天室内成员列表
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit('onMembersUpdate', chatroomMemberList)
    }
  }, [chatroomMemberList])

  useEffect(() => {
    // 更新等候室成员
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onWaitingRoomMembersUpdate',
        chatroomWaitingRoomMemberList
      )
    }
  }, [chatroomWaitingRoomMemberList])

  useEffect(() => {
    // 更新聊天室内选中的私聊用户
    if (
      ChatroomHelper.instance &&
      isMountedRef.current &&
      meetingInfo.privateChatMemberId
    ) {
      ChatroomHelper.instance.emit(
        'onPrivateChatMemberSelected',
        meetingInfo.privateChatMemberId
      )
    }
  }, [meetingInfo.privateChatMemberId])

  useUpdateEffect(() => {
    // 更新会中聊天室的权限
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onMeetingChatPermissionChange',
        meetingInfo.meetingChatPermission
      )
      ChatroomHelper.instance.emit(
        'onPrivateChatMemberSelected',
        meetingInfo.privateChatMemberId
      )
    }
  }, [meetingInfo.meetingChatPermission])

  useUpdateEffect(() => {
    // 更新等候室聊天室的权限
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onWaitingRoomChatPermissionChange',
        meetingInfo.waitingRoomChatPermission
      )
      ChatroomHelper.instance.emit(
        'onPrivateChatMemberSelected',
        meetingInfo.privateChatMemberId
      )
    }
  }, [meetingInfo.waitingRoomChatPermission])

  useUpdateEffect(() => {
    // 更新等候室聊天室的权限
    if (ChatroomHelper.instance && isMountedRef.current) {
      ChatroomHelper.instance.emit(
        'onPrivateChatMemberSelected',
        meetingInfo.privateChatMemberId
      )
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
  }, [meetingInfo.roomArchiveId, dispatch])

  useEffect(() => {
    function handle() {
      if (
        ChatroomHelper.instance &&
        isMountedRef.current &&
        initMsgs &&
        initMsgs.length > 0
      ) {
        ChatroomHelper.instance.emit('initMessages', initMsgs)
      }
    }

    handle()
  }, [initMsgs])

  useEffect(() => {
    if (isWaitingRoom) {
      window.addEventListener('online', getHostAndCohostList)
      return () => {
        window.removeEventListener('online', getHostAndCohostList)
      }
    }
  }, [getHostAndCohostList, isWaitingRoom])

  return <div ref={chatroomRef} className="nemeeting-chatroom-wrapper" />
}

export default Chatroom
