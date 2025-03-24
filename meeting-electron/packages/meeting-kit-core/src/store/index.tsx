import { ConfigProvider, notification } from 'antd'
import { NotificationInstance } from 'antd/es/notification/interface'
import React, { useReducer } from 'react'
import { createMeetingInfoFactory } from '../services'
import {
  Action,
  ActionType,
  EventType,
  GlobalContext as GlobalContextInterface,
  GlobalProviderProps,
  MeetingInfoContextInterface,
  MeetingInfoProviderProps,
  NEMeetingInfo,
  NEMember,
  Role,
  WaitingRoomContextInterface,
} from '../types'
import { NEMeetingIdDisplayOption } from '../types/type'
import { MAJOR_AUDIO } from '../config'
import { setLocalStorageSetting } from '../utils'

const antdPrefixCls = 'nemeeting'

type GlobalContextType = GlobalContextInterface & {
  notificationApi?: NotificationInstance
}

export const GlobalContext = React.createContext<GlobalContextType>({})

const globalReducer = (
  state: GlobalContextInterface,
  action: Action<ActionType>
): GlobalContextInterface => {
  switch (action.type) {
    case ActionType.JOIN_LOADING: {
      const joinLoading = (action as Action<ActionType.JOIN_LOADING>).data

      return { ...state, joinLoading }
    }

    case ActionType.UPDATE_GLOBAL_CONFIG: {
      const config = (action as Action<ActionType.UPDATE_GLOBAL_CONFIG>).data

      if (config.interpretationSetting) {
        if (config.interpretationSetting.listenLanguage === MAJOR_AUDIO) {
          config.interpretationSetting.isListenMajor = false
        }

        config.interpretationSetting = {
          ...state.interpretationSetting,
          ...config.interpretationSetting,
        }
        state.eventEmitter?.emit(
          EventType.onInterpretationSettingChange,
          config.interpretationSetting
        )
      }

      return { ...state, ...config }
    }

    default:
      return { ...state }
  }
}

export const GlobalContextProvider: React.FC<GlobalProviderProps> = (props) => {
  const [notificationApi, contextHolder] = notification.useNotification({
    stack: false,
    bottom: 60,
    getContainer: () =>
      document.getElementById('ne-web-meeting') || document.body,
  })
  const [global, dispatch] = useReducer(globalReducer, {
    eventEmitter: props.eventEmitter,
    outEventEmitter: props.outEventEmitter,
    neMeeting: props.neMeeting,
    inviteService: props.inviteService,
    joinLoading: props.joinLoading,
    logger: props.logger,
    globalConfig: props.globalConfig,
    showMeetingRemainingTip: props.showMeetingRemainingTip,
    waitingRejoinMeeting: false,
    online: true,
    meetingIdDisplayOption: NEMeetingIdDisplayOption.DISPLAY_ALL,
    toolBarList: [],
    moreBarList: [],
    interpretationSetting: {
      listenLanguage: MAJOR_AUDIO,
    },
  })

  return (
    <ConfigProvider prefixCls={antdPrefixCls} theme={{ hashed: false }}>
      <GlobalContext.Provider value={{ ...global, dispatch, notificationApi }}>
        {contextHolder}
        {props.children}
      </GlobalContext.Provider>
    </ConfigProvider>
  )
}

export const useGlobalContext = (): GlobalContextType =>
  React.useContext<GlobalContextType>(GlobalContext)

export const MeetingInfoContext = React.createContext<MeetingInfoContextInterface>(
  {
    meetingInfo: createMeetingInfoFactory(),
    memberList: [],
    inInvitingMemberList: [],
  }
)
export const WaitingRoomContext = React.createContext<WaitingRoomContextInterface>(
  {
    waitingRoomInfo: {
      memberCount: 0,
      isEnabledOnEntry: false,
      unReadMsgCount: 0,
    },
    memberList: [],
  }
)
export const useWaitingRoomContext = (): WaitingRoomContextInterface =>
  React.useContext<WaitingRoomContextInterface>(WaitingRoomContext)

export const useMeetingInfoContext = (): MeetingInfoContextInterface =>
  React.useContext<MeetingInfoContextInterface>(MeetingInfoContext)

