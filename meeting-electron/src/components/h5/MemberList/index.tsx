import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react'
import {
  NEMember,
  Role,
  MeetingInfoContextInterface,
  GlobalContext as GlobalContextInterface,
  ActionType,
  NEClientType,
} from '../../../types'
import { ActionSheet, Input } from 'antd-mobile/es'
import type { Action } from 'antd-mobile/es/components/action-sheet'
import Dialog from '../ui/dialog'
import Toast from '../../common/toast'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import './index.less'
import {
  NEChatPermission,
  hostAction,
  memberAction,
} from '../../../types/innerType'
import UserAvatar from '../../common/Avatar'
import { useTranslation } from 'react-i18next'
import { useUpdateEffect } from 'ahooks'

interface MemberListProps {
  visible: boolean
  memberList?: NEMember[]
  isPrivateChat?: boolean
  privateChatMemberId?: string
  privateChatAll?: boolean
  onPrivateChatClick?: () => void
  onClose: () => void
}

const MemberListUI: React.FC<MemberListProps> = ({
  visible = false,
  isPrivateChat = false,
  privateChatMemberId,
  privateChatAll,
  onPrivateChatClick,
  onClose,
  ...restProps
}) => {
  const { t } = useTranslation()

  const [selfShow, setSelfShow] = useState(false)
  const {
    meetingInfo: { localMember, hostUuid, myUuid, meetingChatPermission },
    memberList: memberListContext,
    dispatch,
  } = useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const [showOperation, setShowOperation] = useState(false)
  const [beOperatedUser, setBeOperatedUser] = useState<NEMember>()
  const [userActions, setUserActions] = useState<Action[]>([])
  const meetingLockStatus = true
  const [showDialog, setShowDialog] = useState(false)
  const [showRenameDialog, setShowRenameDialog] = useState(false)
  const [newName, setNewName] = useState('')
  const [searchName, setSearchName] = useState('')
  const [clickMember, setClickMember] = useState<NEMember>()
  const isComposingRef = React.useRef(false)

  const memberList = useMemo(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []
    const memberList = restProps.memberList || memberListContext

    memberList.forEach((member) => {
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
    ]
    return res
  }, [restProps.memberList, memberListContext, localMember])

  useEffect(() => {
    setSelfShow(visible)
  }, [visible])

  const onCloseClick = (e: React.MouseEvent) => {
    onClose && onClose()
    e.stopPropagation()
  }

  /**
   * 成员操作内容
   */
  const displayMoreBtns = (item: NEMember, isHost: boolean) => {
    if (isPrivateChat) {
      console.log('item', item)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          privateChatMemberId: item.uuid,
        },
      })
      onClose?.()
      return
    }
    const displayBtns: Action[] = [] // 展示的action结构

    const getPrivateChatShow = () => {
      // 点击的人是自己
      if (item.uuid === myUuid) {
        return false
      }
      if (item.clientType === NEClientType.SIP) {
        return false
      }
      // 自己是主持人或者联席主持人
      if (localMember.role === Role.host || localMember.role === Role.coHost) {
        return true
      }
      // 不可以聊天
      if (meetingChatPermission === NEChatPermission.NO_CHAT) {
        return false
      }
      // 点击的人是主持人或者联席主持人
      if (item.role === Role.host || item.role === Role.coHost) {
        return true
      }
      // 自由聊天
      if (meetingChatPermission === NEChatPermission.FREE_CHAT) {
        return true
      }
    }

    // 所有人展示的操作
    const normalBtns = [
      {
        id: memberAction.modifyMeetingNickName,
        name: t('noRename'),
        isShow: item.uuid === localMember?.uuid,
        // testName: (item, localInfo, isWhiteSharer, uid) => (item.avRoomUid === localInfo.avRoomUid && !localInfo?.noRename && 'member-update-meeting-nickname') + '-' + item.nickName, // 测试自动化使用
        // needDialog: false,
      },
      {
        id: memberAction.privateChat,
        name: t('chatPrivate'),
        isShow: getPrivateChatShow(),
        onClick: () => {
          onPrivateChatClick?.()
          setShowOperation(false)
        },
      },
    ]
    normalBtns.map((btn) => {
      if (btn.isShow) {
        if (btn.id === memberAction.modifyMeetingNickName) {
          displayBtns.push({
            text: btn.name,
            key: btn.id,
            onClick: async () => {
              setNewName(localMember?.name)
              setShowOperation(false)
              setShowRenameDialog(true)
            },
          })
        } else {
          displayBtns.push({
            text: btn.name,
            key: btn.id,
            onClick: async () => {
              btn.onClick?.()
              handleMemberMore(item, item?.uuid, btn.id)
            },
          })
        }
      }
    })

    // 主持人和联席主持人展示的操作
    const hostOrCohostBtns: any[] = []
    // if (isHost) {
    //   const hostBtns = [
    //     // isShow 预留展示逻辑
    //     {
    //       id: hostAction.muteMemberAudio,
    //       name: '静音',
    //       isShow: item.isAudioOn,
    //       // testName: (item) => (item.isHost ? 'mute-audio-control-host' : 'mute-audio-control-member') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: false,
    //     },
    //     {
    //       id: hostAction.unmuteMemberAudio,
    //       name: '解除静音',
    //       isShow: !item.isAudioOn,
    //       // testName: (item) => (item.isHost ? 'unmute-audio-control-host' : 'unmute-audio-control-member') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: false,
    //     },
    //     // {
    //     //   id: hostAction.agreeHandsUp, // 举手逻辑后续执行解除静音
    //     //   name: '解除静音',
    //     //   isShow: (item, allowUnMuteAudio) => !allowUnMuteAudio && (item.audio === 3 || item.audio === 2),
    //     //   needDialog: false,
    //     // },
    //     {
    //       id: hostAction.muteMemberVideo,
    //       name: '停止视频',
    //       isShow: item.isVideoOn,
    //       // testName: (item) => (item.isHost ? 'mute-video-control-host' : 'mute-video-control-member') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.unmuteMemberVideo,
    //       name: '开启视频',
    //       isShow: !item.isVideoOn,
    //       // testName: (item) => (item.isHost ? 'unmute-video-control-host' : 'unmute-video-control-member') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.muteVideoAndAudio,
    //       name: '关闭音视频',
    //       isShow: item.isVideoOn && item.isAudioOn,
    //       // testName: (item) => (item.isHost ? 'mute-video-and-audio-control-host' : 'mute-video-and-audio-control-member') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.unmuteVideoAndAudio,
    //       name: '开启音视频',
    //       isShow: !item.isVideoOn || !item.isAudioOn,
    //       // testName: (item) => (item.isHost ? 'unmute-video-and-audio-control-host' : 'unmute-video-and-audio-control-member') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.setFocus,
    //       name: '设为焦点视频',
    //       isShow: false, // todo:设为焦点视频的逻辑
    //       // isShow: (item) => !item.isFocus && !this.isScreen,
    //       // testName: (item) => (!item.isHost && 'setfocus-control') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.unsetFocus,
    //       name: '取消焦点视频',
    //       isShow: false, // todo:取消焦点视频的逻辑
    //       // isShow: (item) => item.isFocus && !this.isScreen,
    //       // testName: (item) => (item.isFocus && 'unsetfocus-control') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: false,
    //     },
    //     {
    //       id: hostAction.closeScreenShare,
    //       name: '结束共享',
    //       isShow: false, // todo:结束共享逻辑
    //       // isShow: (item) => !item.isHost && item.screenSharing === 1,
    //       // testName: (item) => (!item.isHost && item.screenSharing === 1 && 'close-screen-control') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: true,
    //     },

    //     {
    //       id: hostAction.closeWhiteShare,
    //       name: '退出白板',
    //       isShow: false, // todo:退出白板逻辑
    //       // isShow: (item, meetingInfo) => meetingInfo.whiteboardAvRoomUid.includes(item.avRoomUid.toString()) && !item.isHost,
    //       // testName: (item, meetingInfo) => (meetingInfo.whiteboardAvRoomUid.includes(item.avRoomUid.toString()) && 'closewhiteboard-control') + '-' + item.nickName, // 测试自动化使用
    //       needDialog: true,
    //     },
    //   ]
    //   hostOrCohostBtns = hostOrCohostBtns.concat(hostBtns)
    // }

    // 仅主持人展示的操作
    // if (isHost) {
    //   const onlyHostBtns = [
    //     {
    //       id: hostAction.remove,
    //       name: '移除', // todo: 移除需要二次弹窗确认
    //       isShow: item.uuid !== hostUuid,
    //       // testName: (item) => (!item.isHost && 'remove-member-control') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: true,
    //     },
    //     {
    //       id: hostAction.transferHost,
    //       name: '移交主持人',
    //       isShow: item.uuid !== hostUuid,
    //       // testName: (item) => (!item.isHost && 'transferhost-control') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: true,
    //     },
    //     {
    //       id: hostAction.setCoHost, // 联席主持人
    //       name: '设为联席主持人',
    //       isShow: false, // todo: 联席主持人展示逻辑
    //       // isShow: (item) => item.role !== Role.coHost && !item.isHost,
    //       // testName: (item) => (!item.isHost && 'set-coHost-control') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: true,
    //     },
    //     {
    //       id: hostAction.unSetCoHost, // 取消联席主持人
    //       name: '取消设为联席主持人',
    //       isShow: false, // todo:取消联席主持人展示逻辑
    //       // isShow: (item) => item.role === Role.coHost && !item.isHost,
    //       // testName: (item) => (!item.isHost && 'unSet-coHost-control') + '-' + item.nickName, // 测试自动化使用
    //       // needDialog: true,
    //     },
    //   ]
    //   hostOrCohostBtns = hostOrCohostBtns.concat(onlyHostBtns)
    // } else {
    //   // 仅联席主持人展示的操作
    // }

    // hostOrCohostBtns.map((btn) => {
    //   if (btn.isShow) {
    //     displayBtns.push({
    //       text: btn.name,
    //       key: btn.id,
    //       onClick: async () => {
    //         handleMore(item, item?.uuid, btn.id)
    //       },
    //     })
    //   }
    // })

    if (displayBtns.length > 0) {
      setBeOperatedUser(item)
      setUserActions(displayBtns)
      setShowOperation(true)
    } else {
      setShowOperation(false)
      setClickMember(undefined)
    }
  }

  useUpdateEffect(() => {
    clickMember && displayMoreBtns(clickMember, localMember?.uuid === hostUuid)
  }, [memberList, meetingChatPermission])

  useUpdateEffect(() => {
    setClickMember(undefined)
  }, [visible])

  // 成员离开，隐藏操作弹窗
  useUpdateEffect(() => {
    const index = memberList.findIndex(
      (item) => item.uuid === clickMember?.uuid
    )
    if (index === -1) {
      setShowOperation(false)
      setClickMember(undefined)
    }
  }, [memberList])

  const operateAllOrMeeting = async (type: hostAction) => {
    await neMeeting?.sendHostControl(type, localMember?.uuid)
  }

  // host操作成员
  const handleMore = async (
    memberInfo: NEMember,
    uid: string,
    type: hostAction
  ) => {
    // const { commit, dispatch } = this.$store;
    let callback: () => any = () => {
      return true
    }
    switch (type) {
      case hostAction.remove:
        console.debug('执行成员移除 %o %t', memberInfo)
        callback = () => {
          // this.settingInfo.type = type;
          // this.settingInfo.uid = uid;
          // this.hideAll();
          // this.visibleRemoveMember = true;
        }
        break
      case hostAction.muteMemberVideo:
        console.debug('执行成员关闭视频 %o %t', memberInfo)
        // this.$toast(`关闭 ${memberInfo.nickName} 视频`);
        callback = () => {
          // memberInfo.video = 2;
        }
        break
      case hostAction.muteMemberAudio:
        console.debug('执行成员静音 %o %t', memberInfo)
        // this.$toast(`${memberInfo.nickName} 静音`);
        callback = () => {
          // memberInfo.audio = 2;
        }
        break
      case hostAction.unmuteMemberVideo:
        console.debug('执行成员开启视频 %o %t', memberInfo)
        // this.$toast(`开启 ${memberInfo.nickName} 视频`);
        callback = () => {
          // memberInfo.video = 4;
        }
        break
      case hostAction.unmuteMemberAudio:
        console.debug('执行成员取消静音 %o %t', memberInfo)
        // this.$toast(`取消 ${memberInfo.nickName} 静音`);
        callback = () => {
          // memberInfo.audio = 4;
        }
        break
      case hostAction.muteVideoAndAudio:
        console.debug('执行成员关闭音视频 %o %t', memberInfo)
        callback = () => {
          //
        }
        break
      case hostAction.unmuteVideoAndAudio:
        console.debug('执行成员开启音视频 %o %t', memberInfo)
        callback = () => {
          //
        }
        break
      // case hostAction.agreeHandsUp:
      //   console.debug('执行成员取消静音', memberInfo);
      //   // this.$toast(`取消 ${memberInfo.nickName} 静音`);
      //   callback = () => {
      //     // memberInfo.audio = 4;
      //   }
      //   break;
      case hostAction.transferHost:
        console.debug('执行成员主持人移交 %o %t', memberInfo)
        callback = () => {
          // const oldHost = state.memberMap[state.localInfo.avRoomUid]
          // oldHost.isHost = false;
          // commit('updateMember', oldHost);
          // this.$store.commit('setLocalInfo', {
          //   role: 'participant',
          // });
          // memberInfo.isHost = true;
          // this.settingInfo.type = type;
          // this.settingInfo.uid = uid;
          // this.hideAll();
          // if (memberInfo.clientType === NEMeetingClientType.sip) {
          //   this.$toast('无法设置SIP设备为主持人');
          // } else {
          //   this.visibleRemoveHost = true;
          // }
        }
        break
      case hostAction.closeWhiteShare:
        console.debug('主持人关闭白板 %o %t', memberInfo)
        callback = () => {
          // this.settingInfo.type = type;
          // this.settingInfo.uid = uid;
          // this.hideAll();
          // this.visibleCloseWhiteboard = true;
        }
        break
      case hostAction.setFocus:
        console.debug('执行设置焦点视频 %o %t', memberInfo)
        // this.$toast(`设置 ${memberInfo.nickName} 为焦点`);
        callback = () => {
          // memberInfo.isFocus = true;
          // commit('setMeetingInfo', { focusAvRoomUid: memberInfo.avRoomUid })
          // dispatch('sortMemberList');
        }
        break
      case hostAction.unsetFocus:
        console.debug('执行移除焦点视频 %o %t', memberInfo)
        // this.$toast(`移除 ${memberInfo.nickName} 为焦点`);
        callback = () => {
          // memberInfo.isFocus = false;
          // commit('setMeetingInfo', { focusAvRoomUid: 0 })
          // dispatch('sortMemberList');
        }
        break
      case hostAction.closeScreenShare:
        console.debug('主持人关闭屏幕共享 %o %t', memberInfo)
        callback = () => {
          // this.settingInfo.type = type;
          // this.settingInfo.uid = uid;
          // this.hideAll();
          // this.visibleCloseScreenShare = true;
        }
        break
      case hostAction.setCoHost:
        console.debug('主持人设置联席主持人 %o %t', memberInfo)
        // 添加trycatch 捕获设置联席主持人上限错误提示
        try {
          await neMeeting?.sendHostControl(
            hostAction.setCoHost,
            memberInfo.uuid
          )
        } catch (e: any) {
          // 国际化
          // this.$toast(this.errorCodes[e.code] || e.msg || e.message);
        }
        break
      case hostAction.unSetCoHost:
        console.debug('主持人取消设置联席主持人 %o %t', memberInfo)
        await neMeeting?.sendHostControl(
          hostAction.unSetCoHost,
          memberInfo.uuid
        )
        break
      default:
        break
    }
    if (
      // type !== hostAction.remove &&
      type !== hostAction.transferHost &&
      type !== hostAction.closeWhiteShare &&
      type !== hostAction.setCoHost &&
      type !== hostAction.unSetCoHost &&
      type !== hostAction.closeScreenShare
    ) {
      console.log('memberInfo', memberInfo, type)
      await neMeeting?.sendHostControl(type, memberInfo.uuid)
      // if( type === hostAction.unmuteMemberAudio|| type === hostAction.unmuteMemberVideo || type === hostAction.unmuteAllVideo || type === hostAction.unmuteVideoAndAudio) {
      //   neMeeting?.sendHostControl(hostAction.rejectHandsUp, [memberInfo.accountId]);
      // }
    }
    callback()
    setShowOperation(false)
    setShowRenameDialog(false)
    // commit('updateMember', memberInfo);
    // dispatch('sortMemberList');
    // document.body.click();
  }

  // 成员自己的操作
  const handleMemberMore = async (
    memberInfo: NEMember,
    uid: string,
    type: memberAction
  ) => {
    await neMeeting?.sendMemberControl(type, memberInfo.uuid)
  }

  const memberIdentityStr = (uuid: string, role: string) => {
    const identities: string[] = []
    role === Role.host && identities.push(t('host'))
    role === Role.coHost && identities.push(t('coHost'))
    role === Role.guest && identities.push(t('meetingRoleGuest'))
    uuid === myUuid && identities.push(t('participantMe'))
    return '(' + identities.join('，') + ')'
  }

  const filteredMemberList = useMemo(() => {
    const list = memberList
      .filter((member) => {
        if (isPrivateChat) {
          return member.uuid !== myUuid
        }
        return true
      })
      .filter((member) => member.name.indexOf(searchName) > -1)
    return list
  }, [memberList, searchName, isPrivateChat, myUuid])

  const isNickNameValid = useMemo(() => {
    if (!showRenameDialog) return
    const _byteResult = newName.replace(/[\u4e00-\u9fa5]/g, 'aa')
    if (newName.trim().length <= 0) {
      return false
    }
    if (_byteResult.length > 20) {
      return false
    }
    return true
  }, [newName, showRenameDialog])

  const memberRename = async () => {
    if (!isNickNameValid) return
    neMeeting
      ?.modifyNickName({ nickName: newName })
      .then(() => {
        setShowRenameDialog(false)
        Toast.success(t('reNameSuccessToast'))
      })
      .catch((e) => {
        Toast.fail(
          e?.message === 'failure' ? t('reNameFailureToast') : e?.message
        )
      })
  }
  const handleInputChange = (value: string) => {
    let userInput = value
    if (!isComposingRef.current) {
      let inputLength = 0

      for (let i = 0; i < userInput.length; i++) {
        // 检测字符是否为中文字符
        if (userInput.charCodeAt(i) > 127) {
          inputLength += 2
        } else {
          inputLength += 1
        }
        // 判断当前字符长度是否超过限制，如果超过则终止 for 循环
        if (inputLength > 20) {
          userInput = userInput.slice(0, i)
          break
        }
      }
    }
    setNewName(userInput)
  }

  const renderPrivateMemberAllItem = () => {
    if (!isPrivateChat || !privateChatAll) {
      return null
    }
    const isHostOrCoHost =
      localMember.role === Role.host || localMember.role === Role.coHost

    if (
      !isHostOrCoHost &&
      meetingChatPermission === NEChatPermission.PRIVATE_CHAT_HOST_ONLY
    ) {
      return null
    }

    return (
      <div
        className={`nemeeting-member-item relative`}
        key="meetingAll"
        onClick={() => {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              privateChatMemberId: 'meetingAll',
            },
          })
          onClose?.()
        }}
      >
        <div className="member-info">
          <svg className="icon iconfont icon-all" aria-hidden="true">
            <use xlinkHref="#iconsuoyouren-24px"></use>
          </svg>
          <span className="nemeeting-member-name line-height-3 w-full truncate">
            {t('chatAllMembers')}
          </span>
        </div>
        {privateChatMemberId === 'meetingAll' ? (
          <div className="member-status absolute line-height-3">
            <svg className="icon iconfont icon-blue" aria-hidden="true">
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          </div>
        ) : null}
      </div>
    )
  }

  return (
    <>
      <div
        className={`member-list ${selfShow ? 'show' : ''}`}
        onClick={(e) => {
          onCloseClick(e)
        }}
      >
        <div
          className={`member-list-content ${selfShow ? 'show' : ''}`}
          onClick={(e) => {
            e.stopPropagation()
          }}
        >
          <div className="member-list-title-wrap text-center">
            <span className="member-list-title">
              {isPrivateChat
                ? t('sendTo')
                : `${t('memberListBtnForNormal')}(${memberList?.length})`}
            </span>
            <i
              onClick={(e) => {
                onCloseClick(e)
              }}
              className="iconfont iconyx-pc-closex close-icon"
            ></i>
          </div>
          <div className="search-member">
            <Input
              clearable
              className="input-ele"
              placeholder={t('participantSearchMember')}
              value={searchName}
              onChange={setSearchName}
            />
          </div>
          <div
            className={`member-scroll text-left ${
              ['host', 'cohost'].includes(localMember?.role) &&
              'member-scroll-for-host'
            }`}
          >
            {renderPrivateMemberAllItem()}
            {filteredMemberList.map((member, index) => {
              return (
                <div
                  className={`nemeeting-member-item relative`}
                  key={member?.uuid + index}
                  onClick={() => {
                    displayMoreBtns(member, localMember?.uuid === hostUuid)
                    setClickMember(member)
                  }}
                >
                  <div className="member-info">
                    <UserAvatar
                      className="nemeeting-member-item-avatar"
                      nickname={member.name}
                      avatar={member.avatar}
                      size={32}
                    />
                    {member?.role === Role.coHost ||
                    member?.role === Role.host ||
                    member?.uuid === myUuid ? (
                      <>
                        <div className="truncate">
                          {member?.name}
                          <div className="member-tag">
                            {memberIdentityStr(member.uuid, member.role)}
                          </div>
                        </div>
                      </>
                    ) : (
                      <>
                        <span className="nemeeting-member-name line-height-3 w-full truncate">
                          {member?.name}
                        </span>
                      </>
                    )}
                  </div>
                  {isPrivateChat ? (
                    privateChatMemberId === member.uuid ? (
                      <div className="member-status absolute line-height-3">
                        <svg
                          className="icon iconfont icon-blue"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconcheck-line-regular1x"></use>
                        </svg>
                      </div>
                    ) : null
                  ) : (
                    <div className="member-status absolute line-height-3">
                      {member?.isSharingWhiteboard ? (
                        <i className="iconfont icon-blue iconyx-baiban"></i>
                      ) : (
                        ''
                      )}
                      {member?.isSharingScreen ? (
                        <i className="iconfont icon-blue icongongxiangpingmu"></i>
                      ) : (
                        ''
                      )}
                      {member?.clientType === NEClientType.SIP ? (
                        <svg
                          className="icon iconfont iconSIPwaihudianhua icon-blue"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconSIPwaihudianhua" />
                        </svg>
                      ) : (
                        ''
                      )}
                      {member?.isVideoOn ? (
                        <i className="iconfont iconyx-tv-video-onx"></i>
                      ) : (
                        <i className="icon-red iconfont iconyx-tv-video-offx"></i>
                      )}
                      {member?.isAudioOn ? (
                        <i className="iconfont iconyx-tv-voice-onx"></i>
                      ) : (
                        <i className="icon-red iconfont iconyx-tv-voice-offx"></i>
                      )}
                    </div>
                  )}
                </div>
              )
            })}
          </div>

          {/* {['host', 'cohost'].includes(localMember?.role) && (
              <>
                <div className="flex justify-between px-5 h-12 line-height-3 b-b-1-gray">
                  <span>锁定会议</span>
                  <Switch
                    defaultChecked={meetingLockStatus}
                    style={{
                      '--height': '25px',
                      '--width': '42px',
                    }}
                    onChange={(val) => {
                      if (val) {
                        operateAllOrMeeting(hostAction.lockMeeting)
                      } else {
                        operateAllOrMeeting(hostAction.unlockMeeting)
                      }
                    }}
                  />
                </div>
                <div className="entireOperation h-24 ">
                  <div className="py-2.5 b-b-1-gray">
                    <span
                      onClick={() => {
                        operateAllOrMeeting(hostAction.muteMemberAudio)
                      }}
                    >
                      全体静音
                    </span>
                    <span
                      onClick={() => {
                        operateAllOrMeeting(hostAction.unmuteAllAudio)
                      }}
                    >
                      全体解除静音
                    </span>
                  </div>
                  <div className="py-2.5">
                    <span
                      onClick={() => {
                        operateAllOrMeeting(hostAction.muteAllVideo)
                      }}
                    >
                      全体视频关闭{' '}
                    </span>
                    <span
                      onClick={() => {
                        operateAllOrMeeting(hostAction.unmuteAllVideo)
                      }}
                    >
                      解除全体视频关闭
                    </span>
                  </div>
                </div>
              </>
            )} */}
        </div>
      </div>
      <ActionSheet
        extra={beOperatedUser?.name}
        cancelText={t('globalCancel')}
        visible={showOperation}
        actions={userActions}
        getContainer={null}
        onClose={() => setShowOperation(false)}
        popupClassName={'action-sheet'}
      />
      <Dialog
        visible={showDialog}
        title={t('participantTransferHost')}
        onCancel={() => {
          setShowDialog(false)
        }}
        onConfirm={() => {
          // todo: 筛选
        }}
      >
        {t('participantTransferHostConfirm', { userName: clickMember?.name })}
      </Dialog>
      <Dialog
        visible={showRenameDialog}
        title={t('reName')}
        cancelText={t('globalCancel')}
        confirmText={t('globalSure')}
        onCancel={() => {
          setShowRenameDialog(false)
        }}
        onConfirm={memberRename}
        confirmDisabled={!isNickNameValid}
      >
        <div
          className={`change-name ${!newName.trim() && 'change-name-error'}`}
        >
          <input
            className={'input-ele'}
            value={newName}
            placeholder={t('reNamePlaceholder')}
            required
            onChange={(e) => {
              handleInputChange(e.currentTarget.value)
            }}
            onCompositionStart={() => (isComposingRef.current = true)}
            onCompositionEnd={(e) => {
              isComposingRef.current = false
              handleInputChange(e.currentTarget.value)
            }}
          />
          <div className="change-name-tip">{t('reNameTips')}</div>
        </div>
      </Dialog>
    </>
  )
}
export default MemberListUI
