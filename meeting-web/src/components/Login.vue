<template>
  <div class="login">
    <div v-if="isDev && !isWebSite">
      <label for="">
        <span style="color: #fff">音频</span>
        <input type="number" v-model="audio" />
      </label>
      <label for="">
        <span style="color: #fff">视频</span>
        <input type="number" v-model="video" />
      </label>
      <input
        type="text"
        name="accountId"
        placeholder="accountId"
        v-model="accountId"
      />
      <input
        type="text"
        name="accountToken"
        placeholder="accountToken"
        v-model="accountToken"
      />
      <button @click="loginNormal">登录</button>
      <br />
      <input
        type="text"
        name="username"
        placeholder="username"
        v-model="loginUsername"
      />
      <input
        type="text"
        name="password"
        placeholder="password"
        v-model="loginPassword"
      />
      <button @click="loginByPassword">账密登录</button>
      <br />
      <input
        type="text"
        name="ssoToken"
        placeholder="ssoToken"
        v-model="ssoToken"
      />
      <button @click="loginBySSO">SSO登录</button>
      <br />
      <input type="checkbox" name="" v-model="attendeeAudioOff" /><span
        class="text"
        >创建后全体静音</span
      >
      <input type="checkbox" name="" v-model="attendeeVideoOff" /><span
        class="text"
        >创建后全体关闭视频</span
      >
      <br />
      <input
        type="text"
        name="nickName"
        placeholder="nickName"
        v-model="nickName"
      />
      <button name="create-meeting" @click="createMeeting">创建会议</button>
      <button name="create-meeting-random" @click="createMeeting(1)">
        创建随机ID会议
      </button>
      <input
        type="text"
        name="meetingId"
        placeholder="meetingId"
        v-model="meetingId"
      />
      <button @click="debounce(joinMeeting)">加入会议</button>
      <button @click="debounce(joinMeeting(false, true))">匿名入会</button>
      <button @click="end">结束会议</button>
      <button @click="subscribe('audio', true)">订阅全部</button>
      <button @click="subscribe('audio', false)">取消订阅全部</button>
      <button @click="subscribe('audio', true, subscribeId)">订阅单人</button>
      <button @click="subscribe('audio', false, subscribeId)">
        取消订阅单人
      </button>
      <input type="text" v-model="subscribeId" placeholder="订阅accountId" />
      <button @click="changeMode">改变模式</button>
    </div>
    <Dialog
      :visible.sync="dialogVisibleAudio"
      :needBtns="true"
      @close="dialogVisibleAudio = false"
      :title="$t('openMicro')"
      class="confirm-open-micro"
      :width="350"
    >
      <template v-slot:dialogContent>
        {{ $t('hostOpenMicroTips') }}
      </template>
      <template v-slot:dialogFooter>
        <span @click="confirmOk">{{ $t('sure') }}</span>
        <span @click="confirmCancel">{{ $t('cancel') }}</span>
      </template>
    </Dialog>
    <Dialog
      :visible.sync="dialogVisibleVideo"
      :needBtns="true"
      @close="dialogVisibleVideo = false"
      :title="$t('openCamera')"
      class="confirm-open-micro"
      :width="350"
    >
      <template v-slot:dialogContent>
        {{ $t('hostOpenCameraTips') }}
      </template>
      <template v-slot:dialogFooter>
        <span @click="confirmVideoOk">{{ $t('sure') }}</span>
        <span @click="confirmVideoCancel">{{ $t('cancel') }}</span>
      </template>
    </Dialog>
    <Dialog
      :visible.sync="dialogExitMeeting"
      :needBtns="true"
      @close="dialogExitMeeting = false"
      title="房间已存在"
      class="confirm-open-micro"
      :width="350"
    >
      <template v-slot:dialogContent>
        该房间已存在，请确认是否直接加入？
      </template>
      <template v-slot:dialogFooter>
        <span @click="confirmJoinOk">{{ $t('sure') }}</span>
        <span @click="confirmJoinCancel">{{ $t('cancel') }}</span>
      </template>
    </Dialog>
    <Dialog
      :visible.sync="showPasswordVisbale"
      :needBtns="true"
      @close="closePasswordVisible"
      :title="$t('meetingPassword')"
      class="confirm-open-micro"
      :width="350"
    >
      <template v-slot:dialogContent>
        <div class="input-content">
          <input
            @input="handlePasswordInput"
            :class="`${errorMsg ? 'error' : ''}`"
            type="text"
            v-model="password"
            :placeholder="$t('inputMeetingPassword')"
            max="200"
          />
          <span
            v-show="password"
            class="close-btn"
            @click="
              () => {
                password = ''
                errorMsg = ''
              }
            "
          >
            <svg class="icon" aria-hidden="true">
              <use xlink:href="#iconcross"></use>
            </svg>
          </span>
        </div>
        <p class="error-msg">{{ errorMsg }}</p>
      </template>
      <template v-slot:dialogFooter>
        <span
          :class="`join-meeting ${password.length >= 6 ? '' : 'disable'}`"
          @click="confirmJoinByPassword"
          >{{ $t('joinMeeting') }}</span
        >
      </template>
    </Dialog>
  </div>
</template>
<script lang="ts">
import Vue from 'vue'
import { NeMeeting } from '../libs/NeMeeting'
import Dialog from './ui/Dialog.vue'
import {
  AttendeeOffType,
  defaultMenus,
  defaultMoreMenus,
  errorCodes,
  hostAction,
  memberAction,
  memberLeaveTypes,
  NEMeetingIdDisplayOptions,
  Role,
  RoleType,
  shareMode,
  windowModes,
} from '../libs/enum'
import { Logger } from '../libs/3rd/Logger'
import { appkey, meetingServerDomain } from '../config'
import {
  checkType,
  debounce,
  getErrCode,
  getQueryVariable,
  hasProtocol,
  timeStatistics,
} from '../utils'
import { VideoProfile } from '@/types'

const logger = new Logger('Meeting-Login', true)

const roleMap = {
  [RoleType.host]: 'host',
  [RoleType.coHost]: 'coHost',
  [RoleType.participant]: 'participant',
}