const waitingRoomReducer = (
  state: WaitingRoomContextInterface,
  action: Action<ActionType>
): WaitingRoomContextInterface => {
  switch (action.type) {
    case ActionType.WAITING_ROOM_ADD_MEMBER: {
      const {
        member,
      } = (action as Action<ActionType.WAITING_ROOM_ADD_MEMBER>).data
      const { memberList } = state
      const index = memberList.findIndex((item) => item.uuid === member.uuid)

      if (index > -1) {
        memberList[index] = member
      } else {
        memberList.push(member)
      }

      return { ...state, memberList: [...memberList] }
    }

    case ActionType.WAITING_ROOM_REMOVE_MEMBER: {
      const {
        uuid,
      } = (action as Action<ActionType.WAITING_ROOM_REMOVE_MEMBER>).data
      const { memberList } = state
      const index = memberList.findIndex((member) => member.uuid === uuid)

      index > -1 && memberList.splice(index, 1)
      return { ...state, memberList: [...memberList] }
    }

    case ActionType.WAITING_ROOM_UPDATE_MEMBER: {
      const memberInfo = (action as Action<ActionType.WAITING_ROOM_UPDATE_MEMBER>)
        .data
      const { memberList } = state
      const index = memberList.findIndex(
        (item) => item.uuid === memberInfo.uuid
      )

      if (index > -1) {
        memberList[index] = { ...memberList[index], ...memberInfo.member }
      }

      return { ...state, memberList: [...memberList] }
    }

    case ActionType.WAITING_ROOM_UPDATE_INFO: {
      let { waitingRoomInfo } = state
      const {
        info,
      } = (action as Action<ActionType.WAITING_ROOM_UPDATE_INFO>).data

      waitingRoomInfo = { ...waitingRoomInfo, ...info }
      return { ...state, waitingRoomInfo }
    }

    case ActionType.WAITING_ROOM_SET_MEMBER_LIST: {
      const {
        memberList,
      } = (action as Action<ActionType.WAITING_ROOM_SET_MEMBER_LIST>).data

      return { ...state, memberList: [...memberList] }
    }

    case ActionType.WAITING_ROOM_ADD_MEMBER_LIST: {
      const { memberList: oldMemberList } = state
      const {
        memberList,
      } = (action as Action<ActionType.WAITING_ROOM_SET_MEMBER_LIST>).data

      console.log('WAITING_ROOM_ADD_MEMBER_LIST', memberList)
      return { ...state, memberList: [...oldMemberList, ...memberList] }
    }

    default:
      return { ...state }
  }
}

