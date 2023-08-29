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
} from '../../../types'
import { Switch, ActionSheet } from 'antd-mobile'
import type { Action } from 'antd-mobile/es/components/action-sheet'
import Dialog from '../ui/dialog'
import Toast from '../../common/toast'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import './index.less'
import { hostAction, memberAction } from '../../../types/innerType'

interface MemberListProps {
  visible: boolean
  onClose: () => void
}

const MemberListUI: React.FC<MemberListProps> = ({
  visible = false,
  onClose,
}) => {
  const [selfShow, setSelfShow] = useState(false)
  const {
    meetingInfo: { localMember, hostUuid, myUuid },
    memberList,
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
  const displayMoreBtns = useCallback(
    (item: NEMember, isHost: boolean) => {
      console.log(item)
      const displayBtns: Action[] = [] // 展示的action结构

      // 所有人展示的操作
      const normalBtns = [
        {
          id: memberAction.modifyMeetingNickName,
          name: '改名',
          isShow: item.uuid === localMember?.uuid,
          // testName: (item, localInfo, isWhiteSharer, uid) => (item.avRoomUid === localInfo.avRoomUid && !localInfo?.noRename && 'member-update-meeting-nickname') + '-' + item.nickName, // 测试自动化使用
          // needDialog: false,
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
        console.log('diplayBtns ', displayBtns)
      }
    },
    [localMember]
  )

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
          // todo 国际化
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
    role === Role.host && identities.push('主持人')
    role === Role.coHost && identities.push('联席主持人')
    uuid === myUuid && identities.push('我')
    return '(' + identities.join('，') + ')'
  }

  const filteredMemberList = useMemo(() => {
    const list = memberList.filter(
      (member) => member.name.indexOf(searchName) > -1
    )
    return list
  }, [memberList, searchName, memberList.length])

  const memberRename = async () => {
    if (newName.trim()) {
      neMeeting
        ?.modifyNickName({ nickName: newName })
        .then(() => {
          setShowRenameDialog(false)
          Toast.success('昵称修改成功')
        })
        .catch((e) => {
          Toast.fail(e?.message === 'failure' ? '请求失败' : e?.message)
        })
    }
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
              参会者({memberList?.length})
            </span>
            <i
              onClick={(e) => {
                onCloseClick(e)
              }}
              className="iconfont iconyx-pc-closex close-icon"
            ></i>
          </div>
          <div className="search-member">
            <input
              className="input-ele"
              placeholder="搜索成员"
              value={searchName}
              onChange={(e) => {
                setSearchName(e?.target?.value)
              }}
            />
          </div>
          <div
            className={`member-scroll text-left ${
              ['host', 'cohost'].includes(localMember?.role) &&
              'member-scroll-forhost'
            }`}
          >
            {filteredMemberList.map((member, index) => {
              return (
                <div
                  className={`member-item relative`}
                  key={member?.uuid + index}
                  onClick={() => {
                    displayMoreBtns(member, localMember?.uuid === hostUuid)
                  }}
                >
                  <div className="member-info">
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
                        <span className="member-name line-height-3 w-full truncate">
                          {member?.name}
                        </span>
                      </>
                    )}
                  </div>
                  <div className="member-status absolute line-height-3">
                    {member?.isSharingScreen ? (
                      <i className="iconfont icon-bule icongongxiangpingmu"></i>
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
        cancelText="取消"
        visible={showOperation}
        actions={userActions}
        getContainer={null}
        onClose={() => setShowOperation(false)}
        popupClassName={'action-sheet'}
      />
      <Dialog
        visible={showDialog}
        title="移交主持人"
        onCancel={() => {
          setShowDialog(false)
        }}
        onConfirm={() => {
          // todo: 筛选
        }}
      >
        确认移交主持人权限给小A？
      </Dialog>
      <Dialog
        visible={showRenameDialog}
        title="改名"
        cancelText="取消"
        confirmText="确认"
        onCancel={() => {
          setShowRenameDialog(false)
        }}
        onConfirm={memberRename}
      >
        <div
          className={`change-name ${!newName.trim() && 'change-name-error'}`}
        >
          <input
            className={'input-ele'}
            value={newName}
            placeholder="输入名称"
            maxLength={20}
            required
            onChange={(e) => {
              setNewName(e.target.value)
            }}
          />
          {!newName.trim() && <span>请输入昵称</span>}
        </div>
      </Dialog>
    </>
  )
}
export default MemberListUI