export default Vue.extend({
  name: 'login-ne-meeting',
  components: {
    Dialog,
  },
  props: ['isDev', 'isWebSite'],
  data() {
    return {
      accountId: '',
      accountToken: '',
      nickName: '', //Math.random().toString(36).substr(6),
      appKey: this.isDev ? appkey : '',
      // appKey: '', // 打包时取消注释
      meetingId: '',
      password: '', // 遗漏的password
      loginUsername: '',
      loginPassword: '',
      ssoToken: '',
      audio: 0,
      video: 0,
      dialogVisibleAudio: false,
      dialogVisibleVideo: false,
      dialogExitMeeting: false,
      openAudioByHost: false,
      openVideoByHost: false,
      attendeeAudioOff: false,
      attendeeVideoOff: false,
      deviceMap: {
        audioIn: {
          name: 'audioDevicesList',
          commit: 'setAudioDevicesList',
          action: 'changeLocalAudio',
          emit: 'initMicr',
        },
        audioOut: {
          name: 'speakerDevicesList',
          commit: 'setSpeakerDevicesList',
          action: 'selectSpeakers',
          emit: 'initSpeaker',
        },
        video: {
          name: 'videoDevicesList',
          commit: 'setVideoDevicesList',
          action: 'changeLocalVideo',
          emit: 'initCamera',
        },
      },
      createObj: {
        obj: {
          nickName: '',
        },
        callback: (e?) => e || true,
      },
      loginObj: {
        obj: {
          appKey: 0,
        },
        callback: (e?) => e || true,
      },
      joinObj: {
        obj: {
          meetingId: 0,
          video: 0,
          audio: 0,
        },
        callback: (e?) => e || true,
      },
      debounce,
      showPasswordVisbale: false,
      errorMsg: '',
      // leaveCallBack: (leaveType: memberLeaveTypes) => true,
      // activeSpeakerTimeOut: undefined,
      subscribeAudioAll: true,
      subscribeAudioList: Array<any>(),
      stackForAdded: {},
      stackForAddedTimes: {},
      subscribeId: '',
      isKicked: false, // 是否被踢出房间，用于被挤出房间后rtc断开，但是im并没有，造成所有会控都会收到
    }
  },
  beforeDestroy() {
    // syncFinish = false
    // logger.debug('beforeDestroy showPasswordVisbale: ', this.showPasswordVisbale)
  },
  watch: {
    '$store.state.meetingInfo.shareMode': function (val) {
      this.$EventBus.$emit('share-mode', val)
    },
  },
  beforeMount() {
    logger.debug('login beforemounted')
    this.$store.commit('setLocalInfo', {
      leaveCallBack: (leaveType: memberLeaveTypes) => {
        this.subscribeAudioAll = true
        this.subscribeAudioList = []
      },
    })
  },
  mounted() {
    // 根据url参数填充accountId和token
    // const res = /accountId=([0-9]+)&?/.exec(location.search)
    // if (res && res[1]) {
    // }
    // setTimeout(()=>{
    //   logger.debug('mounted showPasswordVisbale: ', showPasswordVisbale)
    //   if(showPasswordVisbale) {
    //     this.showPasswordVisbale = true
    //   }
    // }, 500)
    this.accountId = getQueryVariable('accountId') || ''
    this.accountToken = getQueryVariable('accountToken') || ''
    // this.$store.commit('setLocalInfo', {
    //   audio: this.audio,
    //   video: this.video,
    // });

    if (!Vue.prototype.$neMeeting) {
      logger.debug('初始化会议实例对象 %t')
      Vue.prototype.$neMeeting = new NeMeeting(this.$roomkit)
      this.$store.commit('setIsNEMeetingInit', true)
      this.$neMeeting.on('playLocalStream', (data) => {
        logger.debug('本地视频可以渲染了: %o %t', data)
        this.$store.commit('setStream', {
          uid: this.$neMeeting.avRoomUid,
          stream: data.stream,
          screenStream: data.screenStream,
        })
      })

      // this.$neMeeting.on('playRemoteStream', evt => {
      //   logger.debug('远端视频可以渲染了: ', evt)
      //   if (!evt?.stream) return
      //   this.$store.commit('setStream', {
      //     uid: evt?.uid,
      //     stream: evt?.stream,
      //     basicStream: evt?.basicStream
      //   });
      // });

      this.$neMeeting.on('networkQuality', (data) => {
        this.$EventBus.$emit('networkQuality', data)
      })

      // this.$neMeeting.on('playRemoteStream', evt => this.playRemote(evt))

      this.$neMeeting.on('onMemberJoinRtcChannel', (member) => {
        logger.debug('用户加入: %o %t', member)
        this.$EventBus.$emit('peerJoin', member?.uid)
        this.$store.commit('addRealMemberList', member.uid)
        if (
          this.$store.state.localInfo.role === Role.host &&
          member.role !== Role.ghost
        ) {
          debounce(
            this.$toastChat(`${member.nickName}${this.$t('enterMeetingToast')}`)
          )
        }
        this.$store.commit('addMember', member)
        // 如果进入的是管理员，且未设置焦点，则默认设置管理员为焦点
        // if(member.isHost && !this.$store.state.meetingInfo.focusAvRoomUid) {
        //   console.log('设置管理员为焦点');
        //   this.$neMeeting.sendHostControl(hostAction.setFocus, [member.accountId], [member.avRoomUid]);
        // }
        if (
          this.meetingInfo.shareMode === shareMode.screen &&
          !member.isSharingScreen &&
          this.meetingInfo.screenSharersAvRoomUid.length &&
          this.meetingInfo.screenSharersAvRoomUid[0] === member.uid
        ) {
          // 如果当前正在共享状态并且共享人是刚加入的人，表示该成员是移动端杀进程重新加入，需要设置为非共享状态
          this.$store.commit('setMeetingInfo', {
            shareMode: shareMode.noshare,
            screenSharersAvRoomUid: [],
            screenSharersAccountId: [],
          })
          // 取消对应的远端订阅
          this.$neMeeting.rtcController.unsubscribeRemoteVideoSubStream(
            member.uid
          )
        }
        this.$store.dispatch('sortMemberList')
        this.$EventBus.$emit('joinMemberInfo', this.$store.state.memberMap)
      })

      this.$neMeeting.on('onMemberLeaveRoom', async (member) => {
        const { state } = this.$store
        const uid = member.uid
        logger.debug('用户离开: %o %t', member)
        this.$store.commit('removeRealMemberList', uid)
        this.$EventBus.$emit('peerLeave', uid)
        if (member.uuid === this.$neMeeting.avRoomUid) {
          // 本端
          // this.$toast('您已被踢出会议');

          return
        }
        if (
          checkType(state.memberMap[uid] && state.memberMap[uid].role, 'string')
        ) {
          logger.debug(
            `${
              state.memberMap[uid].roleType !== 4 ? '非影子用户' : '影子用户'
            } %s %t`,
            uid
          )
        }
        if (
          state.localInfo.role === 'host' &&
          state.memberMap[uid] &&
          state.memberMap[uid].role !== Role.ghost
        ) {
          this.$toastChat(
            `${this.$store.state.memberMap[uid].nickName}离开会议`
          )
        }
        this.$store.commit('removeMember', uid)
        this.$store.dispatch('sortMemberList')
        if (
          state.memberIdList &&
          state.memberIdList.length === 1 &&
          state.layout === 'gallery'
        ) {
          this.$store.commit('toggleLayout')
          // this.$toast(`更改视图模式为${this.$store.state.layout === 'speaker' ? '演讲者视图' : '画廊视图'}`)
        }
        this.$EventBus.$emit('joinMemberInfo', this.$store.state.memberMap)
      })
      this.$neMeeting.on(
        'onMemberAudioMuteChanged',
        (member, mute, operator) => {
          logger.debug('onMemberAudioMuteChanged: %o %o %t', member, operator)
          this.$store.commit('updateMember', member)
          if (member.accountId === this.localInfo.avRoomUid) {
            this.$store.commit('setLocalInfo', {
              audio: member.audio,
              isAudioOn: member.isAudioOn,
            })
            if (mute && member.uuid !== operator.uuid) {
              this.$toast(this.$t('meetingHostMuteAudio'))
            }
            // 非主持人端提示被解除静音
            if (
              this.localInfo.role !== Role.host &&
              !mute &&
              operator.uuid !== this.localInfo.avRoomUid
            ) {
              this.$toast(this.$t('hostAgreeAudioHandsUp'))
            }
            // 如果举手则放下
            if (this.localInfo.isHandsUp && member.isAudioOn) {
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
            } else if (member.isAudioOn) {
              this.$EventBus.$emit('needAudioHandsUp', false)
            }
          }
        }
      )

      this.$neMeeting.on(
        'onMemberPropertiesChanged',
        (userUuid, properties) => {
          logger.debug('onMemberPropertiesChanged: %o %t', properties)
          if (properties.handsUp) {
            // 举手
            const handsUp = properties.handsUp
            this.updateMember(userUuid, 'handsUps', handsUp)
            if (handsUp.value == 2 && userUuid === this.localInfo.avRoomUid) {
              this.$toast(this.$t('hostRejectAudioHandsUp'))
            }
          } else if (properties.wbDrawable) {
            // 白板授权
            this.updateMember(
              userUuid,
              'whiteBoardInteract',
              properties.wbDrawable.value
            )
            if (userUuid === this.localInfo.avRoomUid) {
              // 本端属性修改
              this.$store.commit('setLocalInfo', {
                whiteBoardInteract: properties.wbDrawable.value,
              })
              if (properties.wbDrawable.value == '1') {
                this.$EventBus.$emit('whiteboard-setDraw', true)
                this.$toast(this.$t('whiteBoardInteractionTip'))
              } else {
                this.$EventBus.$emit('whiteboard-setDraw', false)
                if (this.meetingInfo.shareMode === shareMode.whiteboard) {
                  // 当还在共享的时候才提示
                  this.$toast(this.$t('undoWhiteBoardInteractionTip'))
                }
              }
            }
            this.$store.dispatch('sortMemberList')
          }
        }
      )

      this.$neMeeting.on('onMemberPropertiesDeleted', (userUuid, keys) => {
        logger.debug('onMemberPropertiesDeleted: %o %o %t', keys, userUuid)
        keys.forEach((key) => {
          if (key === 'handsUp') {
            // 举手
            this.updateMember(userUuid, 'handsUps', { value: 0 })
            // if(userUuid === this.localInfo.avRoomUid) {
            //   this.$toast(this.$t('hostRejectAudioHandsUp'));
            // }
          } else if (key === 'wbDrawable') {
            // 收到取消白板授权
            this.updateMember(userUuid, 'whiteBoardInteract', '0')
            this.$EventBus.$emit('whiteboard-setDraw', false)
          }
        })
      })

      this.$neMeeting.on('onRoomPropertiesDeleted', (keys) => {
        logger.debug('onRoomPropertiesDeleted: %o %t', keys)
        keys.forEach((key) => {
          if (key === 'focus') {
            this.cancelFocus()
            this.$store.commit('setMeetingInfo', { focusAvRoomUid: '' })
          } else if (key === 'lock') {
            this.$store.commit('setMeetLockStatus', 1)
          }
        })
        this.$store.dispatch('sortMemberList')
      })
      this.$neMeeting.on('onRoomLockStateChanged', (isLocked: boolean) => {
        logger.debug('onRoomLockStateChanged: %o %t', isLocked)
        this.$store.commit('setMeetLockStatus', isLocked ? 2 : 1)
        this.setMeetingInfoForSdk()
      })

      this.$neMeeting.on(
        'onMemberWhiteboardStateChanged',
        (member, isOpen, operator) => {
          logger.debug('onMemberWhiteboardStateChanged: %o %t', member, isOpen)
          if (!member && !isOpen) {
            // 用户开着白板退出房间
            this.$store.commit('setLocalInfo', {
              whiteBoardShare: 0,
            })
            // 如果本端有被授权白板权限需要撤回
            this.localInfo.whiteBoardInteract == '1' &&
              this.$neMeeting.sendMemberControl(
                memberAction.cancelShareWhiteShare,
                [this.localInfo.avRoomUid]
              )
            this.$store.commit('setMeetingInfo', {
              shareMode: shareMode.noshare,
              whiteboardAvRoomUid: [],
              whiteboardOwnerImAccid: [],
            })
          } else {
            this.$store.commit('updateMember', member)
            if (this.$store.state.layout !== 'speaker') {
              this.$store.commit('toggleLayout')
            }
            if (member.accountId === this.localInfo.avRoomUid) {
              this.$store.commit('setLocalInfo', {
                whiteBoardShare: isOpen ? 1 : 0,
              })
              !isOpen &&
                this.$neMeeting.whiteboardController.setEnableDraw(false)
            }
            if (isOpen) {
              this.$nextTick(() => {
                this.checkWbloaded('whiteboard-login', member.uuid)
              })
              this.$store.commit('setMeetingInfo', {
                shareMode: shareMode.whiteboard,
                whiteboardAvRoomUid: [member.uuid],
                whiteboardOwnerImAccid: [member.uuid],
              })
            } else {
              this.$store.commit('setLocalInfo', {
                whiteBoardShare: 0,
              })
              // 如果本端有被授权白板权限需要撤回
              this.localInfo.whiteBoardInteract == '1' &&
                this.$neMeeting.sendMemberControl(
                  memberAction.cancelShareWhiteShare,
                  [this.localInfo.avRoomUid]
                )

              if (
                member.uuid === this.$neMeeting.avRoomUid &&
                operator.uuid === this.$store.state.meetingInfo.hostAvRoomUid &&
                this.$store.state.meetingInfo.hostAvRoomUid !==
                  this.$neMeeting.avRoomUid
              ) {
                this.$toast(this.$t('hostCloseWhiteShareToast'))
              }
              this.$store.commit('setMeetingInfo', {
                shareMode: shareMode.noshare,
                whiteboardAvRoomUid: [],
                whiteboardOwnerImAccid: [],
              })
            }
          }
          this.$store.dispatch('sortMemberList')
        }
      )
      this.$neMeeting.on('onRoomPropertiesChanged', (properties) => {
        logger.debug(
          'onRoomPropertiesChanged: %o %o %t',
          properties,
          this.meetingInfo
        )
        if (properties.focus) {
          // 焦点更新
          const focus = properties.focus
          if (focus.value) {
            // 设置焦点
            if (this.$neMeeting.avRoomUid === focus.value) {
              // 设置本端为焦点
              this.$toast(this.$t('getVideoFocus'))
              if (
                this.focusVideoProfile.resolution !==
                  this.videoProfile.resolution ||
                this.focusVideoProfile.frameRate !== this.videoProfile.frameRate
              ) {
                ;(this.localInfo.video === 1 || this.localInfo.video === 4) && // 当前视频画面开启的
                  this.$neMeeting.setVideoProfile(
                    this.focusVideoProfile.resolution,
                    this.focusVideoProfile.frameRate
                  )
              }
            } else if (
              this.$neMeeting.avRoomUid === this.meetingInfo.focusAvRoomUid
            ) {
              // 本端失去焦点(出现在管理员不取消焦点，直接设置其他人焦点情况)
              if (
                this.focusVideoProfile.resolution !==
                  this.videoProfile.resolution ||
                this.focusVideoProfile.frameRate !== this.videoProfile.frameRate
              ) {
                this.localInfo.video === 1 && // 当前视频画面开启的
                  this.$neMeeting.setVideoProfile(
                    this.videoProfile.resolution,
                    this.videoProfile.frameRate
                  )
              }
            }
            this.updateMember(focus.value, 'isFocus', true)
          } else {
            this.cancelFocus()
          }
          this.$store.commit('setMeetingInfo', { focusAvRoomUid: focus.value })
          this.$store.dispatch('sortMemberList')
        } else if (properties.audioOff) {
          const value = properties.audioOff.value?.split('_')[0]
          this.$store.commit(
            'setAllowUnMuteAudioBySelf',
            value !== AttendeeOffType.offNotAllowSelfOn
          ) // 是否允许自我解除静音
          this.$store.commit('setAudioOff', value) // 是否允许自我解除静音
          if (
            value === AttendeeOffType.offNotAllowSelfOn &&
            this.dialogVisibleAudio
          ) {
            // 主持人关闭视频且不允许自行打开，这个时候有开启视频的弹出框则
            // 用于打开视频弹出框点击确认按钮的时候是否需要重新举手，场景：主持人打开人员视频，人员弹出框未点确认，这个时候管理员点击关闭视频不允许自行打开
            this.openAudioByHost = false
          }
          if (
            value === AttendeeOffType.offAllowSelfOn ||
            value === AttendeeOffType.disable
          ) {
            // 允许自行解除静音，且本身在举手情况下解除举手
            this.$EventBus.$emit('needAudioHandsUp', false)
            if (this.localInfo.isHandsUp) {
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
            }
          }
          switch (value) {
            case AttendeeOffType.offNotAllowSelfOn:
            case AttendeeOffType.offAllowSelfOn:
              if (
                this.localInfo.role !== Role.host &&
                this.localInfo.role !== Role.coHost
              ) {
                this.$toast(this.$t('meetingHostMuteAllAudio'))
              }
              if (
                this.localInfo.audio !== 1 ||
                this.localInfo.role === Role.host ||
                this.localInfo.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }
              this.$neMeeting.muteLocalAudio()
              break
            case AttendeeOffType.disable: // 解除静音
              if (
                this.localInfo.audio === 1 ||
                this.localInfo.role === Role.host ||
                this.localInfo.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }
              this.$toast(this.$t('hostAgreeAudioHandsUp'))
              this.unmuteMyAudio()
              break
          }
        } else if (properties.videoOff) {
          const value = properties.videoOff.value?.split('_')[0]
          this.$store.commit(
            'setAllowUnMuteVideoBySelf',
            value !== AttendeeOffType.offNotAllowSelfOn
          ) // 是否允许自我解除静音
          this.$store.commit('setVideoOff', value) // 是否允许自我解除静音
          if (
            value === AttendeeOffType.offNotAllowSelfOn &&
            this.dialogVisibleVideo
          ) {
            // 主持人关闭视频且不允许自行打开，这个时候有开启视频的弹出框则
            this.openVideoByHost = false
          }
          if (
            value === AttendeeOffType.offAllowSelfOn ||
            value === AttendeeOffType.disable
          ) {
            // 允许自行解除静音，且本身在举手情况下解除举手
            this.$EventBus.$emit('needVideoHandsUp', false)
            if (this.localInfo.isHandsUp) {
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
            }
          }
          switch (value) {
            case AttendeeOffType.offNotAllowSelfOn:
            case AttendeeOffType.offAllowSelfOn:
              if (
                this.localInfo.role !== Role.host &&
                this.localInfo.role !== Role.coHost
              ) {
                this.$toast(this.$t('meetingHostMuteAllVideo'))
              }
              if (
                this.localInfo.video !== 1 ||
                this.localInfo.role === Role.host ||
                this.localInfo.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }
              this.$neMeeting.muteLocalVideo()
              break
            case AttendeeOffType.disable: // 全体开启视频
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
              if (
                this.localInfo.video === 1 ||
                this.localInfo.role === Role.host ||
                this.localInfo.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }
              this.dialogVisibleVideo = true
              this.openVideoByHost = true
              break
          }
        }
      })
      // this.$neMeeting.on('streamAdded', evt => {this.streamAdded(evt)})
      this.$neMeeting.on(
        'onMemberVideoMuteChanged',
        (member, mute, operator) => {
          logger.debug('login_对端发mutedChange: %o %t', member)
          this.$store.commit('updateMember', member)
          if (member.accountId === this.localInfo.avRoomUid) {
            this.$store.commit('setLocalInfo', {
              video: member.video,
              isVideoOn: member.isVideoOn,
            })
            if (mute && member.uuid !== operator.uuid) {
              this.$toast(this.$t('meetingHostMuteVideo'))
            }
            // 如果举手则放下
            if (this.localInfo.isHandsUp && member.isVideoOn) {
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
            } else if (member.isVideoOn) {
              this.$EventBus.$emit('needVideoHandsUp', false)
            }
          }
        }
      )
      this.$neMeeting.on(
        'onMemberScreenShareStateChanged',
        (member, isSharing, operator) => {
          logger.debug('onMemberScreenShareStateChanged: %o %t', member)
          this.$store.commit('updateMember', member)
          if (member.accountId === this.localInfo.avRoomUid) {
            this.$store.commit('setLocalInfo', {
              screen: isSharing ? 1 : 0,
            })
          }
          if (isSharing) {
            if (this.$store.state.layout !== 'speaker') {
              this.$store.commit('toggleLayout')
            }
          } else {
            if (
              operator.uuid !== member.uuid &&
              member.uuid === this.$neMeeting.avRoomUid
            ) {
              this.$toast(this.$t('hostStopShare'))
              this.$EventBus.$emit('screen-share-stop')
            }
          }
          this.$store.commit('setMeetingInfo', {
            shareMode: isSharing ? shareMode.screen : shareMode.noshare,
            screenSharersAvRoomUid: [member.uuid],
            screenSharersAccountId: [member.uuid],
          })
          this.$store.dispatch('sortMemberList')
        }
      )

      this.$neMeeting.on('onReceivePassThroughMessage', (res) => {
        logger.debug('onReceivePassThroughMessage: %o %t', res)
        const { body } = res.data
        const senderUuid = res.senderUuid
        if (this.localInfo.isHandsUp) {
          this.$neMeeting.sendMemberControl(memberAction.handsDown, [
            this.localInfo.avRoomUid,
          ])
        }
        const isMySelf = senderUuid == this.localInfo.avRoomUid
        switch (
          body.type // 主持人可开启
        ) {
          case 1:
            logger.debug('开启mic请求 %t')
            if (!isMySelf && this.localInfo.isHandsUp) {
              // 非主持人或者联席主持人打开自己的
              this.$toast(this.$t('hostAgreeAudioHandsUp'))
            }
            // this.$neMeeting.sendMemberControl(memberAction.handsDown, [this.localInfo.avRoomUid]);
            this.unmuteMyAudio(isMySelf)
            break
          case 2:
            logger.debug('开启camera请求 %t')
            // this.$neMeeting.sendMemberControl(memberAction.handsDown, [this.localInfo.avRoomUid]);
            this.unmuteMyVideo(isMySelf)
            break
          case 3:
            logger.debug('开启音视频请求 %t')
            if (!isMySelf && this.localInfo.isHandsUp) {
              // 非主持人或者联席主持人打开自己的
              this.$toast(this.$t('hostAgreeAudioHandsUp'))
            }
            // this.$neMeeting.sendMemberControl(memberAction.handsDown, [this.localInfo.avRoomUid]);
            this.unmuteMyAudio(isMySelf)
            this.unmuteMyVideo(isMySelf)
            break
        }
      })

      this.$neMeeting.on('onRtcActiveSpeakerChanged', (activeSpeaker) => {
        // logger.debug('当前说话音量最高的人: %o %t', activeSpeaker)
        if (
          activeSpeaker.userUuid === this.meetingInfo.activeSpeakerUid ||
          !this.$store.state.enableSortByVoice
        ) {
          return
        }
        this.$store.commit('setMeetingInfo', {
          activeSpeakerUid: activeSpeaker.userUuid,
        })
        // this.updateMember(_data.uid, 'isActiveSpeaker', true)
        this.$store.dispatch('sortMemberList')
        // clearTimeout(this.activeSpeakerTimeOut);
        // this.activeSpeakerTimeOut = (setTimeout(() => {
        //   this.$store.commit('setMeetingInfo', { activeSpeakerUid: 0 })
        //   this.$store.dispatch('sortMemberList');
        // }, 10 * 1000) as any);
      })

      this.$neMeeting.on('onRoomEnded', async (reason) => {
        console.log('onRoomEnded: %o %t', reason)
        logger.debug('onRoomEnded: %o %t', reason)
        let leaveType: memberLeaveTypes = memberLeaveTypes.endByHost
        if (reason === 'kICK_BY_SELF') {
          leaveType = memberLeaveTypes.leaveBySelf
        } else if (reason === 'KICK_OUT') {
          leaveType = memberLeaveTypes.leaveByHost
        }
        const {
          localInfo: { leaveCallBack },
        } = this.$store.state
        // if (this.$store.state.meetingInfo.whiteboardAvRoomUid.length) {
        // this.$EventBus.$emit('whiteboard-logout');
        // }
        this.$EventBus.$emit('whiteboard-clean-cache')
        this.$EventBus.$emit('whiteboard-logout')
        this.$store.dispatch('resetInfo')
        this.setMeetingInfoForSdk(true)
        this.$neMeeting.meetingId = ''
        this.meetingId = ''
        this.hideAllDialog()
        this.$EventBus.$emit('roomEnded', reason)
        this.$toast(this.$t(reason), 2000, () => {
          leaveCallBack && leaveCallBack(memberLeaveTypes.endByHost)
        })
        await this.$neMeeting.destroyRoomContext()
        setTimeout(() => {
          this.$store.commit('changeMeetingStatus', 1)
        }, 1000)
        logger.debug('房间被关闭 %t')
      })
      this.$neMeeting.on('clientBanned', async () => {
        logger.debug('clientBanned: 当前用户被踢出 %t')

        const {
          localInfo: { leaveCallBack },
        } = this.$store.state
        this.$toast(this.$t('hostKickedYou'), 2000, () => {
          leaveCallBack && leaveCallBack(memberLeaveTypes.leaveByHost)
        })
        this.isKicked = true
        this.offlineHandle()
      })
      this.$neMeeting.on('onMemberNameChanged', (member, name) => {
        logger.debug('onMemberNameChanged: %o %t', member)
        // this.$store.commit('updateMember', member);
        this.updateMember(member.uuid, 'nickName', name)
      })

      this.$neMeeting.on(
        'onMemberRoleChanged',
        (member, beforeRole, afterRole) => {
          logger.debug(
            'onMemberRoleChanged: %o %o %o %t',
            member,
            beforeRole,
            afterRole
          )
          if (this.$neMeeting.avRoomUid == member.uuid) {
            if (member.role === Role.host) {
              debounce(this.$toast(this.$t('youBecomeTheHost')), 1000)
            } else if (member.role === Role.coHost) {
              this.$toast(this.$t('youBecomeTheCoHost'))
            } else if (
              beforeRole.name === Role.coHost &&
              afterRole.name !== Role.host
            ) {
              this.$toast(this.$t('looseTheCoHost'))
            }

            if (member.role === Role.coHost || member.role === Role.host) {
              // 取消举手
              this.$neMeeting.sendMemberControl(memberAction.handsDown, [
                this.localInfo.avRoomUid,
              ])
              // 如果此时有举手弹出框则隐藏
              this.$EventBus.$emit('needAudioHandsUp', false)
              this.$EventBus.$emit('needVideoHandsUp', false)
            }
          } else {
            if (
              this.localInfo.role === Role.coHost ||
              this.localInfo.role === Role.host
            ) {
              // 如果本端是主持人或者联席主持人则收到设置联席主持人的通知
              const _member = this.$store.state.memberMap[member.uid] || {
                nickName: '',
              }
              if (member.role == Role.coHost) {
                // 如果是设置联席主持人通知
                this.$toast(_member.nickName + this.$t('becomeTheCoHost'))
              } else if (
                member.role !== Role.coHost &&
                _member.role === Role.coHost
              ) {
                this.$toast(_member.nickName + this.$t('looseTheCoHost'))
              }
            }
          }
          this.getMeetingInfo()
        }
      )
      this.$neMeeting.on('offline', () => {
        // this.$toast('网络中断');
        this.offlineHandle()
        // this.$neMeeting.destroyRoomContext();
        this.$store.commit('setOnline', 0)
        // logger.error('网络中断 %t');
      })
      this.$neMeeting.on('networkReconnect', () => {
        this.$store.commit('setOnline', 1)
        logger.debug('网络重连中 %t')
      })
      this.$neMeeting.on('networkSuccess', () => {
        this.$store.commit('setOnline', 2)
        this.$toast('网络重连成功')
        this.getMeetingInfo()
        logger.error('网络重连成功 %t')
      })
      // this.$neMeeting.on('syncFinish', data => {
      //   logger.debug('音视频房间同步信息完成')
      //   syncFinish = true
      // })
      // 对外暴露api
      this.$EventBus.$on('create', (val) => {
        this.createObj = val
        debounce(this.createMeeting())
      })
      this.$EventBus.$on('login', (val) => {
        this.loginObj = val
        debounce(this.login())
      })
      this.$EventBus.$on('join', (val) => {
        this.joinObj = val
        // joinObj = val;
        debounce(this.joinMeeting())
      })
      this.$EventBus.$on('anonymousJoin', (val) => {
        this.joinObj = val
        // joinObj = val;
        debounce(this.joinMeeting(false, true))
      })
      this.$EventBus.$on('beforeDestroy', () => {
        // 销毁时清除全部信息
        // if (this.$store.state.status === 2) {
        //   this.leave();
        // }
        if (!Vue.prototype.$neMeeting) {
          return
        }
        this.$neMeeting.destroy()
        Vue.prototype.$neMeeting = null
        this.$store.commit('setIsNEMeetingInit', false)
        this.$store.dispatch('resetInfo')
        this.$store.commit('changeMeetingStatus', 0)
        this.$nextTick(() => {
          this.$destroy()
        })
      })
      this.$EventBus.$on('afterLeave', (val: any) => {
        // 结束后回调
        this.$store.commit('setLocalInfo', {
          leaveCallBack: (leaveType: memberLeaveTypes) => {
            this.subscribeAudioAll = true
            this.subscribeAudioList = []
            val(leaveType)
          },
        })
      })
      this.$EventBus.$on('uploadNIMconf', (val) => {
        // 更新私有化IM信息
        this.$neMeeting.NIMconf = val
      })
      this.$EventBus.$on('uploadNeRtcServerAddresses', (val) => {
        // 更新私有化RTC信息
        this.$neMeeting.neRtcServerAddresses = val
      })
      this.$EventBus.$on('uploadInit', (val) => {
        // 初始化配置信息
        this.$neMeeting.initConf(val)
        this.$neMeeting.getGlobalConfig().then((res) => {
          this.$store.commit('setLocalInfo', {
            whiteBoardGlobalConfig: this.$neMeeting.whiteBoardGlobalConfig,
            recordGlobalConfig: this.$neMeeting.recordGlobalConfig,
          })
          this.$store.commit('setGlobalConfig', res)
          this.$EventBus.$emit('NESettingsService', {
            isWhiteboardEnabled:
              this.$neMeeting.whiteBoardGlobalConfig.status === 1,
            isCloudRecordEnabled:
              this.$neMeeting.recordGlobalConfig.status === 1,
          })
        })
        this.$store.commit('setLocalInfo', {
          wbTargetOrigin: val.wbTargetOrigin || '',
          wbTargetUrl: val.wbTargetUrl || '',
        })
        console.log('初始化完成')
      })

      this.$EventBus.$on('removeGlobalEventListener', () => {
        this.$neMeeting.removeGlobalEventListener()
      })
      this.$EventBus.$on('updateInitOptions', (val) => {
        // 初始化配置信息
        this.initOptions(val.obj, true)
        val.callback && val.callback()
      })

      this.$EventBus.$on('setDefaultRenderMode', (val) => {
        this.$store.commit('setLocalInfo', {
          defaultRenderMode: val,
        })
      })
      this.$EventBus.$on('setHideLeave', (val) => {
        this.$store.commit('setLocalInfo', {
          hideLeave: val,
        })
      })
      this.$EventBus.$on('setSmallModeDom', (val) => {
        this.$store.commit('setLocalInfo', {
          smallModeDom: val,
        })
      })
      this.$EventBus.$on('setScreenSharingSourceId', (id: string) => {
        this.$store.commit('setScreenSharingSourceId', id)
      })
      this.$EventBus.$on('setTheme', (data) => {
        this.$store.commit('setTheme', data)
      })
      this.$EventBus.$on('resetTheme', () => {
        this.$store.commit('resetTheme')
      })

      if (this.isDev || this.isWebSite) {
        this.$EventBus.$emit('uploadInit', {
          appKey: appkey,
          meetingServerDomain,
        })
      }
    }
  },
  methods: {
    setSpeakerHandle(isShow: boolean) {
      this.$store.commit('setShowSpeaker', isShow)
      isShow &&
        this.$neMeeting.on(
          'onRtcAudioVolumeIndication',
          (data: { userUuid: string; volume: number }[]) => {
            const memberMap = this.$store.state.memberMap
            const speakerList = data.map((item) => {
              const member = memberMap[item.userUuid]
              let name = item.userUuid
              if (member) {
                name = member.nickName
              }
              return {
                uid: item.userUuid,
                nickName: name,
                level: item.volume,
              }
            })
            this.$store.commit('setSpeakerList', speakerList)
          }
        )
    },
    cancelFocus() {
      if (this.$neMeeting.avRoomUid === this.meetingInfo.focusAvRoomUid) {
        // 取消焦点
        this.$toast(this.$t('looseVideoFocus'))
        if (
          this.focusVideoProfile.resolution !== this.videoProfile.resolution ||
          this.focusVideoProfile.frameRate !== this.videoProfile.frameRate
        ) {
          ;(this.localInfo.video === 1 || this.localInfo.video === 4) && // 当前视频画面开启的
            this.$neMeeting.setVideoProfile(
              this.videoProfile.resolution,
              this.videoProfile.frameRate
            )
        }
      }
      this.updateMember(this.meetingInfo.focusAvRoomUid, 'isFocus', false)
    },
    playRemote(evt) {
      logger.debug('可播放远端流: %o %t', evt)
      // const { webrtc } = this.$neMeeting;
      const { memberMap } = this.$store.state
      logger.debug('login_当前memberMap: %o %t', Object.keys(memberMap))
      // 之前出现过G2与网易会议消息到达时间过长的情况，做一下兼容
      if (!memberMap[evt?.uid]) {
        logger.debug('触发递归的id %s %t', evt?.uid)
        this.stackForAdded[evt?.uid] = () => this.playRemote(evt)
        this.stackForAddedTimes[evt?.uid] =
          (this.stackForAddedTimes[evt?.uid] || 0) + 1
        if (this.stackForAddedTimes[evt?.uid] >= 10) {
          logger.debug('长期未找到，清除递归的id %s %t', evt?.uid)
          delete this.stackForAdded[evt?.uid]
          this.stackForAddedTimes[evt?.uid] = 0
        } else {
          setTimeout(this.stackForAdded[evt?.uid], 1500)
          return
        }
      }
      if (
        evt?.stream?.active ||
        memberMap[evt?.uid]?.roleType === 4 ||
        evt?.screenStream?.active
      ) {
        this.$store.commit('setStream', {
          uid: evt?.uid,
          stream: evt?.stream,
          basicStream: evt?.basicStream,
          screenStream: evt?.screenStream,
        })
      }
      logger.debug('删除递归的id %s %t', evt?.uid)
      delete this.stackForAdded[evt?.uid]
      // const { memberMap } = this.$store.state;
      this.$nextTick(async () => {
        if (!this.subscribeAudioAll) {
          // webrtc.subscribe(evt?.basicStream, false)
          await evt?.basicStream.muteAudio()
          logger.debug('当前状态为：不自动订阅 %s %t', evt?.uid)
        } else if (
          memberMap[evt?.uid] &&
          memberMap[evt?.uid]?.roleType &&
          memberMap[evt?.uid]?.roleType === 4
        ) {
          // webrtc.unsubscribe(evt?.basicStream)
          await evt?.basicStream.muteAudio()
          logger.debug('该用户需手动订阅 %i  %o %t', evt?.uid, evt)
        } else if (this.subscribeAudioAll) {
          logger.debug('该用户以及状态为：自动订阅 %s %t', evt?.uid)
          // await evt?.basicStream.unmuteAudio();
          // webrtc.subscribe(evt?.basicStream)
        }
        if (this.subscribeAudioList.includes(evt?.uid)) {
          await evt?.basicStream.unmuteAudio()
          logger.debug('已手动订阅用户 %s %t', evt?.uid)
        }
      })
    },
    unmuteMyVideo(isMySelf = false) {
      if (this.localInfo.video === 1) {
        return
      }
      if (
        (this.localInfo.role === Role.host ||
          this.localInfo.role === Role.coHost) &&
        isMySelf
      ) {
        this.$neMeeting
          .unmuteLocalVideo(this.$store.state.cameraId)
          .then(() => {
            this.$store.commit('setLocalInfo', {
              isHandsUp: false,
            })
          })
      } else {
        this.dialogVisibleVideo = true
        this.openVideoByHost = true
      }
    },
    unmuteMyAudio(isMySelf = false) {
      if (this.localInfo.audio === 1) {
        // 已经开启不需要重新打开
        return
      }
      if (
        (this.localInfo.role === Role.host ||
          this.localInfo.role === Role.coHost) &&
        isMySelf
      ) {
        this.$neMeeting
          .unmuteLocalAudio(this.$store.state.microphoneId)
          .then(() => {
            this.$store.commit('setLocalInfo', {
              isHandsUp: false,
            })
          })
        return
      }
      if (!this.localInfo.isHandsUp) {
        // 如果已举手则音频不需要弹框
        this.dialogVisibleAudio = true
        this.openAudioByHost = true
      } else {
        this.$neMeeting
          .unmuteLocalAudio(this.$store.state.microphoneId)
          .then(() => {
            this.$store.commit('setLocalInfo', {
              isHandsUp: false,
            })
          })
      }
    },
    updateMember(uid, key, value, isSetByMySelf?) {
      const { state, commit } = this.$store
      logger.debug('总的成员列表: %o %t', this.$store.state.memberMap)
      let m = this.$store.state.memberMap[uid]
      if (!m) {
        logger.debug(`${uid} 已经不再会议中了 %t`)
        return
      }
      m = m ? Object.assign({}, m) : {}
      m[key] = value
      logger.debug('更新成员列表:  %o %t', m)
      if (key === 'isActiveSpeaker' && m[key].isActiveSpeaker) {
        // null
      } else if ((key === 'audio' || key === 'video') && value === 4) {
        //
      } else {
        commit('updateMember', m)
      }

      if (state.localInfo.avRoomUid === uid) {
        const info = {}
        if (key === 'handsUps') {
          key = 'isHandsUp'
          value = value.value == 1
        }
        info[key] = value
        commit('setLocalInfo', info)
        this.$forceUpdate()
      }
    },
    // unmuteLocalVideo(deviceId?: string, need = true) {
    //   let videoProfile = this.videoProfile;
    //   if(this.isFocus) { // 如果当前是焦点画面则设置焦点画面分辨率配置
    //     videoProfile = this.focusVideoProfile
    //   }
    //   return this.$neMeeting.unmuteLocalVideo(deviceId, need, videoProfile);
    // },
    async offlineHandle() {
      this.$EventBus.$emit('whiteboard-clean-cache')
      this.$EventBus.$emit('whiteboard-logout')
      this.$store.dispatch('resetInfo')
      this.setMeetingInfoForSdk(true)
      this.$neMeeting.meetingId = ''
      this.meetingId = ''
      this.hideAllDialog()
      await this.$neMeeting.destroyRoomContext()
      setTimeout(() => {
        this.$store.commit('changeMeetingStatus', 1)
      }, 1000)
    },
    confirmMuteAudio(audio) {
      // 本地静音
      const {
        state: { localInfo },
        commit,
      } = this.$store
      if (localInfo.role === Role.host || localInfo.role === Role.coHost) {
        logger.debug('自己是主持人，忽略此信息 %t')
        return
      }
      if (audio === 4 && (localInfo.audio === 3 || localInfo.audio === 2)) {
        // 确认是否要开启声音
        this.$EventBus.$emit('needAudioHandsUp', false)
        this.dialogVisibleAudio = true
      } else if (
        audio === 4 &&
        (localInfo.audio === 1 || localInfo.audio === 3)
      ) {
        //TODO
      } else {
        // 非web没有通知，需要手动修改全部的状态为2
        commit('setAllAudioMute')
        if (localInfo.audio !== 2 && localInfo.audio !== 3) {
          this.$toast(this.$t('meetingHostMuteAllAudio'))
          this.$neMeeting
            .muteLocalAudio()
            .then(() => {
              commit('setLocalInfo', {
                audio: 2,
              })
            })
            .catch((e) => {
              this.$toast(this.$t('muteAllAudioFail'))
              logger.error('muteLocalAudio %o %t', e)
            })
        }
      }
    },
    confirmMuteVideo(video) {
      // 本地静音
      const {
        state: { localInfo },
        commit,
      } = this.$store
      if (
        localInfo.roleType === RoleType.host ||
        localInfo.roleType === RoleType.coHost
      ) {
        logger.debug('自己是主持人，忽略此信息 %t')
        return
      }
      if (video === 4 && (localInfo.video === 3 || localInfo.video === 2)) {
        // 确认是否要开启视频
        this.$EventBus.$emit('needVideoHandsUp', false)
        this.dialogVisibleVideo = true
      } else {
        // 非web没有通知，需要手动修改全部的状态为2
        commit('setAllVideoMute')
        if (localInfo.video !== 2 && localInfo.video !== 3) {
          this.$toast(this.$t('meetingHostMuteAllVideo'))
          this.$neMeeting
            .muteLocalVideo()
            .then(() => {
              commit('setLocalInfo', {
                video: 2,
              })
            })
            .catch((e) => {
              this.$toast(this.$t('muteAllVideoFail'))
              logger.error('muteLocalVideo %o %t', e)
            })
        }
      }
    },
    confirmCancel() {
      logger.debug('不开启声音 %t')
      this.$neMeeting.sendMemberControl(memberAction.muteAudio)
      this.dialogVisibleAudio = false
      this.openAudioByHost = false
    },
    confirmOk() {
      logger.debug('开启声音 %t')
      this.dialogVisibleAudio = false
      if (
        !this.allowUnMuteAudioBySelf &&
        !this.openAudioByHost &&
        this.localInfo.roleType === RoleType.participant
      ) {
        this.$EventBus.$emit('needAudioHandsUp', true)
        return
      }
      this.openAudioByHost = false
      this.$neMeeting
        .unmuteLocalAudio(this.$store.state.microphoneId)
        .then(() => {
          this.$store.commit('setLocalInfo', {
            audio: 1,
          })
        })
        .catch((e) => {
          logger.error('unmuteLocalAudio error %o %t', e)
          if (e && e.code) {
            switch (e.code) {
              case 2108:
                this.localInfo.role === Role.participant &&
                  this.$EventBus.$emit('needAudioHandsUp', true)
                this.$toast(
                  this.errorCodes[getErrCode(e.code)] ||
                    e.msg ||
                    '请举手申请开启'
                )
                this.$neMeeting.muteLocalAudio(false)
                break
              default:
                break
            }
          } else {
            // 其他情况重新关闭音频防止状态不同步
            console.log('重新设置音频为关闭状态')
            // 设置回原来的状态
            this.$neMeeting.muteLocalAudio(true)
            // 设置回原来的状态
            this.$store.commit('setLocalInfo', {
              audio: 2,
            })
          }
        })
    },
    confirmVideoCancel() {
      logger.debug('不开启摄像头 %t')
      this.$neMeeting.sendMemberControl(memberAction.muteVideo)
      this.dialogVisibleVideo = false
      // fix 管理员开启视频，本地点击取消后，无法再次开启bug
      this.$store.commit('setLocalInfo', {
        video: 2,
      })
      this.openVideoByHost = false
    },
    confirmVideoOk() {
      logger.debug('开启摄像头 %t')
      this.dialogVisibleVideo = false
      console.log(
        'confirmVideoOk',
        this.allowUnMuteVideoBySelf,
        this.openVideoByHost,
        this.localInfo.role
      )
      if (
        !this.allowUnMuteVideoBySelf &&
        !this.openVideoByHost &&
        this.localInfo.role === Role.participant
      ) {
        this.$EventBus.$emit('needVideoHandsUp', true)
        return
      }
      this.openVideoByHost = false
      this.$store.commit('setLocalInfo', {
        video: 1,
      })

      this.$neMeeting.unmuteLocalVideo().catch((e) => {
        logger.error('unmuteLocalVideo error %o %t', e)
        if (e && e.code && e.code === 2108) {
          this.localInfo.role === Role.participant &&
            this.$EventBus.$emit('needVideoHandsUp', true)
          this.$toast(
            this.errorCodes[getErrCode(e.code)] || e.msg || '请举手申请开启'
          )
          this.$neMeeting.muteLocalVideo(false)
        }
      })
      // this.unmuteLocalVideo(this.$store.state.cameraId)
    },
    confirmJoinCancel() {
      logger.debug('不加入房间 %t')
      this.dialogExitMeeting = false
      this.createObj.callback(new Error('取消加入房间'))
    },
    confirmJoinOk() {
      logger.debug('直接加入房间 %t')
      debounce(this.joinMeeting(true))
      this.dialogExitMeeting = false
    },
    loginByPassword() {
      // 仅限于本地调试，不暴露
      this.$set(this.loginObj, 'obj', {
        ...this.loginObj.obj,
        username: this.loginUsername,
        password: this.loginPassword,
        loginType: 2,
      })
      this.login()
    },
    loginBySSO() {
      // 仅限于本地调试，不暴露
      this.$set(this.loginObj, 'obj', {
        ...this.loginObj.obj,
        ssoToken: this.ssoToken,
        loginType: 3,
      })
      this.login()
    },
    loginNormal() {
      // accountId登陆
      this.$set(this.loginObj, 'obj', {
        ...this.loginObj.obj,
        accountId: this.accountId,
        accountToken: this.accountToken,
        loginType: 1,
      })
      this.login()
    },
    login() {
      // 登陆
      logger.debug('start 登录 %t')
      const params: any = { ...this.loginObj.obj }

      this.$neMeeting
        .login({
          ...params,
          meetingServerDomain: `${
            params.meetingServerDomain
              ? `${hasProtocol(params.meetingServerDomain) ? '' : 'https://'}${
                  params.meetingServerDomain
                }`
              : ''
          }`, //'meeting-api-test.netease.im'
        })
        .then(() => {
          logger.debug('登录完成 %t')
          this.$store.commit('setOnline', 2)
          this.$store.commit('changeMeetingStatus', 1)
          this.loginObj.callback()
        })
        .catch((e) => {
          logger.error('登录失败： %o %t', e)
          this.loginObj.callback(e)
        })
    },
    async createMeeting(random?) {
      // 创建会议
      logger.debug('start 创建房间 %t')
      timeStatistics('创建房间-加入成功时间')
      if (!this.nickName) {
        this.nickName = Math.random().toString(36).substr(6)
      }
      let params: any
      if (this.createObj && this.createObj.obj.nickName) {
        params = { chatRoom: 1, ...this.createObj.obj }
      } else {
        let showMaxCount = false
        let showMemberTag = false
        let showSubject = false
        let extraData = ''
        if (this.createObj && this.createObj.obj) {
          const obj = this.createObj.obj as any
          showMemberTag = obj.showMemberTag
          showMaxCount = obj.showMaxCount
          showSubject = obj.showSubject
          extraData = obj.extraData || ''
        }
        params = {
          meetingId: 2, // 1.随机会议，2.个人会议，3.预约会议
          nickName: this.nickName,
          video: this.video == 1 ? 1 : 0,
          audio: this.audio == 1 ? 1 : 0,
          chatRoom: 1,
          live: 0,
          attendeeAudioOff: this.attendeeAudioOff ? 2 : 0,
          attendeeVideoOff: this.attendeeVideoOff ? 2 : 0,
          showMaxCount,
          showMemberTag,
          showSubject,
          extraData,
          password: (this.createObj.obj as any).password,
          noSip: false,
          // defaultWindowMode: 2
          // noRename: true,
          // noCloudRecord: false,
        }
      }
      if (this.$store.state.beforeLoading) {
        this.$toast('正在创建会议，请勿重复创建')
        return
      }
      if (this.$store.state.status === 2) {
        await this.leave()
      }
      this.$store.commit('toggleBeforeLoading', true)
      this.initOptions(this.createObj.obj)

      this.$neMeeting
        .create({
          // meetingId: (random === 1 ? 1 : 0), // 1随机0固定
          // nickName: this.nickName,
          // video: this.video,
          // audio: this.audio,
          // chatRoom: 0,
          // live: 0
          ...params,
        })
        .then(() => {
          // this.$store.commit('toggleBeforeLoading', true);
          this.isKicked = false
          this.$store.commit('setOnline', 2)
          logger.debug('创建房间成功-加入房间 %t')
          this.meetingId = this.$neMeeting.meetingId
          // 设置是否显示memberTag和房间应进最大人数
          this.$store.commit('setShowMemberTag', params.showMemberTag === true)
          this.$store.commit('setShowingMaxCount', params.showMaxCount === true)
          // 剩余时间提醒
          params.showMeetingRemainingTip &&
            this.$store.commit(
              'setRemainingTime',
              this.$neMeeting.roomContext.remainingSeconds
            )
          // 设置是否显示会议主题
          this.$store.commit('setShowSubject', params.showSubject === true)
          this.setSpeakerHandle(params.showSpeaker !== false)
          // 设置是否显示全体静音视频按钮
          // this.$store.commit('setNoMuteAllConfig', {
          //   noMuteAllVideo: params.noMuteAllVideo !== false, // 默认为true
          //   noMuteAllAudio: params.noMuteAllAudio === true, // 默认为false
          // });
          // 独立设置4个是否显示全体静音视频按钮
          this.$store.commit('setMuteBtnConfig', params.muteBtnConfig)
          this.$store.commit('setShowFocusBtn', params.showFocusBtn !== false)
          this.$store.commit('setEnableUnmuteBySpace', params.enableUnmuteBySpace === true)
          params.env && this.$store.commit('setEnv', params.env) // 设置环境主要针对electron
          this.$store.commit(
            'setEnableSortByVoice',
            params.enableSortByVoice !== false
          )
          this.$store.commit(
            'setNoSip',
            params.noSip === undefined ? true : params.noSip
          )
          if (params.videoProfile) {
            this.$store.commit('setVideoProfile', params.videoProfile)
            // 如果没有设置焦点视频分辨率则使用默认分辨率
            !params.focusVideoProfile &&
              (params.focusVideoProfile = params.videoProfile)
          }
          params.chatroomConfig &&
            this.$store.commit('setChatroomConfig', params.chatroomConfig)
          params.focusVideoProfile &&
            this.$store.commit('setFocusVideoProfile', params.focusVideoProfile)

          // this.$store.commit('addRealMemberList', this.$neMeeting.avRoomUid);
          this.$store.commit('setLocalInfo', {
            role: 'host',
            nickName: params.nickName,
            // video: params.video,
            // audio: params.audio,
            isUnMutedAudio: params.audio == 1,
            isUnMutedVideo: params.video == 1,
            mainSpeakerUId: this.$neMeeting.avRoomUid,
          })
          this.setMeetingInfoForSdk()
          this.$store.commit(
            'setMeetingId',
            this.$neMeeting.meetingId.toString()
          )
          this.getMeetingInfo().then((res) => {
            params.enableSetDefaultFocus === true && this.setDefaultFocus(res)
          })
          this.$store.commit('changeMeetingStatus', 2)
          logger.debug('加入房间成功 %t')
          timeStatistics('创建房间-加入成功时间', true)
          this.getVideoOrAudioTime()
          this.$store.commit('setLocalInfo', {
            avRoomUid: this.$neMeeting.avRoomUid,
          })
          this.initReporter()
          // this.$nextTick(() => {
          //   this.resolveParams(params);
          // })
          setTimeout(() => {
            this.resolveParams(params)
            this.$EventBus.$emit('whiteboard-clean-cache')
            // if (this.showRecording) this.$toast(this.$t('meetingRecording'));
            this.$store.commit('toggleBeforeLoading', false)
          }, 1000)
          this.createObj.callback()
        })
        .catch((e) => {
          logger.error('创建房间失败:  %o %t', e)
          console.log('e.code', e.message)
          if (e.code === 3100) {
            this.dialogExitMeeting = true
          } else {
            this.$toast(this.errorCodes[e.code] || '创建失败')
          }
          this.createObj.callback(e)
          // setTimeout(() => {
          this.$store.commit('toggleBeforeLoading', false)
          // }, 1000)
        })
    },
    async joinMeeting(hasRoom = false, isAnonymous = false) {
      // 加入会议
      logger.debug('加入房间 %t')
      timeStatistics('加入房间-加入成功时间')
      let params: any
      if (!this.joinObj.obj.meetingId) {
        Object.assign({}, this.joinObj)
      }
      if (this.joinObj && this.joinObj.obj.meetingId) {
        params = { ...this.joinObj.obj }
      } else {
        if (!this.meetingId) {
          //return
        }
        let showMaxCount = false
        let showMemberTag = false
        let showSubject = false
        if (this.createObj && this.createObj.obj) {
          const obj = this.createObj.obj as any
          showMemberTag = obj.showMemberTag
          showMaxCount = obj.showMaxCount
          showSubject = obj.showSubject
        }
        if (!this.nickName) {
          this.nickName = Math.random().toString(36).substr(6)
        }
        params = {
          meetingId: this.meetingId,
          nickName: this.nickName,
          appKey: this.appKey,
          video: this.video == 1 ? 1 : 0,
          audio: this.audio == 1 ? 1 : 0,
          showMemberTag,
          showMaxCount,
          showSubject,
          // defaultWindowMode: 2,
          // noRename: true,
          // noCloudRecord: true,
        }
      }
      if (this.$store.state.status === 2) {
        await this.leave()
      }
      if (this.$store.state.beforeLoading) {
        this.$toast('正在加入会议，请勿重复加入')
        return
      }
      this.initOptions(!hasRoom ? this.joinObj.obj : this.createObj.obj)
      this.$store.commit('toggleBeforeLoading', true)
      this.showPasswordVisbale = false
      // showPasswordVisbale = false
      console.log('是否匿名', isAnonymous)
      const jonHandler = isAnonymous
        ? this.$neMeeting.anonymousJoin.bind(this.$neMeeting)
        : this.$neMeeting.join.bind(this.$neMeeting)
      jonHandler({
        // meetingId: this.meetingId,
        // nickName: this.nickName,
        // appKey: this.appKey,
        // video: this.video,
        // audio: this.audio
        ...params,
        password: this.password || params.password,
        meetingServerDomain: `${
          params.meetingServerDomain
            ? `${hasProtocol(params.meetingServerDomain) ? '' : 'https://'}${
                params.meetingServerDomain
              }`
            : ''
        }`, //'https://meeting-api-test.netease.im'
      })
        .then((res) => {
          this.isKicked = false
          this.password = ''
          logger.debug('加入房间成功 %t')
          this.$store.commit('setOnline', 2)
          timeStatistics('加入房间-加入成功时间', true)
          // 剩余时间提醒
          params.showMeetingRemainingTip &&
            this.$store.commit(
              'setRemainingTime',
              this.$neMeeting.roomContext.remainingSeconds
            )
          // 设置是否显示memberTag和房间应进最大人数
          this.$store.commit('setMuteBtnConfig', params.muteBtnConfig)
          this.$store.commit('setShowMemberTag', params.showMemberTag === true)
          this.$store.commit('setShowingMaxCount', params.showMaxCount === true)
          this.$store.commit('setShowSubject', params.showSubject === true)
          this.$store.commit('setShowFocusBtn', params.showFocusBtn !== false)
          this.$store.commit('setEnableUnmuteBySpace', params.enableUnmuteBySpace === true)
          this.setSpeakerHandle(params.showSpeaker !== false)
          params.env && this.$store.commit('setEnv', params.env)
          this.$store.commit(
            'setEnableSortByVoice',
            params.enableSortByVoice !== false
          )
          this.$store.commit(
            'setNoSip',
            params.noSip === undefined ? true : params.noSip
          )
          if (params.videoProfile) {
            this.$store.commit('setVideoProfile', params.videoProfile)
            // 如果没有设置焦点视频分辨率则使用默认分辨率
            !params.focusVideoProfile &&
              (params.focusVideoProfile = params.videoProfile)
          }
          params.chatroomConfig &&
            this.$store.commit('setChatroomConfig', params.chatroomConfig)
          params.focusVideoProfile &&
            this.$store.commit('setFocusVideoProfile', params.focusVideoProfile)
          // 设置是否显示全体静音视频按钮
          // this.$store.commit('setNoMuteAllConfig', {
          //   noMuteAllVideo: params.noMuteAllVideo !== false, // 默认为true
          //   noMuteAllAudio: params.noMuteAllAudio === true, // 默认为false
          // });

          this.getVideoOrAudioTime()
          // this.$store.commit('toggleBeforeLoading', true);
          this.$store.commit('setLocalInfo', {
            avRoomUid: this.$neMeeting.avRoomUid,
            nickName: params.nickName,
            isUnMutedAudio: params.audio == 1,
            isUnMutedVideo: params.video == 1,
            // video: params.video,
            // audio: params.audio,
          })
          this.$store.commit(
            'setMeetingId',
            this.$neMeeting.meetingId.toString() || params.meetingId
          )
          this.$store.commit('addRealMemberList', this.$neMeeting.avRoomUid)
          // if (this.$neMeeting.meetingStatus === 'login') {
          if (this.$store.state.status === 1) {
            const role =
              this.$neMeeting.localMember.role.name || Role.participant
            this.$store.commit('setLocalInfo', {
              role: role,
              roleType: RoleType[role],
            })
            if (role === Role.coHost) {
              this.$toast(this.$t('youBecomeTheCoHost'))
              // 联席主持人
              this.updateMember(
                res.ret.roomUid,
                'role',
                role || Role.participant
              )
              this.updateMember(res.ret.roomUid, 'roleType', RoleType[role])
            }
          } else {
            this.$store.commit('setLocalInfo', {
              role: 'AnonymousParticipant',
              roleType: RoleType.participant,
            })
          }
          this.$store.commit('changeMeetingStatus', 2)
          this.setMeetingInfoForSdk()
          this.getMeetingInfo().then((res) => {
            params.enableSetDefaultFocus === true && this.setDefaultFocus(res)
          })
          this.initReporter()
          // this.$nextTick(() => {
          //   this.resolveParams(params);
          // })
          setTimeout(() => {
            // 入会提示静音
            if (
              this.$store.state.memberMap[this.$neMeeting.avRoomUid]?.audio ===
                3 &&
              this.$store.state.memberMap[this.$neMeeting.avRoomUid]
                ?.avRoomUid === this.$neMeeting.avRoomUid
            ) {
              this.$toast(this.$t('meetingHostMuteAudio'))
            }
            this.resolveParams(params)
            // if (this.showRecording) this.$toast(this.$t('meetingRecording'));
            this.joinCheckWhiteShare()
            this.$store.commit('toggleBeforeLoading', false)
          }, 1000)
          this.joinObj.callback()
          return true
        })
        .catch((e) => {
          console.log('加入房间失败', e)
          logger.error('%time 加入房间失败： %o %t ', e)
          // const message = e.message.replace(/Error/g, '');
          // const reason = message.match(/[\u4e00-\u9fa5_a-zA-Z0-9]+/g) && message.match(/[\u4e00-\u9fa5_a-zA-Z0-9]+/g).length && message.match(/[\u4e00-\u9fa5_a-zA-Z0-9]+/g)[0] || '加入失败';
          // const reason = getErrCode(message);
          const reason = e.code
          this.errorMsg = this.errorCodes[reason]

          switch (Number(reason)) {
            case 1020:
              this.joinObj.callback()
              this.$store.commit('toggleBeforeLoading', false)
              this.showPasswordVisbale = true
              // showPasswordVisbale = true;
              if (!this.password) {
                // 第一次进
                this.errorMsg = ''
              }
              break
            case 2014:
              this.joinObj.callback()
              this.$store.commit('toggleBeforeLoading', false)
              this.showPasswordVisbale = true
              // showPasswordVisbale = true;
              break
            default:
              this.joinObj.callback(e)
              setTimeout(() => {
                this.$store.commit('toggleBeforeLoading', false)
              }, 1000)
              this.$toast(this.errorCodes[reason] || this.$t('joinMeetingFail'))
              break
          }
        })
    },
    setDefaultFocus(meetingInfo) {
      // 如果开启默认设置主持人焦点功能
      console.log('setDefaultFocus', meetingInfo)
      if (!meetingInfo.ret.members) {
        return
      }
      // 找到本端信息
      const m = meetingInfo.ret.members.find((member) => {
        return member.avRoomUid === this.$neMeeting.avRoomUid
      })
      if (!m) return
      const meeting = meetingInfo.ret.meeting
      // 如果进入的是管理员，且未设置焦点，则默认设置管理员为焦点
      if (m.isHost && !meeting.focusAvRoomUid) {
        this.$neMeeting.sendHostControl(
          hostAction.setFocus,
          [m.accountId],
          [m.avRoomUid]
        )
      }
    },
    getMeetingInfo(): Promise<any> {
      // 获取会议信息
      console.log('start getMeetingInfo')
      return this.$neMeeting
        .getMeetingInfo()
        .then((res) => {
          logger.debug('getMeetingInfo success', res)
          if (res.code !== 200) {
            logger.warn('getMeetingInfo 请求失败： %s %t', res.msg)
            return Promise.reject(res)
          }
          const { commit, dispatch } = this.$store
          commit('resetMeetingInfo', res.ret.meeting)
          commit('resetMembers', res.ret.members)
          const roomProperties = res.ret.meeting.properties
          if (roomProperties) {
            console.log('roomProperties', roomProperties)
            if (roomProperties.audioOff) {
              commit(
                'setAllowUnMuteAudioBySelf',
                roomProperties.audioOff.value !==
                  AttendeeOffType.offNotAllowSelfOn
              ) // 是否允许自我解除静音
              commit('setAudioOff', roomProperties.audioOff.value) // 是否允许自我解除静音
            }
            if (roomProperties.videoOff) {
              commit(
                'setAllowUnMuteVideoBySelf',
                roomProperties.videoOff.value !==
                  AttendeeOffType.offNotAllowSelfOn
              ) // 是否允许自我解除静音
              commit('setVideoOff', roomProperties.videoOff.value) // 是否允许自我解除静音
            }
            if (roomProperties.lock) {
              commit(
                'setMeetLockStatus',
                roomProperties.lock.value === 1 ? 2 : 1
              )
            }
          }
          const myInfo = res.ret.members.find((member) => {
            return member.avRoomUid === this.$neMeeting.avRoomUid
          })
          // modify
          if (myInfo && myInfo.role === Role.host) {
            commit('setLocalInfo', {
              role: Role.host,
              roleType: RoleType.host,
            })
            //this.$toast('您已成为主持人');
          } else if (myInfo && myInfo.role === Role.coHost) {
            // 如果是被设置为联席主持人
            commit('setLocalInfo', {
              role: Role.coHost,
              isHandsUp: false,
              roleType: RoleType.coHost,
            })
          } else {
            commit('setLocalInfo', {
              role: Role.participant,
              roleType: RoleType.participant,
            })
          }
          this.setMeetingInfoForSdk()
          // dispatch('sortMemberList');
          this.$EventBus.$emit(
            'memberInfo',
            Object.assign({}, this.$store.state.localInfo)
          )
          if (this.$store.state.localInfo.avRoomUid) {
            console.log('avRoomUid存在')
            const joinMemberInfo =
              Object.assign(
                {},
                this.$store.state.memberMap[this.$neMeeting.avRoomUid]
              ) || {}
            if (this.localInfo.video === 1 && joinMemberInfo.video !== 1) {
              this.$neMeeting.muteLocalVideo(false)
            }
            commit('setLocalInfo', {
              audio: joinMemberInfo.audio,
              video: joinMemberInfo.video,
            })
            // if (joinMemberInfo.audio && joinMemberInfo.video) {
            //   if (joinMemberInfo.audio !== 1) {
            //     this.$neMeeting.muteLocalAudio(false);
            //   }
            //   if (joinMemberInfo.video !== 1) {
            //     this.$neMeeting.muteLocalVideo(false)
            //   }
            // }
          }
          dispatch('sortMemberList')
          this.$EventBus.$emit('joinMemberInfo', this.$store.state.memberMap)
          return res
        })
        .catch((e) => {
          logger.error('getMeetingInfo error:  %o %t', e)
          return Promise.reject(e)
        })
    },
    async leave() {
      // 离开会议
      logger.debug('离开会议')
      this.$neMeeting
        .leave(this.$store.state.localInfo.role)
        .then(() => {
          logger.debug('离开会议成功 %t')
        })
        .catch((e) => {
          logger.error('离开会议失败:  %o %t', e)
        })
    },
    end() {
      // 结束会议
      logger.debug('结束会议')
      this.$neMeeting
        .end()
        .then(() => {
          logger.debug('结束会议成功 %t')
        })
        .catch((e) => {
          logger.error('结束会议失败:  %o %t', e)
          // const reason = e.message.match(/[\u4e00-\u9fa5]+/) && e.message.match(/[\u4e00-\u9fa5]+/).length && e.message.match(/[\u4e00-\u9fa5]+/)[0] || '结束会议失败'
          this.$toast(this.errorCodes[getErrCode(e.message)] || '结束会议失败')
        })
    },
    manageDevices(list = [], action) {
      // 1增加 0删除
      if (!list.length) {
        return false
      }
      list.forEach((item: any) => {
        const params = {
          ...item,
        }
        delete params.isSelected
        this.actionDevice(item, action, item.type)
      })
    },
    actionDevice(device, action, type = 'audioIn') {
      // 动态插拔设备
      const { commit } = this.$store
      const list = [...(this.$store.state[this.deviceMap[type].name] || [])]
      // let index = -1;
      let needResetDevice = false
      switch (action) {
        case 1:
          if (list.length > 0) {
            const hasDevice = list.some((item) => item.label === device.label)
            if (!hasDevice) {
              list.push(device)
            }
          }
          if (list.length === 1) {
            this.$neMeeting[this.deviceMap[type].action](list[0].deviceId)
          }
          break
        case 0:
          list.some((item) => {
            if (item.label === device.label) {
              // index = i;
              if (item.isSelected) {
                needResetDevice = true
              }
              return true
            }
          })
          // if (index > -1) {
          //   list.splice(index, 1);
          // }
          // if (needResetDevice && list.length) {
          //   this.$neMeeting[this.deviceMap[type].action](list[0].deviceId);
          // }
          this.$EventBus.$emit(this.deviceMap[type].emit)
          if (needResetDevice && type === 'video' && list.length) {
            commit('setResetVideoId', list[0].deviceId)
          }
          break
        default:
          break
      }
      commit(this.deviceMap[type].commit, list)
    },
    confirmJoinByPassword() {
      // 密码校验
      if (this.password.length < 6) {
        return
      }
      switch (true) {
        case this.password.length < 6 || this.password.length > 20:
          this.errorMsg = '请输入 6-20 位的密码'
          break
        case this.password.length >= 6 && this.password.length <= 20:
          this.joinMeeting()
          break
        default:
          break
      }
      this.errorMsg = ''
    },
    handlePasswordInput({ target }) {
      // 格式化密码输入框
      this.password = target.value.replace(/[\D]/g, '').slice(0, 20)
    },
    hideAllDialog() {
      // 关闭弹窗
      this.dialogVisibleAudio = false
      this.dialogExitMeeting = false
      this.dialogVisibleVideo = false
      this.showPasswordVisbale = false
      // showPasswordVisbale = false;
    },
    closePasswordVisible() {
      this.showPasswordVisbale = false
      this.password = ''
      this.joinObj.callback(new Error('取消输入密码'))
    },
    getVideoOrAudioTime() {
      // 页面效能方法
      if (this.isDev) {
        if (this.video === 1) {
          timeStatistics('入会成功-视频首帧展示时间')
        }
      }
    },
    setMeetingInfoForSdk(reset = false) {
      // 设置提供给SDK信息
      const {
        state: { meetingInfo, localInfo, meetLockStatus },
      } = this.$store
      if (!reset) {
        this.$EventBus.$emit(
          'NEMeetingInfo',
          Object.assign(
            {},
            {
              meetingId: this.$neMeeting.meetingId,
              isHost: localInfo.role === 'host',
              isLocked: meetLockStatus === 2,
              shortMeetingId: meetingInfo.shortId,
              meetingUniqueId:
                this.$neMeeting.meetingInfo.get('meetingUniqueId') || '',
              password: meetingInfo.password || '',
              sipId: meetingInfo.sipCid || '',
            }
          )
        )
      } else {
        this.$EventBus.$emit('NEMeetingInfo', null)
        this.$EventBus.$emit('memberInfo', {})
        this.$EventBus.$emit('joinMemberInfo', {})
      }
    },
    initOptions(obj, ignoreNULL?) {
      // 初始化创建或加入会议加入配置
      const types = [
        {
          type: 'meetingIdDisplayOptions',
          default: NEMeetingIdDisplayOptions.displayAll,
        },
        {
          type: 'toolBarList',
          default: defaultMenus,
        },
        {
          type: 'moreBarList',
          default: defaultMoreMenus,
        },
      ]
      for (const item of types) {
        let result: any = obj[item.type]
        if (
          checkType(obj[item.type], 'undefined') ||
          checkType(obj[item.type], 'null')
        ) {
          result = item.default
          if (ignoreNULL) {
            continue
          }
        }
        this.$store.commit('setLocalInfo', {
          [item.type]: result,
        })
      }
    },
    async resolveParams(obj) {
      let key: any
      const {
        state: { meetingInfo },
        commit,
      } = this.$store
      for (key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) {
          const ele = obj[key]
          logger.debug(
            'defaultWindowMode %o %i %t',
            ele,
            meetingInfo.whiteboardAvRoomUid
          )
          switch (key) {
            case 'defaultWindowMode':
              console.log('默认开启白板', ele, meetingInfo.whiteboardAvRoomUid)
              if (ele === windowModes.whiteBoard) {
                if (!meetingInfo.whiteboardAvRoomUid.length) {
                  // 无分享人自动分享
                  await this.$neMeeting.sendMemberControl(
                    memberAction.openWhiteShare
                  )
                  this.getMeetingInfo()
                  commit('setLocalInfo', {
                    whiteBoardShare: 1,
                  })
                  this.$nextTick(() => {
                    // this.$EventBus.$emit('whiteboard-login');
                    this.checkWbloaded('whiteboard-login')
                  })
                } else {
                  this.$toast(this.$t('shareOverLimit'))
                }
              }
              break
            case 'noRename':
              commit('setLocalInfo', {
                noRename: !!ele,
              })
              break
            case 'noCloudRecord':
              commit('setLocalInfo', {
                attendeeRecordOn: !ele,
              })
              break
            case 'defaultRenderMode':
              commit('setLocalInfo', {
                defaultRenderMode: ele,
              })
              break
            case 'hideLeave':
              commit('setLocalInfo', {
                hideLeave: ele,
              })
              break
            default:
              break
          }
        }
      }
    },
    joinCheckWhiteShare() {
      // 有分享人加入分享
      const {
        state: { meetingInfo },
      } = this.$store
      logger.debug(
        '是否触发白板分享加入 %o %t',
        meetingInfo.whiteboardOwnerImAccid
      )
      if (
        meetingInfo.whiteboardOwnerImAccid &&
        meetingInfo.whiteboardOwnerImAccid.length
      ) {
        this.$nextTick(() => {
          // this.$EventBus.$emit('whiteboard-login', meetingInfo.whiteboardOwnerImAccid[0])
          this.checkWbloaded(
            'whiteboard-login',
            meetingInfo.whiteboardOwnerImAccid[0]
          )
        })
      }
    },
    checkWbloaded(actionName: string, ownerId?: string) {
      if (!this.wbHasLoaded) {
        setTimeout(() => {
          this.checkWbloaded(actionName, ownerId)
        }, 3000)
        return
      }
      this.$EventBus.$emit(actionName, ownerId)
    },
    changeMode() {
      const {
        commit,
        state: { localInfo },
      } = this.$store
      commit('setLocalInfo', {
        defaultRenderMode:
          localInfo.defaultRenderMode === 'big' ? 'small' : 'big',
      })
    },
    initReporter() {
      const {
        localInfo: { avRoomUid, nickName },
        meetingId,
      } = this.$store.state
    },
  },
  computed: {
    isFocus(): boolean {
      // 本端是否是焦点
      if (!this.$store.state.meetingInfo.focusAvRoomUid) {
        return false
      }
      return (
        this.$store.state.meetingInfo.focusAvRoomUid ===
        this.$store.state.localInfo.avRoomUid
      )
    },
    errorCodes(): any {
      return errorCodes(this.$i18n)
    },
    allowUnMuteAudioBySelf(): boolean {
      return this.$store.state.allowUnMuteAudioBySelf
    },
    allowUnMuteVideoBySelf(): boolean {
      return this.$store.state.allowUnMuteVideoBySelf
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
    wbHasLoaded(): boolean {
      return this.$store.state.whiteBoardHasLoaded
    },
    videoProfile(): VideoProfile {
      return this.$store.state.videoProfile
    },
    focusVideoProfile(): VideoProfile {
      return this.$store.state.focusVideoProfile
    },
    meetingInfo(): any {
      return this.$store.state.meetingInfo
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
  },
})
</script>
<style lang="stylus" scoped>
.login
  // margin 30px auto
  input
    width 200px
    height 30px
    border-radius 5px
    &[type='checkbox']
      width 30px
  .text
    margin-left 8px
    margin-right 15px
    color #fff
  button
    height 34px
    margin-right 30px
</style>
<style lang="stylus">
.confirm-open-micro
  .dialog-header
    border-bottom none
  .dialog-content
    padding 10px 20px 20px
    div.input-content
      position relative
      & input
        width 100%
        border 1px solid #E1E3E6
        border-radius 2px
        text-indent 12px
        font-size 14px
        height 32px
        line-height 32px
        &.error
          border 1px solid #F24957;
      & .close-btn
        position absolute
        display flex
        right 5px
        top 9px
        width 16px
        height 16px
        color #fff
        background rgba(60,60,67,0.60)
        border-radius 50%
        font-size 10px
        // line-height 15px
        justify-content center
        align-items center
        color #fff
        cursor pointer
        .icon-close
          display inline-block

    .error-msg
      font-size 14px
      color #F24957
      text-align left
      margin 5px 0
  .dialog-footer
    cursor pointer
    border-top 1px solid #ebedf0
    span
      display inline-block
      width 50%
      padding 10px 0
    span:first-child
      color #337eff
      border-right 1px solid #ebedf0
      box-sizing border-box
    span.join-meeting
      margin 14px auto
      border none
      display inline-block
      width 120px
      height 36px
      line-height 36px
      background #337EFF
      border-radius 18px
      color #fff
      padding 0
      user-select none
      &:active
        opacity 0.8
      &.disable
        opacity 0.5
        cursor not-allowed
</style>