const meetingInfoReducer = (
  state: MeetingInfoContextInterface,
  action: Action<ActionType>
): MeetingInfoContextInterface => {
  switch (action.type) {
    case ActionType.UPDATE_MEMBER: {
      const memberInfo = (action as Action<ActionType.UPDATE_MEMBER>).data
      const meetingInfo = state.meetingInfo
      const { memberList } = state
      const index = memberList.findIndex(
        (item) => item.uuid === memberInfo.uuid
      )

      if (index > -1) {
        memberList[index] = { ...memberList[index], ...memberInfo.member }
        if (meetingInfo.localMember.uuid === memberInfo.uuid) {
          meetingInfo.localMember = {
            ...meetingInfo.localMember,
            ...memberInfo.member,
          }
        }

        if (
          memberInfo.member.role !== undefined &&
          memberInfo.member.role === Role.host
        ) {
          meetingInfo.hostUuid = memberInfo.uuid
          meetingInfo.hostName = memberList[index].name
        }

        // 更新共享者信息同步到meetingInfo，只有共享一项变更的时候才会更新，防止更新整个member的时候，meetingInfo中的共享id设置错误
        if (
          memberInfo.member.isSharingScreen !== undefined &&
          Object.keys(memberInfo.member).length === 1
        ) {
          meetingInfo.screenUuid = memberInfo.member.isSharingScreen
            ? memberList[index]?.uuid
            : ''
        }

        if (
          memberInfo.member.isSharingSystemAudio !== undefined &&
          Object.keys(memberInfo.member).length === 1
        ) {
          meetingInfo.systemAudioUuid = memberInfo.member.isSharingSystemAudio
            ? memberList[index]?.uuid
            : ''
        }
      }

      // 本端数据更新
      // 成员列表进行排序
      // memberList = sortMembers(memberList, meetingInfo.localMember.uuid)
      return { ...state, memberList: [...memberList], meetingInfo }
    }

    case ActionType.UPDATE_MEMBERS: {
      const { members } = (action as Action<ActionType.UPDATE_MEMBERS>).data
      const { memberList } = state

      members.forEach((member) => {
        const index = memberList.findIndex((item) => item.uuid === member.uuid)

        if (index > -1) {
          memberList[index] = { ...memberList[index], ...member }
        }
      })
      return {
        ...state,
        memberList: [...memberList],
      }
    }

    case ActionType.ADD_MEMBER: {
      const { member } = (action as Action<ActionType.ADD_MEMBER>).data
      const { memberList, inInvitingMemberList } = state
      const index = memberList.findIndex((item) => item.uuid === member.uuid)

      if (index > -1) {
        memberList[index] = member
      } else {
        memberList.push(member)
        const sipIndex = inInvitingMemberList?.findIndex(
          (item) => item.uuid === member.uuid
        )

        // 如果邀请列表存在则需要删除邀请列表的
        if (sipIndex != undefined && sipIndex > -1) {
          inInvitingMemberList?.splice(sipIndex, 1)
        }
      }

      // memberList = sortMembers(memberList, meetingInfo.localMember.uuid)
      return {
        ...state,
        memberList: [...memberList],
        inInvitingMemberList: [...(inInvitingMemberList || [])],
      }
    }

    case ActionType.REMOVE_MEMBER: {
      const { uuids } = (action as Action<ActionType.REMOVE_MEMBER>).data
      const { memberList, inInvitingMemberList } = state

      uuids.forEach((uuid) => {
        const index = memberList.findIndex((member) => member.uuid === uuid)

        if (index > -1) {
          memberList.splice(index, 1)
        } else {
          // 如果成员列表不存在，去邀请列表中删除
          const sipIndex = inInvitingMemberList?.findIndex(
            (item) => item.uuid === uuid
          )

          if (sipIndex != undefined && sipIndex > -1) {
            state.inInvitingMemberList?.splice(sipIndex, 1)
          }
        }
      })
      return {
        ...state,
        memberList: [...memberList],
        inInvitingMemberList: [...(inInvitingMemberList || [])],
      }
    }

    case ActionType.RESET_MEMBER: {
      return { ...state, memberList: [] }
    }

    case ActionType.UPDATE_MEMBER_PROPERTIES: {
      const {
        uuid,
        properties,
      } = (action as Action<ActionType.UPDATE_MEMBER_PROPERTIES>).data
      const { memberList, meetingInfo } = state
      const index = memberList.findIndex((item) => item.uuid === uuid)

      if (index > -1) {
        const member = memberList[index]
        if(member && properties?.localRecord){
          member.isLocalRecording = properties.localRecord?.value == '1'
        }
        if(member && properties?.localRecordAvailable){
          member.localRecordAvailable = properties.localRecordAvailable?.value == '1'
        }
        member.properties = {
          ...member.properties,
          ...properties,
        }
        // 本端数据更新
        if (meetingInfo.localMember.uuid === uuid) {
          meetingInfo.localMember = {
            ...meetingInfo.localMember,
            ...member,
          }
        }

        memberList[index] = { ...memberList[index], ...member }
      }

      return { ...state, memberList: [...memberList] }
    }

    case ActionType.DELETE_MEMBER_PROPERTIES: {
      const {
        uuid,
        properties,
      } = (action as Action<ActionType.DELETE_MEMBER_PROPERTIES>).data
      const { memberList, meetingInfo } = state
      const index = memberList.findIndex((item) => item.uuid === uuid)

      if (index > -1) {
        const member = memberList[index]
        const memberProperties = member.properties

        properties.forEach((key) => {
          if (memberProperties && memberProperties[key]) {
            delete memberProperties[key]
          }
        })
        member.properties = memberProperties
        // 本端数据更新
        if (meetingInfo.localMember.uuid === uuid) {
          meetingInfo.localMember = {
            ...meetingInfo.localMember,
            ...member,
          }
        }

        memberList[index] = { ...memberList[index], ...member }
      }

      return { ...state, memberList: [...memberList] }
    }

    case ActionType.UPDATE_MEETING_INFO: {
      let { meetingInfo } = state
      const partMeetingInfo = (action as Action<ActionType.UPDATE_MEETING_INFO>)
        .data

      meetingInfo = { ...meetingInfo, ...partMeetingInfo }
      // 更新设置
      if (partMeetingInfo.setting) {
        const setting = partMeetingInfo.setting

        setLocalStorageSetting(JSON.stringify(setting))
        meetingInfo.enableVideoMirror =
          setting.videoSetting.enableVideoMirroring
        meetingInfo.galleryModeMaxCount =
          setting.videoSetting.galleryModeMaxCount
        meetingInfo.showDurationTime = setting.normalSetting.showDurationTime
        meetingInfo.enableFixedToolbar = setting.normalSetting.showToolbar
        meetingInfo.showSpeaker = setting.normalSetting.showSpeakerList
        meetingInfo.enableUnmuteBySpace =
          setting.audioSetting.enableUnmuteBySpace
        meetingInfo.enableTransparentWhiteboard =
          setting.normalSetting.enableTransparentWhiteboard
      }

      if (partMeetingInfo.interpretation) {
        const localMember = meetingInfo.localMember

        meetingInfo.isInterpreter = !!partMeetingInfo.interpretation
          .interpreters?.[localMember.uuid]
      }

      // 如果有取消共享的需要重新排序下列表
      // if (
      //   partMeetingInfo.focusUuid !== undefined ||
      //   partMeetingInfo.activeSpeakerUuid !== undefined
      // ) {
      // memberList = sortMembers(memberList, meetingInfo.localMember.uuid)
      // }
      return { ...state, meetingInfo }
    }

    case ActionType.SET_MEETING: {
      const meeting = (action as Action<ActionType.SET_MEETING>).data
      const memberList = meeting.memberList
      const { meetingInfo } = state

      // 成员列表进行排序
      // memberList = sortMembers(memberList, meetingInfo.localMember.uuid)
      meeting.memberList = memberList
      const _meetingInfo = {
        ...meetingInfo,
        ...meeting.meetingInfo,
      } as NEMeetingInfo
      const properties = _meetingInfo.properties

      if (properties.audioOff) {
        _meetingInfo.audioOff = properties.audioOff.value?.split('_')[0]
      }

      if (properties.videoOff) {
        _meetingInfo.videoOff = properties.videoOff.value?.split('_')[0]
      }

      if (properties.lock) {
        _meetingInfo.isLocked = properties.lock.value === 1
      }

      if (properties.live) {
        _meetingInfo.liveState = properties.live.state
      }

      if (properties.wbSharingUuid) {
        _meetingInfo.whiteboardUuid = properties.wbSharingUuid.value
      }

      if (properties.whiteboardConfig) {
        const config = properties.whiteboardConfig.value
        let isTransparent = false

        try {
          isTransparent = JSON.parse(config).isTransparent
        } catch (e) {
          console.error('parse whiteboardConfig error', e)
        }

        _meetingInfo.isWhiteboardTransparent = isTransparent === true
      }

      meeting.meetingInfo = _meetingInfo
      const _meeting = { ...meeting, ...{ meetingInfo: _meetingInfo } }

      return { ...state, ..._meeting }
    }

    case ActionType.RESET_MEETING: {
      return {
        memberList: [],
        meetingInfo: createMeetingInfoFactory(),
        inInvitingMemberList: [],
      }
    }

    case ActionType.SIP_ADD_MEMBER: {
      const { member } = (action as Action<ActionType.SIP_ADD_MEMBER>).data
      const { inInvitingMemberList } = state

      if (!inInvitingMemberList) {
        return state
      }

      const index = inInvitingMemberList.findIndex(
        (item) => item.uuid === member.uuid
      )

      if (index > -1) {
        inInvitingMemberList[index] = member
      } else {
        inInvitingMemberList.push(member)
      }

      return { ...state, inInvitingMemberList: [...inInvitingMemberList] }
    }

    case ActionType.SIP_REMOVE_MEMBER: {
      const { uuids } = (action as Action<ActionType.SIP_REMOVE_MEMBER>).data
      const { inInvitingMemberList } = state

      if (!inInvitingMemberList) {
        return state
      }

      uuids.forEach((uuid) => {
        const index = inInvitingMemberList.findIndex(
          (member) => member.uuid === uuid
        )

        index > -1 && inInvitingMemberList.splice(index, 1)
      })
      return { ...state, inInvitingMemberList: [...inInvitingMemberList] }
    }

    case ActionType.SIP_UPDATE_MEMBER: {
      const memberInfo = (action as Action<ActionType.SIP_UPDATE_MEMBER>).data
      // const meetingInfo = state.meetingInfo
      const { inInvitingMemberList } = state

      if (!inInvitingMemberList) {
        return state
      }

      const index = inInvitingMemberList.findIndex(
        (item) => item.uuid === memberInfo.uuid
      )

      if (index > -1) {
        inInvitingMemberList[index] = {
          ...inInvitingMemberList[index],
          ...memberInfo.member,
        }
      } else {
        return state
      }

      // 本端数据更新
      // 成员列表进行排序
      // memberList = sortMembers(memberList, meetingInfo.localMember.uuid)
      return { ...state, inInvitingMemberList: [...inInvitingMemberList] }
    }

    case ActionType.SIP_RESET_MEMBER: {
      return { ...state, inInvitingMemberList: [] }
    }

    default:
      return { ...state }
  }
}

