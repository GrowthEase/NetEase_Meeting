import {
  shareMode,
  memberLeaveTypes,
  Role,
  AttendeeOffType,
} from './../libs/enum'
import Vue from 'vue'
import Vuex from 'vuex'
import {
  MeetingControl,
  NeMember,
  Layout,
  NoMuteAllConfig,
  VideoProfile,
  MuteBtnConfig,
  ChatroomConfig,
  GetMeetingConfigResponse,
} from '../types/index'
import { getLocalInfo, handsUpStatus } from '../utils'
import {
  NEMeetingIdDisplayOptions,
  defaultMenus,
  defaultMoreMenus,
  defaultSmallMenus,
} from '../libs/enum'
import { Message } from '@xkit-yx/kit-chatroom-web/es/Chatroom/chatroomHelper'
import { Speaker } from '@/types/type'

Vue.use(Vuex)

// "mute_video": 1 , // int ， 是否有画面，1：有，2：无（自己禁），3：无（主持人关闭），4：有（主持人解禁状态）
// "mute_audio": 1,  // int ， 是否有声音，1：有，2：无（自己禁），3：无（主持人关闭），4：有（主持人解禁状态）

function unique(list) {
  return list.filter((item, index, arr) => {
    return arr.indexOf(item, 0) === index
  })
}

// 更新成员列表昵称
function updateNickname(member: any, localInfo: any): string {
  let extraMsg = ''
  if (member.isHost) {
    if (localInfo.avRoomUid === member.avRoomUid) {
      extraMsg = '（主持人，我）'
    } else {
      extraMsg = '（主持人）'
    }
  } else if (localInfo.avRoomUid === member.avRoomUid) {
    if (localInfo.role === Role.coHost) {
      extraMsg = '（联席主持人，我）'
    } else {
      extraMsg = '（我）'
    }
  } else if (member.role === Role.coHost) {
    extraMsg = '（联席主持人）'
  }
  return extraMsg
}

