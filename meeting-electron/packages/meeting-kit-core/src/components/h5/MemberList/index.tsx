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
import { NEChatPermission, memberAction } from '../../../types/innerType'
import UserAvatar from '../../common/Avatar'
import { useTranslation } from 'react-i18next'
import { useUpdateEffect } from 'ahooks'
import AudioIcon from '../../common/AudioIcon'
import useNetworkQuality from '../../../hooks/useNetworkQuality'
import { AutoSizer, List } from 'react-virtualized'

interface MemberListProps {
  visible: boolean
  memberList?: NEMember[]
  isPrivateChat?: boolean
  privateChatMemberId?: string
  privateChatAll?: boolean
  onPrivateChatClick?: () => void
  onClose: () => void
}

interface MemberProps {
  member: NEMember
  displayMoreBtns: (member: NEMember) => void
  onMemberClick: (member: NEMember) => void
  myUuid: string
  memberIdentityStr: (uuid: string, role: string) => string
  isPrivateChat: boolean
  privateChatMemberId?: string
}

const MemberItem: React.FC<MemberProps> = ({
  member,
  displayMoreBtns,
  onMemberClick,
  myUuid,
  memberIdentityStr,
  isPrivateChat,
  privateChatMemberId,
}) => {
  const { isNetworkQualityBad } = useNetworkQuality(member)
  return (
    <div
      className={`nemeeting-member-item relative`}
      key={member?.uuid}
      onClick={() => {
        displayMoreBtns(member)
        onMemberClick(member)
        // setClickMember(member)
      }}
    >
      <div className="member-info">
        <UserAvatar
          className="nemeeting-member-item-avatar"
          nickname={member.name}
          avatar={member.avatar}
          size={32}
          showNetworkQuality={isNetworkQualityBad}
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
            <svg className="icon iconfont icon-blue" aria-hidden="true">
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          </div>
        ) : null
      ) : (
        <div className="member-status absolute line-height-3">
          {member?.isLocalRecording ? (
            <svg
              className="icon-red icon-tool icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconbendiluzhi1"></use>
            </svg>
          ) : (
            ''
          )}
          {member?.isSharingWhiteboard ? (
            <svg className="icon-blue icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconbaiban-mianxing"></use>
            </svg>
          ) : (
            ''
          )}
          {member?.isSharingScreen ? (
            <svg className="icon-blue icon iconfont" aria-hidden="true">
              <use xlinkHref="#icontouping-mianxing"></use>
            </svg>
          ) : (
            ''
          )}
          {member?.clientType === NEClientType.SIP ? (
            <svg
              className="iconfont iconSIPwaihudianhua icon-blue"
              aria-hidden="true"
            >
              <use xlinkHref="#iconSIPwaihudianhua" />
            </svg>
          ) : (
            ''
          )}
          {member?.clientType === NEClientType.H323 ? (
            <svg
              className="iconfont iconSIPwaihudianhua icon-blue"
              aria-hidden="true"
            >
              <use xlinkHref="#icona-323" />
            </svg>
          ) : (
            ''
          )}
          {member?.isVideoOn ? (
            <svg className="iconfont" aria-hidden="true">
              <use xlinkHref="#iconguanbishexiangtou-mianxing"></use>
            </svg>
          ) : (
            <svg
              className="icon-red icon-tool icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconkaiqishexiangtou"></use>
            </svg>
          )}
          {member?.isAudioOn ? (
            <AudioIcon
              memberId={member.uuid}
              className="icon iconfont icon-hover member-iconyx-tv-voice"
              dark
            />
          ) : (
            <svg className="icon-red icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconkaiqimaikefeng"></use>
            </svg>
          )}
        </div>
      )}
    </div>
  )
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
    meetingInfo: {
      localMember,
      myUuid,
      meetingChatPermission,
      updateNicknamePermission,
    },
    memberList: memberListContext,
    dispatch,
  } = useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const [showOperation, setShowOperation] = useState(false)
  const [beOperatedUser, setBeOperatedUser] = useState<NEMember>()
  const [userActions, setUserActions] = useState<Action[]>([])
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

  const isHostOrCoHost = useMemo(
    () => localMember.role === Role.host || localMember.role === Role.coHost,
    [localMember.role]
  )
    // 成员自己的操作
    const handleMemberMore = useCallback(async (
      memberInfo: NEMember,
      uid: string,
      type: memberAction
    ) => {
      await neMeeting?.sendMemberControl(type, memberInfo.uuid)
    }, [])

  /**
   * 成员操作内容
   */
  const displayMoreBtns = useCallback((item: NEMember) => {
    if (isPrivateChat) {
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

      if (
        item.clientType === NEClientType.SIP ||
        item.clientType === NEClientType.H323
      ) {
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
              if (!updateNicknamePermission && !isHostOrCoHost) {
                Toast.fail(t('updateNicknameNoPermission'))
                return
              }

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

    if (displayBtns.length > 0) {
      setBeOperatedUser(item)
      setUserActions(displayBtns)
      setShowOperation(true)
    } else {
      setShowOperation(false)
      setClickMember(undefined)
    }
  }, [onClose, myUuid, localMember.role, localMember.uuid, meetingChatPermission, onPrivateChatClick, updateNicknamePermission, isHostOrCoHost, handleMemberMore])

  useUpdateEffect(() => {
    clickMember && displayMoreBtns(clickMember)
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



  const memberIdentityStr = useCallback((uuid: string, role: string) => {
    const identities: string[] = []

    role === Role.host && identities.push(t('host'))
    role === Role.coHost && identities.push(t('coHost'))
    role === Role.guest && identities.push(t('meetingRoleGuest'))
    uuid === myUuid && identities.push(t('participantMe'))
    return '(' + identities.join('，') + ')'
  }, [myUuid])

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
    if (!updateNicknamePermission && !isHostOrCoHost) {
      Toast.fail(t('updateNicknameNoPermission'))
      return
    }

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

  const roomRowRenderer = useCallback(
    ({ index, key, style }) => {
      const member = filteredMemberList[index]

      return (
        <div style={style} key={key}>
          <MemberItem
            member={member}
            key={member?.uuid + index}
            onMemberClick={setClickMember}
            displayMoreBtns={displayMoreBtns}
            isPrivateChat={isPrivateChat}
            myUuid={myUuid}
            memberIdentityStr={memberIdentityStr}
            privateChatMemberId={privateChatMemberId}
          />
        </div>
      )
    },
    [filteredMemberList, isPrivateChat, privateChatMemberId, myUuid, memberIdentityStr]
  )

  return (
    <>
      <div
        className={`member-list ${selfShow ? 'nemeeting-member-lit-show' : ''}`}
        onClick={(e) => {
          onCloseClick(e)
        }}
      >
        <div
          className={`member-list-content ${
            selfShow ? 'nemeeting-member-lit-show' : ''
          }`}
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
            className={`member-scroll text-left`}
          >
            {renderPrivateMemberAllItem()}
            <AutoSizer>
              {({ height, width }) => (
                <List
                  height={height}
                  overscanRowCount={10}
                  rowCount={filteredMemberList.length}
                  rowHeight={48}
                  rowRenderer={roomRowRenderer}
                  width={width}
                />
              )}
            </AutoSizer>
          </div>
        </div>
      </div>
      <ActionSheet
        extra={beOperatedUser?.name}
        cancelText={t('globalCancel')}
        visible={showOperation}
        actions={userActions}
        getContainer={null}
        onClose={() => {
          setShowOperation(false)
          setClickMember(undefined)
        }}
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