export const MeetingInfoContextProvider: React.FC<MeetingInfoProviderProps> = (
  props
) => {
  // const memberList = sortMembers(
  //   props.memberList,
  //   props.meetingInfo.localMember.uuid
  // )
  const [meetingInfo, dispatch] = useReducer(meetingInfoReducer, {
    meetingInfo: props.meetingInfo,
    memberList: props.memberList,
    inInvitingMemberList: props.inInvitingMemberList,
  })
  const [waitingRoomInfo, waitingRoomDispatch] = useReducer(
    waitingRoomReducer,
    {
      waitingRoomInfo: {
        memberCount: 0,
        isEnabledOnEntry: false,
        unReadMsgCount: 0,
      },
      memberList: [],
    }
  )

  return (
    <MeetingInfoContext.Provider value={{ ...meetingInfo, dispatch }}>
      <WaitingRoomContext.Provider
        value={{ ...waitingRoomInfo, dispatch: waitingRoomDispatch }}
      >
        {props.children}
      </WaitingRoomContext.Provider>
    </MeetingInfoContext.Provider>
  )
}

/**
 * 视频排序规则
 * 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
 * 自己->音视频>视频->音频->都不开
 **/
export function sortMembers(
  memberList: NEMember[],
  localUuid: string
): NEMember[] {
  const tmpMemberList = [...memberList]

  // 0 表示不变，-1表示pre排前面，1表示next排前面
  tmpMemberList.sort((pre, next) => {
    if (pre.uuid !== localUuid && next.uuid !== localUuid) {
      // 都不是自己
      // 都开启音频和视频
      if (pre.isVideoOn && pre.isAudioOn && next.isAudioOn && next.isVideoOn) {
        return 0
      } else {
        // 都开视频或者都不开视频
        if (
          (pre.isVideoOn && next.isVideoOn) ||
          (!pre.isVideoOn && !next.isVideoOn)
        ) {
          // 都开音频或者都不开音频
          if (
            (pre.isAudioOn && next.isAudioOn) ||
            (!pre.isAudioOn && !next.isAudioOn)
          ) {
            return 0
          } else {
            return pre.isAudioOn > next.isAudioOn ? -1 : 1
          }
        } else {
          return pre.isVideoOn > next.isVideoOn ? -1 : 1
        }
      }
    } else {
      return pre.uuid === localUuid ? -1 : 1
    }
    // // 都是主持人或者都不是主持人
    // if (pre.role !== Role.host && next.role !== Role.host) {
    //   // 都是联席主持人或者都不是联席主持人
    //   if (
    //     (pre.role === Role.coHost && next.role === Role.coHost) ||
    //     (pre.role !== Role.coHost && next.role !== Role.coHost)
    //   ) {
    //
    //   } else {
    //     return pre.role === Role.coHost ? -1 : 1
    //   }
    // } else {
    //   return pre.role === Role.host ? -1 : 1
    // }
  })
  return tmpMemberList
}

/*
function map2List(membersMap: Map<string, NEMember>): NEMember[] {
  const memberList: NEMember[] = []
  for (const member of membersMap.values()) {
    memberList.push(member)
  }
  return memberList
}
*/