export default new Vuex.Store({
  state: {
    status: 0, // 0-未登录 1-已登录 2-会议中
    meetingInfo: {
      // 当前会议的信息
      hostAvRoomUid: 0,
      focusAvRoomUid: 0,
      // screenSharingUid: 0,
      whiteboardAvRoomUid: Array<number>(),
      whiteboardOwnerImAccid: [],
      screenSharersAvRoomUid: Array<number>(),
      screenSharersAccountId: [],
      activeSpeakerUid: 0,
      type: 0, // 1即刻会议2个人会议3预约会议
      shortId: 0, // 短号
      shareMode: 0,
    },
    controls: Array<MeetingControl>(), // 会议控制
    memberMap: {}, // 参会成员map，key是avRoomUid，value是成员对象，包含uid，音视频状态，stream等
    memberIdList: Array<number>(), // 参会成员avRoomUid列表，用于成员列表排序
    memberIdVideoList: Array<number>(), // 参会成员avRoomUid列表，用于画面排序
    memberIdHideList: Array<number>(),
    realMemberList: Array<number>(),
    layout: 'speaker', // 布局模式 speaker-演讲者视图，gallery-画廊视图
    localInfo: {
      audio: 0, // 对应上方映射
      video: 0,
      screen: 0,
      isUnMutedVideo: false, // 本端是否点击开启播放过，用于第一次开启音视频进入会议，是否需要走unmute
      isUnMutedAudio: false, // 本端是否点击开启播放过，用于第一次开启音视频进入会议，是否需要走unmute
      whiteBoardShare: 0,
      whiteBoardInteract: '0', // 白板授权绘制权限
      role: 'member', // 'participant'、 'AnonymousParticipant'
      avRoomUid: 0,
      noRename: false, // 改名开关
      nickName: '',
      wbTargetOrigin: '',
      wbTargetUrl: '',
      isHandsUp: false, // 举手
      meetingIdDisplayOptions: NEMeetingIdDisplayOptions.displayAll, // 默认展示全部
      mainSpeakerUId: 0, // 演讲者模式时展示Id
      toolBarList: defaultMenus, // 主区按钮
      moreBarList: defaultMoreMenus, // 更多区按钮
      smallBarList: defaultSmallMenus, // 小窗布局，主区按钮
      whiteBoardGlobalConfig: {}, // 默认应用白板配置
      recordGlobalConfig: {}, // 默认录制配置
      attendeeRecordOn: false, // 录制开关
      defaultRenderMode: 'big', // 窗口形式
      showMySmallVideo: true, // 小窗自我展示
      hideLeave: false, // 隐藏离开按钮
      leaveCallBack: (LeaveTypes: memberLeaveTypes) => true, // 离开回调
      smallModeDom: null,
    },
    whiteBoardHasLoaded: false,
    showList: false, // 是否展示参会者列表
    showChatroom: false, // 是否展示聊天室
    unReadMsgs: Array<Message>(),
    meetingId: '', // 会议Id
    tempStream: {},
    speakerDevicesList: Array<any>(), // 设备列表 - 扬声
    audioDevicesList: Array<any>(), // 设备列表 - 输入
    videoDevicesList: Array<any>(), // 设备列表 - 视频
    defaultSelect: 'video', // 设置默认选择
    microphoneId: '',
    speakerId: '',
    cameraId: '',
    resetVideoId: '', // 视频切换时无法实时获取deviceId，做一个缓存
    beforeLoading: false,
    meetLockStatus: 1, // 1放开2锁定
    online: 2, // 在线状态 默认已连接 0 断开 1 重连中 2 连接正常
    allowUnMuteAudioBySelf: true, // 允许自我解除静音,该字段为老版本保留怕影响逻辑
    allowUnMuteVideoBySelf: true, // 允许自我开启视频,该字段为老版本保留怕影响逻辑
    audioOff: AttendeeOffType.disable as AttendeeOffType, // 表示主持操作全体静音，全体解除静音， 静音且不允许自我解除
    videoOff: AttendeeOffType.disable as AttendeeOffType, // 表示主持操作全体静音，全体解除静音， 静音且不允许自我解除
    isNEMeetingInit: false,
    theme: {
      // headerBgColor: '#fff',
      // headerColor: '#000',
      // contentBgColor: '#fff',
      // contentColor: '#000',
      // videoBgColor: 'rgba(0, 0, 0, 0.5)',
      // controlBarBgColor: '#fff',
      // controlBarColor: '#000',
    },
    websiteState: {
      joinInfo: {
        audio: getLocalInfo('joinInfo', 'audio') ? 1 : 2,
        video: getLocalInfo('joinInfo', 'video') ? 1 : 2,
      },
    },
    showMaxCount: false, // 是否显示房间应进人数
    showMemberTag: false, // 是否显示
    showSubject: false, // 顶部是否显示会议主题
    showFocusBtn: true, // 是否显示设置焦点后画面右上角的按钮， 默认为true
    enableSortByVoice: true, // 设置是否根据声音大小动态排序 默认为true
    canvasInfo: null, // 当前画布布局信息，null或者Layout
    noMuteAllConfig: {
      noMuteAllVideo: true, // 配置会议中成员列表是否显示"全体关闭/打开视频"，默认为true，即不显示
      noMuteAllAudio: false, // 配置会议中成员列表是否显示"全体禁音/解除全体静音"，默认为false，即显示
    },
    muteBtnConfig: {
      showMuteAllVideo: false, // 显示全体关闭视频按钮
      showUnMuteAllVideo: false, // 显示全体开启按钮
      showMuteAllAudio: true, // 显示全体静音按钮
      showUnMuteAllAudio: true, // 显示全体解除静音按钮
    },
    videoProfile: {
      resolution: 720, // 设置视频分辨率 1080 720 480 180
      frameRate: 25, // 设置帧率25 20 15 10 5
    },
    focusVideoProfile: {
      resolution: 720, // 设置视频分辨率 1080 720 480 180
      frameRate: 25, // 设置帧率25 20 15 10 5
    },
    chatroomConfig: null as null | ChatroomConfig, // 聊天室单向聊天配置
    noSip: true, // 是否开启sip
    env: 'web', // 当前环境 web electron
    speakerList: [] as Speaker[], // 当前说话者列表，本都如果说话为第一项，leave不同于远端只有0-1
    showSpeaker: true, // 是否展示说话者列表 默认为true
    remainingTime: 0, // 会议剩余时间
    globalConfig: {} as GetMeetingConfigResponse,
    screenSharingSourceId: '', // electron共享时候需要传入这个id
    enableUnmuteBySpace: false, // 是否支持长按空格进行解除静音
  },
  mutations: {
    toggleLayout(state, newLayout?: string) {
      state.layout =
        newLayout || (state.layout === 'speaker' ? 'gallery' : 'speaker')
    },
    updateWBLoaded(state, newValue: boolean) {
      state.whiteBoardHasLoaded = newValue
    },
    toggleList(state, newValue) {
      const finalValue = newValue === undefined ? !state.showList : newValue
      state.showList = finalValue
    },
    toggleChatroom(state, newValue) {
      const finalValue = newValue === undefined ? !state.showChatroom : newValue
      state.showChatroom = finalValue
      if (finalValue) {
        const { commit } = this as any
        commit('resetUnReadMsgs')
      }
    },
    addUnReadMsgs(state, newVal) {
      state.unReadMsgs.push(...newVal)
    },
    resetUnReadMsgs(state) {
      state.unReadMsgs = []
    },
    addRealMemberList(state, uid: number) {
      const result = [...state.realMemberList]
      result.push(uid)
      state.realMemberList = unique(result)
      console.log('real-member-add', state.realMemberList)
    },
    removeRealMemberList(state, uid) {
      const result = [...state.realMemberList]
      const i = result.indexOf(uid)
      if (i >= 0) {
        result.splice(i, 1)
      }
      state.realMemberList = unique(result)
      console.log('real-member-remove', state.realMemberList)
    },
    resetRealMemberList(state) {
      state.realMemberList = []
    },
    resetMembers(state, list: Array<NeMember>) {
      state.memberIdList = []
      state.memberIdVideoList = []
      state.memberIdHideList = []
      state.realMemberList = []
      state.memberMap = {}
      if (list.length === 0) {
        return
      }
      //console.warn('更新 memberMap:list ', list)
      list.forEach((item: any) => {
        const uid = item.accountId
        item.isHost = item.role === Role.host
        // if (state.meetingInfo.hostAvRoomUid === item.avRoomUid) {
        //   //console.log('host')
        //   item.isHost = true
        // } else {
        //   item.isHost = false
        // }
        if (state.meetingInfo.focusAvRoomUid === item.avRoomUid) {
          item.isFocus = true
        } else {
          item.isFocus = false
        }
        // if (state.tempStream[uid]) {
        //   item.stream = state.tempStream[uid].stream
        //   item.basicStream = state.tempStream[uid].basicStream
        //   item.screenStream = state.tempStream[uid].screenStream
        // }
        state.memberMap[uid] = item
        if (item.role === Role.ghost) {
          state.memberIdHideList.push(uid)
        } else {
          state.memberIdList.push(uid)
          state.memberIdVideoList.push(uid)
          state.realMemberList.push(uid)
        }
      })
    },
    setMeetingInfo(state, list: any) {
      //console.warn('更新会议详情: ', list)
      state.meetingInfo = { ...state.meetingInfo, ...list }
    },
    resetMeetingInfo(state, val: any) {
      state.meetingInfo = {
        ...val,
        ...{
          activeSpeakerUid: state.meetingInfo.activeSpeakerUid,
          whiteboardAvRoomUid: val.whiteboardAvRoomUid || [],
          whiteboardOwnerImAccid: val.whiteboardAvRoomUid || [],
          screenSharersAvRoomUid: val.screenSharersAvRoomUid || [],
          screenSharersAccountId: val.screenSharersAvRoomUid || [],
        },
      }
    },
    sortMemberIdList(state, memberIdList: Array<number>) {
      //   state.memberIdList = unique(memberIdList)
      state.memberIdList = unique(
        memberIdList.filter((item) => state.realMemberList.includes(item))
      )
    },
    sortMemberIdVideoList(state, memberIdVideoList: Array<number>) {
      //   state.memberIdVideoList = unique(memberIdVideoList)
      state.memberIdVideoList = unique(
        memberIdVideoList.filter((item) => state.realMemberList.includes(item))
      )
    },
    sortMemberIdHideList(state, memberIdVideoList: Array<number>) {
      //   state.memberIdHideList = unique(memberIdVideoList)
      state.memberIdHideList = unique(
        memberIdVideoList.filter((item) => state.realMemberList.includes(item))
      )
    },
    addMember(state, member: NeMember) {
      //console.log('store addMember ', member, state)
      const { commit } = this as any
      member.isHost = state.meetingInfo.hostAvRoomUid === member.avRoomUid
      member.isFocus = state.meetingInfo.focusAvRoomUid === member.avRoomUid
      const uid = member.avRoomUid
      if (!uid) {
        console.log('uid不存在，不添加成员')
        return
      }
      if (member.role === Role.ghost) {
        // 影子成员
        state.memberIdHideList.push(uid)
      } else {
        state.memberIdList.push(uid)
        state.memberIdVideoList.push(uid)
      }
      state.memberMap[uid] = member
      // 若member有暂存的stream，则更新
      // if (state.tempStream[uid]) {
      //   state.memberMap[uid].stream = state.tempStream[uid].stream
      //   state.memberMap[uid].screenStream = state.tempStream[uid].screenStream
      //   state.memberMap = Object.assign({}, state.memberMap)
      // }
      state.memberMap = Object.assign({}, state.memberMap)
      commit('sortMemberIdList', state.memberIdList)
      commit('sortMemberIdVideoList', state.memberIdVideoList)
      commit('sortMemberIdHideList', state.memberIdHideList)
      // 避免重复add，如果已存在，则更新之
      if (state.memberMap[uid]) {
        Object.assign(state.memberMap[uid], member)
        return
      }
    },
    removeMember(state, uid) {
      const { commit } = this as any
      //console.error('删除 uid: ', uid)
      // if (!state.memberMap[uid]) return

      let i = state.memberIdList.indexOf(uid)
      if (i >= 0) state.memberIdList.splice(i, 1)
      i = state.memberIdVideoList.indexOf(uid)
      if (i >= 0) state.memberIdVideoList.splice(i, 1)
      i = state.memberIdHideList.indexOf(uid)
      if (i >= 0) state.memberIdHideList.splice(i, 1)
      i = state.meetingInfo.screenSharersAvRoomUid.indexOf(uid)
      if (i >= 0) {
        state.meetingInfo.screenSharersAvRoomUid.splice(i, 1)
        state.meetingInfo.shareMode = shareMode.noshare
      }
      i = state.meetingInfo.whiteboardAvRoomUid.indexOf(+uid)
      if (i >= 0) {
        state.meetingInfo.whiteboardAvRoomUid.splice(i, 1)
        state.meetingInfo.shareMode = shareMode.noshare
      }
      if (state.meetingInfo.activeSpeakerUid === +uid) {
        state.meetingInfo.activeSpeakerUid = 0
      }
      const result = Object.assign({}, state.memberMap)
      delete result[uid]
      state.memberMap = Object.assign({}, result)
      delete state.tempStream[uid]
      commit('sortMemberIdList', state.memberIdList)
      commit('sortMemberIdVideoList', state.memberIdVideoList)
      commit('sortMemberIdHideList', state.memberIdHideList)
    },
    updateMember(state, item) {
      //console.warn('更新成员列表信息 ', item)
      const { commit } = this as any
      // item.isHost = state.meetingInfo.hostAvRoomUid === item.avRoomUid;
      // item.isFocus = state.meetingInfo.focusAvRoomUid === item.avRoomUid;

      if (item.isActiveSpeaker) {
        let key: any
        for (key in state.memberMap) {
          state.memberMap[key].isActiveSpeaker = key === item.uid
        }
      }
      state.memberMap[item.avRoomUid || item.uid] = Object.assign(
        {},
        state.memberMap[item.avRoomUid || item.uid],
        item
      )
      // 更新昵称
      if (item.role) {
        state.memberMap[item.avRoomUid || item.uid].extraMsg = updateNickname(
          state.memberMap[item.avRoomUid || item.uid],
          state.localInfo
        )
      }
      state.memberMap = Object.assign({}, state.memberMap)
    },
    setStream(state, params) {
      if (!state.tempStream[params.uid]) {
        state.tempStream[params.uid] = {}
      }

      if (params.stream) state.tempStream[params.uid].stream = params.stream
      state.tempStream[params.uid].basicStream = params.basicStream
      if (params.screenStream)
        state.tempStream[params.uid].screenStream = params.screenStream
      if (!state.memberMap[params.uid]) {
        // 还没有获取到用户信息，暂存stream
        return
      }
      if (params.stream) state.memberMap[params.uid].stream = params.stream
      state.memberMap[params.uid].basicStream = params.basicStream
      if (params.screenStream)
        state.memberMap[params.uid].screenStream = params.screenStream
      state.memberMap = Object.assign({}, state.memberMap)
    },
    changeMeetingStatus(state, status: 0 | 1 | 2) {
      state.status = status
    },
    setMeetingId(state, id: '') {
      state.meetingId = id
    },
    setSpeakerDevicesList(state, list) {
      state.speakerDevicesList = list
    },
    setShowSpeaker(state, isShow) {
      state.showSpeaker = isShow
    },
    setRemainingTime(state, time: number) {
      state.remainingTime = time || 0
    },
    setGlobalConfig(state, config: GetMeetingConfigResponse) {
      state.globalConfig = config
    },
    setAudioDevicesList(state, list) {
      state.audioDevicesList = list
    },
    setVideoDevicesList(state, list) {
      state.videoDevicesList = list
    },
    setNoSip(state, noSip: boolean) {
      state.noSip = noSip
    },
    setSettingSelect(state, type) {
      state.defaultSelect = type
    },
    setMicrophoneId(state, id) {
      state.microphoneId = id
    },
    setSpeakerId(state, id) {
      state.speakerId = id
    },
    setCameraId(state, id) {
      state.cameraId = id
    },
    toggleBeforeLoading(state, value) {
      state.beforeLoading = value
    },
    checkPresenter() {
      const { state, commit } = this as any
      let mainSpeakerUId = state.localInfo.avRoomUid
      commit('setLocalInfo', { mainSpeakerUId })
      if (state.memberIdList.length <= 1) return
      let hostAvRoomUid = 0
      let screenShareingUid = 0
      // let activeSpeakerUid = state.activeSpeakerUid;
      const focusUid = state.meetingInfo.focusAvRoomUid
      const activeSpeakerUid = state.meetingInfo.activeSpeakerUid
      let key: any
      for (key in state.memberMap) {
        state.memberMap[key].showBorder = false
        if (state.memberMap[key].role === Role.host) {
          hostAvRoomUid = state.memberMap[key].avRoomUid
          if (state.localInfo.avRoomUid === hostAvRoomUid) {
            state.memberMap[key].extraMsg = '（主持人，我）'
          } else {
            state.memberMap[key].extraMsg = '（主持人）'
          }
        } else if (
          state.localInfo.avRoomUid === state.memberMap[key].avRoomUid
        ) {
          if (state.localInfo.role === Role.coHost) {
            state.memberMap[key].extraMsg = '（联席主持人，我）'
          } else {
            state.memberMap[key].extraMsg = '（我）'
          }
        } else if (state.memberMap[key].role === Role.coHost) {
          state.memberMap[key].extraMsg = '（联席主持人）'
        }
        //TODO 屏幕共享处理未统一，后续调整
        if (
          state.memberMap[key].screenSharing &&
          state.realMemberList.includes(key)
        ) {
          screenShareingUid = state.memberMap[key].avRoomUid
        }

        // if (state.memberMap[key].isActiveSpeaker) {
        //   activeSpeakerUid = state.memberMap[key].avRoomUid
        // }
      }

      //联系人列表排序(自己>主持人>联席主持人>其他人)
      const memberIdList = [...state.memberIdList]
      const selfIndex = memberIdList.findIndex(
        (item) => item === state.localInfo.avRoomUid
      )
      const first = memberIdList.splice(selfIndex, 1)[0]
      if (state.localInfo.avRoomUid === hostAvRoomUid) {
        memberIdList.unshift(first)
      } else {
        const hostIndex = memberIdList.findIndex(
          (item) => item === hostAvRoomUid
        )
        //console.warn('hostIndex: ', hostIndex)
        if (hostIndex >= 0) {
          const second = memberIdList.splice(hostIndex, 1)[0]
          memberIdList.unshift(first, second)
        } else {
          memberIdList.unshift(first)
        }
      }
      //console.warn('memberIdList: ', memberIdList)

      //视频主画面列表排序(屏幕共享>焦点>谁在讲话>双人会议>主持人>自己)
      const memberIdVideoList = [...state.memberIdVideoList]
      mainSpeakerUId =
        screenShareingUid ||
        focusUid ||
        // || state.meetingInfo.activeSpeakerUid
        (state.enableSortByVoice &&
        activeSpeakerUid !== 0 &&
        state.memberMap[activeSpeakerUid] &&
        state.memberMap[activeSpeakerUid].role !== Role.ghost
          ? activeSpeakerUid
          : false) ||
        (memberIdVideoList.length === 2
          ? memberIdVideoList[
              memberIdVideoList.findIndex(
                (item) => item !== state.localInfo.avRoomUid
              )
            ]
          : 0) ||
        hostAvRoomUid ||
        // || (state.localInfo.avRoomUid === hostAvRoomUid ? 0 : hostAvRoomUid)
        // || (memberIdVideoList.length ? memberIdVideoList[memberIdVideoList.length - 1] : 0) // 导致连轴转
        state.localInfo.avRoomUid

      const avRoomUid = state.localInfo.avRoomUid
      if (
        avRoomUid &&
        (state.memberMap[avRoomUid].video === 1 ||
          state.memberMap[avRoomUid].video === 4)
      ) {
        // 自己在画廊模式首页展示第一
        const firstIndex = memberIdVideoList.findIndex(
          (item) => item === avRoomUid
        )
        const firstItem = memberIdVideoList.splice(firstIndex, 1)[0]
        memberIdVideoList.unshift(firstItem)
      }
      // 屏幕共享，焦点，讲话人，展示border
      if (
        state.memberMap[mainSpeakerUId] &&
        [focusUid, state.meetingInfo.activeSpeakerUid].includes(mainSpeakerUId)
      ) {
        state.memberMap[mainSpeakerUId].showBorder = true
      }
      //console.warn('memberIdVideoList: ', memberIdVideoList)
      const memberIdHideList = [...state.memberIdHideList]
      commit('setLocalInfo', { mainSpeakerUId })
      commit('sortMemberIdList', memberIdList)
      commit('sortMemberIdVideoList', memberIdVideoList)
      commit('sortMemberIdHideList', memberIdHideList)
      commit('checkFocus')
    },
    setLocalInfo(state, info) {
      state.localInfo = Object.assign({}, state.localInfo, info)
    },
    setTheme(state, data) {
      state.theme = Object.assign({}, state.theme, data)
    },
    resetTheme(state) {
      // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
      // @ts-ignore
      state.theme = {}
    },
    setMeetLockStatus(state, status: 1 | 2) {
      state.meetLockStatus = status
    },
    setResetVideoId(state, id) {
      state.resetVideoId = id
    },
    setAllAudioMute(state) {
      const newResult = { ...state.memberMap }
      for (const uid in newResult) {
        if (!newResult[uid].isHost && !(newResult[uid].screenSharing === 1)) {
          newResult[uid].audio = 0
        }
      }
      state.memberMap = newResult
    },
    setAllVideoMute(state) {
      const newResult = { ...state.memberMap }
      for (const uid in newResult) {
        // 设置全体静音管理员和联席主持人不需要关闭
        if (
          !newResult[uid].isHost &&
          newResult[uid].role !== Role.coHost &&
          !(newResult[uid].screenSharing === 1)
        ) {
          newResult[uid].video = 0
        }
      }
      state.memberMap = newResult
    },
    checkFocus(state) {
      const newResult = { ...state.memberMap }
      for (const uid in newResult) {
        if (state.meetingInfo.focusAvRoomUid === newResult[uid].avRoomUid) {
          newResult[uid].isFocus = true
        } else {
          newResult[uid].isFocus = false
        }
      }
      state.memberMap = newResult
    },
    setOnline(state, value) {
      state.online = value
    },
    setAllowUnMuteAudioBySelf(state, value: boolean) {
      state.allowUnMuteAudioBySelf = value
    },
    setAudioOff(state, audioOff: AttendeeOffType) {
      state.audioOff = audioOff
    },
    setVideoOff(state, videoOff: AttendeeOffType) {
      state.videoOff = videoOff
    },
    setAllowUnMuteVideoBySelf(state, value: boolean) {
      state.allowUnMuteVideoBySelf = value
    },
    resetHandsUpStatus(state, handsType = 1) {
      for (const key in state.memberMap) {
        const item = state.memberMap[key]
        item.handsUps = handsUpStatus({ value: '0' })
      }
    },
    setIsNEMeetingInit(state, value: boolean) {
      state.isNEMeetingInit = value
    },
    // 自此往下是涉及到web的方法
    setWebsiteJoinInfo(state, value) {
      state.websiteState.joinInfo = Object.assign(
        {},
        state.websiteState.joinInfo,
        value
      )
    },
    setShowingMaxCount(state, showMaxCount: boolean) {
      state.showMaxCount = showMaxCount
    },
    setShowMemberTag(state, showTag) {
      state.showMemberTag = showTag
    },
    setNoMuteAllConfig(state, nuMuteAllConfig: NoMuteAllConfig) {
      state.noMuteAllConfig = nuMuteAllConfig
    },
    setMuteBtnConfig(state, muteBtnConfig?: MuteBtnConfig) {
      if (muteBtnConfig) {
        state.muteBtnConfig = { ...state.muteBtnConfig, ...muteBtnConfig }
      }
    },
    setShowFocusBtn(state, showFocusBtn) {
      state.showFocusBtn = showFocusBtn
    },
    setShowSubject(state, showSubject: boolean) {
      state.showSubject = showSubject
    },
    setVideoProfile(state, videoProfile: VideoProfile) {
      state.videoProfile = { ...state.videoProfile, ...videoProfile }
    },
    setFocusVideoProfile(state, videoProfile: VideoProfile) {
      state.focusVideoProfile = { ...state.focusVideoProfile, ...videoProfile }
    },
    setEnv(state, env: 'web' | 'electron') {
      state.env = env
    },
    setSpeakerList(state, speakerList: Speaker[]) {
      state.speakerList = [...speakerList]
    },

    setEnableSortByVoice(state, enableSortByVoice: boolean) {
      state.enableSortByVoice = enableSortByVoice
    },
    setChatroomConfig(state, chatroomConfig?: ChatroomConfig) {
      if (chatroomConfig) {
        state.chatroomConfig = chatroomConfig
      }
    },
    setControl(state, controls) {
      state.controls = controls
    },
    setCanvasInfo(state, layoutInfo: Layout) {
      state.canvasInfo = Object.assign({}, state.canvasInfo, layoutInfo)
    },
    setScreenSharingSourceId(state, id: string) {
      state.screenSharingSourceId = id
    },
    setEnableUnmuteBySpace(state, enableUnmute) {
      state.enableUnmuteBySpace = enableUnmute
    },
  },
  actions: {
    sortMemberList({ commit }) {
      commit('checkPresenter')
    },
    resetInfo({ commit }) {
      commit('setLocalInfo', {
        audio: 0,
        video: 0,
        screen: 0,
        whiteBoardShare: 0,
        role: 'participant',
        avRoomUid: 0,
        meetingIdDisplayOptions: NEMeetingIdDisplayOptions.displayAll,
        mainSpeakerUId: 0,
        nickName: '',
        isHandsUp: false,
        // whiteBoardGlobalConfig: {},
        // recordGlobalConfig: {},
        attendeeRecordOn: false,
        noRename: false,
      })
      commit('resetMeetingInfo', {
        hostAvRoomUid: 0,
        focusAvRoomUid: 0,
        // screenSharingUid: 0,
        whiteboardAvRoomUid: [],
        whiteboardOwnerImAccid: [],
        screenSharersAvRoomUid: [],
        screenSharersAccountId: [],
        type: 0,
        shortId: 0,
        shareMode: 0,
      })
      commit('resetUnReadMsgs', [])
      commit('toggleLayout', 'speaker')
      commit('setMeetLockStatus', 0)
      commit('toggleBeforeLoading', false)
      commit('resetRealMemberList')
      commit('resetMembers', [])
      commit('setAllowUnMuteAudioBySelf', true)
      commit('setAllowUnMuteVideoBySelf', true)
      commit('setAudioOff', AttendeeOffType.disable)
      commit('setVideoOff', AttendeeOffType.disable)
      commit('setShowSpeaker', true)
      commit('setSpeakerList', [])
      commit('setRemainingTime', 0)
      commit('setEnv', 'web')
      commit('setScreenSharingSourceId', '')
      commit('setEnableUnmuteBySpace', false)
    },
    setCanvasInfo({ commit }, layoutInfo: Layout) {
      commit('setCanvasInfo', layoutInfo)
    },
  },
  modules: {},
  getters: {
    audioControl() {
      // 音频控制
    },
    videoControl() {
      // 视频控制
    },
  },
})
