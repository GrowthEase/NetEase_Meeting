<template>
  <div
    tabindex="-1"
    ref="meeting"
    @keydown="keydownEventHandler"
    @keyup="keyupEventHandler"
    class="meeting"
    :style="`height: ${height && !isWebSite ? height + 'px' : '100%'};width: ${
      width ? width + 'px' : '100%'
    }; position: relative; background-color: ${
      theme.contentBgColor || ''
    }; color: ${theme.contentColor || ''};`"
  >
    <div
      v-if="!$store.state.beforeLoading && defaultRenderMode === 'big'"
      style="height: 100%; width: 100%"
    >
      <div
        class="meeting-header"
        :style="{
          background: theme.headerBgColor || '',
          color: theme.headerColor || '',
        }"
      >
        <img
          v-if="isWebSite"
          class="meeting-logo flex-same"
          :src="require('../assets/meeting-logo.png')"
          alt="meeting log"
        />
        <div v-else class="meeting-logo flex-same"></div>
        <div class="meeting-subject" v-if="meetingId">
          <span v-if="$i18n.locale !== 'zh'">
            {{ $t('appName') }}
          </span>
          <span v-else class="meeting-title">
            {{ showSubject ? meetingInfo.subject : `会议ID：${meetingId}` }}
          </span>
          <MeetingInfo v-if="meetingInfo" />
        </div>
        <div class="meeting-header-userinfo flex-same">
          <span
            v-if="$store.state.localInfo.nickName"
            class="meeting-header-userinfo-content"
          >
            {{ $store.state.localInfo.nickName.charAt(0) }}
          </span>
        </div>
      </div>
      <div
        class="meeting-main"
        ref="meetingMain"
        :style="`max-width: ${baseHeight * 1.77}px;`"
        @click="clickBox"
      >
        <!--    剩余时间提醒    -->
        <RemainingTimeTip
          class="time-tip-wrap"
          v-if="showTimeTip && showTimeTipByGlobalConfig"
          :text="timeTipContent"
          @close="onRemainingTimeCloseHandler"
        />
        <!--   说话者列表     -->
        <SpeakerList
          v-if="showSpeaker && !isLocalScreen"
          :class="showSpeakerList ? '' : 'speaker-list-hide'"
          @handleClick="showSpeakerList = !showSpeakerList"
          :speakerList="speakerList"
          v-show="speakerList.length > 0 && memberNum > 1"
        />
        <slider
          @changeIndex="onIndexChange"
          :class="`${$store.state.layout}-slider`"
          :width="isSpeaker ? 656 : baseHeight * 1.77"
          :num="memberIdListGroup.length"
          ref="slider"
          v-show="
            (!isLocalScreen && memberIdListGroup.length > 0) ||
            isWhiteBoardShare
          "
        >
          <div
            :style="`width: ${isSpeaker ? 656 : baseHeight * 1.77}px`"
            v-for="(list, i) in memberIdListGroup"
            :class="`slider slider-for-${list.length}`"
            :key="i"
          >
            <video-card
              :ref="`videoCard_${item}`"
              :class="`for-${list.length}`"
              v-for="item in list"
              :key="item"
              :uid="item"
              :isShowVideo="i === currentIndex"
              :myUid="myUid"
              :member="memberMap[item]"
              :isScreen="isScreen"
              :main="false"
              :muted="item === myUid"
            ></video-card>
          </div>
        </slider>
        <!-- <div class="right-top-corner">
            <p class="recording" v-if="showRecording">
              <i class="recording-icon"></i>
              录制中
            </p>
          </div> -->
        <!--        为了能够切换用户销毁dom，以免造成复用dom多个画面情况-->
        <video-card
          v-for="item in [mainSpeakerUId]"
          :key="item"
          :muted="item === myUid"
          :ref="`videoCard_${item}_main`"
          :isPresenter="isPresenter"
          :isScreen="isScreen"
          mediaType="video"
          v-if="isSpeaker && !isScreen && !isWhiteBoardShare && memberMap[item]"
          :member="memberMap[mainSpeakerUId]"
          :isShowVideo="true"
          :myUid="myUid"
          :uid="mainSpeakerUId"
          :style="`height: ${baseHeight}px;`"
          :main="true"
        />
        <video-card
          :muted="mainSpeakerUId === myUid"
          :ref="`videoCard_${mainSpeakerUId}_main`"
          :isPresenter="isPresenter"
          :isScreen="isScreen"
          mediaType="screen"
          v-if="isScreen && !isWhiteBoardShare && memberMap[mainSpeakerUId]"
          :member="memberMap[mainSpeakerUId]"
          :isShowVideo="true"
          :myUid="myUid"
          :uid="mainSpeakerUId"
          :style="`height: ${baseHeight}px;`"
          :main="true"
        />
        <WhiteBoard
          :isWhiteBoardShare="isWhiteBoardShare"
          v-if="isWhiteBoardShare"
          ref="whiteBoard"
          :baseHeight="baseHeight"
        />
      </div>
      <!-- 隐藏用户 -->
      <div v-show="false">
        <video-card
          v-for="item in memberIdHideList"
          :key="item"
          :uid="item"
          :stream="getStream(item)"
        ></video-card>
      </div>
      <ControlBar
        :showControlBar="showControlBar"
        :class="`meeting-footer ${showControlBar ? '' : 'hide'}`"
        v-show="$store.state.status === 2"
      />
      <!-- 不可改为v-if，影响部分初始化逻辑 -->
      <member-list
        :showMaxCount="showMaxCount"
        :showMemberTag="showMemberTag"
        :isPresenter="isPresenter"
        :isScreen="isScreen"
      />
      <chatroom v-if="chatroomEnabled" />
    </div>
    <div
      v-if="!$store.state.beforeLoading && defaultRenderMode === 'small'"
      style="height: 100%; width: 100%"
      class="meeting-small-layout"
    >
      <div
        v-if="!otherMember && smallModeDom"
        class="other-notin"
        v-html="smallModeDom"
      ></div>
      <div
        v-else-if="!otherMember && !smallModeDom"
        class="other-notin"
        :style="{
          color: theme.contentColor || '',
        }"
      >
        <p class="tips">成员尚未加入</p>
      </div>
      <video-card
        class="other-hasin"
        v-else-if="otherMember && memberMap[otherMember]"
        :uid="otherMember"
        :member="memberMap[otherMember]"
        :stream="getStream(otherMember)"
        :style="`height: ${baseHeight}px;`"
      />
      <!-- 本端设置静音 -->
      <video-card
        class="self-hasin"
        v-if="showMySmallVideo && memberMap[myUid]"
        :member="memberMap[myUid]"
        :uid="myUid"
        :myUid="myUid"
        :isShowVideo="true"
        :muted="true"
        :style="`height: ${baseHeight}px;`"
      />
      <SmalllControlBar class="small-meeting-control" />
    </div>

    <BeforeEnter :isWebsite="isWebSite" v-if="$store.state.beforeLoading" />
    <VMask
      :visible.sync="connecting"
      msg="网络已断开，正在尝试重新连接…"
    ></VMask>
    <!--  长按空格取消静音  -->
    <div class="unmute-audio-toast" v-show="showUnmuteAudioToast">
      <img
        class="unmut-auido-icon"
        :src="require('../assets/mic.png')"
      />
      <div>暂时取消静音</div>
    </div>
  </div>
</template>
<script lang="ts">
import Vue from 'vue'
import ControlBar from './ControlBar.vue'
import Slider from './Slider.vue'
import VideoCard from './VideoCard.vue'
import MemberList from './MemberList.vue'
import RemainingTimeTip from './custom/RemainingTimeTip.vue'
import BeforeEnter from './BeforeEnter.vue'
import VMask from './ui/Mask.vue'
import SmalllControlBar from './SmallControlBar.vue'
import SpeakerList from './custom/SpeakerList.vue'
import { formatMeetingId } from '../utils'
import {
  NEMeetingIdDisplayOptions,
  shareMode,
  LayoutTypeEnum,
  RenderModeEnum,
  Role, AttendeeOffType, RoleType
} from "../libs/enum";
import WhiteBoard from './WhiteBoard/index.vue'
import { Logger } from '@/libs/3rd/Logger'
import { NEMenuIDs } from '../libs/enum'
import Chatroom from './Chatroom.vue'
import MeetingInfo from './MeetingInfo.vue'
import {
  Theme,
  Layout,
  StreamState,
  GetMeetingConfigResponse,
} from '@/types/index'
import store from '@/store'
import { Speaker } from '@/types/type'
const logger = new Logger('Meeting-main', true)

export default Vue.extend({
  props: {
    isDev: {
      type: Boolean,
    },
    isWebSite: {
      type: Boolean,
    },
    height: {
      type: Number,
      default: 800,
    },
    width: {
      type: Number,
      default: 0, // 0代表100%
    },
  },
  components: {
    ControlBar,
    Slider,
    VideoCard,
    MemberList,
    BeforeEnter,
    VMask,
    WhiteBoard,
    SmalllControlBar,
    Chatroom,
    MeetingInfo,
    SpeakerList,
    RemainingTimeTip,
  },
  data() {
    return {
      speaker: 0,
      showControlBar: false,
      timeOut: undefined,
      currentIndex: 0, // 当前人员页面
      body: document.querySelector('body') as HTMLBodyElement,
      showSpeakerList: true, // 是否显示说话者列表
      showTimeTip: false, // 是否显示剩余时间提示
      remainingTimer: null as any, // 剩余时间定时器句柄
      remainingSeconds: 0, // 剩余时间
      timeTipContent: '',
      hiddenTimeTipTimer: null as any, // 显示会议剩余时间1分钟后需要自动隐藏
      spaceKeydownTimer: null as any, // 按下空格延迟句柄
      cancelUnmuteTimer: null as any, // 按下空格解除静音取消句柄
      spaceKeyStatus: 'complete' as 'up' | 'down' | 'complete', // 空格按下后抬起
      showUnmuteAudioToast: false, // 是否显示暂时取消静音
    }
  },
  computed: {
    online(): number {
      return this.$store.state.online
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    isCoHost(): boolean {
      // 是否是联席主持人
      return this.$store.state.localInfo.roleType === RoleType.coHost
    },
    audio(): number{
      return this.$store.state.localInfo.audio
    },
    enableUnmuteBySpace(): boolean {
      return this.$store.state.enableUnmuteBySpace
    },
    showTimeTipByGlobalConfig(): GetMeetingConfigResponse {
      return this.$store.state.globalConfig.appConfig.ROOM_END_TIME_TIP?.enable
    },
    remainingTime(): number {
      return this.$store.state.remainingTime
    },
    showSpeaker(): boolean {
      return this.$store.state.showSpeaker
    },
    speakerList(): Speaker[] {
      return this.$store.state.speakerList
    },
    memberNum(): number {
      return this.$store.state.memberIdList.length || 0
    },
    memberMap(): Array<any> {
      return this.$store.state.memberMap
    },
    memberIdHideList(): Array<any> {
      return this.$store.state.memberIdHideList
    },
    memberIdVideoList(): Array<any> {
      //console.log('meeting.vue memberIdVideoList: ', this.$store.state.memberIdVideoList)
      return this.$store.state.memberIdVideoList
    },
    currentMemberLayout(): { layoutType: LayoutTypeEnum; uids: Array<string> } {
      // 当前显示的分组成员，用于获取当前页面可视的用户
      let currentGroup: string[] = []
      if (
        this.memberIdListGroup.length > 0 &&
        this.memberIdListGroup[this.currentIndex]
      ) {
        currentGroup = [...this.memberIdListGroup[this.currentIndex]]
      }
      if ((this.isSpeaker || this.isScreen) && !this.isWhiteBoardShare) {
        currentGroup && currentGroup.push(this.mainSpeakerUId)
      }
      return {
        layoutType: this.isSpeaker
          ? LayoutTypeEnum.speaker
          : LayoutTypeEnum.gallery,
        uids: currentGroup,
      }
    },
    memberIdListGroup(): Array<any> {
      // 注释展示第一个逻辑
      // const data = this.memberIdVideoList.slice(this.isSpeaker ? 1 : 0) || [];
      // const firstShow = this.memberIdVideoList[0] || null;
      let copyList = this.memberIdVideoList.concat()
      if (this.isWhiteBoardShare && this.meetingInfo.whiteboardAvRoomUid[0]) {
        // 白板展示分享者的摄像头
        copyList = copyList.filter(
          (ele) => ele !== this.meetingInfo.whiteboardAvRoomUid[0]
        )
        copyList.unshift(this.meetingInfo.whiteboardAvRoomUid[0])
      } else if (this.isScreen && this.meetingInfo.screenSharersAvRoomUid[0]) {
        copyList = copyList.filter(
          (ele) => ele !== this.meetingInfo.screenSharersAvRoomUid[0]
        )
        copyList.unshift(this.meetingInfo.screenSharersAvRoomUid[0])
      } else if (this.isSpeaker) {
        copyList.splice(
          copyList.findIndex((item) => this.mainSpeakerUId === item),
          1
        )
      }
      // 有画面的优先排前面
      copyList.sort((preId: number, nextId: number) => {
        const pre = this.memberMap[preId]
        const next = this.memberMap[nextId]
        const isPreVideoOn = pre ? pre.video === 1 : false
        const isNextVideoOn = next ? next.video === 1 : false
        if (isPreVideoOn !== isNextVideoOn) {
          return isPreVideoOn > isNextVideoOn ? -1 : 1
        } else {
          return 0
        }
      })
      const groupsNum = Math.ceil(copyList.length / this.groupsLen)
      const arr: Array<any> = []
      for (let i = 0; i < groupsNum; i++) {
        // 排第一逻辑
        // let pushResult: Array<any> = []
        // if (this.isSpeaker) {
        //   pushResult = data.slice(i * this.groupsLen, (i + 1) * this.groupsLen)
        // } else {
        //   pushResult = data.slice(i * this.groupsLen, (i + 1) * (this.groupsLen - (i > 0 ? 1 : 0)))
        //   if (firstShow && i > 0) {
        //     pushResult.unshift(firstShow)
        //   }
        // }
        // arr.push(pushResult)
        // 原有逻辑
        this.memberMap[copyList[i]] &&
          arr.push(copyList.slice(i * this.groupsLen, (i + 1) * this.groupsLen))
      }
      return arr
    },
    layoutType(): LayoutTypeEnum {
      return this.isSpeaker ? LayoutTypeEnum.speaker : LayoutTypeEnum.gallery
    },
    isSpeaker(): boolean {
      // 是否主持人
      return this.$store.state.layout === 'speaker'
    },
    isScreen(): boolean {
      // let key: any;
      // for(key in this.$store.state.memberMap){
      //   if (this.$store.state.memberMap[key].screenSharing) {
      //     return true
      //   }
      // }
      // return false;
      return this.$store.state.meetingInfo.shareMode === shareMode.screen
    },
    isLocalScreen(): boolean {
      return this.$store.state.localInfo.screen === 1
    },
    isWhiteBoardShare(): boolean {
      // let key: any;
      // for(key in this.$store.state.memberMap){
      //   if (this.$store.state.memberMap[key].whiteBoardSharing) {
      //     return true
      //   }
      // }
      // return false
      return this.$store.state.meetingInfo.shareMode === shareMode.whiteboard
    },
    offset(): number {
      return this.isSpeaker ? 1 : 0
    },
    groupsLen(): number {
      return this.isSpeaker ? 4 : 16
    },
    baseHeight(): number {
      let height =
        (this.isWebSite || this.height === 0
          ? document.body.clientHeight
          : this.height) - 118
      if (!this.isLocalScreen) {
        if (this.isSpeaker && this.memberIdListGroup.length)
          height = height * 0.857
      }
      return height
    },
    meetingInfo(): any {
      const {
        state: { meetingInfo },
      } = this.$store
      return meetingInfo
    },
    meetingId(): string {
      let result = ''
      const {
        state: { localInfo, meetingId, meetingInfo },
      } = this.$store
      switch (localInfo.meetingIdDisplayOptions) {
        case NEMeetingIdDisplayOptions.displayAll:
          result = meetingId.toString()
          break
        case NEMeetingIdDisplayOptions.displayLongId:
          result = meetingId.toString()
          break
        case NEMeetingIdDisplayOptions.displayShortId:
          result =
            meetingInfo?.shortId && meetingInfo.shortId !== 0
              ? meetingInfo.shortId.toString()
              : meetingId.toString()
          break
        default:
          break
      }
      return formatMeetingId(result || '')
    },
    isPresenter(): boolean {
      const result = this.$store.state.localInfo.role
      return result === Role.host
    },
    connecting(): boolean {
      return this.$store.state.online === 1
    },
    mainSpeakerUId(): string {
      return this.$store.state.localInfo.mainSpeakerUId
    },
    recordGlobalConfig(): any {
      return this.$store.state.localInfo.recordGlobalConfig
    },
    showRecording(): boolean {
      return (
        this.recordGlobalConfig.status === 1 &&
        (this.$store.state.meetingInfo?.settings?.attendeeRecordOn ||
          this.$store.state.localInfo.attendeeRecordOn)
      )
    },
    defaultRenderMode(): string {
      return this.$store.state.localInfo.defaultRenderMode
    },
    showMySmallVideo(): boolean {
      return this.$store.state.localInfo.showMySmallVideo
    },
    myUid(): string {
      return this.$store.state.localInfo.avRoomUid
    },
    smallModeDom(): string | null {
      return this.$store.state.localInfo.smallModeDom
    },
    theme(): Theme {
      return this.$store.state.theme
    },
    otherMember(): any {
      return this.memberIdVideoList.filter((item) => item !== this.myUid)[0]
    },
    chatroomEnabled(): boolean {
      return (
        this.$store.state.localInfo.toolBarList.some(
          (item) => item.id === NEMenuIDs.chat
        ) && this.$store.state.status === 2
      )
    },
    showMemberTag(): boolean {
      return this.$store.state.showMemberTag
    },
    showMaxCount(): boolean {
      return this.$store.state.showMaxCount
    },
    showSubject(): boolean {
      return this.$store.state.showSubject
    },
    renderMode(): RenderModeEnum {
      return this.defaultRenderMode === 'big'
        ? RenderModeEnum.big
        : RenderModeEnum.small
    },
  },
  watch: {
    'audio': function(newValue) {
      if(newValue !== 1) {
        this.showUnmuteAudioToast = false
      }
    },
    // 显示倒计时提示后 需要1分钟后自动关闭
    showTimeTip: function (newVal: boolean, preVal: boolean) {
      if (newVal) {
        this.hiddenTimeTipTimer && clearTimeout(this.hiddenTimeTipTimer)
        this.hiddenTimeTipTimer = setTimeout(() => {
          this.hiddenTimeTipTimer = null
          this.showTimeTip = false
        }, 60000)
      } else {
        this.hiddenTimeTipTimer && clearTimeout(this.hiddenTimeTipTimer)
      }
    },
    remainingTime: function (newTime, preTime) {
      if (newTime) {
        this.handleRemainingTime(newTime)
      }
    },
    '$store.state.layout': function () {
      const slider: Vue = this.$refs.slider as Vue
      this.currentIndex = 0
      slider.$emit('resetIndex', 0)
    },
    '$store.state.status': function (newValue) {
      if (newValue === 2) {
        window.addEventListener('beforeunload', this.listenCloseTab)
      } else {
        this.$store.commit('resetUnReadMsgs')
        window.removeEventListener('beforeunload', this.listenCloseTab)
      }
    },
    '$store.state.meetingInfo.shareMode': function (newValue) {
      if (newValue === shareMode.whiteboard) {
        this.handleChangeAutoHide(false)
      } else {
        this.handleChangeAutoHide(true)
      }
    },
    currentMemberLayout: function (newItem, oldItem) {
      // TODO 有报错 newITem
      if (
        oldItem &&
        newItem &&
        oldItem.layoutType === newItem.layoutType &&
        oldItem.uids.toString() === newItem.uids.toString()
      ) {
        // 判断是否有变化
        return
      }
      // this.emitLayoutChange(this.renderMode)
    },
    renderMode: function (newMode, oldMode) {
      // this.emitLayoutChange(newMode)
    },
    showMySmallVideo: function (newValue) {
      // this.emitLayoutChange(this.renderMode)
    },
  },
  methods: {
    onRemainingTimeCloseHandler() {
      this.showTimeTip = false
    },
    // 剩余时间提醒处理函数
    handleRemainingTime(time: number | undefined) {
      if (!time || !this.showTimeTipByGlobalConfig) {
        return
      }
      this.remainingSeconds = Math.max(time - 1, 0)
      this.handleCheckTime(this.remainingSeconds, time)
    },
    handleCheckTime(time: number, preTime: number) {
      //5分钟到10分钟，并且上一秒是大于600秒则表示第一次进入10分钟。需要进行提示
      if (preTime > 600 && 300 < time && time <= 600) {
        this.timeTipContent = '距离会议结束仅剩10分钟！'
        this.showTimeTip = true
      } else if (preTime > 300 && 60 < time && time <= 300) {
        //1分钟到5分钟，并且上一秒是大于300秒则表示第一次进入5分钟。需要进行提示
        this.timeTipContent = '距离会议结束仅剩5分钟！'
        this.showTimeTip = true
      } else if (preTime > 60 && 0 < time && time <= 60) {
        this.timeTipContent = '距离会议结束仅剩1分钟！'
        this.showTimeTip = true
      }
      if (time <= 0) {
        return
      }
      // 一秒检查一次
      this.remainingTimer = setTimeout(() => {
        this.remainingTimer = null
        this.remainingSeconds = Math.max(time - 1, 0)
        this.handleCheckTime(this.remainingSeconds, time)
      }, 1000)
    },
    listenCloseTab(e) {
      ;(e || window.event).returnValue = '确定离开当前页面吗？'
    },
    clickBox() {
      this.$store.commit('toggleList', false)
      this.$store.commit('toggleChatroom', false)
    },
    getStream(uid) {
      /*console.log('获取stream: ', uid)
      console.log('成员列表: %o', this.memberMap[uid])*/
      return (this.memberMap[uid] && this.memberMap[uid].stream) || ''
    },
    getScreenStream(uid) {
      // console.log('获取屏幕共享stream: ', uid)
      // console.log('屏幕共享成员成员列表: ', this.isScreen,  this.memberMap[uid]?.screenStream)
      return this.isScreen
        ? (this.memberMap[uid] && this.memberMap[uid].screenStream) || ''
        : (this.memberMap[uid] && this.memberMap[uid].stream) || ''
    },
    mainMouseEnter() {
      if (this.timeOut) {
        clearTimeout(this.timeOut)
      }
      this.timeOut = setTimeout(() => {
        this.showControlBar = false
      }, 5000) as any
      this.showControlBar = true
    },
    mainMouseLeave() {
      if (this.timeOut) {
        clearTimeout(this.timeOut)
      }
      this.showControlBar = false
    },
    bindMouseListener() {
      this.body.addEventListener('mousemove', this.mainMouseEnter)
      this.body.addEventListener('mouseenter', this.mainMouseEnter)
      this.body.addEventListener('mouseleave', this.mainMouseLeave)
    },
    unbindMouseListener() {
      this.body.removeEventListener('mousemove', this.mainMouseEnter)
      this.body.removeEventListener('mouseenter', this.mainMouseEnter)
      this.body.removeEventListener('mouseleave', this.mainMouseLeave)
    },
    handleChangeAutoHide(val) {
      switch (val) {
        case true:
          this.bindMouseListener()
          break
        case false:
          this.unbindMouseListener()
          clearTimeout(this.timeOut)
          this.showControlBar = true
          break
        default:
          this.bindMouseListener()
          break
      }
    },
    onIndexChange(currentIndex: number) {
      // 当多人情况下，进行切换人员时候，
      this.currentIndex = Math.max(currentIndex, 0)
    },
    getLayout() {
      const renderMode =
        this.defaultRenderMode === 'big'
          ? RenderModeEnum.big
          : RenderModeEnum.small
      const layout = this.generateLayout(
        this.currentMemberLayout.uids,
        this.layoutType,
        renderMode
      )
      this.$store.commit('setCanvasInfo', layout)
      return layout
    },
    generateLayout(
      uids: Array<string>,
      layoutType: LayoutTypeEnum,
      renderMode: RenderModeEnum
    ) {
      // 生成首页布局数据
      if (renderMode === RenderModeEnum.big) {
        // 多人模式
        const meetingMainRef: any =
          layoutType === LayoutTypeEnum.speaker
            ? this.$refs.meetingMain
            : (this.$refs.slider as any).$el
        if (!meetingMainRef) {
          return null
        }
        const layout: Layout = {
          canvas: {
            width: 0,
            height: 0,
          },
          users: [],
        }
        const containerWidth = meetingMainRef.scrollWidth
        const containerHeight = meetingMainRef.scrollHeight
        layout.canvas.width = containerWidth
        layout.canvas.height = containerHeight
        if (this.isScreen && this.isLocalScreen) {
          // 本地共享
          layout.users = [
            {
              uid: this.myUid,
              isScreen: true,
              x: 0,
              y: 0,
              width: containerWidth,
              height: containerHeight,
            },
          ]
          return layout
        }
        uids &&
          uids.forEach((id, index) => {
            let elRefs = this.$refs[`videoCard_${id}`] as any
            if (
              (this.isScreen || this.isSpeaker) &&
              !this.isLocalScreen &&
              index === uids.length - 1
            ) {
              // 如果是非本端屏幕共享则最后一个获取共享窗口元素
              elRefs = this.$refs[`videoCard_${this.mainSpeakerUId}_main`]
            }
            if (!elRefs) {
              return
            }
            const element = Array.isArray(elRefs) ? elRefs[0].$el : elRefs.$el
            let x = element.offsetLeft
            let y = element.offsetTop
            let transformX = 0 // 多页切换的transform距离
            let isScreen = false
            if (layoutType === LayoutTypeEnum.speaker) {
              if (index === uids.length - 1) {
                // 如果是演讲者模式主讲者由于父元素是meeting-main，存在margin数据，获取到的offsetLeft包含了该值，所以需要去除
                // const computedStyle = (window.getComputedStyle(meetingMainRef, null) as any)
                x = 1
                y = Math.max(0, y - 50) // 需要减去顶部header的高度
                isScreen = this.isScreen
              } else {
                const constainerOffsetLeft =
                  containerWidth > 656 ? (containerWidth - 656) / 2 : 0 // 计算出顶部成员容器距离左侧的距离
                transformX = 656 * this.currentIndex
                x = constainerOffsetLeft + x
              }
            } else {
              transformX = this.baseHeight * 1.77 * this.currentIndex // 多页切换的transform距离
            }
            x = x - transformX
            layout.users.push({
              uid: id,
              width: element.offsetWidth,
              height: element.offsetHeight,
              x,
              y,
              isScreen,
            })
          })
        return layout
      } else {
        // 小屏模式
        const width = document.body.clientWidth
        const height = this.height
        const users = [
          {
            uid: this.otherMember,
            width,
            height: height - 48,
          },
        ]
        if (this.showMySmallVideo) {
          // 是否显示本端画面
          users.push({
            uid: this.myUid,
            width: width / 3,
            height: height / 3,
          })
        }
        return {
          canvas: {
            width,
            height,
          },
          users,
        }
      }
    },
    emitLayoutChange(renderMode: RenderModeEnum) {
      this.$nextTick(() => {
        if (renderMode == RenderModeEnum.small || this.$refs.meetingMain) {
          // 获取最新布局信息
          const layout = this.getLayout()
          this.$EventBus.$emit('layoutChange', layout)
        }
      })
    },
    keydownEventHandler(e) {
      if(!this.enableUnmuteBySpace) {
        return
      }
      const keyNum = window.event ? e.keyCode :e.which;
      // 空格
      if(keyNum === 32) {
        e.preventDefault()
        // 当前未静音无须解除静音
        if(this.audio === 1 || this.spaceKeyStatus === 'down' || this.spaceKeydownTimer || this.online !== 2) {
          // 2s内没有收到按下事件表示离开当前页面获取被阻止。需要取消
          this.cancelUnmuteTimer && clearTimeout(this.cancelUnmuteTimer)
          this.cancelUnmuteTimer = setTimeout(() => {
            this.cancelUnmuteTimer = null
            this.muteLocalAudioBySpace()
          }, 800)
          return
        }
        this.spaceKeyStatus = 'down'
        this.spaceKeydownTimer = setTimeout(() => {
          this.spaceKeydownTimer = null
          if(this.audio !== 1 && (this.$store.state.audioOff != AttendeeOffType.offNotAllowSelfOn || this.isHost)) {
            this.$neMeeting.unmuteLocalAudio().finally(() => {
              this.showUnmuteAudioToast = true
              // 如果声音还没有开启，提前弹起空格，只能当开启语音之后再关闭，否则关闭报错
              if(this.spaceKeyStatus === 'up') {
                this.spaceKeyStatus = 'complete'
                this.$neMeeting.muteLocalAudio()
              }
            })
          }
        }, 800)

      }
    },
    keyupEventHandler(e) {
      if(!this.enableUnmuteBySpace) {
        return
      }
      const keyNum = window.event ? e.keyCode :e.which;
      // 空格
      if(keyNum === 32) {
        this.muteLocalAudioBySpace()
      }
    },
    muteLocalAudioBySpace() {
      if(this.spaceKeydownTimer) {
        clearTimeout(this.spaceKeydownTimer)
        this.spaceKeydownTimer = null
        this.spaceKeyStatus = 'complete'
        return
      }
      if(this.spaceKeyStatus === 'up') {
        return
      }
      this.spaceKeyStatus = 'up'
      if(this.audio === 1) {
        this.$neMeeting.muteLocalAudio().finally(() => {
          this.spaceKeyStatus = 'complete'
        })
      }
    },
  },
  mounted() {
    if(this.$refs.meeting) {
      (this.$refs.meeting as any).focus()
    }
    this.bindMouseListener()
  },
  beforeDestroy() {
    this.unbindMouseListener()
    this.remainingTimer && clearTimeout(this.remainingTimer)
    this.hiddenTimeTipTimer && clearTimeout(this.hiddenTimeTipTimer)
    window.removeEventListener('beforeunload', this.listenCloseTab)
  },
})
</script>

<style lang="stylus">
// 布局需要考虑到长宽可变，这里先写个默认值
.meeting
  position relative
  background-color #000
  padding 50px 0 68px
  box-sizing border-box
  overflow hidden
  // transform translateX(0%)
  &-header
    height 50px
    width 100%
    position absolute
    top 0
    color #fff
    background-image linear-gradient(180deg, #292933 7%, #212129 100%)
    display: flex
    justify-content: space-between
    align-items: center
    padding: 0 20px
    box-sizing: border-box;
    img
      height 28px
    .meeting-subject
      display: flex
      align-items: center
    .flex-same
      width 106px
      display inline-block
    &-userinfo
      text-align right
    &-userinfo-content
      display inline-block
      width 28px
      height 28px
      border-radius 50%
      background #337eff
      line-height 28px
      font-weight bold
      text-align center
      color #fff
  &-main
    height 100%
    width 100%
    transition width 0.3s ease-out
    margin 0 auto
    &>*
      margin 0 auto
    .right-top-corner
      position absolute
      top 54px;
      right 16px
      color #fff
      z-index 11
      .recording
        background rgba(49, 49, 56, .8)
        border-radius 2px
        padding 4px 8px
        display: flex;
        align-items: center;
        &-icon
          display inline-block
          width 12px
          height 12px
          border-radius 50%
          border 2px solid #F54545
          margin-right 4px
          display flex
          justify-content center
          align-items center
          &:after
            content ''
            width 6px
            height 6px
            border-radius 50%
            background #F54545
    .speaker-slider
      height 14.3%
      .slider
        width 656px
        &>*
          width 25%
          .center-nickname
            font-size 12px
    .gallery-slider
      height 100%
      .slider
        flex-wrap wrap
        align-items center
        justify-content center
        align-content center
        width 100%
        overflow-y scroll
        -ms-overflow-style: none;
        &::-webkit-scrollbar
          display none
        .for-1
          width calc(100% - 4px)
          height calc(100% - 2px)
        .for-2,.for-3,.for-4
          width calc(50% - 4px)
          height calc(50% - 2px)
        .for-5,.for-6,.for-7,.for-8,.for-9
          width calc(33% - 4px)
          height calc(33% - 2px)
        .for-10,.for-11,.for-12,.for-13,.for-14,.for-15,.for-16,
          width calc(25% - 4px)
          height calc(25% - 2px)
      .video-card
        width calc(25% - 4px)
        height calc(25% - 2px)
        .center-nickname
          font-size 12px
  &-main-showList
    width calc(100% - 320px)
  &-footer
    height 68px
    width 100%
    position absolute
    bottom 0px
    z-index 1001
    transition: all .5s
    &.hide
      bottom -68px
  &-small-layout
    height 100%
    width: 100%
    .other-notin, .other-hasin
      height calc(100% - 48px)!important
      width: 100%
      position absolute
      top 0
      left 0
      display flex
      align-items center
      justify-content center
      color #fff
      p.tips
        text-align center
        color inherit
    .self-hasin
      width calc(100% / 3)
      height calc(100% / 3)!important
      position absolute
      bottom 48px
      right 0
      z-index 10
    .small-meeting-control
      right 0
      bottom 0
      position absolute
  .meeting-title
    display: inline-block
    white-space nowrap
    text-overflow ellipsis
    overflow hidden
    max-width 1200px
  .speaker-list-hide
    right -195px
  .time-tip-wrap
    position: absolute
    top 60px
    left 50%
    z-index 13002
    transform translateX(-50%)
  .unmute-audio-icon
    width: 40px
    height: 40px
  .unmute-audio-toast
    color white
    position absolute
    width 100px
    height 100px
    left 50%
    bottom: 100px
    padding 17px 7px
    font-size 14px
    z-index 13002
    transform translateX(-50%)
    border-radius 6px
    background-color rgba(0, 0, 0, 0.7)
</style>
